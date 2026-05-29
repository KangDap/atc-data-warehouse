# 📌 SSAS Cube Deployment Guide — PT. ATC Data Warehouse

Repository ini sudah dilengkapi dengan script SQL dan script XMLA untuk membuat SSAS Multidimensional Cube dari Data Warehouse PT. ATC. Agar tim UI/Dashboard dapat menghubungkan visualisasi ke cube ini, ikuti panduan setup di bawah secara berurutan.

---

## 🗂️ Struktur File yang Perlu Dijalankan

```
sql/
  01_create_dw_sqlserver.sql   ← Membuat schema DW di SQL Server
  02_load_data.sql             ← Load data CSV ke SQL Server

ssas/
  ATC_CUBE.xmla                ← Script deploy cube ke SSAS

data/processed/                ← File CSV sumber data (dari repo ETL)
  dim_channel_pembelian.csv
  dim_lokasi.csv
  dim_pelanggan.csv
  dim_produk.csv
  dim_status_transaksi.csv
  dim_waktu.csv
  fact_transaksi_layanan.csv
```

---

## 🛠️ Langkah-Langkah Setup Lokal

### TAHAP 1: Setup SQL Server (Relational Database)

1. Buka **SQL Server Management Studio (SSMS)**, hubungkan ke server **Database Engine** lokal.
2. Buka file **`sql/01_create_dw_sqlserver.sql`** lalu jalankan (`F5`).  
   Script ini akan membuat database `ATC_DW` beserta semua tabel dimensi dan fakta.
3. Buka file **`sql/02_load_data.sql`**.
4. ⚠️ **WAJIB DIEDIT**: Cari semua baris yang berisi:
   ```
   FROM 'C:\Path\To\datawarehouse\data\processed\...'
   ```
   Ganti dengan **path absolut** ke folder `data/processed` di laptop kamu.  
   Contoh: `C:\Users\Nama\Downloads\datawarehouse\data\processed\dim_waktu.csv`
5. Jalankan `02_load_data.sql`. Cek bagian hasil query `Verifikasi Row Count` di bagian bawah script — pastikan semua tabel terisi.

**Row count yang diharapkan:**

| Tabel                   | Jumlah Baris |
|-------------------------|-------------:|
| dim_channel_pembelian   |            6 |
| dim_lokasi              |           98 |
| dim_pelanggan           |        1.000 |
| dim_produk              |           50 |
| dim_status_transaksi    |            5 |
| dim_waktu               |        1.096 |
| fact_transaksi_layanan  |       ~25.364|

---

### TAHAP 2: Deploy Cube ke SSAS (Analysis Services)

1. Buka **SSMS**, lalu hubungkan ke server **Analysis Services** lokal kamu (bukan Database Engine).
2. Di toolbar klik **New Query** → pilih **MDX** atau langsung buka editor XMLA:  
   - Di Object Explorer, klik kanan server AS → pilih **New Query** → **XMLA**
3. Salin seluruh isi file **`ssas/ATC_CUBE.xmla`** ke dalam jendela editor XMLA.
4. ⚠️ **WAJIB DIEDIT**: Cari baris `ConnectionString` di bagian `<DataSources>`:
   ```xml
   <ConnectionString>Provider=MSOLEDBSQL19.1;Data Source=localhost;Persist Security Info=False;Integrated Security=SSPI;User ID=;Initial Catalog=ATC_DW;Initial File Name=;Trust Server Certificate=True;Server SPN=;Authentication=;Access Token=;Host Name In Certificate=;Server Certificate=</ConnectionString>
   ```
   Ubah `Data Source=localhost` menjadi nama server SQL Engine lokal kamu  
   (bisa `localhost`, `.\SQLEXPRESS`, atau nama komputermu, tergantung instalasi).
5. Jalankan script XMLA (`F5`). Kalau sukses, database **`ATC_DW_CUBE`** akan muncul di Object Explorer SSAS.

---

### TAHAP 3: Konfigurasi Ulang Impersonation (PENTING ⚠️)

## A
Setelah cube berhasil dibuat, SSAS perlu kredensial untuk mengakses SQL Server saat *process*:

