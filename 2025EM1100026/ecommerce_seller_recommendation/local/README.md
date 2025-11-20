# E-commerce Seller Recommendation System

**Roll Number:** 2025EM1100026  
**Assignment:** Data Storage and Pipeline - Assignment #1

## Overview

This assignment implements a data pipeline for an e-commerce recommendation system. The goal is to help sellers identify which top-selling items are missing from their catalogs so they can improve revenue.

The pipeline processes three datasets:
- Seller catalog data (what each seller currently sells)
- Company sales data (internal sales performance)
- Competitor sales data (market-wide sales trends)

It then generates personalized recommendations for each seller, showing them which popular items they don't currently stock along with expected revenue projections.

## What This Pipeline Does

1. **Data Ingestion & Cleaning**: Reads raw CSV/SV files, cleans the data, and validates quality
2. **Storage**: Stores cleaned data in Apache Hudi tables (supports schema evolution and incremental updates)
3. **Quality Control**: Separates invalid records into a quarantine zone for review
4. **Analysis**: Identifies top 10 selling items per category across all sales channels
5. **Recommendations**: Generates seller-specific recommendations with revenue forecasts

## Quick Start

The easiest way to run this assignment:

```bash
cd ecommerce_seller_recommendation/local
docker compose up
```

This will:
- Build the Docker container with all dependencies
- Run all 3 ETL pipelines sequentially
- Execute the recommendation generation
- Output results to the `processed/` directory

Expected runtime: 5-10 minutes

## Project Structure

```
2025EM1100026/ecommerce_seller_recommendation/local/
│
├── configs/
│   └── ecomm_prod.yml              # Main configuration file (paths only)
│
├── src/                            # Source code
│   ├── etl_seller_catalog.py      # Pipeline 1: Process seller catalogs
│   ├── etl_company_sales.py       # Pipeline 2: Process company sales
│   ├── etl_competitor_sales.py    # Pipeline 3: Process competitor sales
│   └── consumption_recommendation.py  # Pipeline 4: Generate recommendations
│
├── scripts/                        # Spark submit scripts
│   ├── etl_seller_catalog_spark_submit.sh
│   ├── etl_company_sales_spark_submit.sh
│   ├── etl_competitor_sales_spark_submit.sh
│   ├── consumption_recommendation_spark_submit.sh
│   └── run_all_pipelines.sh       # Runs all 4 in sequence
│
├── raw/                            # Input data
│   ├── seller_catalog/
│   │   ├── seller_catalog_clean.csv
│   │   └── seller_catalog_dirty.csv
│   ├── company_sales/
│   │   ├── company_sales_clean.csv
│   │   └── company_sales_dirty.csv
│   └── competitor_sales/
│       ├── competitor_sales_clean.sv    # Pipe-delimited file
│       └── competitor_sales_dirty.sv
│
├── Dockerfile                      # Container setup
├── docker-compose.yml              # Orchestration config
├── requirements.txt                # Python dependencies
├── RUN_ASSIGNMENT.sh               # Interactive execution menu
└── README.md                       # This file
```

## Configuration File

The `configs/ecomm_prod.yml` file contains all the input and output paths. Per assignment requirements, it only includes:
- Input CSV/SV file paths
- Hudi table output paths  
- Final CSV output path

Quarantine paths are calculated automatically by the code (not stored in config).

Example structure:
```yaml
seller_catalog:
  input_path: "/app/raw/seller_catalog/seller_catalog_clean.csv"
  hudi_output_path: "/app/processed/seller_catalog_hudi/"

competitor_sales:
  input_path: "/app/raw/competitor_sales/competitor_sales_clean.sv"  # Note: .sv format
  hudi_output_path: "/app/processed/competitor_sales_hudi/"

recommendation:
  output_csv: "/app/processed/recommendations_csv/seller_recommend_data.csv"
```

**Important**: Competitor sales uses `.sv` extension (pipe-delimited format) instead of `.csv`.

## How to Run

### Method 1: Docker (Recommended)

```bash
cd ecommerce_seller_recommendation/local
docker compose up
```

This handles everything automatically - no need to install Spark or Java locally.

### Method 2: Using the Helper Script

```bash
cd ecommerce_seller_recommendation/local
bash RUN_ASSIGNMENT.sh
```

This gives you a menu with options:
1. Run with Docker
2. Run locally (requires Spark installation)
3. Run demo with dirty data
4. Verify outputs

### Method 3: Manual Execution

If you have Spark 3.5.0 installed locally:

