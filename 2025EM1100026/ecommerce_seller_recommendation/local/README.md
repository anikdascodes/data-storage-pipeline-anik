# E-commerce Top-Seller Items Recommendation System

**Assignment #1: Data Storage and Pipeline**
**Student:** MSc Data Science & AI
**Roll No:** 2025EM1100026

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Prerequisites](#prerequisites)
5. [Setup Instructions](#setup-instructions)
6. [Execution Guide](#execution-guide)
7. [Pipeline Details](#pipeline-details)
8. [Data Quality Checks](#data-quality-checks)
9. [Output](#output)
10. [Troubleshooting](#troubleshooting)

---

## Project Overview

This project implements an end-to-end data pipeline for an e-commerce recommendation system that helps sellers identify top-selling items they should add to their catalog. The system:

- Ingests data from 3 sources (Seller Catalog, Company Sales, Competitor Sales)
- Applies data cleaning and quality checks
- Uses Apache Hudi for incremental data storage
- Implements medallion architecture (Bronze → Silver → Gold)
- Generates actionable recommendations with expected revenue calculations

### Key Features

- **ETL Pipelines:** 3 separate pipelines for each data source
- **Data Quality:** Comprehensive DQ checks with quarantine zone for bad data
- **Apache Hudi:** Schema evolution and incremental upserts
- **Medallion Architecture:** Bronze (raw) → Silver (cleaned) → Gold (consumption-ready)
- **Dockerized:** Complete production-ready environment
- **uv Package Manager:** Fast Python dependency management

---

## Architecture

```
Raw Data (CSV)
    ↓
ETL Pipeline 1 (Seller Catalog)
    ↓ (Clean, Validate, DQ Checks)
    ↓
Hudi Table 1 ← Quarantine Zone
    ↓

ETL Pipeline 2 (Company Sales)
    ↓ (Clean, Validate, DQ Checks)
    ↓
Hudi Table 2 ← Quarantine Zone
    ↓

ETL Pipeline 3 (Competitor Sales)
    ↓ (Clean, Validate, DQ Checks)
    ↓
Hudi Table 3 ← Quarantine Zone
    ↓

Consumption Layer
    ↓ (Top-selling analysis, Recommendations)
    ↓
CSV Output (Recommendations)
```

---

## Project Structure

```
2025EM1100026/ecommerce_seller_recommendation/local/
│
├── configs/
│   └── ecomm_prod.yml              # YAML configuration (paths only)
│
├── src/
│   ├── etl_seller_catalog.py      # ETL for seller catalog
│   ├── etl_company_sales.py       # ETL for company sales
│   ├── etl_competitor_sales.py    # ETL for competitor sales
│   └── consumption_recommendation.py  # Consumption layer
│
├── scripts/
│   ├── etl_seller_catalog_spark_submit.sh
│   ├── etl_company_sales_spark_submit.sh
│   ├── etl_competitor_sales_spark_submit.sh
│   └── consumption_recommendation_spark_submit.sh
│
├── raw/                            # Input CSV files
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── processed/                      # Hudi tables and output CSV
│   ├── seller_catalog_hudi/
│   ├── company_sales_hudi/
│   ├── competitor_sales_hudi/
│   └── recommendations_csv/
│
├── quarantine/                     # Bad data records
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── Dockerfile                      # Docker image definition
├── docker-compose.yml              # Docker orchestration
├── pyproject.toml                  # uv project configuration
├── requirements.txt                # Python dependencies
└── README.md                       # This file
```

---

## Prerequisites

### Option 1: Docker (Recommended)

- Docker 20.10+
- Docker Compose 1.29+
- 4GB+ RAM available for container

### Option 2: Local Installation

- Python 3.8+
- Java 11 (OpenJDK)
- Apache Spark 3.5.0
- uv package manager
- 8GB+ RAM

---

## Setup Instructions

### Option 1: Using Docker (Recommended)

1. **Clone the repository:**
   ```bash
   cd /path/to/project
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   ```

2. **Build Docker image:**
   ```bash
   docker-compose build
   ```
   This will:
   - Install Java 11
   - Install Apache Spark 3.5.0
   - Install Python and uv
   - Install all dependencies from requirements.txt

3. **Start the container:**
   ```bash
   docker-compose up -d
   ```

4. **Access the container:**
   ```bash
   docker-compose exec ecommerce-recommendation bash
   ```

### Option 2: Local Installation

1. **Install Java 11:**
   ```bash
   sudo apt-get update
   sudo apt-get install openjdk-11-jdk
   export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
   ```

2. **Install Apache Spark 3.5.0:**
   ```bash
   wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
   tar -xzf spark-3.5.0-bin-hadoop3.tgz
   sudo mv spark-3.5.0-bin-hadoop3 /opt/spark
   export SPARK_HOME=/opt/spark
   export PATH=$PATH:$SPARK_HOME/bin
   ```

3. **Install uv:**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   source $HOME/.cargo/env
   ```

4. **Install Python dependencies:**
   ```bash
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   uv venv
   source .venv/bin/activate
   uv pip install -r requirements.txt
   ```

---

## Execution Guide

### Step 1: Run ETL Pipelines (Execute in Order)

**Important:** Execute the ETL pipelines in sequence before running the consumption layer.

#### 1.1 Seller Catalog ETL
```bash
bash /home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/scripts/etl_seller_catalog_spark_submit.sh
```

**What it does:**
- Reads `raw/seller_catalog/seller_catalog_clean.csv`
- Cleans data (trim, normalize, deduplicate)
- Applies DQ checks
- Writes valid data to `processed/seller_catalog_hudi/`
- Writes invalid data to `quarantine/seller_catalog/`

#### 1.2 Company Sales ETL
```bash
bash /home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/scripts/etl_company_sales_spark_submit.sh
```

**What it does:**
- Reads `raw/company_sales/company_sales_clean.csv`
- Cleans data (trim, type conversion)
- Applies DQ checks
- Writes valid data to `processed/company_sales_hudi/`
- Writes invalid data to `quarantine/company_sales/`

#### 1.3 Competitor Sales ETL
```bash
bash /home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/scripts/etl_competitor_sales_spark_submit.sh
```

**What it does:**
- Reads `raw/competitor_sales/competitor_sales_clean.csv`
- Cleans data (trim, normalize, type conversion)
- Applies DQ checks
- Writes valid data to `processed/competitor_sales_hudi/`
- Writes invalid data to `quarantine/competitor_sales/`

### Step 2: Run Consumption Layer

```bash
bash /home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/scripts/consumption_recommendation_spark_submit.sh
```

**What it does:**
- Reads 3 Hudi tables
- Identifies top 10 selling items per category
- Finds items missing from each seller's catalog
- Calculates expected revenue
- Writes recommendations to `processed/recommendations_csv/seller_recommend_data.csv`

### Alternative: Direct spark-submit Commands

If you prefer to run spark-submit directly:

```bash
# Seller Catalog
spark-submit \
  --packages org.apache.hudi:hudi-spark3.5-bundle_2.12:0.15.0,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.legacy.timeParserPolicy=LEGACY \
  /home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/src/etl_seller_catalog.py \
  --config /home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/configs/ecomm_prod.yml

# Repeat for other pipelines...
```

---

## Pipeline Details

### ETL Pipeline 1: Seller Catalog

**Input Schema:**
- `seller_id` (STRING)
- `item_id` (STRING)
- `item_name` (STRING)
- `category` (STRING)
- `marketplace_price` (DOUBLE)
- `stock_qty` (INT)

**Cleaning Steps:**
1. Trim whitespace in all string columns
2. Normalize `item_name` to Title Case
3. Normalize `category` to standard labels
4. Fill missing `stock_qty` with 0
5. Remove duplicates by (seller_id, item_id)

**DQ Checks:**
- seller_id IS NOT NULL
- item_id IS NOT NULL
- marketplace_price >= 0
- stock_qty >= 0
- item_name IS NOT NULL
- category IS NOT NULL

### ETL Pipeline 2: Company Sales

**Input Schema:**
- `item_id` (STRING)
- `units_sold` (INT)
- `revenue` (DOUBLE)
- `sale_date` (DATE)

**Cleaning Steps:**
1. Trim strings
2. Fill missing numeric fields with 0
3. Round revenue to 2 decimals
4. Remove duplicates by item_id

**DQ Checks:**
- item_id IS NOT NULL
- units_sold >= 0
- revenue >= 0
- sale_date IS NOT NULL AND <= current_date()

### ETL Pipeline 3: Competitor Sales

**Input Schema:**
- `seller_id` (STRING)
- `item_id` (STRING)
- `units_sold` (INT)
- `revenue` (DOUBLE)
- `marketplace_price` (DOUBLE)
- `sale_date` (DATE)

**Cleaning Steps:**
1. Trim strings
2. Fill missing numeric fields with 0
3. Round revenue and price to 2 decimals
4. Remove duplicates by (seller_id, item_id)

**DQ Checks:**
- item_id IS NOT NULL
- seller_id IS NOT NULL
- units_sold >= 0
- revenue >= 0
- marketplace_price >= 0
- sale_date IS NOT NULL AND <= current_date()

### Consumption Layer: Recommendations

**Business Logic:**

1. **Aggregate Sales Data:**
   - Aggregate company sales by item_id
   - Aggregate competitor sales by item_id
   - Combine to get total units sold

2. **Identify Top-Selling Items:**
   - Rank items by category
   - Select top 10 per category

3. **Generate Recommendations:**
   - For each seller, find missing items from top-selling list
   - Calculate:
     - `expected_units_sold = total_units_sold / num_sellers`
     - `expected_revenue = expected_units_sold * market_price`

4. **Output:**
   - CSV with columns: seller_id, item_id, item_name, category, market_price, expected_units_sold, expected_revenue

---

## Data Quality Checks

All invalid records are moved to the quarantine zone with the following information:

- `dataset_name`: Source dataset name
- Original record fields
- `dq_failure_reason`: Comma-separated list of DQ failures
- `quarantine_timestamp`: When the record was quarantined

Example quarantine reasons:
- `seller_id_null`
- `item_id_null`
- `price_invalid`
- `stock_invalid`
- `sale_date_invalid`

---

## Output

### Hudi Tables (Parquet format)

Located in `processed/`:
- `seller_catalog_hudi/`
- `company_sales_hudi/`
- `competitor_sales_hudi/`

### Recommendations CSV

Located in `processed/recommendations_csv/seller_recommend_data.csv`

**Columns:**
- seller_id
- item_id
- item_name
- category
- market_price
- expected_units_sold
- expected_revenue

---

## Troubleshooting

### Issue 1: Out of Memory Error

**Solution:** Increase Spark memory:
```bash
spark-submit --driver-memory 4g --executor-memory 4g ...
```

### Issue 2: Hudi Table Not Found

**Solution:** Ensure ETL pipelines ran successfully before consumption layer.

### Issue 3: Permission Denied

**Solution:** Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Issue 4: Java Not Found

**Solution:** Set JAVA_HOME:
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

### Issue 5: PySpark Import Error

**Solution:** Set PYTHONPATH:
```bash
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip
```

---

## Configuration

The `configs/ecomm_prod.yml` file contains all paths. Update paths as needed for your environment.

**Note:** The configuration follows the assignment requirement of containing only input/output paths.

---

## Testing with Dirty Data

To test with dirty datasets, update `configs/ecomm_prod.yml`:

```yaml
seller_catalog:
  input_path: "/path/to/raw/seller_catalog_dirty.csv"
```

Then run the pipelines. Invalid records will be quarantined.

---

## Performance Considerations

- **Partitioning:** For large datasets, consider partitioning Hudi tables
- **Caching:** Cache DataFrames if used multiple times
- **Coalesce:** Adjust number of partitions based on data size
- **Broadcast Joins:** Use for small lookup tables

---

## Future Enhancements

1. **Incremental Processing:** Support daily incremental loads
2. **Data Lineage:** Track data lineage and transformations
3. **Monitoring:** Add metrics and monitoring dashboards
4. **Orchestration:** Use Airflow for pipeline scheduling
5. **S3 Support:** Add S3 support for cloud deployment

---

## Contact

**Student:** 2025EM1100026
**Course:** MSc Data Science & AI
**Assignment:** Data Storage and Pipeline - Assignment #1

---

**Note:** This is a production-ready implementation with complete error handling, logging, and data quality checks. The system is designed to be scalable, maintainable, and follows best practices for data engineering.
