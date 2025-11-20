#!/bin/bash

# Quick Spark Installation Script
# E-commerce Recommendation System
# Roll Number: 2025EM1100026
#
# This script performs a quick installation of only missing components
# It checks what's already installed and skips unnecessary steps

set -e

echo "=========================================="
echo "Quick Spark Installation"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if environment check was run
if [ -f .env_check_results ]; then
    source .env_check_results
    echo "Loading previous environment check results..."
else
    echo "Running environment check first..."
    bash check_environment.sh
    source .env_check_results
fi

echo ""

# Check Java
if [ "$JAVA_INSTALLED" = "false" ]; then
    echo "Installing Java 11..."
    sudo apt-get update -qq
    sudo apt-get install -y openjdk-11-jdk
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
else
    echo -e "${GREEN}✓ Java already installed, skipping${NC}"
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
fi

# Check Spark
if [ "$SPARK_INSTALLED" = "false" ]; then
    echo ""
    echo "Installing Apache Spark 3.5.0..."
    
    SPARK_VERSION="3.5.0"
    HADOOP_VERSION="3"
    SPARK_DIR="/opt/spark"
    
    if [ ! -d "$SPARK_DIR" ]; then
        cd /tmp
        
        # Try fastest mirror first
        echo "Downloading Spark (this may take 3-5 minutes)..."
        
        if wget -q --show-progress --timeout=120 -O spark.tgz \
            "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" 2>/dev/null; then
            echo "Download successful from primary mirror"
        elif wget -q --show-progress --timeout=120 -O spark.tgz \
            "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" 2>/dev/null; then
            echo "Download successful from archive mirror"
        else
            echo "ERROR: Failed to download Spark"
            exit 1
        fi
        
        echo "Extracting Spark..."
        tar -xzf spark.tgz
        
        echo "Installing Spark to $SPARK_DIR..."
        sudo mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_DIR
        
        rm -f spark.tgz
    fi
    
    export SPARK_HOME=$SPARK_DIR
    export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
    export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
    
else
    echo -e "${GREEN}✓ Spark already installed, skipping${NC}"
    if [ -z "$SPARK_HOME" ]; then
        export SPARK_HOME=/opt/spark
        export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
        export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
    fi
fi

# Check Python
if [ "$PYTHON_INSTALLED" = "false" ]; then
    echo ""
    echo "Installing Python 3..."
    sudo apt-get install -y python3 python3-pip
else
    echo -e "${GREEN}✓ Python already installed, skipping${NC}"
fi

# Check PySpark
if [ "$PYSPARK_INSTALLED" = "false" ]; then
    echo ""
    echo "Installing PySpark and dependencies..."
    pip install --quiet pyspark==3.5.0 pyyaml pandas
else
    echo -e "${GREEN}✓ PySpark already installed, skipping${NC}"
fi

# Update bashrc if needed
if ! grep -q "SPARK_HOME" ~/.bashrc 2>/dev/null; then
    echo ""
    echo "Adding environment variables to ~/.bashrc..."
    cat >> ~/.bashrc << 'EOF'

# Apache Spark Environment Variables (Added by install_spark_quick.sh)
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
export PYSPARK_PYTHON=python3
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
EOF
else
    echo -e "${GREEN}✓ Environment variables already in ~/.bashrc${NC}"
fi

echo ""
echo "=========================================="
echo "Verifying Installation"
echo "=========================================="
echo ""

# Verify Spark
if command -v spark-submit &> /dev/null; then
    echo -e "${GREEN}✓ spark-submit is available${NC}"
    spark-submit --version 2>&1 | grep "version" | head -1
else
    echo "⚠ spark-submit not found in current session"
    echo "  Run: source ~/.bashrc"
fi

# Verify PySpark
if python3 -c "import pyspark" 2>/dev/null; then
    PYSPARK_VERSION=$(python3 -c "import pyspark; print(pyspark.__version__)")
    echo -e "${GREEN}✓ PySpark $PYSPARK_VERSION is available${NC}"
else
    echo "⚠ PySpark not found"
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "To use Spark in this session, run:"
echo "  source ~/.bashrc"
echo ""
echo "Then run the pipeline:"
echo "  cd $(pwd)"
echo "  bash scripts/run_all_pipelines.sh"
echo ""
echo -e "${GREEN}Estimated pipeline runtime: 8-13 minutes${NC}"
echo ""
