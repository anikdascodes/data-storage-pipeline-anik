# E-commerce Recommendation System - Project Summary

**Student:** MSc Data Science & AI
**Roll No:** 2025EM1100026
**Assignment:** Data Storage and Pipeline - Assignment #1

---

## Completion Status: ✅ COMPLETE

All components of the assignment have been successfully implemented and pushed to the branch:
**claude/ecommerce-recommendation-system-01RxhaFbUeGUCoCUfmDAJjA8**

---

## What Was Built

### 1. ETL Pipelines (3 Separate Pipelines)

#### Pipeline 1: Seller Catalog ETL
- **File:** `src/etl_seller_catalog.py`
- **Purpose:** Process seller catalog data
- **Features:**
  - Data extraction from CSV
  - Data cleaning (trim, normalize, deduplicate)
  - DQ checks (6 validation rules)
  - Quarantine for invalid records
  - Hudi table output (overwrite mode)

#### Pipeline 2: Company Sales ETL
- **File:** `src/etl_company_sales.py`
- **Purpose:** Process company sales data
- **Features:**
  - Data extraction from CSV
  - Data cleaning (trim, type conversion)
  - DQ checks (4 validation rules)
  - Quarantine for invalid records
  - Hudi table output (overwrite mode)

#### Pipeline 3: Competitor Sales ETL
- **File:** `src/etl_competitor_sales.py`
- **Purpose:** Process competitor sales data
- **Features:**
  - Data extraction from CSV
  - Data cleaning (trim, normalize, type conversion)
  - DQ checks (6 validation rules)
  - Quarantine for invalid records
  - Hudi table output (overwrite mode)

### 2. Consumption Layer

- **File:** `src/consumption_recommendation.py`
- **Purpose:** Generate seller recommendations
- **Features:**
  - Read from 3 Hudi tables
  - Identify top 10 selling items per category
  - Find missing items for each seller
  - Calculate expected revenue
  - Output to CSV

### 3. Configuration

- **File:** `configs/ecomm_prod.yml`
- **Purpose:** YAML-based configuration
- **Contains:** Input/output paths only (as per assignment requirement)

### 4. Execution Scripts

- `scripts/etl_seller_catalog_spark_submit.sh`
- `scripts/etl_company_sales_spark_submit.sh`
- `scripts/etl_competitor_sales_spark_submit.sh`
- `scripts/consumption_recommendation_spark_submit.sh`
- `scripts/run_all_pipelines.sh` (master script)

### 5. Docker Setup

- **Dockerfile:** Complete Spark + Hudi + Python environment
- **docker-compose.yml:** Easy deployment
- **pyproject.toml:** uv package configuration
- **requirements.txt:** Python dependencies

### 6. Documentation

- **README.md:** Comprehensive setup and execution guide

---

## Project Structure

```
2025EM1100026/ecommerce_seller_recommendation/local/
│
├── configs/
│   └── ecomm_prod.yml              # Configuration (paths only)
│
├── src/
│   ├── etl_seller_catalog.py      # ETL Pipeline 1
│   ├── etl_company_sales.py       # ETL Pipeline 2
│   ├── etl_competitor_sales.py    # ETL Pipeline 3
│   └── consumption_recommendation.py  # Consumption Layer
│
├── scripts/
│   ├── etl_seller_catalog_spark_submit.sh
│   ├── etl_company_sales_spark_submit.sh
│   ├── etl_competitor_sales_spark_submit.sh
│   ├── consumption_recommendation_spark_submit.sh
│   └── run_all_pipelines.sh       # Master script (runs all 4)
│
├── raw/                            # Input datasets
│   ├── seller_catalog/
│   │   └── seller_catalog_clean.csv
│   ├── company_sales/
│   │   └── company_sales_clean.csv
│   ├── competitor_sales/
│   │   └── competitor_sales_clean.csv
│   ├── seller_catalog_dirty.csv   # For testing DQ checks
│   ├── company_sales_dirty.csv
│   └── competitor_sales_dirty.csv
│
├── processed/                      # Outputs (created at runtime)
│   ├── seller_catalog_hudi/       # Hudi table 1
│   ├── company_sales_hudi/        # Hudi table 2
│   ├── competitor_sales_hudi/     # Hudi table 3
│   └── recommendations_csv/       # Final CSV output
│
├── quarantine/                     # Bad data (created at runtime)
│   ├── seller_catalog/
│   ├── company_sales/
│   └── competitor_sales/
│
├── Dockerfile                      # Docker setup
├── docker-compose.yml
├── pyproject.toml                  # uv configuration
├── requirements.txt                # Python dependencies
├── .gitignore
└── README.md                       # Documentation
```

---

## How to Execute

### Option 1: Using Docker (Recommended for Reviewer)

```bash
# Navigate to project directory
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Build Docker image
docker-compose build

# Start container
docker-compose up -d

# Access container
docker-compose exec ecommerce-recommendation bash

# Run all pipelines
bash /app/scripts/run_all_pipelines.sh

# Or run individually:
bash /app/scripts/etl_seller_catalog_spark_submit.sh
bash /app/scripts/etl_company_sales_spark_submit.sh
bash /app/scripts/etl_competitor_sales_spark_submit.sh
bash /app/scripts/consumption_recommendation_spark_submit.sh
```

### Option 2: Local Execution (If Spark Already Installed)

```bash
# Navigate to project directory
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Run all pipelines
bash scripts/run_all_pipelines.sh

# Or run individually (in order):
bash scripts/etl_seller_catalog_spark_submit.sh
bash scripts/etl_company_sales_spark_submit.sh
bash scripts/etl_competitor_sales_spark_submit.sh
bash scripts/consumption_recommendation_spark_submit.sh
```

---

## Expected Outputs

