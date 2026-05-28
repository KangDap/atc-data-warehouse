-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.dim_channel_pembelian (
  id_channel integer NOT NULL,
  nama_channel character varying,
  jenis_channel character varying,
  CONSTRAINT dim_channel_pembelian_pkey PRIMARY KEY (id_channel)
);
CREATE TABLE public.dim_lokasi (
  id_lokasi integer NOT NULL,
  site_id character varying,
  kelurahan character varying,
  kecamatan character varying,
  kabupaten_kota character varying,
  provinsi character varying,
  regional character varying,
  CONSTRAINT dim_lokasi_pkey PRIMARY KEY (id_lokasi)
);
CREATE TABLE public.dim_pelanggan (
  id_pelanggan integer NOT NULL,
  nomor_hp character varying,
  nama_pelanggan character varying,
  jenis_layanan character varying,
  jenis_kartu character varying,
  tanggal_registrasi date,
  status_aktif boolean,
  CONSTRAINT dim_pelanggan_pkey PRIMARY KEY (id_pelanggan)
);
CREATE TABLE public.dim_produk (
  id_produk integer NOT NULL,
  kode_produk character varying UNIQUE,
  nama_produk character varying,
  jenis_produk character varying,
  kategori_produk character varying,
  harga numeric,
  CONSTRAINT dim_produk_pkey PRIMARY KEY (id_produk)
);
CREATE TABLE public.dim_status_transaksi (
  id_status integer NOT NULL,
  kode_status character varying UNIQUE,
  deskripsi_status character varying,
  CONSTRAINT dim_status_transaksi_pkey PRIMARY KEY (id_status)
);
CREATE TABLE public.dim_waktu (
  id_waktu integer NOT NULL,
  tanggal_lengkap date,
  hari character varying,
  bulan character varying,
  kuartal character varying,
  tahun integer,
  CONSTRAINT dim_waktu_pkey PRIMARY KEY (id_waktu)
);
CREATE TABLE public.fact_transaksi_layanan (
  id_fakta integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_waktu integer,
  id_pelanggan integer,
  id_produk integer,
  id_lokasi integer,
  id_channel integer,
  id_status integer,
  nomor_transaksi character varying UNIQUE,
  jumlah_pembelian integer DEFAULT 1,
  total_harga numeric,
  jumlah_data_mb numeric,
  durasi_telpon_menit integer,
  jumlah_sms integer,
  CONSTRAINT fact_transaksi_layanan_pkey PRIMARY KEY (id_fakta),
  CONSTRAINT fk_fact_waktu FOREIGN KEY (id_waktu) REFERENCES public.dim_waktu(id_waktu),
  CONSTRAINT fk_fact_pelanggan FOREIGN KEY (id_pelanggan) REFERENCES public.dim_pelanggan(id_pelanggan),
  CONSTRAINT fk_fact_produk FOREIGN KEY (id_produk) REFERENCES public.dim_produk(id_produk),
  CONSTRAINT fk_fact_lokasi FOREIGN KEY (id_lokasi) REFERENCES public.dim_lokasi(id_lokasi),
  CONSTRAINT fk_fact_channel FOREIGN KEY (id_channel) REFERENCES public.dim_channel_pembelian(id_channel),
  CONSTRAINT fk_fact_status FOREIGN KEY (id_status) REFERENCES public.dim_status_transaksi(id_status)
);