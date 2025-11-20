#!/bin/bash

# QUICK START SCRIPT FOR TEACHER EVALUATION
# Student: MSc Data Science & AI, Roll No: 2025EM1100026
# Assignment: Data Storage and Pipeline

echo "=========================================="
echo "E-COMMERCE RECOMMENDATION SYSTEM"
echo "Student: MSc Data Science & AI"
echo "Roll No: 2025EM1100026"
echo "=========================================="
echo ""
echo "This script will run the complete assignment pipeline."
echo "Choose your execution method:"
echo ""
echo "1. 🐳 Docker (Recommended - No setup required)"
echo "2. 🖥️  Local (Requires Spark installation)"
echo "3. 📊 Complete Demo (Both clean and dirty data)"
echo ""

read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        echo ""
        echo "🐳 Starting Docker execution..."
        echo "This will build and run the complete pipeline in Docker."
        echo ""
        
        # Check if Docker is available
        if ! command -v docker &> /dev/null; then
            echo "❌ Docker not found. Please install Docker first."
            echo "   Or choose option 2 for local execution."
            exit 1
        fi
        
        echo "Building Docker image..."
        docker compose build
        
        echo "Running pipeline..."
        docker compose up
        
        echo ""
        echo "✅ Docker execution completed!"
        echo "Check the 'processed/' folder for results."
        ;;
        
    2)
        echo ""
        echo "🖥️  Starting local execution..."
        echo "Using clean datasets for production-ready processing."
        echo ""
        
        # Check if Spark is available
        if ! command -v spark-submit &> /dev/null; then
            echo "❌ Spark not found. Please install Apache Spark 3.5.0 first."
            echo "   Or choose option 1 for Docker execution."
            exit 1
        fi
        
        # Clean previous outputs
        rm -rf processed/ quarantine/ logs/
        mkdir -p processed/ quarantine/ logs/
        
        # Run ETL pipelines
        echo "📊 Step 1: Processing Seller Catalog..."
        bash scripts/etl_seller_catalog_spark_submit.sh --config configs/ecomm_local.yml
        
        echo "📊 Step 2: Processing Company Sales..."
        bash scripts/etl_company_sales_spark_submit.sh --config configs/ecomm_local.yml
        
        echo "📊 Step 3: Processing Competitor Sales..."
        bash scripts/etl_competitor_sales_spark_submit.sh --config configs/ecomm_local.yml
        
        echo "🎯 Step 4: Generating Recommendations..."
        bash scripts/consumption_recommendation_spark_submit.sh --config configs/ecomm_local.yml
        
        echo ""
        echo "✅ Local execution completed!"
        echo "Check the 'processed/' folder for results."
        ;;
        
    3)
        echo ""
        echo "📊 Starting complete demo..."
        echo "This will demonstrate both clean and dirty data processing."
        echo ""
        
        bash run_complete_demo.sh
        ;;
        
    *)
        echo "❌ Invalid choice. Please run the script again and choose 1, 2, or 3."
        exit 1
        ;;
esac

echo ""
echo "📁 Output Files:"
echo "  - processed/seller_catalog_hudi/     (Seller catalog Hudi table)"
echo "  - processed/company_sales_hudi/      (Company sales Hudi table)"
echo "  - processed/competitor_sales_hudi/   (Competitor sales Hudi table)"
echo "  - processed/recommendations_csv/     (Final recommendations CSV)"
echo "  - quarantine/                       (Invalid records, if any)"
echo ""
echo "🎉 Assignment execution completed successfully!"