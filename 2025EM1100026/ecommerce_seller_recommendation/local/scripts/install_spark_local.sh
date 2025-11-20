#!/bin/bash

# Quick Local Spark Installation Script
# For faster testing without Docker
# Student: MSc Data Science & AI, Roll No: 2025EM1100026

set -e

echo "=============================================="
echo "Quick Spark 3.5.0 Installation Script"
echo "=============================================="
echo ""

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Installing Java 11..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
    echo "✓ Java installed"
else
    echo "✓ Java already installed"
fi

# Set Java Home
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Check if Spark is already installed
if [ -d "/opt/spark" ]; then
    echo "✓ Spark already installed at /opt/spark"
else
    echo "Downloading Apache Spark 3.5.0..."
    cd /tmp

    # Try faster mirror first, fallback to archive
    if ! wget --timeout=30 --tries=2 -q --show-progress https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz; then
        echo "Trying fallback mirror..."
        wget --timeout=30 --tries=2 -q --show-progress https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
    fi

    echo "Extracting Spark..."
    tar -xzf spark-3.5.0-bin-hadoop3.tgz

    echo "Installing Spark to /opt/spark..."
    sudo mv spark-3.5.0-bin-hadoop3 /opt/spark

    rm spark-3.5.0-bin-hadoop3.tgz
    echo "✓ Spark installed"
fi

# Set Spark environment variables
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=python3

# Install Python dependencies
echo "Installing Python dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install pyspark==3.5.0 pyyaml pandas

echo ""
echo "=============================================="
echo "Installation Complete!"
echo "=============================================="
echo ""
echo "Please run these commands to set environment variables:"
echo ""
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
echo "export SPARK_HOME=/opt/spark"
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin"
echo "export PYSPARK_PYTHON=python3"
echo ""
echo "Or add them to your ~/.bashrc file"
echo ""
echo "Test with: spark-submit --version"
echo ""
