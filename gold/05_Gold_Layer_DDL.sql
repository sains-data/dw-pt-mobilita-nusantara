-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Buat skema gold jika belum ada
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END
GO

-- Hapus tabel jika sudah ada (urutkan berdasarkan foreign key dependencies jika perlu)
IF OBJECT_ID('gold.fact_car_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_car_sales;
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
    DROP TABLE gold.dim_date;
IF OBJECT_ID('gold.dim_car', 'U') IS NOT NULL
    DROP TABLE gold.dim_car;
IF OBJECT_ID('gold.dim_dealer', 'U') IS NOT NULL
    DROP TABLE gold.dim_dealer;
IF OBJECT_ID('gold.dim_customer', 'U') IS NOT NULL
    DROP TABLE gold.dim_customer;
GO

-- Create dimension table for Date
CREATE TABLE gold.dim_date (
    date_key INT PRIMARY KEY,
    [date] DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    weekday VARCHAR(20) NOT NULL,
    month_name VARCHAR(20) NOT NULL, -- KOLOM INI DIPERLUKAN
    quarter INT NOT NULL             -- KOLOM INI DIPERLUKAN
);
GO

-- Create dimension table for Car
CREATE TABLE gold.dim_car (
    car_key INT PRIMARY KEY IDENTITY(1,1),
    car_id VARCHAR(255) NOT NULL UNIQUE,
    make VARCHAR(255),
    model VARCHAR(255),
    engine_type VARCHAR(255),       -- KOLOM INI DIPERLUKAN
    transmission_type VARCHAR(255), -- KOLOM INI DIPERLUKAN
    color VARCHAR(255),
    body_style VARCHAR(255)
);
GO

-- Create dimension table for Dealer
CREATE TABLE gold.dim_dealer (
    dealer_key INT PRIMARY KEY IDENTITY(1,1),
    dealer_number VARCHAR(255) UNIQUE,
    dealer_name VARCHAR(255),
    dealer_region VARCHAR(255)
);
GO

-- Create dimension table for Customer
CREATE TABLE gold.dim_customer (
    customer_key INT PRIMARY KEY IDENTITY(1,1),
    customer_name VARCHAR(255),
    gender VARCHAR(50),
    annual_income DECIMAL(18,2),
    customer_phone VARCHAR(50)
);
GO

-- Create fact table for Car Sales
CREATE TABLE gold.fact_car_sales (
    sales_id INT PRIMARY KEY IDENTITY(1,1),
    car_id_original VARCHAR(255),
    date_key INT NOT NULL,
    car_key INT NOT NULL,
    dealer_key INT NOT NULL,
    customer_key INT NOT NULL,
    sales_price DECIMAL(18, 2),
    FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key),
    FOREIGN KEY (car_key) REFERENCES gold.dim_car(car_key),
    FOREIGN KEY (dealer_key) REFERENCES gold.dim_dealer(dealer_key),
    FOREIGN KEY (customer_key) REFERENCES gold.dim_customer(customer_key)
);
GO

SELECT 'Skema Gold dan tabel-tabel dimensi serta fakta berhasil dibuat DENGAN KOLOM YANG BENAR.' AS Status;
