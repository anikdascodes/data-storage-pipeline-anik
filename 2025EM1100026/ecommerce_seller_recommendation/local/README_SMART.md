# E-commerce Recommendation System - Smart Installation

**Roll Number:** 2025EM1100026  
**Assignment:** Data Storage Pipeline #1  
**Feature:** Intelligent setup that adapts to your system

---

## 🚀 Quick Start for Reviewers

### One-Command Setup (Recommended)

```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local
bash smart_setup.sh
```

This intelligent script will:
1. ✅ Detect what's already installed on your system
2. ✅ Recommend the fastest installation method
3. ✅ Install only missing components
4. ✅ Optionally run the pipeline immediately

**Time savings: Up to 15 minutes compared to full Docker installation!**

---

## 📊 Installation Options

### Option 1: Smart Setup (Recommended) ⚡

**Best for:** All reviewers

```bash
bash smart_setup.sh
```

**Benefits:**
- Automatically detects your environment
- Chooses fastest installation method
- Interactive guidance
- Time: 0-15 minutes depending on your system

### Option 2: Check First, Then Decide 🔍

**Best for:** Reviewers who want to see what's needed first

```bash
# Step 1: Check your environment
bash check_environment.sh

# Step 2: Follow the recommendation shown
# (Could be 0 minutes if everything is installed!)
```

### Option 3: Direct Run (If You Have Spark) 🏃

**Best for:** Reviewers with Spark already installed

```bash
# Just run it!
bash scripts/run_all_pipelines.sh
```

**Time:** 8-13 minutes (no installation needed)

### Option 4: Traditional Docker 🐳

**Best for:** Reviewers who prefer isolated environments

```bash
docker compose build
docker compose up -d
docker compose exec ecommerce-recommendation bash
bash /app/scripts/run_all_pipelines.sh
```

**Time:** 18-28 minutes (full installation)

---

## ⏱️ Time Comparison

| Your System | Smart Setup | Traditional Docker | Time Saved |
|-------------|-------------|-------------------|------------|
| **All installed** | 8-13 min | 18-28 min | **10-15 min** ⚡ |
| **Spark missing** | 11-18 min | 18-28 min | **7-10 min** ⚡ |
| **Nothing installed** | 13-21 min | 18-28 min | **5-7 min** ⚡ |

---

## 🎯 What Makes This "Smart"?

### 1. Environment Detection
Automatically checks:
- ✅ Java 11
- ✅ Apache Spark 3.5.0
- ✅ Python 3.8+
- ✅ PySpark
- ✅ Docker

### 2. Conditional Installation
Only installs what's missing:
```
If Spark exists → Skip Spark installation (saves 5-8 minutes)
If Java exists → Skip Java installation (saves 2-3 minutes)
If PySpark exists → Skip PySpark installation (saves 1-2 minutes)
```

### 3. Multiple Paths
Offers different installation methods based on your system:
- **Path A:** Direct run (0 min setup)
- **Path B:** Quick install (3-5 min setup)
- **Path C:** Docker slim (2-3 min setup)
- **Path D:** Docker full (10-15 min setup)
- **Path E:** Local install (5-8 min setup)

### 4. Interactive Guidance
Asks questions and guides you:
```
Would you like to install now? (y/n)
Run pipeline immediately? (y/n)
Select installation method (1-4)
```

---

## 📋 Available Scripts

### Core Scripts

| Script | Purpose | Time | When to Use |
|--------|---------|------|-------------|
| `smart_setup.sh` | Interactive setup | 0-15 min | **Recommended for all reviewers** |
| `check_environment.sh` | Check system | 0 min | Want to see what's needed first |
| `install_spark_quick.sh` | Install missing only | 3-5 min | Only Spark is missing |
| `install_spark.sh` | Full installation | 5-8 min | Fresh system, no Docker |
| `run_pipeline_smart.sh` | Run with checks | 8-13 min | After installation |
| `scripts/run_all_pipelines.sh` | Run directly | 8-13 min | Everything already installed |

### Docker Options

| File | Purpose | Time | When to Use |
|------|---------|------|-------------|
| `docker compose.yml` | Full Docker | 10-15 min | Traditional approach |
| `docker compose.smart.yml` | Smart Docker | 2-15 min | Choose full or slim |
| `Dockerfile` | Full image | 10-15 min | Complete isolation |
| `Dockerfile.slim` | Slim image | 2-3 min | Use host Spark |

---

## 🎓 For Assignment Reviewers

### Recommended Workflow

**Step 1: Navigate to project**
```bash
cd 2025EM1100026/ecommerce_seller_recommendation/local
```

**Step 2: Run smart setup**
```bash
bash smart_setup.sh
```

**Step 3: Follow prompts**
The script will guide you through the rest!

### Alternative: Manual Check

**Step 1: Check environment**
```bash
bash check_environment.sh
```

**Step 2: Follow recommendation**
The script will tell you the fastest method for your system.

---

## 💡 Example Scenarios

### Scenario A: Reviewer Has Spark Installed

```bash
$ bash check_environment.sh

✓ Java 11 found
✓ Apache Spark found
✓ Python 3 found
✓ PySpark found

Recommendation: All dependencies installed!
You can run directly without installation.

$ bash scripts/run_all_pipelines.sh
# Pipeline runs immediately (8-13 minutes)
```

**Total time: 8-13 minutes** ⚡

### Scenario B: Reviewer Has Java/Python, Missing Spark

```bash
$ bash smart_setup.sh

✓ Java 11 found
✓ Python 3 found
✗ Spark not found

Recommendation: Quick Spark installation (3-5 minutes)

Install Spark now? (y/n) y
# Installs Spark only
# Then runs pipeline

Total time: 11-18 minutes
```

