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

This will give you two options:
1. **Docker** (recommended - no setup needed)
2. **Local** (requires Spark installation)

### Execution Steps

1. **Extract the assignment** (if zipped)
2. **Navigate to the local folder:** `cd 2025EM1100026/ecommerce_seller_recommendation/local`
3. **Run the main script:** `bash RUN_ASSIGNMENT.sh`
4. **Select option 1** (Docker) for easiest execution
5. **Wait for completion** - takes approximately 5-10 minutes
6. **Verify results** in the `processed/` folder

## Project Structure

```
2025EM1100026/
├── README.md                                    # Main documentation
└── ecommerce_seller_recommendation/
    └── local/
        ├── .gitignore
        ├── Dockerfile                           # Container definition
        ├── docker-compose.yml                   # Docker orchestration
        ├── docker-entrypoint.sh                 # Container startup script
        ├── RUN_ASSIGNMENT.sh                    # Interactive execution menu
        ├── requirements.txt                     # Python dependencies
        ├── README.md                            # Detailed technical docs
        ├── configs/
        │   ├── ecomm_prod.yml                   # Production config
        │   ├── ecomm_local.yml                  # Local config (clean data)
        │   └── ecomm_dirty.yml                  # Demo config (dirty data)
        ├── src/                                 # Python ETL pipelines
        │   ├── etl_seller_catalog.py           # Pipeline 1: Seller catalogs
        │   ├── etl_company_sales.py            # Pipeline 2: Company sales
        │   ├── etl_competitor_sales.py         # Pipeline 3: Competitor sales
        │   └── consumption_recommendation.py    # Pipeline 4: Recommendations
        ├── scripts/                             # Spark submit wrappers
        │   ├── etl_seller_catalog_spark_submit.sh
        │   ├── etl_company_sales_spark_submit.sh
        │   ├── etl_competitor_sales_spark_submit.sh
        │   ├── consumption_recommendation_spark_submit.sh
        │   └── run_all_pipelines.sh             # Runs all 4 pipelines
        └── raw/                                 # Input data files
            ├── DATA_FILES_NOTE.md
            ├── seller_catalog/
            │   ├── seller_catalog_clean.csv
            │   └── seller_catalog_dirty.csv
            ├── company_sales/
            │   ├── company_sales_clean.csv
            │   └── company_sales_dirty.csv
            └── competitor_sales/
                ├── competitor_sales_clean.csv
                ├── competitor_sales_clean.sv     # Pipe-delimited
                ├── competitor_sales_dirty.csv
                └── competitor_sales_dirty.sv     # Pipe-delimited

Generated during execution:
├── processed/                                   # Hudi tables & recommendations CSV
│   ├── seller_catalog_hudi/
│   ├── company_sales_hudi/
│   ├── competitor_sales_hudi/
│   └── recommendations_csv/
│       └── seller_recommend_data.csv
└── quarantine/                                  # Invalid records (if any)
    ├── seller_catalog/
    ├── company_sales/
    └── competitor_sales/
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

**First time:** The build takes 5-10 minutes to download dependencies.  
**Subsequent runs:** Just use `docker compose up` (much faster).

To stop: `docker compose down`

### Option 2: Local Execution

If you have Spark installed locally:

```bash
cd ecommerce_seller_recommendation/local

# Run all pipelines at once
bash scripts/run_all_pipelines.sh

# Or run individually:
bash scripts/etl_seller_catalog_spark_submit.sh
bash scripts/etl_company_sales_spark_submit.sh
bash scripts/etl_competitor_sales_spark_submit.sh
bash scripts/consumption_recommendation_spark_submit.sh
```

## Expected Outputs

After successful execution, the following outputs are generated:

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

## Execution Time

- **First run (Docker):** 5-10 minutes (includes image build)
- **Subsequent runs:** 2-3 minutes (uses cached image)
- **Data processed:** ~3 million records (1M per dataset)
- **Recommendations generated:** ~2,000 items

## Data Quality Framework

The system includes comprehensive validation:

- **Missing value checks** - Ensures required fields are present
- **Data type validation** - Converts and validates numeric/date fields  
- **Business rule enforcement** - Rejects negative prices, future dates, etc.
- **Quarantine handling** - Invalid records are isolated with failure reasons

Rejected records are saved to `quarantine/` with detailed error messages for analysis.

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
- Make sure Docker is running: `docker --version`
- Try rebuilding: `docker compose down && docker compose up --build`
- Check logs: `docker logs ecommerce_recommendation_system -f`
- Clean rebuild: `docker compose build --no-cache`

**Local execution issues:**
- Ensure Java 21 and Spark 3.5.0 are installed
- Check that SPARK_HOME is set correctly

**Permission issues:**
- Run `chmod +x *.sh` in the scripts directory

## Assignment Requirements Implemented

✅ **ETL Ingestion** - Three complete pipelines with Hudi integration  
✅ **Consumption Layer** - Recommendation generation with business metrics  
✅ **Data Cleaning & Quality Checks** - Comprehensive validation and quarantine handling  
✅ **Schema Evolution** - Hudi tables support schema changes  
✅ **YAML Configuration** - Flexible path management  
✅ **Docker Support** - Containerized execution environment  

## Sample Results

The system typically generates around 2,000 recommendations for clean data, with each recommendation including:
- Seller ID and missing item details
- Market price and expected units sold
- Calculated expected revenue

Dirty data processing generates fewer recommendations (around 1,800) with invalid records properly quarantined.

---

This implementation follows industry best practices for data engineering pipelines and demonstrates a production-ready approach to building recommendation systems.