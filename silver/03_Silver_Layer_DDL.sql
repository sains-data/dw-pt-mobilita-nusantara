
USE [pt-mobilita-nusantara];
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO


IF OBJECT_ID('silver.transformed_car_sales_transactions', 'U') IS NOT NULL
    DROP TABLE silver.transformed_car_sales_transactions;
GO


CREATE TABLE silver.transformed_car_sales_transactions (
    Car_ID VARCHAR(255) PRIMARY KEY,
    Sales_Date DATE,
    Customer_Name VARCHAR(255),
    Gender VARCHAR(50),
    Annual_Income DECIMAL(18, 2),
    Dealer_Name VARCHAR(255),
    Car_Make VARCHAR(255),
    Car_Model VARCHAR(255),
    Engine_Type VARCHAR(255),
    Transmission_Type VARCHAR(255),
    Car_Color VARCHAR(255),
    Sales_Price DECIMAL(18, 2),
    Dealer_Number VARCHAR(255),
    Body_Style VARCHAR(255),
    Customer_Phone VARCHAR(50),
    Dealer_Region VARCHAR(255),
    Sales_Year INT,
    Sales_Month INT,
    Sales_Day INT,
    Last_Updated DATETIME DEFAULT GETDATE()
);
GO

SELECT 'Tabel silver.transformed_car_sales_transactions berhasil dibuat dengan struktur yang benar.' AS Status;
