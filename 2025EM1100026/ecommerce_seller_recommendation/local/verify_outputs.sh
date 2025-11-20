#!/bin/bash

# Output Verification Script
# E-commerce Recommendation System
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

echo "================================================================"
echo "  Output Verification Report"
echo "  E-commerce Recommendation System"
echo "  Student Roll No: 2025EM1100026"
echo "================================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Function to check and report
check_output() {
    local name=$1
    local path=$2
    local type=$3

    if [ -e "$path" ]; then
        echo -e "${GREEN}✓${NC} $name: Found"
        PASSED=$((PASSED + 1))

        # Additional info based on type
        if [ "$type" == "hudi" ]; then
            local parquet_count=$(find "$path" -name "*.parquet" 2>/dev/null | wc -l)
            echo "  └─ Parquet files: $parquet_count"

            # Check for Hudi metadata
            if [ -d "$path/.hoodie" ]; then
                echo "  └─ Hudi metadata: Present"
            fi
        elif [ "$type" == "csv" ]; then
            local csv_file=$(find "$path" -name "*.csv" -type f | head -n 1)
            if [ -n "$csv_file" ]; then
                local line_count=$(wc -l < "$csv_file" 2>/dev/null || echo "0")
                echo "  └─ CSV file: $(basename "$csv_file")"
                echo "  └─ Total lines: $line_count"

                # Show first few lines
                if [ "$line_count" -gt 0 ]; then
                    echo "  └─ Sample (first 5 rows):"
                    head -5 "$csv_file" | sed 's/^/       /'
                fi
            fi
        fi
    else
        echo -e "${RED}✗${NC} $name: NOT FOUND"
        echo "  └─ Expected path: $path"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

echo "1. Checking Hudi Tables..."
echo "-----------------------------------"
check_output "Seller Catalog Hudi Table" "/app/processed/seller_catalog_hudi" "hudi"
check_output "Company Sales Hudi Table" "/app/processed/company_sales_hudi" "hudi"
check_output "Competitor Sales Hudi Table" "/app/processed/competitor_sales_hudi" "hudi"

echo "2. Checking Recommendation Outputs..."
echo "-----------------------------------"
check_output "Recommendations CSV" "/app/processed/recommendations_csv" "csv"

echo "3. Checking Quarantine Zone..."
echo "-----------------------------------"
if [ -d "/app/quarantine" ]; then
    QUARANTINE_FILES=$(find /app/quarantine -type f -name "*.parquet" 2>/dev/null | wc -l)
    if [ "$QUARANTINE_FILES" -gt 0 ]; then
        echo -e "${YELLOW}!${NC} Quarantine: $QUARANTINE_FILES file(s) found"
        echo "  └─ This indicates some records failed DQ checks"

        # List quarantine directories
        for dir in /app/quarantine/*/; do
            if [ -d "$dir" ]; then
                dataset=$(basename "$dir")
                count=$(find "$dir" -name "*.parquet" | wc -l)
                if [ "$count" -gt 0 ]; then
                    echo "  └─ $dataset: $count file(s)"
                fi
            fi
        done
    else
        echo -e "${GREEN}✓${NC} Quarantine: Empty (all records passed DQ checks)"
    fi
else
    echo -e "${YELLOW}!${NC} Quarantine directory not found"
fi
echo ""

echo "4. Storage Summary..."
echo "-----------------------------------"
if [ -d "/app/processed" ]; then
    TOTAL_SIZE=$(du -sh /app/processed 2>/dev/null | cut -f1)
    echo "Total processed data size: $TOTAL_SIZE"
fi

if [ -d "/app/quarantine" ]; then
    QUARANTINE_SIZE=$(du -sh /app/quarantine 2>/dev/null | cut -f1)
    echo "Total quarantine data size: $QUARANTINE_SIZE"
fi
echo ""

echo "================================================================"
echo "  Verification Summary"
echo "================================================================"
echo -e "${GREEN}Passed:${NC} $PASSED checks"
if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Failed:${NC} $FAILED checks"
fi
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ All expected outputs are present!${NC}"
    echo ""
    echo "Assignment Status: SUCCESS"
    exit 0
else
    echo -e "${RED}✗ Some outputs are missing!${NC}"
    echo ""
    echo "Assignment Status: INCOMPLETE"
    exit 1
fi
