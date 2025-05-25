CREATE SCHEMA gold;
GO

-- Drop tables if they exist
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
    date DATE,
    year INT,
    month INT,
    day INT,
    weekday VARCHAR(20)
);
GO

-- Create dimension table for Car
CREATE TABLE gold.dim_car (
    car_key INT PRIMARY KEY IDENTITY(1,1),
    car_id VARCHAR(255),
    make VARCHAR(255),
    model VARCHAR(255),
    year INT, -- Assuming year is part of car model or can be derived
    color VARCHAR(255),
    body_style VARCHAR(255)
);
GO

-- Create dimension table for Dealer
CREATE TABLE gold.dim_dealer (
    dealer_key INT PRIMARY KEY IDENTITY(1,1),
    dealer_name VARCHAR(255),
    dealer_region VARCHAR(255)
);
GO

-- Create dimension table for Customer
CREATE TABLE gold.dim_customer (
    customer_key INT PRIMARY KEY IDENTITY(1,1),
    customer_name VARCHAR(255),
    gender VARCHAR(50),
    annual_income DECIMAL(18,2) -- Assuming this is cleaned in silver
);
GO

-- Create fact table for Car Sales
CREATE TABLE gold.fact_car_sales (
    sales_id INT PRIMARY KEY IDENTITY(1,1),
    date_key INT,
    car_key INT,
    dealer_key INT,
    customer_key INT,
    sales_price DECIMAL(18, 2),
    FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key),
    FOREIGN KEY (car_key) REFERENCES gold.dim_car(car_key),
    FOREIGN KEY (dealer_key) REFERENCES gold.dim_dealer(dealer_key),
    FOREIGN KEY (customer_key) REFERENCES gold.dim_customer(customer_key)
);
GO
