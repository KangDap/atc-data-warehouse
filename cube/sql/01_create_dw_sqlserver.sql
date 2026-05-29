-- ============================================================
-- PT. ATC Data Warehouse - SQL Server Schema
-- File        : 01_create_dw_sqlserver.sql
-- Deskripsi   : Script DDL untuk membuat skema Data Warehouse
--               PT. ATC pada SQL Server (Database Engine)
-- Urutan      : Jalankan script ini PERTAMA, sebelum load data
--               dan sebelum restore/deploy SSAS Cube
-- ============================================================

-- ----------------------------------------------------------
-- LANGKAH 1: Buat Database
-- ----------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ATC_DW')
BEGIN
    CREATE DATABASE ATC_DW
    COLLATE Latin1_General_CI_AS;
    PRINT 'Database ATC_DW berhasil dibuat.';
END
ELSE
BEGIN
    PRINT 'Database ATC_DW sudah ada, melewati pembuatan.';
END
GO

USE ATC_DW;
GO

-- ----------------------------------------------------------
-- LANGKAH 2: Drop tabel yang ada (urutan: Fact dulu)
-- ----------------------------------------------------------
IF OBJECT_ID('dbo.fact_transaksi_layanan', 'U') IS NOT NULL
    DROP TABLE dbo.fact_transaksi_layanan;

IF OBJECT_ID('dbo.dim_waktu', 'U') IS NOT NULL
    DROP TABLE dbo.dim_waktu;

IF OBJECT_ID('dbo.dim_pelanggan', 'U') IS NOT NULL
    DROP TABLE dbo.dim_pelanggan;

IF OBJECT_ID('dbo.dim_produk', 'U') IS NOT NULL
    DROP TABLE dbo.dim_produk;

IF OBJECT_ID('dbo.dim_lokasi', 'U') IS NOT NULL
    DROP TABLE dbo.dim_lokasi;

IF OBJECT_ID('dbo.dim_channel_pembelian', 'U') IS NOT NULL
    DROP TABLE dbo.dim_channel_pembelian;

IF OBJECT_ID('dbo.dim_status_transaksi', 'U') IS NOT NULL
    DROP TABLE dbo.dim_status_transaksi;
GO

-- ----------------------------------------------------------
-- LANGKAH 3: Buat Tabel Dimensi
-- ----------------------------------------------------------

-- Dimensi 1: Waktu
CREATE TABLE dbo.dim_waktu (
    id_waktu          INT             NOT NULL,
    tanggal_lengkap   DATE            NULL,
    hari              NVARCHAR(20)    NULL,
    bulan             NVARCHAR(20)    NULL,
    kuartal           NVARCHAR(10)    NULL,
    tahun             INT             NULL,
    CONSTRAINT PK_dim_waktu PRIMARY KEY (id_waktu)
);

-- Dimensi 2: Pelanggan
CREATE TABLE dbo.dim_pelanggan (
    id_pelanggan        INT             NOT NULL,
    nomor_hp            NVARCHAR(50)    NULL,
    nama_pelanggan      NVARCHAR(255)   NULL,
    jenis_layanan       NVARCHAR(100)   NULL,
    jenis_kartu         NVARCHAR(100)   NULL,
    tanggal_registrasi  DATE            NULL,
    status_aktif        BIT             NULL,
    CONSTRAINT PK_dim_pelanggan PRIMARY KEY (id_pelanggan)
);

-- Dimensi 3: Produk
CREATE TABLE dbo.dim_produk (
    id_produk           INT             NOT NULL,
    kode_produk         NVARCHAR(50)    NULL,
    nama_produk         NVARCHAR(255)   NULL,
    jenis_produk        NVARCHAR(100)   NULL,
    kategori_produk     NVARCHAR(100)   NULL,
    harga               DECIMAL(18, 2)  NULL,
    CONSTRAINT PK_dim_produk PRIMARY KEY (id_produk),
    CONSTRAINT UQ_dim_produk_kode UNIQUE (kode_produk)
);

-- Dimensi 4: Lokasi
CREATE TABLE dbo.dim_lokasi (
    id_lokasi       INT             NOT NULL,
    site_id         NVARCHAR(50)    NULL,
    kelurahan       NVARCHAR(100)   NULL,
    kecamatan       NVARCHAR(100)   NULL,
    kabupaten_kota  NVARCHAR(100)   NULL,
    provinsi        NVARCHAR(100)   NULL,
    regional        NVARCHAR(100)   NULL,
    CONSTRAINT PK_dim_lokasi PRIMARY KEY (id_lokasi)
);

