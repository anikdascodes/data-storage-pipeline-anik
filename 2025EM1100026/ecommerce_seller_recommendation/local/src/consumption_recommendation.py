"""
Consumption Layer - Recommendation Generation

E-commerce Top-Seller Items Recommendation System
Student: MSc Data Science & AI
Roll No: 2025EM1100026

Business Logic:
- Read Hudi tables (seller catalog, company sales, competitor sales)
- Identify top 10 selling items per category
- Find missing items in each seller's catalog
- Calculate expected revenue for recommendations
- Output recommendations to CSV
"""

import os
import sys
import logging
import argparse
import yaml
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F
from pyspark.sql import types as T
from pyspark.sql.window import Window


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
# DATA EXTRACTION FROM HUDI
# ---------------------------------------------------------------------------
def extract_hudi_data(spark: SparkSession, config: dict) -> tuple:
    """
    Extract data from Hudi tables
    Returns: (seller_catalog_df, company_sales_df, competitor_sales_df)
    """
    logging.info("Extracting data from Hudi tables...")

    # Read Seller Catalog Hudi table
    seller_catalog_df = spark.read.format("hudi").load(
        config["recommendation"]["seller_catalog_hudi"]
    )
    logging.info(f"Seller Catalog records: {seller_catalog_df.count()}")

    # Read Company Sales Hudi table
    company_sales_df = spark.read.format("hudi").load(
        config["recommendation"]["company_sales_hudi"]
    )
    logging.info(f"Company Sales records: {company_sales_df.count()}")

    # Read Competitor Sales Hudi table
    competitor_sales_df = spark.read.format("hudi").load(
        config["recommendation"]["competitor_sales_hudi"]
    )
    logging.info(f"Competitor Sales records: {competitor_sales_df.count()}")

    return seller_catalog_df, company_sales_df, competitor_sales_df


# ---------------------------------------------------------------------------
# IDENTIFY TOP-SELLING ITEMS
# ---------------------------------------------------------------------------
def identify_top_selling_items(company_sales_df: DataFrame, competitor_sales_df: DataFrame,
                                seller_catalog_df: DataFrame) -> DataFrame:
    """
    Identify top 10 selling items per category from company and competitor data
    Combined approach:
    1. Aggregate company sales by item
    2. Aggregate competitor sales by item
    3. Join with catalog to get category information
    4. Rank items by units_sold within each category
    5. Select top 10 per category
    """
    logging.info("Identifying top-selling items...")

    # Aggregate company sales by item_id
    company_agg = (
        company_sales_df
        .groupBy("item_id")
        .agg(
            F.sum("units_sold").alias("company_units_sold"),
            F.sum("revenue").alias("company_revenue")
        )
    )

    # Aggregate competitor sales by item_id
    competitor_agg = (
        competitor_sales_df
        .groupBy("item_id")
        .agg(
            F.sum("units_sold").alias("competitor_units_sold"),
            F.sum("revenue").alias("competitor_revenue"),
            F.avg("marketplace_price").alias("avg_marketplace_price"),
            F.count("seller_id").alias("num_sellers")
        )
    )

    # Join company and competitor aggregates
    combined_sales = (
        company_agg.join(competitor_agg, "item_id", "outer")
        .fillna(0, subset=["company_units_sold", "company_revenue", "competitor_units_sold", "competitor_revenue"])
        .fillna(1, subset=["num_sellers"])  # Avoid division by zero
    )

    # Calculate total units sold
    combined_sales = combined_sales.withColumn(
        "total_units_sold",
        F.col("company_units_sold") + F.col("competitor_units_sold")
    )

    # Get unique catalog items with category and price info
    catalog_unique = (
        seller_catalog_df
        .select("item_id", "item_name", "category", "marketplace_price")
        .dropDuplicates(["item_id"])
    )

    # Join with catalog to get category
    items_with_category = combined_sales.join(catalog_unique, "item_id", "left")

    # Calculate market price (prefer competitor avg, fallback to catalog price)
    items_with_category = items_with_category.withColumn(
        "market_price",
        F.coalesce(F.col("avg_marketplace_price"), F.col("marketplace_price"))
    )

    # Rank items within each category by total_units_sold
    window_spec = Window.partitionBy("category").orderBy(F.desc("total_units_sold"))

    top_items = (
        items_with_category
        .withColumn("rank", F.row_number().over(window_spec))
        .filter(F.col("rank") <= 10)
        .select(
            "item_id",
            "item_name",
            "category",
            "total_units_sold",
            "num_sellers",
            "market_price"
        )
    )

    logging.info(f"Top-selling items identified: {top_items.count()}")
    return top_items


