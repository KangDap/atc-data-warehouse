# Data Dictionary

This document describes the warehouse tables and their columns after the ETL process.

## Dimension Tables

### `dim_channel_pembelian`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_channel` | integer | No | Primary key for the purchase channel |
| `nama_channel` | varchar | Yes | Purchase channel name |
| `jenis_channel` | varchar | Yes | Purchase channel type |

### `dim_lokasi`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_lokasi` | integer | No | Primary key for the location |
| `site_id` | varchar | Yes | Site identifier |
| `kelurahan` | varchar | Yes | Village or urban ward |
| `kecamatan` | varchar | Yes | District |
| `kabupaten_kota` | varchar | Yes | Regency or city |
| `provinsi` | varchar | Yes | Province |
| `regional` | varchar | Yes | Regional grouping |

### `dim_pelanggan`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_pelanggan` | integer | No | Primary key for the customer |
| `nomor_hp` | varchar | Yes | Customer phone number |
| `nama_pelanggan` | varchar | Yes | Customer name |
| `jenis_layanan` | varchar | Yes | Service type |
| `jenis_kartu` | varchar | Yes | Card type |
| `tanggal_registrasi` | date | Yes | Customer registration date |
| `status_aktif` | boolean | Yes | Customer active status |

### `dim_produk`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_produk` | integer | No | Primary key for the product |
| `kode_produk` | varchar | Yes | Product code |
| `nama_produk` | varchar | Yes | Product name |
| `jenis_produk` | varchar | Yes | Product type |
| `kategori_produk` | varchar | Yes | Product category |
| `harga` | numeric | Yes | Product price |

### `dim_status_transaksi`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_status` | integer | No | Primary key for the transaction status |
| `kode_status` | varchar | Yes | Transaction status code |
| `deskripsi_status` | varchar | Yes | Transaction status description |

### `dim_waktu`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_waktu` | integer | No | Primary key for the time dimension |
| `tanggal_lengkap` | date | Yes | Full date |
| `hari` | varchar | Yes | Day name |
| `bulan` | varchar | Yes | Month name |
| `kuartal` | varchar | Yes | Quarter |
| `tahun` | integer | Yes | Year |

## Fact Table

### `fact_transaksi_layanan`

| Column | Data Type | Nullable | Description |
| --- | --- | --- | --- |
| `id_fakta` | integer | No | Primary key for the fact row |
| `id_waktu` | integer | Yes | Foreign key to `dim_waktu` |
| `id_pelanggan` | integer | Yes | Foreign key to `dim_pelanggan` |
| `id_produk` | integer | Yes | Foreign key to `dim_produk` |
| `id_lokasi` | integer | Yes | Foreign key to `dim_lokasi` |
| `id_channel` | integer | Yes | Foreign key to `dim_channel_pembelian` |
| `id_status` | integer | Yes | Foreign key to `dim_status_transaksi` |
| `nomor_transaksi` | varchar | Yes | Unique transaction number or business key |
| `jumlah_pembelian` | integer | Yes | Quantity purchased |
| `total_harga` | numeric | Yes | Total transaction amount |
| `jumlah_data_mb` | numeric | Yes | Data usage amount in MB |
| `durasi_telpon_menit` | integer | Yes | Call duration in minutes |
| `jumlah_sms` | integer | Yes | SMS count |

## Relationships

| From Table | Column | To Table | Column |
| --- | --- | --- | --- |
| `fact_transaksi_layanan` | `id_waktu` | `dim_waktu` | `id_waktu` |
| `fact_transaksi_layanan` | `id_pelanggan` | `dim_pelanggan` | `id_pelanggan` |
| `fact_transaksi_layanan` | `id_produk` | `dim_produk` | `id_produk` |
| `fact_transaksi_layanan` | `id_lokasi` | `dim_lokasi` | `id_lokasi` |
| `fact_transaksi_layanan` | `id_channel` | `dim_channel_pembelian` | `id_channel` |
| `fact_transaksi_layanan` | `id_status` | `dim_status_transaksi` | `id_status` |
