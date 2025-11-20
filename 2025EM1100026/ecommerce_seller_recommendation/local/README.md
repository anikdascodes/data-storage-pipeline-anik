# Assignment #1: E-commerce Top-Seller Items Recommendation System

## Student Information

**Name:** Anik Das
**Roll Number:** 2025EM1100026
**Course:** Data Storage and Pipeline
**Program:** MSc Data Science & AI

---

## Project Overview

This project implements a recommendation system for sellers on an e-commerce platform. The system analyzes internal sales data and competitor data to recommend top-selling items that sellers currently don't have in their catalogs, helping them increase revenue and profit.

### Key Features

- **3 ETL Pipelines** for data ingestion, cleaning, and validation
- **Apache Hudi 0.15.0** for incremental data lake storage with schema evolution
- **Medallion Architecture** with Bronze → Silver → Gold layers
- **Data Quality Checks** with quarantine zone for invalid records
- **Consumption Layer** for generating actionable recommendations
- **Dockerized** for easy deployment and testing

---

## Project Structure

As per assignment requirements:

```
2025EM1100026/ecommerce_seller_recommendation/local/
│
├── configs/
│   └── ecomm_prod.yml              # Configuration file (input/output paths only)
│
├── src/
│   ├── etl_seller_catalog.py       # ETL pipeline for seller catalog data
│   ├── etl_company_sales.py        # ETL pipeline for company sales data
│   ├── etl_competitor_sales.py     # ETL pipeline for competitor sales data
│   └── consumption_recommendation.py # Consumption layer for recommendations
│
├── scripts/
│   ├── etl_seller_catalog_spark_submit.sh       # Spark submit for seller catalog
│   ├── etl_company_sales_spark_submit.sh        # Spark submit for company sales
│   ├── etl_competitor_sales_spark_submit.sh     # Spark submit for competitor sales
│   ├── consumption_recommendation_spark_submit.sh # Spark submit for consumption
│   └── run_all_pipelines.sh                     # Helper: Run all 4 pipelines
│
├── raw/                            # Input CSV files
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── processed/                      # Output: Hudi tables and recommendation CSV
│   ├── seller_catalog_hudi/
│   ├── company_sales_hudi/
│   ├── competitor_sales_hudi/
│   └── recommendations_csv/
│
├── quarantine/                     # Invalid records with failure reasons
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── Dockerfile                      # Docker image configuration
├── docker-compose.yml              # Docker orchestration for easy testing
├── docker-entrypoint.sh            # Auto-execution script
├── verify_outputs.sh               # Output verification
├── requirements.txt                # Python dependencies
└── README.md                       # This file
```

---

## Technology Stack

- **Apache Spark 3.5.0** - Distributed data processing
- **Apache Hudi 0.15.0** - Incremental data lake with ACID transactions
- **PySpark** - Python API for Spark
- **Docker** - Containerization
- **Python 3.10+** - Core programming language

---

## How to Run the Assignment

### ⭐ Option 1: Using Docker (Recommended for Reviewers)

This is the **easiest and fastest** way to run and test the complete assignment. Everything runs automatically with one command!

#### Prerequisites
- Docker installed
- Docker Compose installed

#### Steps

**1. Navigate to the project directory:**
```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local
```

**2. Run the complete pipeline (ONE COMMAND!):**
```bash
docker compose up --build
```

This will:
- Build the Docker image with all dependencies (Spark 3.5.0, Java 11, Python, Hudi packages)
- Run all 3 ETL pipelines automatically
- Run the consumption layer to generate recommendations
- Verify all outputs
- Display detailed execution logs

**3. Expected output:**
```
================================================================
  E-commerce Recommendation System - Docker Container
  Student Roll No: 2025EM1100026
================================================================

✓ All pre-flight checks passed!

[1/4] Running Seller Catalog ETL Pipeline...
✓ Seller Catalog ETL completed successfully

[2/4] Running Company Sales ETL Pipeline...
✓ Company Sales ETL completed successfully

[3/4] Running Competitor Sales ETL Pipeline...
✓ Competitor Sales ETL completed successfully

[4/4] Running Recommendations Pipeline...
✓ Recommendations Pipeline completed successfully

================================================================
✓ All 4 pipelines completed successfully!
================================================================
```

