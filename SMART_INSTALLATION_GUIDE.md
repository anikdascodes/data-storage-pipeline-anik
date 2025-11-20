# Smart Installation Guide - E-commerce Recommendation System

**Roll Number:** 2025EM1100026  
**Assignment:** Data Storage Pipeline #1  
**Feature:** Intelligent installation that adapts to reviewer's system

---

## 🚀 Quick Start (Recommended)

The **smart setup** automatically detects what's already installed on your system and chooses the fastest installation method.

### One-Command Setup

```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local
bash smart_setup.sh
```

That's it! The script will:
1. ✅ Check what software is already installed
2. ✅ Recommend the fastest installation method
3. ✅ Install only what's missing
4. ✅ Optionally run the pipeline immediately

---

## 📊 Installation Time Comparison

| Scenario | Method | Setup Time | Total Time |
|----------|--------|------------|------------|
| **All software installed** | Direct run | 0 min | 8-13 min |
| **Only Spark missing** | Quick install | 3-5 min | 11-18 min |
| **Java + Python installed** | Quick install | 3-5 min | 11-18 min |
| **Docker available** | Docker slim | 2-3 min | 10-16 min |
| **Nothing installed** | Docker full | 10-15 min | 18-28 min |
| **Nothing installed** | Local install | 5-8 min | 13-21 min |

---

## 🎯 Installation Scenarios

### Scenario 1: Everything Already Installed ⚡

**If you have:**
- ✅ Java 11
- ✅ Apache Spark 3.5.0
- ✅ Python 3.8+
- ✅ PySpark

**Setup time:** 0 minutes  
**Total time:** 8-13 minutes

```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Check environment
bash check_environment.sh

# Run directly
bash scripts/run_all_pipelines.sh
```

### Scenario 2: Only Spark Missing 🔧

**If you have:**
- ✅ Java 11
- ✅ Python 3.8+
- ❌ Apache Spark

**Setup time:** 3-5 minutes  
**Total time:** 11-18 minutes

```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Quick Spark installation
bash install_spark_quick.sh
source ~/.bashrc

# Run pipeline
bash scripts/run_all_pipelines.sh
```

### Scenario 3: Docker Available 🐳

**If you have:**
- ✅ Docker
- ❌ Other dependencies

**Option A: Docker Full (10-15 min setup)**
```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Full installation with all dependencies
docker-compose build
docker-compose up -d
docker-compose exec ecommerce-recommendation bash
bash /app/scripts/run_all_pipelines.sh
```

**Option B: Docker Slim (2-3 min setup, if Spark exists on host)**
```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Slim installation (uses host Spark)
export SPARK_HOME=/opt/spark
docker-compose -f docker-compose.smart.yml --profile slim build
docker-compose -f docker-compose.smart.yml --profile slim up -d
docker-compose -f docker-compose.smart.yml exec ecommerce-recommendation-slim bash
bash /app/scripts/run_all_pipelines.sh
```

### Scenario 4: Fresh System 🆕

**If you have:**
- ❌ No dependencies installed

**Option A: Local Installation (5-8 min setup)**
```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Install everything locally
bash install_spark.sh
source ~/.bashrc

# Run pipeline
bash scripts/run_all_pipelines.sh
```

**Option B: Docker Full (10-15 min setup)**
```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local

# Use Docker for complete isolation
docker-compose build
docker-compose up -d
docker-compose exec ecommerce-recommendation bash
bash /app/scripts/run_all_pipelines.sh
```

---

## 🛠️ Available Scripts

### 1. check_environment.sh
**Purpose:** Detect installed software and recommend best method

```bash
bash check_environment.sh
```

**Output:**
- ✅ Lists all installed dependencies
- ⚠️ Shows missing dependencies
- 💡 Recommends fastest installation method
- ⏱️ Estimates setup and total time

### 2. smart_setup.sh
**Purpose:** Interactive setup that guides you through installation

```bash
bash smart_setup.sh
```

**Features:**
- Auto-detects environment
- Offers multiple installation options
- Interactive prompts
- Can run pipeline immediately after setup

### 3. install_spark_quick.sh
**Purpose:** Install only missing components (fast)

```bash
bash install_spark_quick.sh
```

**Features:**
- Checks what's already installed
- Skips installed components
- Installs only what's needed
- 3-5 minute installation time

### 4. install_spark.sh
**Purpose:** Complete installation from scratch

```bash
bash install_spark.sh
```

**Features:**
- Full installation of all dependencies
- Sets up environment variables
- Adds to ~/.bashrc for persistence
- 5-8 minute installation time

### 5. run_pipeline_smart.sh
**Purpose:** Run pipeline with environment detection

```bash
bash run_pipeline_smart.sh
```

**Features:**
- Detects Docker vs local environment
- Verifies all dependencies
- Checks input data
- Shows execution time
- Colored output for better readability

---

## 📋 Pre-flight Checklist

Before running, the system checks:

- [ ] **Java 11** - Required for Spark
- [ ] **Apache Spark 3.5.0** - Core processing engine
- [ ] **Python 3.8+** - For PySpark
- [ ] **PySpark 3.5.0** - Python Spark bindings
- [ ] **Input Data** - CSV files in raw/ directories
- [ ] **Disk Space** - At least 2GB free

