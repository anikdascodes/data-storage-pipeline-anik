# Assignment #1: E-commerce Top-Seller Items Recommendation System

## Student Information

**Name:** Anik Das
**Roll Number:** 2025EM1100026
**Program:** MSc Data Science & AI
**Course:** Data Storage and Pipeline

---

## Overview

This project implements an end-to-end data pipeline for an e-commerce recommendation system. The system analyzes sales data from multiple sources to recommend top-selling items that sellers should add to their catalogs to maximize revenue.

### Business Problem

In an e-commerce marketplace with multiple sellers:
- Each seller has their own catalog of items
- Some items are top-selling but not available in all seller catalogs
- By analyzing internal and competitor sales data, we can recommend items that sellers are missing

This pipeline helps sellers identify revenue opportunities by recommending the top 10 selling items they don't currently offer.

---

## Technical Architecture

### Technology Stack
- **Apache Spark 3.5.0** - Distributed data processing engine
- **Apache Hudi 0.15.0** - Data lake storage with ACID transactions and schema evolution
- **PySpark** - Python API for Spark
- **Docker** - Containerization for consistent environments
- **Python 3.10+** - Core programming language

### Architecture Pattern
- **Medallion Architecture:** Bronze (raw) → Silver (cleaned) → Gold (consumption-ready)
- **Data Quality Framework:** Validation rules with quarantine zone for invalid records
- **Incremental Processing:** Hudi tables support upserts and schema evolution

---

## Project Structure

Following the assignment requirements:

```
2025EM1100026/ecommerce_seller_recommendation/local/
│
├── configs/
│   └── ecomm_prod.yml                    # Input/output paths configuration
│
├── src/
│   ├── etl_seller_catalog.py             # ETL for seller catalog data
│   ├── etl_company_sales.py              # ETL for company sales data
│   ├── etl_competitor_sales.py           # ETL for competitor sales data
│   └── consumption_recommendation.py     # Consumption layer - recommendations
│
├── scripts/
│   ├── etl_seller_catalog_spark_submit.sh
│   ├── etl_company_sales_spark_submit.sh
│   ├── etl_competitor_sales_spark_submit.sh
│   ├── consumption_recommendation_spark_submit.sh
│   └── run_all_pipelines.sh              # Helper to run all pipelines
│
├── raw/                                   # Input CSV files
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── processed/                             # Output: Hudi tables and CSV
│   ├── seller_catalog_hudi/
│   ├── company_sales_hudi/
│   ├── competitor_sales_hudi/
│   └── recommendations_csv/
│
├── quarantine/                            # Invalid records with failure reasons
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── Dockerfile                             # Docker image configuration
├── docker-compose.yml                     # Docker orchestration
├── docker-entrypoint.sh                   # Auto-execution entry point
├── verify_outputs.sh                      # Output verification script
├── requirements.txt                       # Python dependencies
└── README.md                              # This file
```

---

## How to Run

### Option 1: Docker (Recommended)

The easiest way to run all pipelines with a single command.

#### Prerequisites
- Docker installed and running
- Docker Compose installed
- At least 4GB RAM available for Docker

#### Steps

1. **Navigate to project directory:**
   ```bash
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   ```

2. **Run all pipelines:**
   ```bash
   docker compose up --build
   ```

   This single command will:
   - Build Docker image with Spark 3.5.0, Java 11, Python, and all dependencies
   - Execute all 3 ETL pipelines sequentially
   - Execute consumption layer to generate recommendations
   - Verify outputs
   - Display execution logs

3. **Expected output:**
   ```
   ================================================================
     E-commerce Recommendation System - Docker Container
     Student Roll No: 2025EM1100026
   ================================================================

   [1/4] Running Seller Catalog ETL Pipeline...
   ✓ Seller Catalog ETL completed

   [2/4] Running Company Sales ETL Pipeline...
   ✓ Company Sales ETL completed

   [3/4] Running Competitor Sales ETL Pipeline...
   ✓ Competitor Sales ETL completed

   [4/4] Running Recommendations Pipeline...
   ✓ Recommendations Pipeline completed

   ✓ All pipelines completed successfully!
   ================================================================
   ```

