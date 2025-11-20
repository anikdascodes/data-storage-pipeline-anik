#!/bin/bash

# Master Script to Run All Pipelines
# E-commerce Top-Seller Items Recommendation System
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

set -e  # Exit on error

echo "=============================================="
echo "E-commerce Recommendation System - Full Pipeline"
echo "Student: 2025EM1100026"
echo "=============================================="
echo ""

BASE_DIR="/home/user/data-storage-pipeline-anik/2025EM1100026/ecommerce_seller_recommendation/local"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Step 1: Seller Catalog ETL
echo "[1/4] Running Seller Catalog ETL Pipeline..."
bash $SCRIPTS_DIR/etl_seller_catalog_spark_submit.sh
if [ $? -eq 0 ]; then
    echo "✓ Seller Catalog ETL completed successfully"
else
    echo "✗ Seller Catalog ETL failed"
    exit 1
fi
echo ""

# Step 2: Company Sales ETL
echo "[2/4] Running Company Sales ETL Pipeline..."
bash $SCRIPTS_DIR/etl_company_sales_spark_submit.sh
if [ $? -eq 0 ]; then
    echo "✓ Company Sales ETL completed successfully"
else
    echo "✗ Company Sales ETL failed"
    exit 1
fi
echo ""

# Step 3: Competitor Sales ETL
echo "[3/4] Running Competitor Sales ETL Pipeline..."
bash $SCRIPTS_DIR/etl_competitor_sales_spark_submit.sh
if [ $? -eq 0 ]; then
    echo "✓ Competitor Sales ETL completed successfully"
else
    echo "✗ Competitor Sales ETL failed"
    exit 1
fi
echo ""

# Step 4: Consumption Layer - Recommendations
echo "[4/4] Running Consumption Layer - Recommendations..."
bash $SCRIPTS_DIR/consumption_recommendation_spark_submit.sh
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