**4. Verify outputs (optional):**
```bash
docker compose exec ecommerce-recommendation bash /app/verify_outputs.sh
```

**5. Clean up:**
```bash
docker compose down
```

**Total Execution Time:** 15-20 minutes (including build time)

---

### Option 2: Manual Execution (Local Environment)

If you prefer to run without Docker:

#### Prerequisites
- Apache Spark 3.5.0 installed
- Java 11+ installed
- Python 3.10+ installed
- Required packages: `pyspark`, `pyyaml`

#### Installation

**1. Install Python dependencies:**
```bash
pip install -r requirements.txt
```

**2. Set environment variables:**
```bash
export SPARK_HOME=/path/to/spark-3.5.0
export PATH=$SPARK_HOME/bin:$PATH
```

#### Running Pipelines

**Run all pipelines at once:**
```bash
cd scripts
bash run_all_pipelines.sh
```

**Or run each pipeline separately:**

**Step 1: Run ETL Pipelines (in order)**
```bash
cd scripts
bash etl_seller_catalog_spark_submit.sh
bash etl_company_sales_spark_submit.sh
bash etl_competitor_sales_spark_submit.sh
```

**Step 2: Run Consumption Layer**
```bash
bash consumption_recommendation_spark_submit.sh
```

---

## Configuration File

The `configs/ecomm_prod.yml` contains all input and output paths (as per assignment requirements):

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

**Note:** Paths use `/app/` for Docker. Scripts auto-detect environment and adjust paths for local execution.

---

## Pipeline Details

### 1. ETL Pipeline: Seller Catalog (`etl_seller_catalog.py`)

**Input:** `raw/seller_catalog/seller_catalog_clean.csv`

**Data Cleaning:**
- Trim whitespace in all string columns
- Normalize item_name to Title Case
- Standardize category labels
- Remove duplicates based on (seller_id + item_id)
- Convert marketplace_price → DOUBLE, stock_qty → INT

**Data Quality Checks (6 rules):**
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

### 2. ETL Pipeline: Company Sales (`etl_company_sales.py`)

**Input:** `raw/company_sales/company_sales_clean.csv`

**Data Cleaning:**
- Trim strings
- Convert units_sold → INT, revenue → DOUBLE, sale_date → DATE
- Remove duplicates based on item_id
- Standardize date format

**Data Quality Checks (4 rules):**
- item_id IS NOT NULL
- units_sold >= 0
- revenue >= 0
- sale_date IS NOT NULL AND <= current_date()

**Outputs:**
- Valid records → `processed/company_sales_hudi/` (Hudi table, overwrite mode)
- Invalid records → `quarantine/company_sales/`

---

### 3. ETL Pipeline: Competitor Sales (`etl_competitor_sales.py`)

**Input:** `raw/competitor_sales/competitor_sales_clean.csv`

**Data Cleaning:**
- Trim strings and normalize casing
- Convert units_sold → INT, revenue → DOUBLE, marketplace_price → DOUBLE
- Convert sale_date → DATE
- Fill missing numeric fields with 0

**Data Quality Checks (6 rules):**
- item_id IS NOT NULL
- seller_id IS NOT NULL
- units_sold >= 0
- revenue >= 0
- marketplace_price >= 0
- sale_date IS NOT NULL AND <= current_date()

**Outputs:**
- Valid records → `processed/competitor_sales_hudi/` (Hudi table, overwrite mode)
- Invalid records → `quarantine/competitor_sales/`

---

### 4. Consumption Layer (`consumption_recommendation.py`)

**Inputs:** Reads 3 Hudi tables from ETL pipelines

**Data Transformation:**
- Aggregate company sales to find top-selling items per category
- Aggregate competitor sales to find top-selling items in market
- Compare each seller's catalog with top-selling items
- Identify missing items per seller

**Recommendation Calculation:**

For each missing item:
```
expected_units_sold = total_units_sold / number_of_sellers_selling_item
expected_revenue = expected_units_sold × marketplace_price
```

**Output Columns:**
- seller_id
- item_id
- item_name
- category
- market_price
- expected_units_sold
- expected_revenue

**Output:** `processed/recommendations_csv/seller_recommend_data.csv` (CSV, overwrite mode)

