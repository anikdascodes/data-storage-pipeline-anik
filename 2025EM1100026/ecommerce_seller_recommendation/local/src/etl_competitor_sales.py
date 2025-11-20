"""
ETL Pipeline for Competitor Sales Data

E-commerce Top-Seller Items Recommendation System
Student: MSc Data Science & AI
Roll No: 2025EM1100026

Pipeline Flow:
- Extract competitor sales data from CSV
- Clean data (trim, normalize, type conversion, deduplicate)
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
    Extract competitor sales data from CSV
    """
    logging.info(f"Extracting data from: {input_path}")

    # Define schema for competitor sales
    schema = T.StructType([
        T.StructField("seller_id", T.StringType(), True),
        T.StructField("item_id", T.StringType(), True),
        T.StructField("units_sold", T.IntegerType(), True),
        T.StructField("revenue", T.DoubleType(), True),
        T.StructField("marketplace_price", T.DoubleType(), True),
        T.StructField("sale_date", T.DateType(), True)
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
    Clean competitor sales data:
    - Trim strings (item_id, seller_id)
    - Normalize casing
    - Convert numeric columns to proper types
    - Convert sale_date to DATE
    - Fill missing numeric fields with 0
    - Remove duplicates based on (seller_id + item_id)
    """
    logging.info("Starting data cleaning...")

    # Trim whitespace in string columns
    cleaned_df = (
        df.withColumn("seller_id", F.trim(F.col("seller_id")))
          .withColumn("item_id", F.trim(F.col("item_id")))
    )

    # Fill missing numeric fields with 0
    cleaned_df = cleaned_df.withColumn(
        "units_sold",
        F.coalesce(F.col("units_sold"), F.lit(0))
    )

    cleaned_df = cleaned_df.withColumn(
        "revenue",
        F.coalesce(F.col("revenue"), F.lit(0.0))
    )

    cleaned_df = cleaned_df.withColumn(
        "marketplace_price",
        F.coalesce(F.col("marketplace_price"), F.lit(0.0))
    )

    # Round revenue and price to 2 decimal places
    cleaned_df = cleaned_df.withColumn(
        "revenue",
        F.round(F.col("revenue"), 2)
    )

    cleaned_df = cleaned_df.withColumn(
        "marketplace_price",
        F.round(F.col("marketplace_price"), 2)
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
    - item_id IS NOT NULL
    - seller_id IS NOT NULL
    - units_sold >= 0
    - revenue >= 0
    - marketplace_price >= 0
    - sale_date IS NOT NULL AND sale_date <= current_date()

    Returns: (valid_df, invalid_df)
    """
    logging.info("Applying DQ checks...")

    # Add DQ check columns
    df_with_checks = (
        df.withColumn("dq_item_id_null", F.when(F.col("item_id").isNull(), "item_id_null").otherwise(None))
          .withColumn("dq_seller_id_null", F.when(F.col("seller_id").isNull(), "seller_id_null").otherwise(None))
          .withColumn("dq_units_sold_invalid", F.when((F.col("units_sold").isNull()) | (F.col("units_sold") < 0), "units_sold_invalid").otherwise(None))
          .withColumn("dq_revenue_invalid", F.when((F.col("revenue").isNull()) | (F.col("revenue") < 0), "revenue_invalid").otherwise(None))
          .withColumn("dq_price_invalid", F.when((F.col("marketplace_price").isNull()) | (F.col("marketplace_price") < 0), "price_invalid").otherwise(None))
          .withColumn("dq_sale_date_invalid",
                     F.when((F.col("sale_date").isNull()) | (F.col("sale_date") > F.current_date()), "sale_date_invalid").otherwise(None))
    )

    # Combine all DQ failure reasons
    df_with_checks = df_with_checks.withColumn(
        "dq_failure_reason",
        F.concat_ws(", ",
            F.col("dq_item_id_null"),
            F.col("dq_seller_id_null"),
            F.col("dq_units_sold_invalid"),
            F.col("dq_revenue_invalid"),
            F.col("dq_price_invalid"),
            F.col("dq_sale_date_invalid")
        )
    )

    # Separate valid and invalid records
    valid_df = (
        df_with_checks
        .filter(F.col("item_id").isNotNull())
        .filter(F.col("seller_id").isNotNull())
        .filter(F.col("units_sold") >= 0)
        .filter(F.col("revenue") >= 0)
        .filter(F.col("marketplace_price") >= 0)
        .filter(F.col("sale_date").isNotNull())
        .filter(F.col("sale_date") <= F.current_date())
        .select("seller_id", "item_id", "units_sold", "revenue", "marketplace_price", "sale_date")
    )

    invalid_df = (
        df_with_checks
        .filter(F.col("dq_failure_reason") != "")
        .withColumn("dataset_name", F.lit("competitor_sales"))
        .withColumn("quarantine_timestamp", F.current_timestamp())
        .select("dataset_name", "seller_id", "item_id", "units_sold", "revenue",
                "marketplace_price", "sale_date", "dq_failure_reason", "quarantine_timestamp")
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
    hudi_path = config["competitor_sales"]["hudi_output_path"]
    quarantine_path = config["competitor_sales"]["quarantine_path"]

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
            "hoodie.table.name": "competitor_sales_hudi",
            "hoodie.datasource.write.recordkey.field": "seller_id,item_id",
            "hoodie.datasource.write.partitionpath.field": "",
            "hoodie.datasource.write.precombine.field": "sale_date",
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
    parser = argparse.ArgumentParser(description="ETL Pipeline for Competitor Sales")
    parser.add_argument("--config", required=True, help="Path to YAML configuration file")
    args = parser.parse_args()

    # Load configuration
    config = load_config(args.config)
    logging.info("Configuration loaded successfully")

    # Initialize Spark session
    spark = get_spark_session("ETL_Competitor_Sales")
    logging.info("Spark session initialized")

    try:
        # ETL Pipeline
        input_path = config["competitor_sales"]["input_path"]

        # Extract
        df = extract(spark, input_path)

        # Transform (Clean + DQ checks)
        cleaned_df = clean_data(df)
        valid_df, invalid_df = apply_dq_checks(cleaned_df)

        # Load
        load(valid_df, invalid_df, config)

        logging.info("Competitor Sales ETL Pipeline completed successfully")

    except Exception as e:
        logging.error(f"ETL Pipeline failed with error: {str(e)}")
        raise
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