---

## 🎨 Smart Features

### 1. Conditional Installation
Only installs what's missing:
```bash
# If Java exists → Skip Java installation
# If Spark exists → Skip Spark installation
# If PySpark exists → Skip PySpark installation
```

### 2. Multiple Docker Options
Choose based on your needs:
```bash
# Full: Complete isolated environment (slower)
# Slim: Uses host Spark (faster)
```

### 3. Environment Detection
Automatically detects:
```bash
# Running in Docker container?
# Running on host system?
# Which dependencies are available?
```

### 4. Interactive Prompts
Guides you through setup:
```bash
# Would you like to install now? (y/n)
# Run pipeline immediately? (y/n)
# Select installation method (1-4)
```

---

## 🔍 Verification

After installation, verify everything is working:

```bash
# Check Spark
spark-submit --version

# Check PySpark
python3 -c "import pyspark; print(pyspark.__version__)"

# Check Java
java -version

# Run environment check
bash check_environment.sh
```

---

## 📊 Comparison: Traditional vs Smart Installation

### Traditional Approach
```bash
# Always installs everything (10-15 minutes)
docker-compose build
docker-compose up -d
docker-compose exec ecommerce-recommendation bash
bash /app/scripts/run_all_pipelines.sh
```

### Smart Approach
```bash
# Installs only what's needed (0-15 minutes depending on system)
bash smart_setup.sh
# Automatically selects fastest method
# Can be 0 minutes if everything is installed!
```

---

## 💡 Tips for Reviewers

### If You Have Spark Installed
```bash
# Fastest option - no installation needed
cd 2025EM1100026/ecommerce_seller_recommendation/local
bash check_environment.sh
bash scripts/run_all_pipelines.sh
```

### If You Want Isolated Environment
```bash
# Use Docker for complete isolation
cd 2025EM1100026/ecommerce_seller_recommendation/local
docker-compose build
docker-compose up -d
docker-compose exec ecommerce-recommendation bash
bash /app/scripts/run_all_pipelines.sh
```

### If You Want Fastest Setup
```bash
# Use smart setup - it will choose the best method
cd 2025EM1100026/ecommerce_seller_recommendation/local
bash smart_setup.sh
```

---

## 🚨 Troubleshooting

### Issue: "spark-submit not found"

**Solution:**
```bash
# Source environment variables
source ~/.bashrc

# Or set manually
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin
```

### Issue: "PySpark import error"

**Solution:**
```bash
# Install PySpark
pip install pyspark==3.5.0

# Or use smart setup
bash smart_setup.sh
```

### Issue: "Docker build too slow"

**Solution:**
```bash
# Use local installation instead
bash install_spark_quick.sh
source ~/.bashrc
bash scripts/run_all_pipelines.sh
```

### Issue: "Permission denied"

**Solution:**
```bash
# Make scripts executable
chmod +x *.sh scripts/*.sh
```

---

## 📈 Performance Optimization

### For Fastest Execution

1. **Check existing installations first:**
   ```bash
   bash check_environment.sh
   ```

2. **If everything is installed:**
   ```bash
   bash scripts/run_all_pipelines.sh  # 8-13 minutes
   ```

3. **If only Spark is missing:**
   ```bash
   bash install_spark_quick.sh  # 3-5 minutes
   bash scripts/run_all_pipelines.sh  # 8-13 minutes
   ```

4. **If using Docker with host Spark:**
   ```bash
   docker-compose -f docker-compose.smart.yml --profile slim build  # 2-3 minutes
   # Then run pipeline
   ```

---

## 🎓 For Assignment Reviewers

### Recommended Workflow

1. **First, check your system:**
   ```bash
   cd 2025EM1100026/ecommerce_seller_recommendation/local
   bash check_environment.sh
   ```

2. **Follow the recommendation:**
   - If all installed → Run directly (8-13 min total)
   - If Spark missing → Quick install (11-18 min total)
   - If nothing installed → Choose Docker or local (13-28 min total)

3. **Or use smart setup:**
   ```bash
   bash smart_setup.sh
   # Follow interactive prompts
   ```

### Time Savings

| Your System | Traditional | Smart | Time Saved |
|-------------|-------------|-------|------------|
| All installed | 18-28 min | 8-13 min | **10-15 min** |
| Spark missing | 18-28 min | 11-18 min | **7-10 min** |
| Nothing | 18-28 min | 13-21 min | **5-7 min** |

---

## 📚 Additional Resources

- **QUICK_START_GUIDE.md** - Step-by-step instructions
- **EXECUTION_SUMMARY.md** - Complete execution guide
- **ASSIGNMENT_REVIEW.md** - Detailed code review
- **README.md** - Project documentation

---

## ✅ Summary

The smart installation system provides:

1. **⚡ Speed** - Only installs what's needed
2. **🎯 Flexibility** - Multiple installation options
3. **🤖 Intelligence** - Auto-detects environment
4. **💬 Guidance** - Interactive prompts
5. **⏱️ Time Savings** - Up to 15 minutes saved

**Recommended command for reviewers:**
```bash
bash smart_setup.sh
```

---

**Prepared by:** Ona AI Assistant  
**Date:** November 20, 2025  
**Status:** Ready for Review 🚀
