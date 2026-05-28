# ATC Data Warehouse

This project is a sample data warehouse for PT. ATC, a fictional telecommunications company that provides digital and physical service channels for its customers. The warehouse is designed to organize generated customer, product, location, time, channel, status, and service transaction data into clean dimension and fact tables.

## Dataset

The dataset is generated and already follows a simple star schema structure with dimension tables and a service transaction fact table.

Dataset details, source files, and table descriptions are available in:

[docs/dataset.md](docs/dataset.md)

Warehouse table definitions, columns, and relationships are available in:

[docs/data_dictionary.md](docs/data_dictionary.md)

## ETL Pipeline

The ETL pipeline is organized into four notebooks:

| Notebook | Purpose |
| --- | --- |
| `notebooks/01_extract_profile.ipynb` | Read raw CSV files from `data/raw` and create initial data profiling |
| `notebooks/02_transform_validate.ipynb` | Clean data, validate primary/foreign keys, and create final processed outputs |
| `notebooks/03_load_supabase.ipynb` | Load transformed data into Supabase PostgreSQL |
| `notebooks/04_etl_run_summary.ipynb` | Summarize ETL execution results and validation status |

## ETL Output

The main ETL outputs are final CSV files in `data/processed`:

- `dim_channel_pembelian.csv`
- `dim_lokasi.csv`
- `dim_pelanggan.csv`
- `dim_produk.csv`
- `dim_status_transaksi.csv`
- `dim_waktu.csv`
- `fact_transaksi_layanan.csv`

These files are used for the Supabase load process and can also be consumed by the Data Cube workstream.

## Validation Output

Validation reports are stored in `data/validation`, including:

- extract profiling summary
- primary key validation
- foreign key validation
- numeric validation
- rejected duplicate transaction records
- rejected invalid foreign key records
- Supabase load result
- final ETL summary

## Data Quality Rules

The main validation rules are:

- Primary keys in every dimension table must be unique.
- `id_fakta` in the fact table must be unique.
- `nomor_transaksi` must be unique because it is treated as a transaction business key.
- Foreign keys in `fact_transaksi_layanan` must exist in the related dimension tables.
- Numeric transaction values must not be negative.
- Invalid rows are separated into `data/validation` and are not loaded into the final warehouse tables.
