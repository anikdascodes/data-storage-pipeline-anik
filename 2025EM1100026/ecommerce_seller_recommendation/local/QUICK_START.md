# Quick Start Guide

**E-commerce Recommendation System**
**Student Roll No:** 2025EM1100026

---

## 🚀 Choose Your Method

### Method 1: Docker (Recommended - Zero Setup)
**Time:** 10-15 minutes (first time), 2 minutes (subsequent runs)
**Best for:** Clean environment, reviewers, production

### Method 2: Local Installation (Faster if Spark exists)
**Time:** 5-10 minutes (if Spark needs install), 1 minute (if Spark exists)
**Best for:** Development, quick testing, limited resources

---

## Method 1: Docker Installation

### Prerequisites
- Docker installed
- Docker Compose installed
- 4GB+ available RAM

### Steps

1. **Navigate to project directory:**
   ```bash
   cd /path/to/2025EM1100026/ecommerce_seller_recommendation/local
   ```

2. **Build Docker image (first time only):**
   ```bash
   docker-compose build
   ```
   This will take 10-15 minutes to:
   - Install Java 11
   - Install Apache Spark 3.5.0
   - Install Python dependencies
   - Set up environment

3. **Start container:**
   ```bash
   docker-compose up -d
   ```

4. **Access container:**
   ```bash
   docker-compose exec ecommerce-recommendation bash
   ```

5. **Run all pipelines:**
   ```bash
   cd /app
   bash scripts/run_all_pipelines.sh
   ```

6. **Check outputs:**
   ```bash
   # Hudi tables
   ls -la processed/

   # Recommendations CSV
   cat processed/recommendations_csv/seller_recommend_data.csv

   # Quarantine (if any invalid data)
   ls -la quarantine/
   ```

7. **Exit and stop container:**
   ```bash
   exit
   docker-compose down
   ```

---

## Method 2: Local Installation

### Prerequisites
- Ubuntu/Debian Linux (or GitHub Codespaces)
- sudo access
- 8GB+ RAM

### Steps

1. **Navigate to project directory:**
   ```bash
   cd /path/to/2025EM1100026/ecommerce_seller_recommendation/local
   ```

2. **Run installation script:**
   ```bash
   bash scripts/install_spark_local.sh
   ```
   This will:
   - Install Java 11 (if needed)
   - Download and install Spark 3.5.0 (if needed)
   - Install Python dependencies

3. **Set environment variables:**
   ```bash
   export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
   export SPARK_HOME=/opt/spark
   export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
   export PYSPARK_PYTHON=python3
   ```

   **OR** add to `~/.bashrc` for permanent setup:
   ```bash
   echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
   echo 'export SPARK_HOME=/opt/spark' >> ~/.bashrc
   echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> ~/.bashrc
   echo 'export PYSPARK_PYTHON=python3' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify installation:**
   ```bash
   spark-submit --version
   ```

5. **Run all pipelines:**
   ```bash
   bash scripts/run_all_pipelines.sh
   ```

6. **Check outputs:**
   ```bash
   # Hudi tables
   ls -la processed/

   # Recommendations CSV
   head -20 processed/recommendations_csv/seller_recommend_data.csv/seller_recommend_data.csv

   # Quarantine (if any invalid data)
   ls -la quarantine/
   ```

---

## Running Individual Pipelines

If you want to run pipelines one by one:

```bash
# 1. Seller Catalog ETL
bash scripts/etl_seller_catalog_spark_submit.sh

# 2. Company Sales ETL
bash scripts/etl_company_sales_spark_submit.sh

# 3. Competitor Sales ETL
bash scripts/etl_competitor_sales_spark_submit.sh

# 4. Consumption Layer (run after all ETLs)
bash scripts/consumption_recommendation_spark_submit.sh
```

---

## Testing with Dirty Data

To test data quality checks and quarantine functionality:

1. **Edit configuration file:**
   ```bash
   nano configs/ecomm_prod.yml
   ```

2. **Change paths to dirty datasets:**
   ```yaml
   seller_catalog:
     input_path: "/home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/raw/seller_catalog_dirty.csv"

   company_sales:
     input_path: "/home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/raw/company_sales_dirty.csv"

   competitor_sales:
     input_path: "/home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local/raw/competitor_sales_dirty.csv"
   ```

3. **Run pipelines:**
   ```bash
   bash scripts/run_all_pipelines.sh
   ```

4. **Check quarantine:**
   ```bash
   # View quarantined records with failure reasons
   ls -la quarantine/
   ```

---

## Troubleshooting

### Issue: Docker build fails downloading Spark
**Solution:** The Dockerfile now uses a faster mirror with fallback. If still failing, check your internet connection or try:
```bash
docker-compose build --no-cache
```

### Issue: "spark-submit: command not found"
**Solution:** Set environment variables:
```bash
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin
```

### Issue: Out of memory
**Solution:** Increase Spark memory:
```bash
spark-submit --driver-memory 4g --executor-memory 4g ...
```

### Issue: Permission denied on scripts
**Solution:** Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Issue: "Java not found"
**Solution:** Install Java 11:
```bash
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

---

## Expected Output Structure

After successful execution:

```
processed/
├── seller_catalog_hudi/        # Hudi table (parquet format)
├── company_sales_hudi/          # Hudi table (parquet format)
├── competitor_sales_hudi/       # Hudi table (parquet format)
└── recommendations_csv/         # Final recommendations
    └── seller_recommend_data.csv

quarantine/
├── seller_catalog/              # Invalid seller records (if any)
├── company_sales/               # Invalid sales records (if any)
└── competitor_sales/            # Invalid competitor records (if any)
```

---

## Time Estimates

| Method | First Run | Subsequent Runs |
|--------|-----------|-----------------|
| Docker (build) | 10-15 min | - |
| Docker (run) | 5-8 min | 5-8 min |
| Local (install) | 5-10 min | - |
| Local (run) | 3-5 min | 3-5 min |

---

## Quick Commands Reference

```bash
# Docker Method
docker-compose build                                  # Build image (first time)
docker-compose up -d                                   # Start container
docker-compose exec ecommerce-recommendation bash      # Access container
bash /app/scripts/run_all_pipelines.sh                # Run pipelines
docker-compose down                                    # Stop container

# Local Method
bash scripts/install_spark_local.sh                   # Install (first time)
source ~/.bashrc                                       # Load environment
bash scripts/run_all_pipelines.sh                     # Run pipelines

# Individual Pipelines
bash scripts/etl_seller_catalog_spark_submit.sh       # Pipeline 1
bash scripts/etl_company_sales_spark_submit.sh        # Pipeline 2
bash scripts/etl_competitor_sales_spark_submit.sh     # Pipeline 3
bash scripts/consumption_recommendation_spark_submit.sh # Pipeline 4
```

---

## For Reviewers

**Fastest path to test:**

1. If you have Docker:
   ```bash
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   docker-compose build && docker-compose up -d
   docker-compose exec ecommerce-recommendation bash -c "cd /app && bash scripts/run_all_pipelines.sh"
   ```

2. If you don't have Docker but have Spark:
   ```bash
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   bash scripts/run_all_pipelines.sh
   ```

3. If you have neither:
   ```bash
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   bash scripts/install_spark_local.sh
   # Follow the instructions to set environment variables
   bash scripts/run_all_pipelines.sh
   ```

---

## Need Help?

Check the main README.md for detailed documentation or refer to:
- **README.md** - Complete project documentation
- **PROJECT_SUMMARY.md** - Project overview
- This file - Quick start guide

---

**Ready to run!** Choose your method and follow the steps above. 🚀
