# ETL Documentation

## Overview

This document describes the ETL process for the PT. ATC sample data warehouse. The source data is generated CSV data that is already separated into dimension tables and a fact table.

## Source Data

| File | Type | Description |
| --- | --- | --- |
| `dim_channel_pembelian.csv` | Dimension | Purchase channel reference data |
| `dim_lokasi.csv` | Dimension | Location or site reference data |
| `dim_pelanggan.csv` | Dimension | Customer reference data |
| `dim_produk.csv` | Dimension | Product and service reference data |
| `dim_status_transaksi.csv` | Dimension | Transaction status reference data |
| `dim_waktu.csv` | Dimension | Time dimension data |
| `fact_transaksi_layanan_fix.csv` | Fact | Main service transaction fact source |

## ETL Process

### Extract

The extract stage reads all raw CSV files from `data/raw` and generates an initial profiling summary. The profiling output includes row counts, column counts, missing value counts, duplicate row counts, and initial column structures.

### Transform

The transform stage standardizes text, dates, boolean values, and numeric fields. It also validates primary keys, removes duplicate transaction numbers, checks fact-to-dimension foreign keys, and writes rejected rows to `data/validation`.

### Load

The load stage reads final CSV files from `data/processed` and loads them into Supabase PostgreSQL using the warehouse schema defined in `sql/01_schema_warehouse.sql`.

## Validation

| Validation | Status | Notes |
| --- | --- | --- |
| Dimension primary keys are unique | Passed | Checked in `transform_table_validation.csv` |
| Fact primary key is unique | Passed | Checked using `id_fakta` |
| Transaction number is unique | Passed | Duplicate values are rejected before load |
| Fact foreign keys are valid | Passed | Invalid FK rows are rejected before load |
| Missing values are handled | Passed | Text defaults and numeric defaults are applied where needed |
| Row counts match after load | Passed | Checked in `load_results.csv` |
