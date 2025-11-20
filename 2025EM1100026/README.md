# E-commerce Seller Recommendation System

**Student:** MSc Data Science & AI  
**Roll Number:** 2025EM1100026  
**Assignment:** Data Storage and Pipeline  

## Overview

This project implements a complete recommendation system for e-commerce sellers using Apache Spark, Apache Hudi, and a medallion architecture. The system analyzes sales data to recommend top-selling items that sellers don't currently have in their catalogs.

## Quick Start

The easiest way to run this assignment is using the provided script:

```bash
cd ecommerce_seller_recommendation/local
bash RUN_ASSIGNMENT.sh
```

This will give you three options:
1. **Docker** (recommended - no setup needed)
2. **Local** (requires Spark installation)
3. **Complete Demo** (shows both clean and dirty data processing)

### Simple Execution Flow

1. **Extract the assignment** (if zipped)
2. **Navigate to the local folder:** `cd 2025EM1100026/ecommerce_seller_recommendation/local`
3. **Run the main script:** `bash RUN_ASSIGNMENT.sh`
4. **Choose option 1** (Docker) for easiest execution
5. **Wait for completion** - takes about 5-10 minutes
6. **Check results** in the `processed/` folder

## Project Structure

```
2025EM1100026/
├── README.md                   # This file - main instructions
└── ecommerce_seller_recommendation/
    └── local/
        ├── configs/
        │   ├── ecomm_prod.yml      # Production config
        │   ├── ecomm_local.yml     # Local config (clean data)
        │   └── ecomm_dirty.yml     # Demo config (dirty data)
        ├── src/
        │   ├── etl_seller_catalog.py
        │   ├── etl_company_sales.py
        │   ├── etl_competitor_sales.py
        │   └── consumption_recommendation.py
        ├── scripts/
        │   ├── etl_seller_catalog_spark_submit.sh
        │   ├── etl_company_sales_spark_submit.sh
        │   ├── etl_competitor_sales_spark_submit.sh
        │   └── consumption_recommendation_spark_submit.sh
        ├── raw/
        │   ├── seller_catalog/
        │   │   ├── seller_catalog_clean.csv
        │   │   └── seller_catalog_dirty.csv
        │   ├── company_sales/
        │   │   ├── company_sales_clean.csv
        │   │   └── company_sales_dirty.csv
        │   └── competitor_sales/
        │       ├── competitor_sales_clean.csv
        │       └── competitor_sales_dirty.csv
        ├── processed/              # Output Hudi tables & CSV
        ├── quarantine/             # Invalid records (created during run)
        ├── Dockerfile
        ├── docker-compose.yml
        ├── RUN_ASSIGNMENT.sh       # Main execution script
        ├── run_complete_demo.sh    # Demo script
        ├── verify_submission.sh    # Verification script
        └── README.md               # Detailed documentation
```

## What This System Does

1. **Ingests three datasets:**
   - Seller catalogs (what each seller currently sells)
   - Company sales data (internal sales performance)
   - Competitor sales data (market performance)

2. **Processes data through medallion architecture:**
   - **Bronze Layer:** Raw data ingestion
   - **Silver Layer:** Data cleaning and validation
   - **Gold Layer:** Business-ready data in Hudi tables

3. **Generates recommendations:**
   - Identifies top-selling items missing from each seller's catalog
   - Calculates expected revenue for each recommendation
   - Outputs final recommendations as CSV

## Running the Assignment

### Option 1: Docker (Recommended)

No setup required - everything runs in containers:

```bash
cd ecommerce_seller_recommendation/local
docker compose up --build
```

### Option 2: Local Execution

If you have Spark installed locally:

```bash
cd ecommerce_seller_recommendation/local

# Run ETL pipelines
bash scripts/etl_seller_catalog_spark_submit.sh
bash scripts/etl_company_sales_spark_submit.sh
bash scripts/etl_competitor_sales_spark_submit.sh

# Generate recommendations
bash scripts/consumption_recommendation_spark_submit.sh
```

### Option 3: Complete Demo

This runs both clean and dirty data to show the data quality framework:

```bash
cd ecommerce_seller_recommendation/local
bash run_complete_demo.sh
```

## Expected Outputs

After successful execution, you'll find:

1. **Hudi Tables** in `processed/`:
   - `seller_catalog_hudi/`
   - `company_sales_hudi/`
   - `competitor_sales_hudi/`

2. **Final Recommendations** in:
   - `processed/recommendations_csv/seller_recommend_data.csv`

3. **Quarantine Records** (if any invalid data):
   - `quarantine/seller_catalog/`
   - `quarantine/company_sales/`
   - `quarantine/competitor_sales/`

## Data Quality Framework

The system includes comprehensive data validation:

- **Missing value checks** - Ensures required fields are present
- **Data type validation** - Converts and validates numeric/date fields
- **Business rule enforcement** - Checks for negative prices, future dates
- **Quarantine handling** - Isolates invalid records with failure reasons

When processing dirty data, you'll see invalid records moved to quarantine folders with detailed error messages.

## Technical Details

- **Spark Version:** 3.5.0
- **Hudi Version:** 0.15.0
- **Java Version:** 21
- **Architecture:** Medallion pattern with quarantine zone
- **Storage:** Apache Hudi for ACID transactions and schema evolution

## Configuration

The system uses YAML configuration files for flexibility:

- `ecomm_local.yml` - Standard configuration with clean data
- `ecomm_dirty.yml` - Demo configuration showing data quality handling
- `ecomm_prod.yml` - Production-ready configuration template

All paths are relative, making the project easy to move and deploy.

## Troubleshooting

**Docker issues:**
- Make sure Docker is running
- Try `docker compose down` then `docker compose up --build`

**Local execution issues:**
- Ensure Java 21 and Spark 3.5.0 are installed
- Check that SPARK_HOME is set correctly

**Permission issues:**
- Run `chmod +x *.sh` in the scripts directory

## Assignment Requirements Met

✅ **ETL Ingestion (15 marks)** - Three complete pipelines with Hudi integration  
✅ **Consumption Layer (5 marks)** - Recommendation generation with business metrics  
✅ **Data Cleaning & DQ** - Comprehensive validation and quarantine handling  
✅ **Schema Evolution** - Hudi tables support schema changes  
✅ **YAML Configuration** - Flexible path management  
✅ **Docker Support** - Containerized execution  

## Sample Results

The system typically generates around 2,000 recommendations for clean data, with each recommendation including:
- Seller ID and missing item details
- Market price and expected units sold
- Calculated expected revenue

For dirty data processing, you'll see fewer recommendations (around 1,800) with invalid records properly quarantined.

---

This implementation follows industry best practices for data engineering pipelines and demonstrates a production-ready approach to building recommendation systems.