-- Dimensi 5: Channel Pembelian
CREATE TABLE dbo.dim_channel_pembelian (
    id_channel      INT             NOT NULL,
    nama_channel    NVARCHAR(100)   NULL,
    jenis_channel   NVARCHAR(50)    NULL,
    CONSTRAINT PK_dim_channel_pembelian PRIMARY KEY (id_channel)
);

-- Dimensi 6: Status Transaksi
CREATE TABLE dbo.dim_status_transaksi (
    id_status           INT             NOT NULL,
    kode_status         NVARCHAR(50)    NULL,
    deskripsi_status    NVARCHAR(255)   NULL,
    CONSTRAINT PK_dim_status_transaksi PRIMARY KEY (id_status),
    CONSTRAINT UQ_dim_status_kode UNIQUE (kode_status)
);

PRINT 'Semua tabel dimensi berhasil dibuat.';
GO

-- ----------------------------------------------------------
-- LANGKAH 4: Buat Tabel Fakta
-- ----------------------------------------------------------
CREATE TABLE dbo.fact_transaksi_layanan (
    id_fakta                INT             NOT NULL,
    id_waktu                INT             NULL,
    id_pelanggan            INT             NULL,
    id_produk               INT             NULL,
    id_lokasi               INT             NULL,
    id_channel              INT             NULL,
    id_status               INT             NULL,
    nomor_transaksi         NVARCHAR(100)   NULL,
    jumlah_pembelian        INT             NULL    DEFAULT 1,
    total_harga             DECIMAL(18, 2)  NULL,
    jumlah_data_mb          DECIMAL(18, 2)  NULL,
    durasi_telpon_menit     INT             NULL,
    jumlah_sms              INT             NULL,

    CONSTRAINT PK_fact_transaksi_layanan    PRIMARY KEY (id_fakta),
    CONSTRAINT UQ_nomor_transaksi           UNIQUE (nomor_transaksi),

    CONSTRAINT FK_fact_waktu        FOREIGN KEY (id_waktu)      REFERENCES dbo.dim_waktu(id_waktu),
    CONSTRAINT FK_fact_pelanggan    FOREIGN KEY (id_pelanggan)  REFERENCES dbo.dim_pelanggan(id_pelanggan),
    CONSTRAINT FK_fact_produk       FOREIGN KEY (id_produk)     REFERENCES dbo.dim_produk(id_produk),
    CONSTRAINT FK_fact_lokasi       FOREIGN KEY (id_lokasi)     REFERENCES dbo.dim_lokasi(id_lokasi),
    CONSTRAINT FK_fact_channel      FOREIGN KEY (id_channel)    REFERENCES dbo.dim_channel_pembelian(id_channel),
    CONSTRAINT FK_fact_status       FOREIGN KEY (id_status)     REFERENCES dbo.dim_status_transaksi(id_status)
);

PRINT 'Tabel fakta berhasil dibuat.';
GO

-- ----------------------------------------------------------
-- LANGKAH 5: Buat Index Tambahan (Opsional, Performa Query)
-- ----------------------------------------------------------
CREATE INDEX IX_fact_id_waktu      ON dbo.fact_transaksi_layanan (id_waktu);
CREATE INDEX IX_fact_id_pelanggan  ON dbo.fact_transaksi_layanan (id_pelanggan);
CREATE INDEX IX_fact_id_produk     ON dbo.fact_transaksi_layanan (id_produk);
CREATE INDEX IX_fact_id_lokasi     ON dbo.fact_transaksi_layanan (id_lokasi);
CREATE INDEX IX_fact_id_channel    ON dbo.fact_transaksi_layanan (id_channel);
CREATE INDEX IX_fact_id_status     ON dbo.fact_transaksi_layanan (id_status);

PRINT 'Index tambahan berhasil dibuat.';
PRINT '===================================================';
PRINT 'Schema ATC_DW berhasil dibuat. Lanjutkan ke:';
PRINT '  02_load_data.sql  ->  untuk mengisi data';
PRINT '===================================================';
GO