4. **Verify outputs (optional):**
   ```bash
   docker compose exec ecommerce-recommendation bash /app/verify_outputs.sh
   ```

5. **Clean up:**
   ```bash
   docker compose down
   ```

**Execution Time:** 15-20 minutes total

---

### Option 2: Local Execution

For running pipelines individually or without Docker.

#### Prerequisites
- Apache Spark 3.5.0 installed
- Java 11 or higher
- Python 3.10 or higher
- Python packages: `pyspark`, `pyyaml`

#### Setup

1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set environment variables:**
   ```bash
   export SPARK_HOME=/path/to/spark-3.5.0
   export PATH=$SPARK_HOME/bin:$PATH
   ```

#### Execution

**Run all pipelines in sequence:**
```bash
cd scripts
bash run_all_pipelines.sh
```

**Or run each pipeline individually:**

```bash
# Step 1: ETL Pipelines (must run in order)
cd scripts
bash etl_seller_catalog_spark_submit.sh
bash etl_company_sales_spark_submit.sh
bash etl_competitor_sales_spark_submit.sh

# Step 2: Consumption Layer
bash consumption_recommendation_spark_submit.sh
```

---

## Configuration

The `configs/ecomm_prod.yml` file contains all input and output paths:

```yaml
seller_catalog:
  input_path: "/app/raw/seller_catalog/seller_catalog_clean.csv"
  hudi_output_path: "/app/processed/seller_catalog_hudi/"
  quarantine_path: "/app/quarantine/seller_catalog/"

company_sales:
  input_path: "/app/raw/company_sales/company_sales_clean.csv"
  hudi_output_path: "/app/processed/company_sales_hudi/"
  quarantine_path: "/app/quarantine/company_sales/"

competitor_sales:
  input_path: "/app/raw/competitor_sales/competitor_sales_clean.csv"
  hudi_output_path: "/app/processed/competitor_sales_hudi/"
  quarantine_path: "/app/quarantine/competitor_sales/"

recommendation:
  seller_catalog_hudi: "/app/processed/seller_catalog_hudi/"
  company_sales_hudi: "/app/processed/company_sales_hudi/"
  competitor_sales_hudi: "/app/processed/competitor_sales_hudi/"
  output_csv: "/app/processed/recommendations_csv/seller_recommend_data.csv"
```

**Note:** Paths use `/app/` for Docker environment. Shell scripts automatically detect the environment and adjust paths for local execution.

---

## Pipeline Implementation

### 1. ETL Pipeline: Seller Catalog

**File:** `src/etl_seller_catalog.py`
**Input:** `raw/seller_catalog/seller_catalog_clean.csv`

**Input Schema:**
- seller_id (STRING) - Unique seller identifier
- item_id (STRING) - Unique item identifier
- item_name (STRING) - Item name
- category (STRING) - Item category
- marketplace_price (DOUBLE) - Selling price
- stock_qty (INT) - Stock quantity

**Data Cleaning:**
1. Trim whitespace from all string columns
2. Normalize item_name to Title Case
3. Standardize category labels (e.g., "Electronics", "Apparel")
4. Remove duplicates based on (seller_id + item_id)
5. Convert marketplace_price to DOUBLE type
6. Convert stock_qty to INT type
7. Fill missing stock_qty with 0

**Data Quality Checks:**
- seller_id IS NOT NULL
- item_id IS NOT NULL
- marketplace_price >= 0
- stock_qty >= 0
- item_name IS NOT NULL
- category IS NOT NULL

**Outputs:**
- Valid records → `processed/seller_catalog_hudi/` (Hudi table, overwrite mode)
- Invalid records → `quarantine/seller_catalog/` (with failure reasons)

---

### 2. ETL Pipeline: Company Sales

**File:** `src/etl_company_sales.py`
**Input:** `raw/company_sales/company_sales_clean.csv`

**Input Schema:**
- item_id (STRING) - Unique item identifier
- units_sold (INT) - Number of units sold
- revenue (DOUBLE) - Total revenue
- sale_date (DATE) - Date of sale

