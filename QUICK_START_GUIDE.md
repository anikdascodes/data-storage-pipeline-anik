# Quick Start Guide - E-commerce Recommendation System

**Roll Number:** 2025EM1100026  
**Assignment:** Data Storage Pipeline #1

---

## Prerequisites Check

Before running the pipeline, ensure you have:

- [ ] Docker and Docker Compose installed
- [ ] At least 4GB RAM available
- [ ] Input data files in `raw/` directories

---

## Quick Start (Docker - Recommended)

### Step 1: Navigate to Project Directory

```bash
cd /workspaces/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local
```

### Step 2: Build Docker Image

```bash
docker-compose build
```

**Expected time:** 10-15 minutes (first time only)

### Step 3: Start Container

```bash
docker-compose up -d
```

### Step 4: Access Container

```bash
docker-compose exec ecommerce-recommendation bash
```

### Step 5: Run All Pipelines

Inside the container:

```bash
bash /app/scripts/run_all_pipelines.sh
```

**OR** run pipelines individually:

```bash
# ETL Pipeline 1: Seller Catalog
bash /app/scripts/etl_seller_catalog_spark_submit.sh

# ETL Pipeline 2: Company Sales
bash /app/scripts/etl_company_sales_spark_submit.sh

# ETL Pipeline 3: Competitor Sales
bash /app/scripts/etl_competitor_sales_spark_submit.sh

# Consumption Layer: Recommendations
bash /app/scripts/consumption_recommendation_spark_submit.sh
```

### Step 6: Verify Outputs

```bash
# Check Hudi tables
ls -lh /app/processed/

# Check quarantine records
ls -lh /app/quarantine/

# View recommendations
head -20 /app/processed/recommendations_csv/seller_recommend_data.csv
```

### Step 7: Exit Container

```bash
exit
```

### Step 8: Stop Container

```bash
docker-compose down
```

---

## Alternative: Local Installation (Without Docker)

### Prerequisites

1. **Install Java 11**

```bash
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

2. **Install Apache Spark 3.5.0**

```bash
cd /tmp
wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
tar -xzf spark-3.5.0-bin-hadoop3.tgz
sudo mv spark-3.5.0-bin-hadoop3 /opt/spark

export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip
```

3. **Install Python Dependencies**

```bash
pip install pyspark==3.5.0 pyyaml pandas
```

### Run Pipelines

```bash
cd /workspaces/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local

# Run all pipelines
bash scripts/run_all_pipelines.sh
```

---

## Troubleshooting

### Issue 1: Docker Build Fails

**Solution:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild
docker-compose build --no-cache
```

### Issue 2: Out of Memory

**Solution:**
```bash
# Increase Docker memory limit (Docker Desktop)
# Settings → Resources → Memory → 4GB+

# OR modify spark-submit scripts to reduce memory
--driver-memory 2g --executor-memory 2g
```

### Issue 3: Permission Denied

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### Issue 4: Hudi Table Not Found

**Solution:**
```bash
# Ensure ETL pipelines run before consumption layer
# Run in order:
# 1. etl_seller_catalog
# 2. etl_company_sales
# 3. etl_competitor_sales
# 4. consumption_recommendation
```

### Issue 5: Java Not Found

**Solution:**
```bash
# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
```

---

## Verification Checklist

After running the pipeline, verify:

- [ ] **Hudi Tables Created**
  ```bash
  ls processed/seller_catalog_hudi/
  ls processed/company_sales_hudi/
  ls processed/competitor_sales_hudi/
  ```

- [ ] **Quarantine Records** (if any invalid data)
  ```bash
  ls quarantine/seller_catalog/
  ls quarantine/company_sales/
  ls quarantine/competitor_sales/
  ```

- [ ] **Recommendations CSV**
  ```bash
  cat processed/recommendations_csv/seller_recommend_data.csv | head -10
  ```

- [ ] **Log Files** (check for errors)
  ```bash
  # Check Spark logs
  tail -100 logs/*.log
  ```

---

## Expected Runtime

| Pipeline | Records | Expected Time |
|----------|---------|---------------|
| Seller Catalog ETL | ~1M | 2-3 minutes |
| Company Sales ETL | ~500K | 1-2 minutes |
| Competitor Sales ETL | ~800K | 2-3 minutes |
| Consumption Layer | Combined | 3-5 minutes |
| **Total** | | **8-13 minutes** |

---

## Output Schema

### Recommendations CSV

```csv
seller_id,item_id,item_name,category,market_price,expected_units_sold,expected_revenue
S001,I10050,Apple Airpods Pro,Electronics,24999.99,150,3749998.50
S001,I10051,Nike Air Max,Footwear,12999.99,200,2599998.00
...
```

**Columns:**
- `seller_id` - Seller identifier
- `item_id` - Item identifier
- `item_name` - Item name (Title Case)
- `category` - Product category
- `market_price` - Current market price
- `expected_units_sold` - Estimated units seller can sell
- `expected_revenue` - Expected revenue (units * price)

---

## Data Quality Metrics

After running, check DQ statistics:

```bash
# Count valid records
spark-sql -e "SELECT COUNT(*) FROM hudi.seller_catalog_hudi"

# Count quarantine records
find quarantine/ -name "*.parquet" -exec wc -l {} \;
```

---

## Performance Tips

1. **Increase Spark Memory** (for large datasets)
   ```bash
   --driver-memory 4g --executor-memory 4g
   ```

2. **Adjust Parallelism**
   ```bash
   --conf spark.default.parallelism=8
   ```

3. **Enable Compression**
   ```bash
   --conf spark.sql.parquet.compression.codec=snappy
   ```

4. **Cache DataFrames** (if reused)
   ```python
   df.cache()
   ```

---

## Monitoring

### Check Pipeline Progress

```bash
# Watch Spark UI (if running locally)
# Open browser: http://localhost:4040

# Check logs in real-time
tail -f logs/spark-*.log
```

### Check Resource Usage

```bash
# Inside Docker container
top

# Check disk usage
df -h
```

---

## Clean Up

### Remove Generated Data

```bash
# Remove processed data
rm -rf processed/*

# Remove quarantine data
rm -rf quarantine/*

# Remove logs
rm -rf logs/*
```

### Remove Docker Resources

```bash
# Stop and remove container
docker-compose down

# Remove image
docker rmi ecommerce-recommendation:latest

# Clean all Docker resources
docker system prune -a
```

---

## Next Steps

1. ✅ Run the pipeline successfully
2. ✅ Verify all outputs
3. ✅ Review quarantine records (if any)
4. ✅ Analyze recommendations
5. ✅ Prepare submission package

---

## Support

For issues or questions:

1. Check the comprehensive README.md
2. Review ASSIGNMENT_REVIEW.md
3. Check Spark logs in `logs/` directory
4. Verify configuration in `configs/ecomm_prod.yml`

---

## Submission Checklist

Before submitting:

- [ ] All pipelines run successfully
- [ ] Outputs verified (Hudi tables + CSV)
- [ ] No critical errors in logs
- [ ] README.md is complete
- [ ] Configuration file is correct
- [ ] Scripts are executable
- [ ] Docker setup is documented
- [ ] Code is well-commented

---

**Good luck with your assignment! 🚀**

---

**Prepared by:** Ona AI Assistant  
**Date:** November 20, 2025