**Total time: 11-18 minutes** ⚡

### Scenario C: Fresh System

```bash
$ bash smart_setup.sh

✗ Multiple dependencies missing

Available options:
  1) Docker Full (10-15 min)
  2) Docker Slim (2-3 min, needs host Spark)
  3) Local Installation (5-8 min)
  4) Manual setup

Select option: 3
# Installs everything locally
# Then runs pipeline

Total time: 13-21 minutes
```

**Total time: 13-21 minutes** ⚡

---

## 🔧 Technical Details

### What Gets Checked

```bash
check_environment.sh checks:
├── Java 11 (required for Spark)
├── Apache Spark 3.5.0 (core engine)
├── Python 3.8+ (for PySpark)
├── PySpark 3.5.0 (Python bindings)
├── Docker (optional, for containerization)
└── Input data files (CSV files)
```

### What Gets Installed

```bash
install_spark_quick.sh installs:
├── Java 11 (if missing)
├── Apache Spark 3.5.0 (if missing)
├── PySpark 3.5.0 (if missing)
├── PyYAML (if missing)
└── Pandas (if missing)

Skips already installed components!
```

### Environment Variables Set

```bash
export SPARK_HOME=/opt/spark
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip
export PYSPARK_PYTHON=python3
```

---

## 🎨 Features

### Color-Coded Output

- 🟢 **Green:** Success, component found
- 🟡 **Yellow:** Warning, component missing
- 🔴 **Red:** Error, critical issue
- 🔵 **Blue:** Information, progress update

### Progress Tracking

```
[1/4] Running Seller Catalog ETL Pipeline...
✓ Seller Catalog ETL completed successfully

[2/4] Running Company Sales ETL Pipeline...
✓ Company Sales ETL completed successfully

[3/4] Running Competitor Sales ETL Pipeline...
✓ Competitor Sales ETL completed successfully

[4/4] Running Consumption Layer - Recommendations...
✓ Consumption Layer completed successfully

Total execution time: 10m 23s
```

### Smart Recommendations

Based on your system, you'll see:
```
✓ All dependencies installed!
  → Run directly (0 min setup)

⚠ Only Spark missing
  → Quick install (3-5 min setup)

⚠ Multiple dependencies missing
  → Choose Docker or local (5-15 min setup)
```

---

## 📚 Documentation Structure

```
Root Documentation:
├── SMART_INSTALLATION_GUIDE.md    ← Detailed smart installation guide
├── QUICK_START_GUIDE.md           ← Traditional step-by-step guide
├── EXECUTION_SUMMARY.md           ← Complete execution reference
├── ASSIGNMENT_REVIEW.md           ← Code review and assessment
└── README_MAIN.md                 ← Main overview

Project Documentation:
└── 2025EM1100026/ecommerce_seller_recommendation/local/
    ├── README.md                  ← Project-specific documentation
    └── README_SMART.md            ← This file
```

---

## 🚨 Troubleshooting

### Issue: "spark-submit not found"

```bash
# Solution 1: Source environment
source ~/.bashrc

# Solution 2: Set manually
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin
```

### Issue: "Java version mismatch"

```bash
# The system works with Java 11 or 21
# If you have Java 21, it will still work
# No action needed
```

### Issue: "Docker build too slow"

```bash
# Use local installation instead
bash install_spark_quick.sh
source ~/.bashrc
bash scripts/run_all_pipelines.sh
```

### Issue: "Permission denied"

```bash
# Make all scripts executable
chmod +x *.sh scripts/*.sh
```

---

## ✅ Verification

After setup, verify everything works:

```bash
# Check Spark
spark-submit --version

# Check PySpark
python3 -c "import pyspark; print(pyspark.__version__)"

# Check environment
bash check_environment.sh

# Run pipeline
bash run_pipeline_smart.sh
```

---

## 📊 Expected Outputs

After successful execution:

```
processed/
├── seller_catalog_hudi/        ← Hudi table
├── company_sales_hudi/         ← Hudi table
├── competitor_sales_hudi/      ← Hudi table
└── recommendations_csv/
    └── seller_recommend_data.csv  ← Final recommendations

quarantine/
├── seller_catalog/             ← Invalid records (if any)
├── company_sales/              ← Invalid records (if any)
└── competitor_sales/           ← Invalid records (if any)
```

---

## 🎯 Summary

### Why Use Smart Installation?

1. **⚡ Faster** - Only installs what's needed
2. **🎯 Flexible** - Multiple installation paths
3. **🤖 Intelligent** - Auto-detects environment
4. **💬 Interactive** - Guides you through setup
5. **⏱️ Time-Saving** - Up to 15 minutes saved

### Recommended for Reviewers

```bash
# One command does it all
bash smart_setup.sh
```

### For Quick Testing

```bash
# Check first
bash check_environment.sh

# Then run if ready
bash scripts/run_all_pipelines.sh
```

---

## 📞 Support

For detailed information:
- **Smart Installation:** SMART_INSTALLATION_GUIDE.md
- **Traditional Setup:** QUICK_START_GUIDE.md
- **Complete Guide:** EXECUTION_SUMMARY.md
- **Code Review:** ASSIGNMENT_REVIEW.md

---

**Prepared by:** Ona AI Assistant  
**Date:** November 20, 2025  
**Status:** Ready for Review 🚀

---

## 🏆 Key Takeaway

**Traditional approach:** Always 18-28 minutes  
**Smart approach:** 8-28 minutes (depending on your system)  
**Best case:** 8 minutes (if everything is installed)  
**Worst case:** Same as traditional (if nothing is installed)

**You can only save time, never lose it!** ⚡
