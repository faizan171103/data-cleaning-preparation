📘 README.md
Layoffs Data Cleaning & Preparation (MySQL)
📌 Project Overview

This project focuses on cleaning and preparing a raw layoffs dataset using MySQL to make it analysis-ready. The workflow follows data engineering best practices, including staging tables, deduplication, standardization, null handling, and data type enforcement.

The final output is a clean, reliable table suitable for exploratory data analysis, reporting, and visualization.

🎯 Objectives

Preserve raw data integrity using staging tables

Remove duplicate records using window functions

Standardize categorical fields (company, industry, country)

Handle missing and null values

Convert date fields to proper data types

Produce a final clean dataset for downstream analysis

🛠 Tools & Technologies

MySQL

SQL Window Functions

CTEs (Common Table Expressions)

Data Cleaning Notes

Duplicate rows were removed using window functions

Industry values were standardized for consistency

Missing industry values were inferred from company-level data

Rows with no layoff metrics were removed

Dates were converted from text to proper DATE format
