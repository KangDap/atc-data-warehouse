# Dataset

This project uses generated data for a sample telecommunications data warehouse. The data represents PT. ATC, a fictional telecommunications company that serves customers through multiple purchase channels and service products.

The source data is already prepared as dimension and fact tables, so the ETL process focuses on profiling, cleaning, data type standardization, constraint validation, and loading into Supabase PostgreSQL.

## Source Folder

The raw dataset is stored in:

```text
data/raw/
```

## Raw Files

| File | Type | Description |
| --- | --- | --- |
| `dim_channel_pembelian.csv` | Dimension | Purchase channel reference data, such as digital, physical, and partner channels |
| `dim_lokasi.csv` | Dimension | Location or site reference data |
| `dim_lokasi_rows.csv` | Dimension | Alternative or duplicate raw location file |
| `dim_pelanggan.csv` | Dimension | Customer data, including phone number, service type, card type, registration date, and active status |
| `dim_produk.csv` | Dimension | Product and service data, including product category and price |
| `dim_status_transaksi.csv` | Dimension | Transaction status reference data |
| `dim_waktu.csv` | Dimension | Time dimension containing date, day, month, quarter, and year |
| `fact_transaksi_layanan.csv` | Fact | Initial raw service transaction fact data |
| `fact_transaksi_layanan_fix.csv` | Fact | Service transaction fact data used as the main transformation source |

## Main Fact Source

The transformation pipeline uses:

```text
data/raw/fact_transaksi_layanan_fix.csv
```

This file is used as the main source for the final fact table.

## Final Processed Tables

After transformation, the final output files are stored in:

```text
data/processed/
```

| Output File | Target Table |
| --- | --- |
| `dim_channel_pembelian.csv` | `dim_channel_pembelian` |
| `dim_lokasi.csv` | `dim_lokasi` |
| `dim_pelanggan.csv` | `dim_pelanggan` |
| `dim_produk.csv` | `dim_produk` |
| `dim_status_transaksi.csv` | `dim_status_transaksi` |
| `dim_waktu.csv` | `dim_waktu` |
| `fact_transaksi_layanan.csv` | `fact_transaksi_layanan` |

## Data Quality Notes

- `nomor_transaksi` is treated as a unique business key.
- Fact rows with duplicate `nomor_transaksi` values are separated into a rejected-record file.
- Fact rows with foreign keys that do not exist in the related dimension tables are separated into a rejected-record file.
- Rejected records are stored in `data/validation` as data quality evidence.

## Related Documentation

- [Data Dictionary](data_dictionary.md)
- [ETL Documentation](etl_documentation.md)
