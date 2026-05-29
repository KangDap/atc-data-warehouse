USE ATC_DW;
GO

-- ===========================================================
-- FIX 1: Load dim_pelanggan via Staging (handle True/False)
-- ===========================================================

-- Kosongkan tabel target dulu (kalau ada partial data)
DELETE FROM dbo.dim_pelanggan;

-- Buat staging table dengan status_aktif sebagai NVARCHAR
IF OBJECT_ID('dbo.stg_dim_pelanggan', 'U') IS NOT NULL
    DROP TABLE dbo.stg_dim_pelanggan;

CREATE TABLE dbo.stg_dim_pelanggan (
    id_pelanggan        INT             NULL,
    nomor_hp            NVARCHAR(50)    NULL,
    nama_pelanggan      NVARCHAR(255)   NULL,
    jenis_layanan       NVARCHAR(100)   NULL,
    jenis_kartu         NVARCHAR(100)   NULL,
    tanggal_registrasi  NVARCHAR(50)    NULL,  -- baca dulu sebagai string
    status_aktif        NVARCHAR(10)    NULL   -- 'True'/'False' diterima
);

-- BULK INSERT ke staging (ganti path sesuai laptop kamu)
BULK INSERT dbo.stg_dim_pelanggan
FROM 'D:\NGODING\SEMESTER6\Datwer\PROJECT-DATWER\atc-data-warehouse\data\processed\dim_pelanggan.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    CODEPAGE        = '65001',
    TABLOCK
);

PRINT 'Staging dim_pelanggan loaded: ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';

-- INSERT ke tabel asli dengan konversi True/False -> 1/0
INSERT INTO dbo.dim_pelanggan (
    id_pelanggan, nomor_hp, nama_pelanggan,
    jenis_layanan, jenis_kartu, tanggal_registrasi, status_aktif
)
SELECT
    id_pelanggan,
    nomor_hp,
    nama_pelanggan,
    jenis_layanan,
    jenis_kartu,
    TRY_CAST(tanggal_registrasi AS DATE),
    CASE
        WHEN LOWER(TRIM(status_aktif)) = 'true'  THEN 1
        WHEN LOWER(TRIM(status_aktif)) = 'false' THEN 0
        WHEN status_aktif = '1' THEN 1
        WHEN status_aktif = '0' THEN 0
        ELSE NULL
    END
FROM dbo.stg_dim_pelanggan
WHERE id_pelanggan IS NOT NULL;

PRINT 'dim_pelanggan inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';

-- Bersihkan staging
DROP TABLE dbo.stg_dim_pelanggan;
GO


-- ===========================================================
-- FIX 2: Isi ulang fact_transaksi_layanan (sekarang FK valid)
-- ===========================================================

-- Kosongkan fact table dulu
DELETE FROM dbo.fact_transaksi_layanan;

-- Buat staging lagi
IF OBJECT_ID('dbo.stg_fact_transaksi_layanan', 'U') IS NOT NULL
    DROP TABLE dbo.stg_fact_transaksi_layanan;

CREATE TABLE dbo.stg_fact_transaksi_layanan (
    id_fakta                INT             NULL,
    id_waktu                INT             NULL,
    id_pelanggan            INT             NULL,
    id_produk               INT             NULL,
    id_lokasi               INT             NULL,
    id_channel              INT             NULL,
    id_status               INT             NULL,
    nomor_transaksi         NVARCHAR(100)   NULL,
    jumlah_pembelian        INT             NULL,
    total_harga             DECIMAL(18, 2)  NULL,
    jumlah_data_mb          DECIMAL(18, 2)  NULL,
    durasi_telpon_menit     INT             NULL,
    jumlah_sms              INT             NULL
);

BULK INSERT dbo.stg_fact_transaksi_layanan
FROM 'D:\NGODING\SEMESTER6\Datwer\PROJECT-DATWER\atc-data-warehouse\data\processed\fact_transaksi_layanan.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    CODEPAGE        = '65001',
    TABLOCK
);

PRINT 'Staging fact loaded: ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';

INSERT INTO dbo.fact_transaksi_layanan (
    id_fakta, id_waktu, id_pelanggan, id_produk, id_lokasi,
    id_channel, id_status, nomor_transaksi, jumlah_pembelian,
    total_harga, jumlah_data_mb, durasi_telpon_menit, jumlah_sms
)
SELECT
    id_fakta, id_waktu, id_pelanggan, id_produk, id_lokasi,
    id_channel, id_status, nomor_transaksi, jumlah_pembelian,
    total_harga, jumlah_data_mb, durasi_telpon_menit, jumlah_sms
FROM dbo.stg_fact_transaksi_layanan
WHERE id_fakta IS NOT NULL
  AND nomor_transaksi IS NOT NULL;

PRINT 'fact_transaksi_layanan inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';

DROP TABLE dbo.stg_fact_transaksi_layanan;
GO


-- ===========================================================
-- Verifikasi Akhir
-- ===========================================================
SELECT 'dim_channel_pembelian'  AS tabel, COUNT(*) AS jumlah FROM dbo.dim_channel_pembelian
UNION ALL SELECT 'dim_lokasi',             COUNT(*) FROM dbo.dim_lokasi
UNION ALL SELECT 'dim_pelanggan',          COUNT(*) FROM dbo.dim_pelanggan
UNION ALL SELECT 'dim_produk',             COUNT(*) FROM dbo.dim_produk
UNION ALL SELECT 'dim_status_transaksi',   COUNT(*) FROM dbo.dim_status_transaksi
UNION ALL SELECT 'dim_waktu',              COUNT(*) FROM dbo.dim_waktu
UNION ALL SELECT 'fact_transaksi_layanan', COUNT(*) FROM dbo.fact_transaksi_layanan;
GO