**Data Cleaning:**
1. Trim whitespace from string columns
2. Convert units_sold to INT type
3. Convert revenue to DOUBLE type
4. Convert sale_date to DATE type
5. Remove duplicates based on item_id
6. Fill missing units_sold with 0
7. Fill missing revenue with 0
8. Standardize date format

**Data Quality Checks:**
- item_id IS NOT NULL
- units_sold >= 0
- revenue >= 0
- sale_date IS NOT NULL AND sale_date <= current_date()

**Outputs:**
- Valid records → `processed/company_sales_hudi/` (Hudi table, overwrite mode)
- Invalid records → `quarantine/company_sales/` (with failure reasons)

---

### 3. ETL Pipeline: Competitor Sales

**File:** `src/etl_competitor_sales.py`
**Input:** `raw/competitor_sales/competitor_sales_clean.csv`

**Input Schema:**
- seller_id (STRING) - Competitor seller identifier
- item_id (STRING) - Unique item identifier
- units_sold (INT) - Number of units sold
- revenue (DOUBLE) - Total revenue
- marketplace_price (DOUBLE) - Competitor's selling price
- sale_date (DATE) - Date of sale

**Data Cleaning:**
1. Trim whitespace from string columns
2. Normalize casing for consistency
3. Convert units_sold to INT type
4. Convert revenue to DOUBLE type
5. Convert marketplace_price to DOUBLE type
6. Convert sale_date to DATE type
7. Remove duplicates based on (seller_id + item_id)
8. Fill missing numeric fields with 0

**Data Quality Checks:**
- item_id IS NOT NULL
- seller_id IS NOT NULL
- units_sold >= 0
- revenue >= 0
- marketplace_price >= 0
- sale_date IS NOT NULL AND sale_date <= current_date()

**Outputs:**
- Valid records → `processed/competitor_sales_hudi/` (Hudi table, overwrite mode)
- Invalid records → `quarantine/competitor_sales/` (with failure reasons)

---

### 4. Consumption Layer: Recommendations

**File:** `src/consumption_recommendation.py`
**Inputs:** Reads all 3 Hudi tables created by ETL pipelines

**Business Logic:**

1. **Aggregate Sales Data:**
   - Combine company sales and competitor sales by item_id
   - Calculate total units sold per item across all sources
   - Identify marketplace price for each item

2. **Identify Top-Selling Items:**
   - Rank items by total units sold within each category
   - Select top 10 items per category

3. **Generate Recommendations:**
   - For each seller, find items from top 10 that are missing from their catalog
   - Calculate metrics for each missing item:
     ```
     expected_units_sold = total_units_sold / number_of_sellers_selling_item
     expected_revenue = expected_units_sold × marketplace_price
     ```

4. **Output Recommendations:**
   - Generate CSV file with recommendations for all sellers

**Output Schema:**
- seller_id - Seller identifier
- item_id - Recommended item identifier
- item_name - Item name
- category - Item category
- market_price - Current market price
- expected_units_sold - Predicted sales volume
- expected_revenue - Predicted revenue if seller adds this item

**Output:** `processed/recommendations_csv/seller_recommend_data.csv` (CSV, overwrite mode)

---

## Spark Submit Configuration

All pipelines use the following Spark submit format:

```bash
spark-submit \
  --packages org.apache.hudi:hudi-spark3.5-bundle_2.12:0.15.0,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.legacy.timeParserPolicy=LEGACY \
  src/<pipeline_file>.py \
  --config configs/ecomm_prod.yml
```

**Spark Session Configuration:**
```python
def get_spark_session(app_name: str) -> SparkSession:
    spark = (
        SparkSession.builder
        .appName(app_name)
        .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
        .config("spark.sql.legacy.timeParserPolicy", "LEGACY")
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")
    return spark
```

---

## Data Quality and Quarantine Zone

### Quarantine Mechanism

All records that fail any data quality check are moved to the quarantine zone with:
- **Original record data** - All original fields preserved
- **dq_failure_reason** - Descriptive failure reason (e.g., "price_negative", "missing_item_id")
- **quarantine_timestamp** - When the record was quarantined

This approach ensures:
- Data integrity in main tables
- No data loss - invalid records are preserved
- Easy investigation and correction of data issues
- Audit trail for data quality monitoring