```bash
cd ecommerce_seller_recommendation/local

# Run ETL pipelines
bash scripts/etl_seller_catalog_spark_submit.sh
bash scripts/etl_company_sales_spark_submit.sh  
bash scripts/etl_competitor_sales_spark_submit.sh

# Generate recommendations
bash scripts/consumption_recommendation_spark_submit.sh
```

## Pipeline Architecture

The system follows a medallion architecture:

**Raw Layer** → Input CSV/SV files in the `raw/` directory

**ETL Processing** → Three separate pipelines that:
- Extract data from raw files
- Clean and transform (trim whitespace, normalize formats, type conversions)
- Validate data quality (check for nulls, negative values, invalid dates)
- Split valid and invalid records

**Gold Layer** → Valid records stored in Hudi tables at `/app/processed/`
- `seller_catalog_hudi/`
- `company_sales_hudi/`
- `competitor_sales_hudi/`

**Quarantine Zone** → Invalid records stored at `/app/quarantine/`
- Includes original data plus failure reason and timestamp
- Stored in Parquet format for review

**Consumption Layer** → Reads Hudi tables and generates:
- Top 10 selling items per category
- Recommendations for each seller (missing items)
- Revenue projections

## Data Cleaning & Quality Checks

### Seller Catalog
- Trims whitespace from all string fields
- Converts item names to title case
- Normalizes category labels
- Removes duplicate entries (same seller + item combination)
- Fills missing stock quantities with 0
- **Quality rules**: Rejects records with null seller_id/item_id or negative prices

### Company Sales  
- Converts data types (integers for units, doubles for revenue, proper dates)
- Removes duplicates based on item_id
- Fills missing numeric values with 0
- **Quality rules**: Rejects records with negative sales or future dates

### Competitor Sales
- Reads pipe-delimited format (`|` separator)
- Normalizes seller and item identifiers  
- Validates numeric fields
- **Quality rules**: Rejects records with negative values or invalid dates

All rejected records go to the quarantine zone with a reason code.

## Output Files

After running the pipeline, you'll find:

### Hudi Tables (Gold Layer)
Location: `/app/processed/`
```
processed/
├── seller_catalog_hudi/
├── company_sales_hudi/
└── competitor_sales_hudi/
```

These are Hudi tables supporting:
- ACID transactions
- Schema evolution (can handle new columns)
- Incremental updates
- Time travel queries

### Recommendations CSV
Location: `/app/processed/recommendations_csv/seller_recommend_data.csv`

Format:
```csv
seller_id,item_id,item_name,category,market_price,expected_units_sold,expected_revenue
S001,I10234,Samsung Galaxy S24,Electronics,89999.00,245,22049755.00
S002,I15678,Dell XPS 15,Electronics,125000.00,156,19500000.00
```

Columns explained:
- `seller_id`: Which seller should consider this item
- `item_id`, `item_name`, `category`: Product details
- `market_price`: Current selling price in the market
- `expected_units_sold`: Projected sales volume (calculated from historical data)
- `expected_revenue`: Estimated revenue = units × price

### Quarantine Files (if any)
Location: `/app/quarantine/`
```
quarantine/
├── seller_catalog/     # Invalid seller records
├── company_sales/      # Invalid sales records  
└── competitor_sales/   # Invalid competitor records
```

Each quarantine file includes:
- All original columns
- `dq_failure_reason`: Why it was rejected (e.g., "negative_price", "null_item_id")
- `quarantine_timestamp`: When it was flagged

## Technical Stack

- **Apache Spark 3.5.0**: Distributed data processing
- **Apache Hudi 0.15.0**: Data lake storage with ACID properties
- **PySpark**: Python API for Spark
- **Docker**: Containerization for easy deployment
- **Ubuntu 22.04**: Base operating system
- **Java 21**: JVM for Spark execution

## Key Implementation Details

### Why Hudi?
- Supports schema changes without breaking existing data
- Handles incremental updates efficiently (upsert operation)
- Provides ACID transactions for data consistency
- Enables time travel (query historical data snapshots)

### Why Pipe-Delimited for Competitor Data?
The `.sv` format uses `|` as delimiter instead of comma, which prevents issues when data values contain commas (like "1,234.50").

### Quarantine Path Derivation
The assignment specifies that `ecomm_prod.yml` should only contain input/output paths. The quarantine paths are automatically calculated:
```python
# Given hudi_output_path = "/app/processed/seller_catalog_hudi/"
# Quarantine becomes: "/app/quarantine/seller_catalog/"
base_dir = os.path.dirname(os.path.dirname(hudi_path))
quarantine_path = os.path.join(base_dir, "quarantine", dataset_name)
```

