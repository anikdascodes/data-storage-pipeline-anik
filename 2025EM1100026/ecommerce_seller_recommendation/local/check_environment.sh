#!/bin/bash

# Environment Pre-flight Check Script
# E-commerce Recommendation System
# Roll Number: 2025EM1100026
#
# This script checks if required software is already installed
# and provides recommendations for the fastest setup method

set -e

echo "=========================================="
echo "Environment Pre-flight Check"
echo "E-commerce Recommendation System"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Tracking variables
JAVA_INSTALLED=false
SPARK_INSTALLED=false
PYTHON_INSTALLED=false
PYSPARK_INSTALLED=false
DOCKER_INSTALLED=false

# Check Java
echo -n "Checking Java 11... "
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" = "11" ] || [ "$JAVA_VERSION" = "1" ]; then
        echo -e "${GREEN}✓ Found${NC}"
        JAVA_INSTALLED=true
        java -version 2>&1 | head -1
    else
        echo -e "${YELLOW}⚠ Found but version is $JAVA_VERSION (need 11)${NC}"
    fi
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Check Spark
echo -n "Checking Apache Spark... "
if command -v spark-submit &> /dev/null; then
    echo -e "${GREEN}✓ Found${NC}"
    SPARK_INSTALLED=true
    SPARK_VERSION=$(spark-submit --version 2>&1 | grep "version" | head -1)
    echo "  $SPARK_VERSION"
    if [ -n "$SPARK_HOME" ]; then
        echo "  SPARK_HOME: $SPARK_HOME"
    fi
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Check Python
echo -n "Checking Python 3... "
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo -e "${GREEN}✓ Found (v$PYTHON_VERSION)${NC}"
    PYTHON_INSTALLED=true
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Check PySpark
echo -n "Checking PySpark... "
if python3 -c "import pyspark" 2>/dev/null; then
    PYSPARK_VERSION=$(python3 -c "import pyspark; print(pyspark.__version__)" 2>/dev/null)
    echo -e "${GREEN}✓ Found (v$PYSPARK_VERSION)${NC}"
    PYSPARK_INSTALLED=true
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Check Docker
echo -n "Checking Docker... "
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
    echo -e "${GREEN}✓ Found (v$DOCKER_VERSION)${NC}"
    DOCKER_INSTALLED=true
else
    echo -e "${RED}✗ Not found${NC}"
fi

echo ""
echo "=========================================="
echo "Recommendation"
echo "=========================================="
echo ""

# Determine best installation method
if [ "$JAVA_INSTALLED" = true ] && [ "$SPARK_INSTALLED" = true ] && [ "$PYTHON_INSTALLED" = true ] && [ "$PYSPARK_INSTALLED" = true ]; then
    echo -e "${GREEN}✓ All required software is already installed!${NC}"
    echo ""
    echo "You can run the pipeline directly without any installation:"
    echo ""
    echo "  cd $(pwd)"
    echo "  bash scripts/run_all_pipelines.sh"
    echo ""
    echo -e "${GREEN}Estimated setup time: 0 minutes${NC}"
    echo -e "${GREEN}Estimated total runtime: 8-13 minutes${NC}"
    echo ""
    exit 0

elif [ "$JAVA_INSTALLED" = true ] && [ "$PYTHON_INSTALLED" = true ]; then
    echo -e "${YELLOW}⚠ Java and Python are installed, but Spark is missing${NC}"
    echo ""
    echo "Quick installation option (recommended):"
    echo ""
    echo "  bash install_spark_quick.sh"
    echo ""
    echo -e "${YELLOW}Estimated setup time: 3-5 minutes${NC}"
    echo -e "${YELLOW}Estimated total runtime: 11-18 minutes${NC}"
    echo ""
    echo "This will:"
    echo "  - Download and install Apache Spark 3.5.0"
    echo "  - Install PySpark and dependencies"
    echo "  - Configure environment variables"
    echo ""

elif [ "$DOCKER_INSTALLED" = true ]; then
    echo -e "${YELLOW}⚠ Some dependencies are missing${NC}"
    echo ""
    echo "Option 1: Docker (Full installation, slower but isolated)"
    echo ""
    echo "  docker-compose build"
    echo "  docker-compose up -d"
    echo "  docker-compose exec ecommerce-recommendation bash"
    echo "  bash /app/scripts/run_all_pipelines.sh"
    echo ""
    echo -e "${YELLOW}Estimated setup time: 10-15 minutes${NC}"
    echo -e "${YELLOW}Estimated total runtime: 18-28 minutes${NC}"
    echo ""
    echo "Option 2: Local installation (faster)"
    echo ""
    echo "  bash install_spark.sh"
    echo "  source ~/.bashrc"
    echo "  bash scripts/run_all_pipelines.sh"
    echo ""
    echo -e "${YELLOW}Estimated setup time: 5-8 minutes${NC}"
    echo -e "${YELLOW}Estimated total runtime: 13-21 minutes${NC}"
    echo ""

else
    echo -e "${RED}✗ Multiple dependencies are missing${NC}"
    echo ""
    echo "Recommended: Use Docker for complete setup"
    echo ""
    echo "  docker-compose build"
    echo "  docker-compose up -d"
    echo "  docker-compose exec ecommerce-recommendation bash"
    echo "  bash /app/scripts/run_all_pipelines.sh"
    echo ""
    echo -e "${RED}Estimated setup time: 10-15 minutes${NC}"
    echo -e "${RED}Estimated total runtime: 18-28 minutes${NC}"
    echo ""
fi

echo "=========================================="
echo "Detailed Installation Guides"
echo "=========================================="
echo ""
echo "For step-by-step instructions, see:"
echo "  - QUICK_START_GUIDE.md"
echo "  - EXECUTION_SUMMARY.md"
echo ""

# Save results to file for other scripts to use
cat > .env_check_results << EOF
JAVA_INSTALLED=$JAVA_INSTALLED
SPARK_INSTALLED=$SPARK_INSTALLED
PYTHON_INSTALLED=$PYTHON_INSTALLED
PYSPARK_INSTALLED=$PYSPARK_INSTALLED
DOCKER_INSTALLED=$DOCKER_INSTALLED
EOF

echo "Environment check results saved to .env_check_results"
echo ""