### Quarantine Location

```
quarantine/
├── seller_catalog/          # Invalid seller catalog records
├── company_sales/           # Invalid company sales records
└── competitor_sales/        # Invalid competitor sales records
```

---

## Output Files

After successful execution, the following outputs are generated:

### Hudi Tables (ETL Outputs)

```
processed/
├── seller_catalog_hudi/     # Cleaned seller catalog data
├── company_sales_hudi/      # Cleaned company sales data
└── competitor_sales_hudi/   # Cleaned competitor sales data
```

**Format:** Apache Hudi tables (Parquet format)
**Table Type:** COPY_ON_WRITE (COW)
**Features:** ACID transactions, schema evolution, incremental upserts

### Recommendations CSV (Consumption Output)

```
processed/recommendations_csv/
└── seller_recommend_data.csv  # Recommendations for all sellers
```

**Format:** CSV file
**Content:** Top 10 item recommendations per seller with expected revenue

---

## Implementation Details

### Apache Hudi Configuration

Each ETL pipeline writes to Hudi tables with the following configuration:

```python
hudi_options = {
    "hoodie.table.name": "table_name",
    "hoodie.datasource.write.recordkey.field": "key_field(s)",
    "hoodie.datasource.write.operation": "upsert",
    "hoodie.datasource.write.table.type": "COPY_ON_WRITE",
    "hoodie.datasource.write.keygenerator.class": "org.apache.hudi.keygen.NonpartitionedKeyGenerator"
}
```

**Key Features:**
- **Upsert Operation:** Ensures idempotent writes
- **Copy-On-Write:** Optimized for read-heavy workloads
- **Schema Evolution:** Automatically handles schema changes
- **Overwrite Mode:** Final output overwrites previous data

### Environment Detection

Shell scripts automatically detect the runtime environment:

```bash
if [ -d "/app" ] && [ -f "/app/configs/ecomm_prod.yml" ]; then
    BASE_DIR="/app"  # Docker environment
else
    # Local environment - detect from script location
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi
```

This allows the same scripts to work in both Docker and local environments without modification.

---

## Assignment Requirements Implementation

### ETL Ingestion

✓ **Read input datasets via YAML configuration**
  - All input/output paths configured in `configs/ecomm_prod.yml`
  - Each pipeline reads configuration from single YAML file

✓ **Apache Hudi for schema evolution and incremental processing**
  - Hudi 0.15.0 with Spark 3.5 bundle
  - Upsert operations for idempotent writes
  - COPY_ON_WRITE table type for optimal read performance

✓ **Data cleaning implemented for all datasets**
  - Seller Catalog: Trim, normalize, deduplicate, type conversion
  - Company Sales: Trim, type conversion, fill missing values
  - Competitor Sales: Trim, normalize, type conversion, fill missing values

✓ **Data quality checks with validation rules**
  - Seller Catalog: 6 validation rules
  - Company Sales: 4 validation rules
  - Competitor Sales: 6 validation rules

✓ **Quarantine zone for invalid records**
  - Separate quarantine path for each dataset
  - Records include failure reasons and timestamps
  - No data loss - all records preserved

✓ **Medallion architecture (Bronze → Silver → Gold)**
  - Bronze: Raw CSV files in `raw/`
  - Silver: Cleaned Hudi tables in `processed/`
  - Gold: Consumption-ready CSV in `processed/recommendations_csv/`

✓ **Three separate ETL pipelines**
  - Pipeline 1: Seller Catalog ETL
  - Pipeline 2: Company Sales ETL
  - Pipeline 3: Competitor Sales ETL

✓ **Hudi tables with overwrite mode**
  - All ETL pipelines write final output with overwrite mode
  - Ensures clean state for each run

### Consumption Layer

✓ **Reads three Hudi tables from ETL outputs**
  - seller_catalog_hudi
  - company_sales_hudi
  - competitor_sales_hudi

✓ **Data transformations and aggregations**
  - Aggregate sales by item and category
  - Identify top-selling items
  - Compare seller catalogs with top items

✓ **Recommendation calculation with business logic**
  - Calculate expected units sold per item
  - Calculate expected revenue
  - Generate top 10 recommendations per seller