---

## Spark Submit Command Format

All pipelines use the following format (as per assignment requirements):

```bash
spark-submit \
  --packages org.apache.hudi:hudi-spark3.5-bundle_2.12:0.15.0,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.legacy.timeParserPolicy=LEGACY \
  <path-to-python-file>.py \
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

## Data Quality & Quarantine Zone

All records that fail DQ checks are moved to the quarantine zone with:
- Original record data
- `dq_failure_reason` column (e.g., "price_negative", "missing_item_id")
- `quarantine_timestamp`

This ensures data integrity and allows investigation of problematic records.

---

## Output Files

After successful execution:

### 1. Hudi Tables (ETL Outputs)
```
processed/
├── seller_catalog_hudi/     # Apache Hudi table (Parquet format)
├── company_sales_hudi/      # Apache Hudi table (Parquet format)
└── competitor_sales_hudi/   # Apache Hudi table (Parquet format)
```

### 2. Recommendations CSV (Consumption Output)
```
processed/recommendations_csv/
└── seller_recommend_data.csv  # Top recommendations per seller
```

### 3. Quarantine Zone
```
quarantine/
├── seller_catalog/          # Invalid seller catalog records
├── company_sales/           # Invalid company sales records
└── competitor_sales/        # Invalid competitor sales records
```

---

## Assignment Requirements Checklist

### ✅ ETL Ingestion (15 Marks)
- ✅ Read input datasets via YAML-configurable pipeline
- ✅ Apache Hudi for schema evolution and incremental upserts
- ✅ Data cleaning implemented for all 3 datasets
- ✅ Data Quality checks with quarantine zone
- ✅ Quarantine zone includes failure reasons
- ✅ Medallion architecture (Bronze → Silver → Gold)
- ✅ 3 separate pipelines for 3 datasets
- ✅ Final output: 3 Hudi tables with overwrite mode

### ✅ Consumption Layer (5 Marks)
- ✅ Medallion architecture followed
- ✅ Reads 3 input Hudi tables
- ✅ Data transformations and aggregations
- ✅ Recommendation calculation with expected revenue
- ✅ Output to CSV with overwrite mode

### ✅ Configuration (Required)
- ✅ `ecomm_prod.yml` contains only input/output paths
- ✅ Follows assignment sample format

### ✅ Project Structure (Required)
- ✅ Follows exact structure specified in assignment
- ✅ All required files present in correct locations

---

## Technical Implementation Details

**Hudi Configuration:**
- Table Type: COPY_ON_WRITE (COW)
- Operation: Upsert (idempotent writes)
- Key Generator: NonpartitionedKeyGenerator
- Write Mode: Overwrite (for final ETL output)

**Spark Configuration:**
- Serializer: KryoSerializer
- Time Parser Policy: LEGACY
- Log Level: WARN

**Environment Detection:**
- Scripts auto-detect Docker (`/app/`) vs local environment
- Paths adjust automatically based on runtime environment

---

## Troubleshooting

### Docker build takes long
**Solution:** First build may take 10-12 minutes. Subsequent builds use cache (~3 minutes).

### PATH_NOT_FOUND errors
**Solution:** Ensure raw data files exist in `raw/` folder before running.

### Out of memory errors
**Solution:** Increase Docker memory in Docker Desktop settings (recommend 4GB+).

### Permission denied on scripts
**Solution:** Run `chmod +x scripts/*.sh` to make scripts executable.

---

## Why Docker?

While not required by the assignment, Docker is included to:
- **For Reviewers:** Test the complete assignment with a single command
- **For Students:** Ensure consistent environment across different machines
- **For Production:** Production-ready deployment approach

The core assignment (Python code, configs, scripts) fully complies with the requirements and can run without Docker.

---

## Contact

**Student:** Anik Das
**Roll No:** 2025EM1100026
**Program:** MSc Data Science & AI

---

## Acknowledgments

This assignment demonstrates:
- Apache Spark for distributed data processing
- Apache Hudi for data lake management
- Medallion architecture for data pipelines
- Data quality frameworks with quarantine patterns
- Production-ready ETL implementations

---

**Assignment Submission Date:** November 2025
**Version:** 1.0
**Status:** ✅ Ready for Submission
