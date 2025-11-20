# Data Files Note

## Large Data Files Removed for GitHub

The original CSV data files were too large for GitHub (>50MB each):
- seller_catalog_clean.csv (56MB)
- seller_catalog_dirty.csv (54MB)  
- company_sales_clean.csv (35MB)
- company_sales_dirty.csv (35MB)
- competitor_sales_clean.csv (49MB)
- competitor_sales_dirty.csv (49MB)

## For Assignment Submission

The complete assignment with all data files is available in the compressed package:
`2025EM1100026_CLEAN_SUBMISSION.tar.gz` (206MB)

## Data File Structure

The data files should be placed in these directories:
```
raw/
├── seller_catalog/
│   ├── seller_catalog_clean.csv
│   └── seller_catalog_dirty.csv
├── company_sales/
│   ├── company_sales_clean.csv
│   └── company_sales_dirty.csv
└── competitor_sales/
    ├── competitor_sales_clean.csv
    └── competitor_sales_dirty.csv
```

## Running the Assignment

1. Extract the complete submission package
2. Place data files in the correct directories
3. Run: `bash RUN_ASSIGNMENT.sh`

The assignment code is fully functional and ready for execution once the data files are in place.