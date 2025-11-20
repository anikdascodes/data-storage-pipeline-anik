#!/bin/bash

# Spark Submit Script for Company Sales ETL Pipeline
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

# Set the base directory
# Set the base directory (auto-detect: Docker uses /app, otherwise get from script location)
if [ -d "/app" ] && [ -f "/app/configs/ecomm_prod.yml" ]; then
    BASE_DIR="/app"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

echo "Starting Company Sales ETL Pipeline..."
echo "Base Directory: $BASE_DIR"

# Run spark-submit
spark-submit \
  --packages org.apache.hudi:hudi-spark3.5-bundle_2.12:0.15.0,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.legacy.timeParserPolicy=LEGACY \
  $BASE_DIR/src/etl_company_sales.py \
  --config $BASE_DIR/configs/ecomm_prod.yml

echo "Company Sales ETL Pipeline completed!"
