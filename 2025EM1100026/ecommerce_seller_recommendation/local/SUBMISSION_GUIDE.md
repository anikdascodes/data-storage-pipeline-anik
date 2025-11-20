# E-commerce Recommendation System - Submission Guide

**Student:** MSc Data Science & AI  
**Roll No:** 2025EM1100026  
**Assignment:** Data Storage and Pipeline  

---

## 🎯 Quick Start for Teacher Evaluation

### Option 1: One-Click Execution (Recommended)

```bash
bash RUN_ASSIGNMENT.sh
```

This interactive script provides three execution modes:
1. **Docker** (no setup required)
2. **Local** (requires Spark)
3. **Complete Demo** (both clean and dirty data)

### Option 2: Docker Execution

```bash
docker compose up --build
```

### Option 3: Complete Demo (Showcases DQ Framework)

```bash
bash run_complete_demo.sh
```

---

## 📊 What This Assignment Demonstrates

### ✅ All Assignment Requirements Met

1. **3 ETL Pipelines** - Seller Catalog, Company Sales, Competitor Sales
2. **1 Consumption Layer** - Recommendation Generation
3. **Apache Hudi Integration** - Schema evolution, incremental upserts
4. **Medallion Architecture** - Bronze → Silver → Gold layers
5. **Quarantine Zone** - Invalid records isolation with failure reasons
6. **Data Quality Framework** - Comprehensive validation rules
7. **YAML Configuration** - Flexible path management
8. **Docker Containerization** - Zero-setup execution

### 🔍 Enhanced Features

1. **Dual Dataset Processing:**
   - **Clean Data:** Production-ready processing
   - **Dirty Data:** DQ framework demonstration

2. **Comprehensive Validation:**
   - Missing value checks
   - Data type validation
   - Business rule enforcement
   - Date format validation

3. **Production-Ready Architecture:**
   - Error handling and logging
   - Configurable paths
   - Scalable design patterns

---

## 📁 Project Structure

```
2025EM1100026/ecommerce_seller_recommendation/local/
├── configs/
│   ├── ecomm_local.yml      # Clean data configuration
│   ├── ecomm_dirty.yml      # Dirty data configuration
│   └── ecomm_prod.yml       # Production configuration
├── src/
│   ├── etl_seller_catalog.py
│   ├── etl_company_sales.py
│   ├── etl_competitor_sales.py
│   └── consumption_recommendation.py
├── scripts/
│   ├── etl_seller_catalog_spark_submit.sh
│   ├── etl_company_sales_spark_submit.sh
│   ├── etl_competitor_sales_spark_submit.sh
│   └── consumption_recommendation_spark_submit.sh
├── raw/                     # Input datasets (clean and dirty)
├── processed/               # Output Hudi tables and CSV
├── quarantine/              # Invalid records with failure reasons
├── Dockerfile
├── docker-compose.yml
├── RUN_ASSIGNMENT.sh        # Quick start script
├── run_complete_demo.sh     # Complete demo script
└── README.md                # Detailed documentation
```

---

## 🚀 Expected Outputs

### Successful Execution Produces:

1. **Hudi Tables:**
   - `processed/seller_catalog_hudi/`
   - `processed/company_sales_hudi/`
   - `processed/competitor_sales_hudi/`

2. **Final Recommendations:**
   - `processed/recommendations_csv/seller_recommend_data.csv`

3. **Quarantine Records (if dirty data):**
   - `quarantine/seller_catalog/`
   - `quarantine/company_sales/`
   - `quarantine/competitor_sales/`

### Sample Results:
- **Clean Data:** ~2,000 recommendations generated
- **Dirty Data:** ~1,800 recommendations + quarantined invalid records

---

## 🔧 Technical Specifications

- **Spark Version:** 3.5.0
- **Hudi Version:** 0.15.0
- **Java Version:** 21
- **Python Version:** 3.10+
- **Docker:** Ubuntu 22.04 base image

---

## 📋 Evaluation Checklist

- [x] **ETL Ingestion (15 marks)** - 3 pipelines with Hudi integration
- [x] **Consumption Layer (5 marks)** - Recommendation generation
- [x] **Data Cleaning & DQ** - Comprehensive validation framework
- [x] **Quarantine Zone** - Invalid records handling
- [x] **Schema Evolution** - Hudi table management
- [x] **YAML Configuration** - Flexible path management
- [x] **Docker Containerization** - Zero-setup execution
- [x] **Production Architecture** - Medallion pattern implementation

---

## 🎉 Assignment Highlights

1. **Complete Implementation:** All requirements fully implemented
2. **Enhanced DQ Framework:** Demonstrates both clean and dirty data processing
3. **Production-Ready:** Docker containerization for easy deployment
4. **Comprehensive Documentation:** Detailed README and inline comments
5. **Easy Evaluation:** One-click execution scripts for teachers

---

**Ready for submission and evaluation!** 🚀