✓ **CSV output with overwrite mode**
  - Final recommendations written to CSV
  - Overwrite mode ensures clean output

### Configuration

✓ **YAML file contains only input/output paths**
  - No hardcoded business logic
  - Paths for all inputs, outputs, and quarantine zones
  - Follows assignment sample format exactly

### Project Structure

✓ **Follows exact assignment structure**
  - configs/ with ecomm_prod.yml
  - src/ with 4 Python files
  - scripts/ with 4 spark-submit scripts
  - README.md with documentation

---

## Troubleshooting

### Docker Issues

**Build takes too long:**
- First build may take 10-12 minutes due to Spark download
- Subsequent builds use cache and complete in ~3 minutes

**Out of memory errors:**
- Increase Docker memory allocation to at least 4GB
- Go to Docker Desktop → Settings → Resources → Memory

**Permission denied on scripts:**
```bash
chmod +x scripts/*.sh
chmod +x docker-entrypoint.sh
chmod +x verify_outputs.sh
```

### Execution Issues

**PATH_NOT_FOUND errors:**
- Ensure raw CSV files exist in `raw/` directory before running
- Check that file names match configuration

**Hudi table not found:**
- Ensure ETL pipelines completed successfully before running consumption layer
- Run pipelines in order: seller_catalog → company_sales → competitor_sales → consumption

**Java not found:**
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

**Spark not found:**
```bash
export SPARK_HOME=/path/to/spark-3.5.0
export PATH=$SPARK_HOME/bin:$PATH
```

---

## Testing

### Verify Configuration
```bash
cat configs/ecomm_prod.yml
```

### Check Input Data
```bash
ls -lh raw/seller_catalog/
ls -lh raw/company_sales/
ls -lh raw/competitor_sales/
```

### Verify Outputs
```bash
# Check Hudi tables
ls -lh processed/seller_catalog_hudi/
ls -lh processed/company_sales_hudi/
ls -lh processed/competitor_sales_hudi/

# Check recommendations
ls -lh processed/recommendations_csv/
head -20 processed/recommendations_csv/seller_recommend_data.csv

# Check quarantine records
ls -lh quarantine/seller_catalog/
ls -lh quarantine/company_sales/
ls -lh quarantine/competitor_sales/
```

---

## Key Design Decisions

### Why Apache Hudi?
- **Schema Evolution:** Automatically handles schema changes without pipeline modifications
- **ACID Transactions:** Ensures data consistency
- **Incremental Processing:** Supports efficient upsert operations
- **Time Travel:** Can query historical data snapshots

### Why Medallion Architecture?
- **Separation of Concerns:** Raw, cleaned, and consumption data clearly separated
- **Data Quality:** Each layer has specific quality standards
- **Reproducibility:** Can rebuild downstream layers from upstream data
- **Debugging:** Easy to identify where issues occur in pipeline

### Why Quarantine Zone?
- **No Data Loss:** Invalid records preserved for investigation
- **Data Quality Monitoring:** Track types and frequency of data issues
- **Audit Trail:** Know when and why records were rejected
- **Reprocessing:** Can fix and reprocess quarantined records

---

## Performance Considerations

- **Spark Serialization:** Using KryoSerializer for better performance
- **Hudi Table Type:** COPY_ON_WRITE optimized for read-heavy workloads
- **Deduplication:** Applied before writing to Hudi to reduce storage
- **Logging:** Set to WARN level to reduce overhead

---

## Future Enhancements

- **Incremental Processing:** Support daily incremental loads instead of full overwrite
- **Partitioning:** Partition Hudi tables by category or date for better query performance
- **Data Lineage:** Track data lineage and transformation history
- **Monitoring:** Add metrics dashboards for pipeline monitoring
- **S3 Support:** Enable S3 storage for cloud deployment
- **Orchestration:** Integrate with Apache Airflow for scheduling

---

## Contact

For questions or clarifications about this implementation:

**Student:** Anik Das
**Roll Number:** 2025EM1100026
**Program:** MSc Data Science & AI

---

**Submission Date:** November 2025
**Version:** 1.0
