-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Buat skema bronze jika belum ada
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END
GO

-- Hapus tabel jika sudah ada
IF OBJECT_ID('bronze.raw_car_sales_transactions', 'U') IS NOT NULL
    DROP TABLE bronze.raw_car_sales_transactions;
GO

-- Buat tabel baru sesuai dengan struktur data sumber Anda
CREATE TABLE bronze.raw_car_sales_transactions (
    Car_id VARCHAR(255),        -- Dari sumber Anda
    [Date] DATE,                -- Dari sumber Anda (gunakan kurung siku jika nama kolom adalah 'Date')
    [Customer Name] VARCHAR(255), -- Dari sumber Anda
    Gender VARCHAR(50),           -- Dari sumber Anda
    [Annual Income] VARCHAR(255), -- Dari sumber Anda (pertimbangkan DECIMAL jika ini angka)
    Dealer_Name VARCHAR(255),     -- Dari sumber Anda
    Company VARCHAR(255),         -- Dari sumber Anda
    Model VARCHAR(255),           -- Dari sumber Anda
    Engine VARCHAR(255),          -- Dari sumber Anda
    Transmission VARCHAR(255),    -- Dari sumber Anda
    Color VARCHAR(255),           -- Dari sumber Anda
    [Price ($)] VARCHAR(255),     -- Dari sumber Anda (pertimbangkan DECIMAL jika ini angka)
    [Dealer_No] VARCHAR(255),   -- Dari sumber Anda
    [Body Style] VARCHAR(255),    -- Dari sumber Anda
    Phone VARCHAR(50),            -- Dari sumber Anda
    Dealer_Region VARCHAR(255)    -- Dari sumber Anda
);
GO

SELECT 'Tabel bronze.raw_car_sales_transactions berhasil dibuat dengan struktur baru.' AS Status;
