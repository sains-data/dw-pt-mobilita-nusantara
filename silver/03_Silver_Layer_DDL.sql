-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Buat skema silver jika belum ada
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO

-- Hapus tabel jika sudah ada
IF OBJECT_ID('silver.transformed_car_sales_transactions', 'U') IS NOT NULL
    DROP TABLE silver.transformed_car_sales_transactions;
GO

-- Buat tabel baru di silver layer dengan transformasi dan tipe data yang sesuai
CREATE TABLE silver.transformed_car_sales_transactions (
    -- Mengambil kolom dari bronze dan menyesuaikan tipe data atau nama jika perlu
    Car_ID VARCHAR(255) PRIMARY KEY,    -- Sebelumnya Car_id, dijadikan Primary Key
    Sales_Date DATE,                    -- Sebelumnya [Date]
    Customer_Name VARCHAR(255),         -- Sebelumnya [Customer Name]
    Gender VARCHAR(50),
    Annual_Income DECIMAL(18, 2),       -- Sebelumnya [Annual Income] (VARCHAR), diubah ke DECIMAL
    Dealer_Name VARCHAR(255),
    Car_Make VARCHAR(255),              -- Sebelumnya Company
    Car_Model VARCHAR(255),             -- Sebelumnya Model
    Engine_Type VARCHAR(255),           -- Sebelumnya Engine
    Transmission_Type VARCHAR(255),     -- Sebelumnya Transmission
    Car_Color VARCHAR(255),             -- Sebelumnya Color
    Sales_Price DECIMAL(18, 2),         -- Sebelumnya [Price ($)] (VARCHAR), diubah ke DECIMAL dan ganti nama
    Dealer_Number VARCHAR(255),         -- Sebelumnya [Dealer_No]
    Body_Style VARCHAR(255),            -- Sebelumnya [Body Style]
    Customer_Phone VARCHAR(50),         -- Sebelumnya Phone
    Dealer_Region VARCHAR(255),

    -- Kolom tambahan yang mungkin berguna di silver layer (contoh)
    Sales_Year INT,
    Sales_Month INT,
    Sales_Day INT,
    Last_Updated DATETIME DEFAULT GETDATE() -- Untuk melacak kapan baris terakhir diupdate
);
GO

SELECT 'Tabel silver.transformed_car_sales_transactions berhasil dibuat.' AS Status;
