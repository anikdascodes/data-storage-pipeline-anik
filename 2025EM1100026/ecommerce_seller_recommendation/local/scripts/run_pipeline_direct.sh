#!/bin/bash

# Direct Python Execution (No Spark Installation Required)
# Uses PySpark library directly instead of spark-submit
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

set -e

echo "=============================================="
echo "E-commerce Recommendation System - Direct Python Execution"
echo "Student: 2025EM1100026"
echo "=============================================="
echo ""

BASE_DIR="/home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local"
cd "$BASE_DIR"

# Install PySpark and dependencies if not already installed
echo "Checking Python dependencies..."
python3 -m pip install -q pyspark==3.5.0 pyyaml pandas 2>/dev/null || true
echo "✓ Dependencies ready"
echo ""

# Set environment variables for PySpark
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=python3

# Download Hudi jars if not present
JARS_DIR="$BASE_DIR/jars"
mkdir -p "$JARS_DIR"

if [ ! -f "$JARS_DIR/hudi-spark3.5-bundle_2.12-0.15.0.jar" ]; then
    echo "Downloading Hudi jar..."
    wget -q -P "$JARS_DIR" https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark3.5-bundle_2.12/0.15.0/hudi-spark3.5-bundle_2.12-0.15.0.jar
    echo "✓ Hudi jar downloaded"
fi

if [ ! -f "$JARS_DIR/hadoop-aws-3.3.4.jar" ]; then
    echo "Downloading Hadoop AWS jar..."
    wget -q -P "$JARS_DIR" https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar
    echo "✓ Hadoop AWS jar downloaded"
fi

if [ ! -f "$JARS_DIR/aws-java-sdk-bundle-1.12.262.jar" ]; then
    echo "Downloading AWS SDK jar..."
    wget -q -P "$JARS_DIR" https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar
    echo "✓ AWS SDK jar downloaded"
fi

echo ""

# Set Spark configuration for direct execution
export SPARK_CLASSPATH="$JARS_DIR/*"
export PYSPARK_SUBMIT_ARGS="--jars $JARS_DIR/hudi-spark3.5-bundle_2.12-0.15.0.jar,$JARS_DIR/hadoop-aws-3.3.4.jar,$JARS_DIR/aws-java-sdk-bundle-1.12.262.jar --conf spark.serializer=org.apache.spark.serializer.KryoSerializer --conf spark.sql.legacy.timeParserPolicy=LEGACY pyspark-shell"

# Step 1: Seller Catalog ETL
echo "[1/4] Running Seller Catalog ETL Pipeline..."
python3 src/etl_seller_catalog.py --config configs/ecomm_prod.yml
if [ $? -eq 0 ]; then
    echo "✓ Seller Catalog ETL completed successfully"
else
    echo "✗ Seller Catalog ETL failed"
    exit 1
fi
echo ""

# Step 2: Company Sales ETL
echo "[2/4] Running Company Sales ETL Pipeline..."
python3 src/etl_company_sales.py --config configs/ecomm_prod.yml
if [ $? -eq 0 ]; then
    echo "✓ Company Sales ETL completed successfully"
else
    echo "✗ Company Sales ETL failed"
    exit 1
fi
echo ""

# Step 3: Competitor Sales ETL
echo "[3/4] Running Competitor Sales ETL Pipeline..."
python3 src/etl_competitor_sales.py --config configs/ecomm_prod.yml
if [ $? -eq 0 ]; then
    echo "✓ Competitor Sales ETL completed successfully"
else
    echo "✗ Competitor Sales ETL failed"
    exit 1
fi
echo ""

# Step 4: Consumption Layer - Recommendations
echo "[4/4] Running Consumption Layer - Recommendations..."
python3 src/consumption_recommendation.py --config configs/ecomm_prod.yml
if [ $? -eq 0 ]; then
    echo "✓ Consumption Layer completed successfully"
else
    echo "✗ Consumption Layer failed"
    exit 1
fi
echo ""

echo "=============================================="
echo "All Pipelines Completed Successfully!"
echo "=============================================="
echo ""
echo "Outputs:"
echo "  - Hudi Tables: $BASE_DIR/processed/"
echo "  - Recommendations: $BASE_DIR/processed/recommendations_csv/"
echo "  - Quarantine: $BASE_DIR/quarantine/"
echo ""