1. Di Object Explorer SSAS, expand **`ATC_DW_CUBE`** → folder **Data Sources**.
2. Klik kanan **`ATC DW`** → pilih **Properties**.
3. Di baris **Connection String**, pastikan `Data Source` sudah mengarah ke server SQL lokal kamu.
4. Di bagian **Security Settings** → klik dua kali nilai **Impersonation Info**.
5. Di pop-up yang muncul, pilih **`Use the service account`**.

## B Memberikan Izin di SQL Server (Database Engine)
Agar Service Account SSAS tidak ditolak (Login Failed) saat menyedot data, buka koneksi Database Engine di SSMS, buka New Query, dan jalankan script ini

```sql
# SQL QUERY

\$ 
USE [master];
GO
CREATE LOGIN [NT Service\MSSQLServerOLAPService] FROM WINDOWS;
GO

USE [ATC_DW];
GO
CREATE USER [NT Service\MSSQLServerOLAPService] FOR LOGIN [NT Service\MSSQLServerOLAPService];
ALTER ROLE [db_datareader] ADD MEMBER [NT Service\MSSQLServerOLAPService];
GO

```


---

### TAHAP 4: Process Cube (Isi Data ke SSAS)

1. Klik kanan **`ATC_DW_CUBE`** di Object Explorer SSAS → pilih **Process...**.
2. Di jendela *Process Database*, pastikan mode-nya **Process Full**, lalu klik **OK**.
3. Tunggu beberapa detik. Jika berhasil akan muncul status hijau: **`Process succeeded`**.

Setelah ini, cube sudah aktif dan semua agregasi sudah ter-precompute di dalam SSAS.

---

## 📊 Menghubungkan ke UI / Dashboard

Setelah *Process succeeded*, hubungkan tool visualisasi ke SSAS lokal (`localhost`):

| Tool       | Cara Koneksi |
|------------|--------------|
| Power BI   | Get Data → Analysis Services → masukkan nama server SSAS |
| Tableau    | Connect → Microsoft Analysis Services → Server: `localhost` |
| Excel      | Data → From Analysis Services → Server: `localhost` |
| Web App    | Gunakan library ADOMD.NET (C#) atau `xmla` package (Python/JS) |

---

## 🧊 Desain Cube: Dimensi & Measures

### Dimensi (6)

| Dimensi | Hierarki / Atribut |
|---|---|
| **Dim Waktu** | Tahun → Kuartal → Bulan → Tanggal |
| **Dim Pelanggan** | Jenis Layanan → Jenis Kartu → Nama Pelanggan |
| **Dim Produk** | Kategori Produk → Jenis Produk → Nama Produk |
| **Dim Lokasi** | Regional → Provinsi → Kab/Kota → Kecamatan → Kelurahan |
| **Dim Channel Pembelian** | Jenis Channel → Nama Channel |
| **Dim Status Transaksi** | Kode Status, Deskripsi Status |

### Measures (8)

| Measure | Fungsi Agregasi | Keterangan |
|---|---|---|
| Jumlah Transaksi | COUNT | Total baris transaksi |
| Total Harga (Rp) | SUM | Total pendapatan transaksi |
| Rata-rata Total Harga (Rp) | AVG | Nilai rata-rata per transaksi |
| Jumlah Pembelian | SUM | Total kuantitas produk terbeli |
| Total Data (MB) | SUM | Total konsumsi data |
| Rata-rata Data (MB) | AVG | Rata-rata data per transaksi |
| Total Durasi Telepon (Menit) | SUM | Total menit telepon |
| Total SMS | SUM | Total SMS terkirim |

---

## ❓ Troubleshooting Umum

| Error | Solusi |
|---|---|
| `Login failed for user` | Ubah Impersonation Info (Tahap 3) |
| `Cannot connect to ... localhost` | Pastikan SQL Server Engine berjalan, cek nama server di Connection String |
| `Process Database: errors found` | Pastikan semua FK di SQL Server valid (cek dengan `02_load_data.sql` verifikasi) |
| Cube tidak muncul di Power BI | Pastikan SQL Server Analysis Services berjalan (cek di Services Windows) |
| `BULK INSERT: Cannot bulk load` | Pastikan path CSV benar dan SQL Server service bisa akses folder tersebut |

*Kalau ada kendala lain, langsung chat di grup ya!*
