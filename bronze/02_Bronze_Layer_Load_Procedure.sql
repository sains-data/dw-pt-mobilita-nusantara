-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Opsional: Jika Anda ingin mengosongkan tabel bronze sebelum memuat data baru setiap kali script ini dijalankan.
-- Jika ini adalah pemuatan pertama kali atau Anda ingin menambahkan data (jika ada Primary Key yang menangani duplikasi),
-- maka baris TRUNCATE TABLE ini bisa di-comment atau dihapus.
-- TRUNCATE TABLE bronze.raw_car_sales_transactions;
-- GO

-- Memasukkan data dari tabel sumber (hasil impor Excel) ke tabel bronze
INSERT INTO bronze.raw_car_sales_transactions (
    Car_id,
    [Date],
    [Customer Name],
    Gender,
    [Annual Income],
    Dealer_Name,
    Company,
    Model,
    Engine,
    Transmission,
    Color,
    [Price ($)],
    [Dealer_No],     -- Verifikasi nama kolom ini dengan hati-hati di tabel sumber Anda
    [Body Style],
    Phone,
    Dealer_Region
)
SELECT
    [Car_id],         -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Date],           -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Customer Name],  -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Gender],         -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Annual Income],  -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Dealer_Name],    -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Company],        -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Model],          -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Engine],         -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Transmission],   -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Color],          -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Price ($)],      -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Dealer_No],    -- PERIKSA NAMA KOLOM INI DI SUMBER. Jika di CSV headernya "Dealer_No ", maka di sini juga harus [Dealer_No ] (dengan spasi).
    [Body Style],     -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Phone],          -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
    [Dealer_Region]   -- Sesuaikan nama kolom ini JIKA berbeda di tabel '[Car Sales#xlsx - car_data$]'
FROM
    ['Car Sales#xlsx - car_data$']; -- Ini adalah tabel sumber Anda yang sudah diimpor dari Excel
GO

-- Verifikasi jumlah data yang dimuat
SELECT COUNT(*) AS TotalRowsLoadedInBronze FROM bronze.raw_car_sales_transactions;
GO

-- Tampilkan beberapa sampel data untuk verifikasi (opsional)
SELECT TOP 10 * FROM bronze.raw_car_sales_transactions;
GO
