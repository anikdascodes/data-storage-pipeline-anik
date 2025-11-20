#!/bin/bash

# Smart Pipeline Runner
# E-commerce Recommendation System
# Roll Number: 2025EM1100026
#
# This script auto-detects the environment and runs the pipeline
# Works in Docker containers, local installations, or mixed environments

set -e

echo "=========================================="
echo "Smart Pipeline Runner"
echo "E-commerce Recommendation System"
echo "Roll Number: 2025EM1100026"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect environment
echo "Detecting environment..."

# Check if running in Docker
if [ -f /.dockerenv ]; then
    echo -e "${BLUE}✓ Running inside Docker container${NC}"
    IN_DOCKER=true
    BASE_DIR="/app"
else
    echo -e "${BLUE}✓ Running on host system${NC}"
    IN_DOCKER=false
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Check if Spark is available
if command -v spark-submit &> /dev/null; then
    echo -e "${GREEN}✓ spark-submit found${NC}"
    SPARK_VERSION=$(spark-submit --version 2>&1 | grep "version" | head -1)
    echo "  $SPARK_VERSION"
else
    echo -e "${RED}✗ spark-submit not found${NC}"
    echo ""
    echo "Please install Apache Spark first:"
    echo "  bash install_spark_quick.sh"
    echo "  source ~/.bashrc"
    exit 1
fi

# Check if Python is available
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓ Python 3 found${NC}"
else
    echo -e "${RED}✗ Python 3 not found${NC}"
    exit 1
fi

# Check if PySpark is available
if python3 -c "import pyspark" 2>/dev/null; then
    PYSPARK_VERSION=$(python3 -c "import pyspark; print(pyspark.__version__)")
    echo -e "${GREEN}✓ PySpark $PYSPARK_VERSION found${NC}"
else
    echo -e "${RED}✗ PySpark not found${NC}"
    echo ""
    echo "Please install PySpark:"
    echo "  pip install pyspark==3.5.0 pyyaml pandas"
    exit 1
fi

# Check if input data exists
echo ""
echo "Checking input data..."
if [ -f "$BASE_DIR/raw/seller_catalog/seller_catalog_clean.csv" ]; then
    echo -e "${GREEN}✓ Seller catalog data found${NC}"
else
    echo -e "${RED}✗ Seller catalog data not found${NC}"
    exit 1
fi

if [ -f "$BASE_DIR/raw/company_sales/company_sales_clean.csv" ]; then
    echo -e "${GREEN}✓ Company sales data found${NC}"
else
    echo -e "${RED}✗ Company sales data not found${NC}"
    exit 1
fi

if [ -f "$BASE_DIR/raw/competitor_sales/competitor_sales_clean.csv" ]; then
    echo -e "${GREEN}✓ Competitor sales data found${NC}"
else
    echo -e "${RED}✗ Competitor sales data not found${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "Starting Pipeline Execution"
echo "=========================================="
echo ""

START_TIME=$(date +%s)

# Set scripts directory
SCRIPTS_DIR="$BASE_DIR/scripts"

# Step 1: Seller Catalog ETL
echo -e "${BLUE}[1/4] Running Seller Catalog ETL Pipeline...${NC}"
bash $SCRIPTS_DIR/etl_seller_catalog_spark_submit.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Seller Catalog ETL completed successfully${NC}"
else
    echo -e "${RED}✗ Seller Catalog ETL failed${NC}"
    exit 1
fi
echo ""

# Step 2: Company Sales ETL
echo -e "${BLUE}[2/4] Running Company Sales ETL Pipeline...${NC}"
bash $SCRIPTS_DIR/etl_company_sales_spark_submit.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Company Sales ETL completed successfully${NC}"
else
    echo -e "${RED}✗ Company Sales ETL failed${NC}"
    exit 1
fi
echo ""

# Step 3: Competitor Sales ETL
echo -e "${BLUE}[3/4] Running Competitor Sales ETL Pipeline...${NC}"
bash $SCRIPTS_DIR/etl_competitor_sales_spark_submit.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Competitor Sales ETL completed successfully${NC}"
else
    echo -e "${RED}✗ Competitor Sales ETL failed${NC}"
    exit 1
fi
echo ""

# Step 4: Consumption Layer - Recommendations
echo -e "${BLUE}[4/4] Running Consumption Layer - Recommendations...${NC}"
bash $SCRIPTS_DIR/consumption_recommendation_spark_submit.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Consumption Layer completed successfully${NC}"
else
    echo -e "${RED}✗ Consumption Layer failed${NC}"
    exit 1
fi
echo ""

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "=========================================="
echo -e "${GREEN}All Pipelines Completed Successfully!${NC}"
echo "=========================================="
echo ""
echo "Total execution time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "Outputs:"
echo "  - Hudi Tables: $BASE_DIR/processed/"
echo "  - Recommendations: $BASE_DIR/processed/recommendations_csv/"
echo "  - Quarantine: $BASE_DIR/quarantine/"
echo ""
echo "To view recommendations:"
echo "  head -20 $BASE_DIR/processed/recommendations_csv/seller_recommend_data.csv"
echo ""
