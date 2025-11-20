#!/bin/bash

# Install Apache Spark 3.5.0 for E-commerce Recommendation System
# Roll Number: 2025EM1100026

set -e

echo "=========================================="
echo "Installing Apache Spark 3.5.0"
echo "=========================================="

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java not found. Installing OpenJDK 11..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
fi

# Set Java Home
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME: $JAVA_HOME"

# Check Java version
java -version

# Download Spark if not already present
SPARK_VERSION="3.5.0"
HADOOP_VERSION="3"
SPARK_DIR="/opt/spark"

if [ -d "$SPARK_DIR" ]; then
    echo "Spark already installed at $SPARK_DIR"
else
    echo "Downloading Apache Spark $SPARK_VERSION..."
    
    cd /tmp
    
    # Try multiple mirrors for faster download
    MIRRORS=(
        "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
        "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
        "https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
    )
    
    DOWNLOADED=false
    for MIRROR in "${MIRRORS[@]}"; do
        echo "Trying mirror: $MIRROR"
        if wget -q --show-progress --timeout=60 -O spark.tgz "$MIRROR"; then
            DOWNLOADED=true
            break
        else
            echo "Failed to download from $MIRROR, trying next..."
        fi
    done
    
    if [ "$DOWNLOADED" = false ]; then
        echo "ERROR: Failed to download Spark from all mirrors"
        exit 1
    fi
    
    echo "Extracting Spark..."
    tar -xzf spark.tgz
    
    echo "Installing Spark to $SPARK_DIR..."
    sudo mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_DIR
    
    echo "Cleaning up..."
    rm -f spark.tgz
fi

# Set environment variables
export SPARK_HOME=$SPARK_DIR
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
export PYSPARK_PYTHON=python3

# Add to bashrc for persistence
if ! grep -q "SPARK_HOME" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Apache Spark Environment Variables" >> ~/.bashrc
    echo "export SPARK_HOME=$SPARK_DIR" >> ~/.bashrc
    echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> ~/.bashrc
    echo "export PYTHONPATH=\$SPARK_HOME/python:\$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:\$PYTHONPATH" >> ~/.bashrc
    echo "export PYSPARK_PYTHON=python3" >> ~/.bashrc
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
fi

# Verify installation
echo ""
echo "=========================================="
echo "Verifying Spark Installation"
echo "=========================================="
echo "SPARK_HOME: $SPARK_HOME"
echo "JAVA_HOME: $JAVA_HOME"
echo ""

if command -v spark-submit &> /dev/null; then
    echo "✅ spark-submit found"
    spark-submit --version
else
    echo "❌ spark-submit not found in PATH"
    exit 1
fi

# Install Python dependencies
echo ""
echo "=========================================="
echo "Installing Python Dependencies"
echo "=========================================="

pip install --quiet pyspark==3.5.0 pyyaml pandas

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "To use Spark in new terminal sessions, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or set environment variables manually:"
echo "  export SPARK_HOME=$SPARK_DIR"
echo "  export PATH=\$PATH:\$SPARK_HOME/bin"
echo "  export PYTHONPATH=\$SPARK_HOME/python:\$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip"
echo ""
echo "Test Spark:"
echo "  spark-submit --version"
echo ""
