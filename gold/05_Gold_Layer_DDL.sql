-- File: 05_Gold_Layer_DDL.sql (Versi Final yang Disesuaikan dan Direvisi)
USE [pt-mobilita-nusantara];
GO

-- Buat skema gold jika belum ada
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END
GO

-- Hapus tabel jika sudah ada (urutkan berdasarkan foreign key dependencies untuk menghindari error)
IF OBJECT_ID('gold.fact_car_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_car_sales;
PRINT 'Tabel gold.fact_car_sales (jika ada) telah di-DROP.';

IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
    DROP TABLE gold.dim_date;
PRINT 'Tabel gold.dim_date (jika ada) telah di-DROP.';

IF OBJECT_ID('gold.dim_car', 'U') IS NOT NULL
    DROP TABLE gold.dim_car;
PRINT 'Tabel gold.dim_car (jika ada) telah di-DROP.';

IF OBJECT_ID('gold.dim_dealer', 'U') IS NOT NULL
    DROP TABLE gold.dim_dealer;
PRINT 'Tabel gold.dim_dealer (jika ada) telah di-DROP.';

IF OBJECT_ID('gold.dim_customer', 'U') IS NOT NULL
    DROP TABLE gold.dim_customer;
PRINT 'Tabel gold.dim_customer (jika ada) telah di-DROP.';
GO

-- Create dimension table for Date
CREATE TABLE gold.dim_date (
    date_key INT PRIMARY KEY,
    [date] DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    weekday VARCHAR(20) NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INT NOT NULL
);
GO
PRINT 'Tabel gold.dim_date berhasil dibuat.';

-- Create dimension table for Car
CREATE TABLE gold.dim_car (
    car_key INT PRIMARY KEY IDENTITY(1,1),
    car_id VARCHAR(255) NOT NULL UNIQUE, -- ID asli dari sumber, unik
    make VARCHAR(255),
    model VARCHAR(255),
    engine_type VARCHAR(255),
    transmission_type VARCHAR(255),
    color VARCHAR(255),
    body_style VARCHAR(255)
);
GO
PRINT 'Tabel gold.dim_car berhasil dibuat.';

-- Create dimension table for Dealer
CREATE TABLE gold.dim_dealer (
    dealer_key INT PRIMARY KEY IDENTITY(1,1),
    dealer_number VARCHAR(255) UNIQUE, -- ID Bisnis Dealer, harus unik
    dealer_name VARCHAR(255),
    dealer_region VARCHAR(255)
);
GO
PRINT 'Tabel gold.dim_dealer berhasil dibuat.';

-- Create dimension table for Customer
CREATE TABLE gold.dim_customer (
    customer_key INT PRIMARY KEY IDENTITY(1,1),
    customer_name VARCHAR(255),
    gender VARCHAR(50),
    annual_income DECIMAL(18,2),
    customer_phone VARCHAR(50)
);
GO
PRINT 'Tabel gold.dim_customer berhasil dibuat.';

-- Create fact table for Car Sales
CREATE TABLE gold.fact_car_sales (
    sales_id INT PRIMARY KEY IDENTITY(1,1), -- Surrogate key untuk fakta penjualan
    car_id_original VARCHAR(255),           -- Menyimpan Car_ID asli untuk referensi
    date_key INT NOT NULL,
    car_key INT NOT NULL,
    dealer_key INT NOT NULL,
    customer_key INT NOT NULL,
    sales_price DECIMAL(18, 2),
    CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key),
    CONSTRAINT FK_FactSales_DimCar FOREIGN KEY (car_key) REFERENCES gold.dim_car(car_key),
    CONSTRAINT FK_FactSales_DimDealer FOREIGN KEY (dealer_key) REFERENCES gold.dim_dealer(dealer_key),
    CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (customer_key) REFERENCES gold.dim_customer(customer_key)
);
GO
PRINT 'Tabel gold.fact_car_sales berhasil dibuat.';
PRINT 'Struktur tabel Gold Layer (Data Mart) berhasil dibuat/diperbarui.';
