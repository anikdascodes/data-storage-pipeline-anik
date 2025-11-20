"""
ETL Pipeline for Seller Catalog

E-commerce Top-Seller Items Recommendation System
Student: MSc Data Science & AI
Roll No: 2025EM1100026

Pipeline Flow:
- Extract seller catalog data from CSV
- Clean data (trim, normalize, deduplicate)
- Apply DQ checks
- Move invalid records to quarantine zone
- Load valid records to Hudi table (overwrite mode)
"""

import os
import sys
import logging
import argparse
import yaml
from datetime import datetime
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F
from pyspark.sql import types as T


# ---------------------------------------------------------------------------
# SPARK SESSION INITIALIZER
# ---------------------------------------------------------------------------
def get_spark_session(app_name: str) -> SparkSession:
    """
    Initialize Spark session with Hudi configurations
    """
    spark = (
        SparkSession.builder
        .appName(app_name)
        .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
        .config("spark.sql.legacy.timeParserPolicy", "LEGACY")
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")
    return spark


# ---------------------------------------------------------------------------
# CONFIGURATION LOADER
# ---------------------------------------------------------------------------
def load_config(config_path: str) -> dict:
    """
    Load YAML configuration file
    """
    with open(config_path, 'r') as file:
        config = yaml.safe_load(file)
    return config


# ---------------------------------------------------------------------------
# DATA EXTRACTION
# ---------------------------------------------------------------------------
def extract(spark: SparkSession, input_path: str) -> DataFrame:
    """
    Extract seller catalog data from CSV
    """
    logging.info(f"Extracting data from: {input_path}")

    # Define schema for seller catalog
    schema = T.StructType([
        T.StructField("seller_id", T.StringType(), True),
        T.StructField("item_id", T.StringType(), True),
        T.StructField("item_name", T.StringType(), True),
        T.StructField("category", T.StringType(), True),
        T.StructField("marketplace_price", T.DoubleType(), True),
        T.StructField("stock_qty", T.IntegerType(), True)
    ])

    df = (
        spark.read
        .schema(schema)
        .option("header", True)
        .option("ignoreLeadingWhiteSpace", True)
        .option("ignoreTrailingWhiteSpace", True)
        .csv(input_path)
    )

    logging.info(f"Extracted {df.count()} records from source")
    return df


# ---------------------------------------------------------------------------
# DATA CLEANING
# ---------------------------------------------------------------------------
def clean_data(df: DataFrame) -> DataFrame:
    """
    Clean seller catalog data:
    - Trim whitespace in string columns
    - Normalize item_name to Title Case
    - Normalize category to standard labels
    - Remove duplicates based on (seller_id + item_id)
    - Convert types properly
    - Fill missing stock_qty with 0
    """
    logging.info("Starting data cleaning...")

    # Trim whitespace in all string columns
    cleaned_df = (
        df.withColumn("seller_id", F.trim(F.col("seller_id")))
          .withColumn("item_id", F.trim(F.col("item_id")))
          .withColumn("item_name", F.trim(F.col("item_name")))
          .withColumn("category", F.trim(F.col("category")))
    )

    # Normalize item_name to Title Case
    cleaned_df = cleaned_df.withColumn(
        "item_name",
        F.initcap(F.col("item_name"))
    )

    # Normalize category (standardize labels)
    # Map common variations to standard names
    category_mappings = {
        "electronics": "Electronics",
        "ELECTRONICS": "Electronics",
        "apparel": "Apparel",
        "APPAREL": "Apparel",
        "footwear": "Footwear",
        "FOOTWEAR": "Footwear",
        "home": "Home",
        "HOME": "Home",
        "beauty": "Beauty",
        "BEAUTY": "Beauty",
        "sports": "Sports",
        "SPORTS": "Sports"
    }

    # Apply category normalization
    cleaned_df = cleaned_df.withColumn(
        "category",
        F.when(F.lower(F.col("category")) == "electronics", "Electronics")
         .when(F.lower(F.col("category")) == "apparel", "Apparel")
         .when(F.lower(F.col("category")) == "footwear", "Footwear")
         .when(F.lower(F.col("category")) == "home", "Home")
         .when(F.lower(F.col("category")) == "beauty", "Beauty")
         .when(F.lower(F.col("category")) == "sports", "Sports")
         .otherwise(F.initcap(F.col("category")))
    )

    # Fill missing stock_qty with 0
    cleaned_df = cleaned_df.withColumn(
        "stock_qty",
        F.coalesce(F.col("stock_qty"), F.lit(0))
    )

    # Remove duplicates based on key (seller_id + item_id)
    cleaned_df = cleaned_df.dropDuplicates(["seller_id", "item_id"])

    logging.info(f"Data cleaning completed. Records after cleaning: {cleaned_df.count()}")
    return cleaned_df


# ---------------------------------------------------------------------------
# DATA QUALITY CHECKS
# ---------------------------------------------------------------------------
def apply_dq_checks(df: DataFrame) -> tuple:
    """
    Apply Data Quality checks:
    - seller_id IS NOT NULL
    - item_id IS NOT NULL
    - marketplace_price >= 0
    - stock_qty >= 0
    - item_name IS NOT NULL
    - category IS NOT NULL

    Returns: (valid_df, invalid_df)
    """
    logging.info("Applying DQ checks...")

    # Add DQ check columns
    df_with_checks = (
        df.withColumn("dq_seller_id_null", F.when(F.col("seller_id").isNull(), "seller_id_null").otherwise(None))
          .withColumn("dq_item_id_null", F.when(F.col("item_id").isNull(), "item_id_null").otherwise(None))
          .withColumn("dq_price_invalid", F.when((F.col("marketplace_price").isNull()) | (F.col("marketplace_price") < 0), "price_invalid").otherwise(None))
          .withColumn("dq_stock_invalid", F.when((F.col("stock_qty").isNull()) | (F.col("stock_qty") < 0), "stock_invalid").otherwise(None))
          .withColumn("dq_item_name_null", F.when(F.col("item_name").isNull(), "item_name_null").otherwise(None))
          .withColumn("dq_category_null", F.when(F.col("category").isNull(), "category_null").otherwise(None))
    )

    # Combine all DQ failure reasons
    df_with_checks = df_with_checks.withColumn(
        "dq_failure_reason",
        F.concat_ws(", ",
            F.col("dq_seller_id_null"),
            F.col("dq_item_id_null"),
            F.col("dq_price_invalid"),
            F.col("dq_stock_invalid"),
            F.col("dq_item_name_null"),
            F.col("dq_category_null")
        )
    )

    # Separate valid and invalid records
    valid_df = (
        df_with_checks
        .filter(F.col("seller_id").isNotNull())
        .filter(F.col("item_id").isNotNull())
        .filter(F.col("marketplace_price") >= 0)
        .filter(F.col("stock_qty") >= 0)
        .filter(F.col("item_name").isNotNull())
        .filter(F.col("category").isNotNull())
        .select("seller_id", "item_id", "item_name", "category", "marketplace_price", "stock_qty")
    )

    invalid_df = (
        df_with_checks
        .filter(F.col("dq_failure_reason") != "")
        .withColumn("dataset_name", F.lit("seller_catalog"))
        .withColumn("quarantine_timestamp", F.current_timestamp())
        .select("dataset_name", "seller_id", "item_id", "item_name", "category",
                "marketplace_price", "stock_qty", "dq_failure_reason", "quarantine_timestamp")
    )

    valid_count = valid_df.count()
    invalid_count = invalid_df.count()

    logging.info(f"DQ checks completed. Valid: {valid_count} | Invalid: {invalid_count}")

    return valid_df, invalid_df


# ---------------------------------------------------------------------------
# LOAD TO HUDI AND QUARANTINE
# ---------------------------------------------------------------------------
def load(valid_df: DataFrame, invalid_df: DataFrame, config: dict):
    """
    Load data to destinations:
    - Valid records → Hudi table (overwrite mode)
    - Invalid records → Quarantine zone (parquet)
    """
    hudi_path = config["seller_catalog"]["hudi_output_path"]
    quarantine_path = config["seller_catalog"]["quarantine_path"]

    # Create output directories
    os.makedirs(quarantine_path, exist_ok=True)

    # Write invalid records to quarantine
    if invalid_df.count() > 0:
        invalid_df.write.mode("overwrite").parquet(quarantine_path)
        logging.warning(f"Invalid records written to quarantine: {quarantine_path}")
    else:
        logging.info("No invalid records to quarantine")

    # Write valid records to Hudi table
    if valid_df.count() > 0:
        # Hudi options
        hudi_options = {
            "hoodie.table.name": "seller_catalog_hudi",
            "hoodie.datasource.write.recordkey.field": "seller_id,item_id",
            "hoodie.datasource.write.partitionpath.field": "",
            "hoodie.datasource.write.precombine.field": "item_id",
            "hoodie.datasource.write.operation": "upsert",
            "hoodie.datasource.write.table.type": "COPY_ON_WRITE",
            "hoodie.datasource.write.hive_style_partitioning": "false",
            "hoodie.datasource.write.keygenerator.class": "org.apache.hudi.keygen.NonpartitionedKeyGenerator",
            "hoodie.datasource.hive_sync.enable": "false"
        }

        valid_df.write.format("hudi").options(**hudi_options).mode("overwrite").save(hudi_path)
        logging.info(f"Valid records written to Hudi table: {hudi_path}")
    else:
        logging.warning("No valid records to write to Hudi")


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
def main():
    """
    Main ETL orchestration
    """
    # Set up logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="ETL Pipeline for Seller Catalog")
    parser.add_argument("--config", required=True, help="Path to YAML configuration file")
    args = parser.parse_args()

    # Load configuration
    config = load_config(args.config)
    logging.info("Configuration loaded successfully")

    # Initialize Spark session
    spark = get_spark_session("ETL_Seller_Catalog")
    logging.info("Spark session initialized")

    try:
        # ETL Pipeline
        input_path = config["seller_catalog"]["input_path"]

        # Extract
        df = extract(spark, input_path)

        # Transform (Clean + DQ checks)
        cleaned_df = clean_data(df)
        valid_df, invalid_df = apply_dq_checks(cleaned_df)

        # Load
        load(valid_df, invalid_df, config)

        logging.info("Seller Catalog ETL Pipeline completed successfully")

    except Exception as e:
        logging.error(f"ETL Pipeline failed with error: {str(e)}")
        raise
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
