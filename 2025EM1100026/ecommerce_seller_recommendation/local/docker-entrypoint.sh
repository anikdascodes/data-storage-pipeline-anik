#!/bin/bash

# Docker Entrypoint Script - Auto-run All Pipelines
# E-commerce Recommendation System
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

set -e

echo "================================================================"
echo "  E-commerce Recommendation System - Docker Container"
echo "  Student Roll No: 2025EM1100026"
echo "  Assignment: Data Storage and Pipeline"
echo "================================================================"
echo ""

# Function to print section headers
print_header() {
    echo ""
    echo "================================================================"
    echo "  $1"
    echo "================================================================"
    echo ""
}

# Function to print success message
print_success() {
    echo "✓ $1"
}

# Function to print error message
print_error() {
    echo "✗ ERROR: $1"
}

# Check if we should run in interactive mode or auto mode
RUN_MODE="${1:-auto}"

if [ "$RUN_MODE" == "bash" ]; then
    print_header "Interactive Mode"
    echo "Container is ready. Starting bash shell..."
    echo ""
    echo "To run all pipelines:"
    echo "  bash /app/scripts/run_all_pipelines.sh"
    echo ""
    echo "Or run individual pipelines:"
    echo "  bash /app/scripts/etl_seller_catalog_spark_submit.sh"
    echo "  bash /app/scripts/etl_company_sales_spark_submit.sh"
    echo "  bash /app/scripts/etl_competitor_sales_spark_submit.sh"
    echo "  bash /app/scripts/consumption_recommendation_spark_submit.sh"
    echo ""
    exec /bin/bash
fi

print_header "Auto-Execution Mode"
echo "All 4 pipelines will run automatically..."
echo "Estimated time: 5-8 minutes"
echo ""

# Verify environment
print_header "Step 1: Environment Verification"

# Check Java
if java -version 2>&1 | grep -q "version"; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_success "Java found: $JAVA_VERSION"
else
    print_error "Java not found"
    exit 1
fi

# Check Spark
if [ -d "$SPARK_HOME" ]; then
    print_success "Spark found at: $SPARK_HOME"
else
    print_error "Spark not found at: $SPARK_HOME"
    exit 1
fi

# Check Python
if python3 --version &> /dev/null; then
    PY_VERSION=$(python3 --version)
    print_success "Python found: $PY_VERSION"
else
    print_error "Python not found"
    exit 1
fi

# Check configuration file
if [ -f "/app/configs/ecomm_prod.yml" ]; then
    print_success "Configuration file found"
else
    print_error "Configuration file not found"
    exit 1
fi

# Check input data
if [ -f "/app/raw/seller_catalog/seller_catalog_clean.csv" ]; then
    print_success "Seller catalog data found"
else
    print_error "Seller catalog data not found"
    exit 1
fi

if [ -f "/app/raw/company_sales/company_sales_clean.csv" ]; then
    print_success "Company sales data found"
else
    print_error "Company sales data not found"
    exit 1
fi

if [ -f "/app/raw/competitor_sales/competitor_sales_clean.sv" ]; then
    print_success "Competitor sales data found (pipe-delimited .sv format)"
else
    print_error "Competitor sales data not found"
    exit 1
fi

echo ""
print_success "All pre-flight checks passed!"

# Run ETL pipelines
print_header "Step 2: Running ETL Pipelines"

# Pipeline 1: Seller Catalog
echo "[1/4] Running Seller Catalog ETL Pipeline..."
if bash /app/scripts/etl_seller_catalog_spark_submit.sh; then
    print_success "Seller Catalog ETL completed"
else
    print_error "Seller Catalog ETL failed"
    exit 1
fi
echo ""

# Pipeline 2: Company Sales
echo "[2/4] Running Company Sales ETL Pipeline..."
if bash /app/scripts/etl_company_sales_spark_submit.sh; then
    print_success "Company Sales ETL completed"
else
    print_error "Company Sales ETL failed"
    exit 1
fi
echo ""

# Pipeline 3: Competitor Sales
echo "[3/4] Running Competitor Sales ETL Pipeline..."
if bash /app/scripts/etl_competitor_sales_spark_submit.sh; then
    print_success "Competitor Sales ETL completed"
else
    print_error "Competitor Sales ETL failed"
    exit 1
fi
echo ""

# Pipeline 4: Consumption Layer
print_header "Step 3: Running Consumption Layer"
echo "[4/4] Running Recommendations Pipeline..."
if bash /app/scripts/consumption_recommendation_spark_submit.sh; then
    print_success "Recommendations Pipeline completed"
else
    print_error "Recommendations Pipeline failed"
    exit 1
fi
echo ""

# Verify outputs
print_header "Step 4: Output Verification"

# Check Hudi tables
if [ -d "/app/processed/seller_catalog_hudi" ]; then
    print_success "Seller catalog Hudi table created"
else
    print_error "Seller catalog Hudi table not found"
fi

if [ -d "/app/processed/company_sales_hudi" ]; then
    print_success "Company sales Hudi table created"
else
    print_error "Company sales Hudi table not found"
fi

if [ -d "/app/processed/competitor_sales_hudi" ]; then
    print_success "Competitor sales Hudi table created"
else
    print_error "Competitor sales Hudi table not found"
fi

# Check recommendations CSV
if [ -d "/app/processed/recommendations_csv" ]; then
    print_success "Recommendations CSV created"
    CSV_COUNT=$(find /app/processed/recommendations_csv -name "*.csv" | wc -l)
    echo "  Found $CSV_COUNT CSV file(s)"
else
    print_error "Recommendations CSV not found"
fi

# Check quarantine (optional)
if [ -d "/app/quarantine" ]; then
    QUARANTINE_COUNT=$(find /app/quarantine -type f -name "*.parquet" 2>/dev/null | wc -l || echo "0")
    if [ "$QUARANTINE_COUNT" -gt 0 ]; then
        echo "  Note: $QUARANTINE_COUNT quarantined record file(s) found"
    fi
fi

# Final summary
print_header "Execution Complete!"
echo "All pipelines have completed successfully!"
echo ""
echo "Output Locations:"
echo "  - Hudi Tables:      /app/processed/"
echo "  - Recommendations:  /app/processed/recommendations_csv/"
echo "  - Quarantine:       /app/quarantine/ (if any invalid records)"
echo ""
echo "To verify outputs:"
echo "  bash /app/verify_outputs.sh"
echo ""
echo "To explore results:"
echo "  # View Hudi tables"
echo "  ls -la /app/processed/"
echo ""
echo "  # View recommendations (first 20 lines)"
echo "  find /app/processed/recommendations_csv -name '*.csv' -exec head -20 {} \\;"
echo ""
print_success "Assignment execution completed successfully!"
echo "================================================================"
echo ""

# Keep container running for inspection
if [ "$RUN_MODE" == "auto" ]; then
    echo "Container will now enter interactive mode for result inspection."
    echo "Press Ctrl+C to exit or use 'docker compose down' to stop the container."
    echo ""
    exec /bin/bash
fi