After successful execution:

### 1. Hudi Tables (Parquet format)
Located in `processed/`:
- `seller_catalog_hudi/` - Clean seller catalog
- `company_sales_hudi/` - Clean company sales
- `competitor_sales_hudi/` - Clean competitor sales

### 2. Recommendations CSV
Located in `processed/recommendations_csv/seller_recommend_data.csv`

Columns:
- seller_id
- item_id
- item_name
- category
- market_price
- expected_units_sold
- expected_revenue

### 3. Quarantine Data (Parquet format)
Located in `quarantine/`:
- `seller_catalog/` - Invalid seller catalog records
- `company_sales/` - Invalid company sales records
- `competitor_sales/` - Invalid competitor sales records

Each quarantine record includes:
- Original data fields
- dataset_name
- dq_failure_reason (e.g., "price_invalid, stock_invalid")
- quarantine_timestamp

---

## Key Features Implemented

### ✅ Assignment Requirements Met

1. **ETL Ingestion (15 Marks):**
   - ✅ 3 separate ETL pipelines
   - ✅ YAML-configurable (paths only)
   - ✅ Apache Hudi for schema evolution and incremental upserts
   - ✅ Data cleaning as per specification
   - ✅ DQ checks as per specification
   - ✅ Quarantine zone handling
   - ✅ Medallion architecture
   - ✅ Hudi tables with overwrite mode

2. **Consumption Layer (5 Marks):**
   - ✅ Read from Hudi tables
   - ✅ Data transformations
   - ✅ Recommendation calculation
   - ✅ CSV output with overwrite mode

3. **Project Structure:**
   - ✅ Follows exact structure specified in assignment
   - ✅ configs/ with ecomm_prod.yml
   - ✅ src/ with 4 Python files
   - ✅ scripts/ with 4 spark-submit shell scripts

4. **Technical Stack:**
   - ✅ PySpark
   - ✅ Apache Hudi 0.15.0
   - ✅ Spark 3.5.0
   - ✅ YAML configuration
   - ✅ Docker & docker-compose

### 🚀 Additional Features (Beyond Requirements)

1. **Production-Ready:**
   - Comprehensive error handling
   - Detailed logging
   - Type hints in Python code
   - Modular, reusable functions

2. **Docker Setup:**
   - Complete containerization
   - uv for fast dependency management
   - One-command deployment

3. **Documentation:**
   - Comprehensive README
   - Inline code documentation
   - Clear execution instructions

4. **Developer Experience:**
   - Master script to run all pipelines
   - Clear separation of concerns
   - Easy to test and debug

---

## Testing

### Test with Clean Data (Default)
The configuration is set up to use clean datasets by default.

### Test with Dirty Data
To test DQ checks and quarantine functionality:

1. Edit `configs/ecomm_prod.yml`
2. Change paths to use dirty datasets:
   ```yaml
   seller_catalog:
     input_path: ".../raw/seller_catalog_dirty.csv"
   ```
3. Run pipelines
4. Check `quarantine/` directory for invalid records

---

## Technical Highlights

### Data Quality Framework
- Rule-based validation
- Detailed failure reasons
- Automatic quarantine
- No data loss

### Apache Hudi Integration
- COW (Copy-On-Write) table type
- NonpartitionedKeyGenerator for simplicity
- Upsert operations
- Schema evolution ready

### Scalability
- Configurable paths
- Modular design
- Docker-based deployment
- Can be extended to S3/HDFS

### Best Practices
- Separation of ETL and consumption
- Configuration-driven approach
- Comprehensive logging
- Error handling at each step

---

## For GitHub Codespaces / Local Testing

The project is ready to run in:
1. **GitHub Codespaces** - Just build Docker and run
2. **Local Machine** - Install Spark and run scripts
3. **Cloud Environment** - Deploy Docker container

All dependencies are managed via:
- **uv** for Python packages (faster than pip)
- **Docker** for complete environment isolation
- **requirements.txt** for reproducibility

---

## Submission Checklist

✅ Project structure follows assignment specification
✅ 3 ETL pipelines implemented
✅ 1 Consumption layer implemented
✅ 4 Spark submit scripts created
✅ YAML configuration (paths only)
✅ Data cleaning implemented
✅ DQ checks implemented
✅ Quarantine zone implemented
✅ Apache Hudi integration
✅ Medallion architecture
✅ Docker setup with uv
✅ Comprehensive README
✅ All code committed and pushed
✅ Clean datasets included
✅ Dirty datasets included for testing

---

## Notes for Reviewer

1. **No Installation Required (Docker Method):**
   - Simply run `docker-compose build && docker-compose up -d`
   - All dependencies included

2. **Single Command Execution:**
   - Run `bash scripts/run_all_pipelines.sh` to execute all 4 pipelines

3. **Configuration:**
   - Only one config file: `configs/ecomm_prod.yml`
   - Contains only input/output paths as required

4. **Spark Submit:**
   - Uses exact Hudi versions specified in assignment
   - Uses exact Spark configurations specified in assignment

5. **Output Verification:**
   - Check `processed/` for Hudi tables
   - Check `processed/recommendations_csv/` for final CSV
   - Check `quarantine/` for invalid records (if any)

---

## Repository Information

- **Branch:** claude/ecommerce-recommendation-system-01RxhaFbUeGUCoCUfmDAJjA8
- **Main Directory:** 2025EM1100026/ecommerce_seller_recommendation/local/
- **All Files Committed:** Yes
- **Ready for Review:** Yes

---

## Contact

**Student Roll No:** 2025EM1100026
**Course:** MSc Data Science & AI
**Assignment:** Data Storage and Pipeline - Assignment #1

---

**🎉 Assignment Complete and Ready for Submission! 🎉**
