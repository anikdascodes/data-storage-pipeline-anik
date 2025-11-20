#!/bin/bash

# Spark Submit Script for Consumption Layer - Recommendations
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

# Set the base directory
BASE_DIR="/home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local"

echo "Starting Consumption Layer - Recommendations Pipeline..."
echo "Base Directory: $BASE_DIR"

# Run spark-submit
spark-submit \
  --packages org.apache.hudi:hudi-spark3.5-bundle_2.12:0.15.0,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.legacy.timeParserPolicy=LEGACY \
  $BASE_DIR/src/consumption_recommendation.py \
  --config $BASE_DIR/configs/ecomm_prod.yml

echo "Consumption Layer - Recommendations Pipeline completed!"
