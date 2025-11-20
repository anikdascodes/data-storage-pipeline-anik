# Dockerfile for E-commerce Recommendation System
# Student: MSc Data Science & AI, Roll No: 2025EM1100026
# Lightweight production-ready environment

FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYSPARK_PYTHON=/usr/bin/python3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    python3 \
    python3-pip \
    wget \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Download and install Apache Spark (optimized)
RUN mkdir -p /opt && \
    cd /opt && \
    wget -q https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.0-bin-hadoop3.tgz && \
    mv spark-3.5.0-bin-hadoop3 spark && \
    rm spark-3.5.0-bin-hadoop3.tgz

# Set working directory
WORKDIR /app

# Copy project files
COPY requirements.txt /app/

# Install Python dependencies using pip (uv alternative for reliability)
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install -r requirements.txt

# Copy the entire project
COPY . /app/

# Make scripts executable and convert line endings (Windows -> Unix)
RUN chmod +x /app/docker-entrypoint.sh && \
    chmod +x /app/RUN_ASSIGNMENT.sh && \
    chmod +x /app/scripts/*.sh && \
    find /app -name "*.sh" -type f -exec sed -i 's/\r$//' {} \;

# Create necessary directories
RUN mkdir -p /app/processed /app/quarantine /app/logs

# Set entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Default command (can be overridden)
CMD ["auto"]