# ---------------------------------------------------------------------------
# GENERATE RECOMMENDATIONS
# ---------------------------------------------------------------------------
def generate_recommendations(seller_catalog_df: DataFrame, top_items_df: DataFrame) -> DataFrame:
    """
    Generate recommendations for each seller:
    - Find items that are top-selling but missing from seller's catalog
    - Calculate expected_units_sold and expected_revenue
    """
    logging.info("Generating recommendations...")

    # Get list of items each seller currently has
    seller_items = (
        seller_catalog_df
        .select("seller_id", "item_id")
        .distinct()
    )

    # Get unique sellers
    sellers = seller_catalog_df.select("seller_id").distinct()

    # Cross join sellers with top items to get all possible combinations
    all_combinations = sellers.crossJoin(top_items_df)

    # Left anti join to find items NOT in seller's catalog
    missing_items = (
        all_combinations
        .join(
            seller_items,
            (all_combinations.seller_id == seller_items.seller_id) &
            (all_combinations.item_id == seller_items.item_id),
            "left_anti"
        )
    )

    # Calculate expected_units_sold = total_units_sold / num_sellers
    # This represents average units sold per seller
    recommendations = missing_items.withColumn(
        "expected_units_sold",
        F.round(F.col("total_units_sold") / F.col("num_sellers"), 0).cast(T.IntegerType())
    )

    # Calculate expected_revenue = expected_units_sold * market_price
    recommendations = recommendations.withColumn(
        "expected_revenue",
        F.round(F.col("expected_units_sold") * F.col("market_price"), 2)
    )

    # Select final columns
    final_recommendations = recommendations.select(
        "seller_id",
        "item_id",
        "item_name",
        "category",
        F.round(F.col("market_price"), 2).alias("market_price"),
        "expected_units_sold",
        "expected_revenue"
    )

    # Order by seller_id and expected_revenue (descending) to prioritize high-value items
    final_recommendations = final_recommendations.orderBy(
        "seller_id",
        F.desc("expected_revenue")
    )

    logging.info(f"Total recommendations generated: {final_recommendations.count()}")
    return final_recommendations


# ---------------------------------------------------------------------------
# LOAD RECOMMENDATIONS TO CSV
# ---------------------------------------------------------------------------
def load_to_csv(recommendations_df: DataFrame, output_path: str):
    """
    Write recommendations to CSV file (overwrite mode)
    """
    logging.info(f"Writing recommendations to: {output_path}")

    # Create output directory
    output_dir = os.path.dirname(output_path)
    os.makedirs(output_dir, exist_ok=True)

    # Write to CSV (coalesce to single partition for single CSV file)
    recommendations_df.coalesce(1).write.mode("overwrite").option("header", True).csv(output_path)

    logging.info("Recommendations written successfully")

    # Find the actual CSV file and rename it
    csv_files = [f for f in os.listdir(output_path) if f.endswith('.csv')]
    if csv_files:
        actual_csv = os.path.join(output_path, csv_files[0])
        final_csv = os.path.join(output_path, "seller_recommend_data.csv")
        if os.path.exists(final_csv):
            os.remove(final_csv)
        os.rename(actual_csv, final_csv)
        logging.info(f"Final CSV: {final_csv}")


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
def main():
    """
    Main consumption layer orchestration
    """
    # Set up logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Consumption Layer - Recommendations")
    parser.add_argument("--config", required=True, help="Path to YAML configuration file")
    args = parser.parse_args()

    # Load configuration
    config = load_config(args.config)
    logging.info("Configuration loaded successfully")

    # Initialize Spark session
    spark = get_spark_session("Consumption_Recommendations")
    logging.info("Spark session initialized")

    try:
        # Extract data from Hudi tables
        seller_catalog_df, company_sales_df, competitor_sales_df = extract_hudi_data(spark, config)

        # Identify top-selling items per category
        top_items_df = identify_top_selling_items(company_sales_df, competitor_sales_df, seller_catalog_df)

        # Generate recommendations
        recommendations_df = generate_recommendations(seller_catalog_df, top_items_df)

        # Load to CSV
        output_path = config["recommendation"]["output_csv"]
        load_to_csv(recommendations_df, output_path)

        logging.info("Consumption Layer Pipeline completed successfully")

    except Exception as e:
        logging.error(f"Consumption Layer Pipeline failed with error: {str(e)}")
        raise
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