### Revenue Calculation Logic
```python
# Step 1: Aggregate total units sold for each item across all sellers
total_units = SUM(company_units + competitor_units)

# Step 2: Find top 10 items per category
top_items = RANK(total_units) WITHIN EACH category LIMIT 10

# Step 3: For each seller, find items they DON'T have
missing_items = top_items NOT IN seller_catalog

# Step 4: Calculate expected performance
expected_units_sold = total_units / count(sellers_selling_this_item)
expected_revenue = expected_units_sold × market_price
```

## Common Issues & Solutions

### Docker Build Takes Long
First build can take 5-10 minutes as it downloads Java, Spark, and dependencies. Subsequent builds use cache and are much faster.

### Permission Errors on Scripts
If you get "permission denied" errors:
```bash
chmod +x scripts/*.sh
chmod +x *.sh
```

### CSV Output is a Directory
Spark naturally writes CSV as a directory with multiple part files. The code handles this automatically by:
1. Writing to a temp directory
2. Finding the actual CSV file (ignoring metadata)
3. Moving it to the final single-file location
4. Cleaning up temp files

### Missing Spark Packages
The scripts download Hudi and Hadoop packages automatically during `spark-submit`. Ensure you have internet connectivity on first run.

## Assignment Compliance Notes

This implementation follows all assignment specifications:

1. **Config file structure**: Only input/output paths (no quarantine_path)
2. **Competitor sales format**: Uses `.sv` file with pipe delimiter
3. **Spark versions**: Hudi 0.15.0, Spark 3.5 bundle, Hadoop 3.3.4
4. **Spark session**: Configured with KryoSerializer and LEGACY time parser
5. **ETL architecture**: 3 separate pipelines for ingestion
6. **Hudi tables**: COPY_ON_WRITE mode with overwrite
7. **Consumption layer**: Single CSV output with all required columns
8. **Data quality**: Comprehensive validation with quarantine handling

## Performance Expectations

With the provided sample data (clean dataset):
- Seller catalog: ~500 records
- Company sales: ~1000 records  
- Competitor sales: ~800 records
- Expected recommendations: ~2000 rows
- Total runtime: 5-10 minutes (mostly Spark initialization)

The dirty dataset includes intentional data quality issues to demonstrate quarantine handling.

## Medallion Architecture Diagram

```
┌───────────────────────────────────────────────────────────┐
│                      RAW LAYER                            │
│  Seller Catalog, Company Sales, Competitor Sales          │
│  (.csv/.sv files in /app/raw/)                            │
└────────────────────┬──────────────────────────────────────┘
                     │
                     ▼
┌───────────────────────────────────────────────────────────┐
│                   ETL PROCESSING                          │
│  • Extract from CSV/SV files                              │
│  • Clean & Transform data                                 │
│  • Apply Data Quality checks                              │
│  • Split valid/invalid records                            │
└────────┬──────────────────────┬─────────────────────────┘
         │                      │
         ▼                      ▼
┌──────────────────┐   ┌──────────────────────────┐
│   GOLD LAYER     │   │   QUARANTINE ZONE        │
│  Hudi Tables     │   │  Invalid Records         │
│  (/processed/)   │   │  • dq_failure_reason     │
│  • COW mode      │   │  • quarantine_timestamp  │
│  • ACID          │   │  • Parquet format        │
│  • Schema Evolve │   │  (/quarantine/)          │
└────────┬─────────┘   └──────────────────────────┘
         │
         ▼
┌───────────────────────────────────────────────────────────┐
│              CONSUMPTION LAYER                            │
│  • Read 3 Hudi tables                                     │
│  • Identify top 10 items per category                     │
│  • Generate seller recommendations                        │
│  • Calculate expected revenue                             │
│  • Output to CSV (/processed/recommendations_csv/)        │
└───────────────────────────────────────────────────────────┘
```

## Recommendation Algorithm

The system uses the following logic to generate recommendations:

1. **Aggregate Sales Data**
   - Combine company sales and competitor sales by item_id
   - Calculate total units sold for each item
   - Count number of sellers selling each item

2. **Identify Top Performers**
   - Rank items within each category by total units sold
   - Select top 10 items per category

3. **Find Gaps in Seller Catalogs**
   - For each seller, compare their catalog against top 10 items
   - Identify items they are NOT currently selling

4. **Calculate Revenue Projections**
   ```python
   expected_units_sold = total_units_sold ÷ number_of_sellers
   expected_revenue = expected_units_sold × market_price
   ```

5. **Output Recommendations**
   - Sort by expected revenue (highest first)
   - Include all relevant details for decision-making

---

**Developed for**: Data Storage and Pipeline - Assignment #1  
**Student**: MSc Data Science & AI  
**Roll Number**: 2025EM1100026  
**Date**: November 2025
