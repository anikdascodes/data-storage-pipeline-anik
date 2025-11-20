#!/bin/bash

# Smart Setup Script
# E-commerce Recommendation System
# Roll Number: 2025EM1100026
#
# This script automatically detects the best installation method
# and sets up the environment accordingly

set -e

echo "=========================================="
echo "Smart Setup - E-commerce Recommendation"
echo "Roll Number: 2025EM1100026"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Run environment check
echo "Step 1: Checking your environment..."
echo ""
bash check_environment.sh

# Load results
if [ -f .env_check_results ]; then
    source .env_check_results
else
    echo "ERROR: Environment check failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 2: Selecting Installation Method"
echo "=========================================="
echo ""

# Determine installation method
if [ "$JAVA_INSTALLED" = "true" ] && [ "$SPARK_INSTALLED" = "true" ] && [ "$PYTHON_INSTALLED" = "true" ] && [ "$PYSPARK_INSTALLED" = "true" ]; then
    # Everything is installed - no setup needed
    echo -e "${GREEN}✓ All dependencies are already installed!${NC}"
    echo ""
    echo "No installation needed. You can run the pipeline directly."
    echo ""
    echo -e "${BLUE}Would you like to run the pipeline now? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Starting pipeline execution..."
        bash scripts/run_all_pipelines.sh
    else
        echo ""
        echo "To run the pipeline later, execute:"
        echo "  bash scripts/run_all_pipelines.sh"
    fi
    exit 0

elif [ "$JAVA_INSTALLED" = "true" ] && [ "$PYTHON_INSTALLED" = "true" ] && [ "$SPARK_INSTALLED" = "false" ]; then
    # Only Spark is missing - quick install
    echo -e "${YELLOW}⚠ Only Apache Spark is missing${NC}"
    echo ""
    echo "Recommended: Quick Spark installation (3-5 minutes)"
    echo ""
    echo -e "${BLUE}Install Spark now? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        bash install_spark_quick.sh
        echo ""
        echo "Installation complete! Sourcing environment..."
        source ~/.bashrc
        echo ""
        echo -e "${BLUE}Run the pipeline now? (y/n)${NC}"
        read -r response2
        if [[ "$response2" =~ ^[Yy]$ ]]; then
            bash scripts/run_all_pipelines.sh
        else
            echo ""
            echo "To run the pipeline later:"
            echo "  source ~/.bashrc"
            echo "  bash scripts/run_all_pipelines.sh"
        fi
    else
        echo ""
        echo "To install Spark later, run:"
        echo "  bash install_spark_quick.sh"
    fi
    exit 0

elif [ "$DOCKER_INSTALLED" = "true" ]; then
    # Docker is available - offer Docker or local installation
    echo -e "${YELLOW}⚠ Multiple dependencies are missing${NC}"
    echo ""
    echo "Available options:"
    echo ""
    echo "  1) Docker Full Installation (10-15 min, isolated environment)"
    echo "  2) Docker Slim Installation (2-3 min, uses host Spark if available)"
    echo "  3) Local Installation (5-8 min, installs directly on system)"
    echo "  4) Manual setup (I'll do it myself)"
    echo ""
    echo -e "${BLUE}Select option (1-4):${NC}"
    read -r option
    
    case $option in
        1)
            echo ""
            echo "Starting Docker Full Installation..."
            docker compose -f docker compose.smart.yml --profile full build
            docker compose -f docker compose.smart.yml --profile full up -d
            echo ""
            echo -e "${GREEN}✓ Docker container is ready!${NC}"
            echo ""
            echo "To run the pipeline:"
            echo "  docker compose -f docker compose.smart.yml exec ecommerce-recommendation-full bash"
            echo "  bash /app/scripts/run_all_pipelines.sh"
            ;;
        2)
            echo ""
            if [ "$SPARK_INSTALLED" = "true" ]; then
                echo "Using host Spark installation at: $SPARK_HOME"
                export SPARK_HOME=${SPARK_HOME:-/opt/spark}
                export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-11-openjdk-amd64}
                docker compose -f docker compose.smart.yml --profile slim build
                docker compose -f docker compose.smart.yml --profile slim up -d
                echo ""
                echo -e "${GREEN}✓ Docker container is ready!${NC}"
                echo ""
                echo "To run the pipeline:"
                echo "  docker compose -f docker compose.smart.yml exec ecommerce-recommendation-slim bash"
                echo "  bash /app/scripts/run_all_pipelines.sh"
            else
                echo -e "${YELLOW}⚠ Spark not found on host. Installing locally first...${NC}"
                bash install_spark_quick.sh
                source ~/.bashrc
                export SPARK_HOME=${SPARK_HOME:-/opt/spark}
                export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-11-openjdk-amd64}
                docker compose -f docker compose.smart.yml --profile slim build
                docker compose -f docker compose.smart.yml --profile slim up -d
                echo ""
                echo -e "${GREEN}✓ Docker container is ready!${NC}"
                echo ""
                echo "To run the pipeline:"
                echo "  docker compose -f docker compose.smart.yml exec ecommerce-recommendation-slim bash"
                echo "  bash /app/scripts/run_all_pipelines.sh"
            fi
            ;;
        3)
            echo ""
            echo "Starting Local Installation..."
            bash install_spark.sh
            source ~/.bashrc
            echo ""
            echo -e "${GREEN}✓ Installation complete!${NC}"
            echo ""
            echo -e "${BLUE}Run the pipeline now? (y/n)${NC}"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                bash scripts/run_all_pipelines.sh
            else
                echo ""
                echo "To run the pipeline later:"
                echo "  bash scripts/run_all_pipelines.sh"
            fi
            ;;
        4)
            echo ""
            echo "Manual setup selected. Please refer to:"
            echo "  - QUICK_START_GUIDE.md"
            echo "  - EXECUTION_SUMMARY.md"
            ;;
        *)
            echo ""
            echo "Invalid option. Please run the script again."
            exit 1
            ;;
    esac

else
    # No Docker, need local installation
    echo -e "${YELLOW}⚠ Docker not found. Using local installation.${NC}"
    echo ""
    echo -e "${BLUE}Install required software now? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        bash install_spark.sh
        source ~/.bashrc
        echo ""
        echo -e "${GREEN}✓ Installation complete!${NC}"
        echo ""
        echo -e "${BLUE}Run the pipeline now? (y/n)${NC}"
        read -r response2
        if [[ "$response2" =~ ^[Yy]$ ]]; then
            bash scripts/run_all_pipelines.sh
        else
            echo ""
            echo "To run the pipeline later:"
            echo "  bash scripts/run_all_pipelines.sh"
        fi
    else
        echo ""
        echo "To install later, run:"
        echo "  bash install_spark.sh"
    fi
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
