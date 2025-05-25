-- NOTE: GO statements removed for SQLFluff compatibility.
-- Creates Bronze schema & raw_car_sales_transactions table.
-- Bronze layer: ingests raw data without transformation.
-- Create the bronze schema if it doesn't already exist
CREATE SCHEMA IF NOT EXISTS bronze;
-- Create the raw_car_sales_transactions table in the bronze schema
-- This table will store raw car sales transaction data as ingested from source CSV files.
-- All data columns are initially stored as NVARCHAR to accommodate variations in the raw data.
-- Type conversions and data cleaning will be performed in the Silver layer.
CREATE TABLE bronze.raw_car_sales_transactions (
    Transaction_ID NVARCHAR(255),       -- Unique identifier for the transaction
    Date NVARCHAR(255),                 -- Date of the transaction (parsed in Silver)
    Sales_Price NVARCHAR(255),          -- Selling price (converted in Silver)
    Car_ID NVARCHAR(255),               -- Unique identifier for the car
    Make NVARCHAR(255),                 -- Make of the car (e.g., Toyota, Honda)
    Model NVARCHAR(255),                -- Model of the car (e.g., Camry, Civic)
    Year NVARCHAR(255),                 -- Manufacturing year (converted in Silver)
    Color NVARCHAR(255),                -- Color of the car
    Body_Style NVARCHAR(255),           -- Body style (e.g., Sedan, SUV)
    Engine_Type NVARCHAR(255),          -- Type of engine (e.g., Petrol, Diesel)
    Transmission NVARCHAR(255),         -- Type of transmission (e.g., Automatic)
    Customer_ID NVARCHAR(255),          -- Unique identifier for the customer
    Customer_Name NVARCHAR(255),        -- Name of the customer
    Gender NVARCHAR(255),               -- Gender of the customer
    Annual_Income NVARCHAR(255),        -- Annual income (converted in Silver)
    City NVARCHAR(255),                 -- City where the customer resides
    Dealer_ID NVARCHAR(255),            -- Unique identifier for the dealer
    Dealer_Name NVARCHAR(255),          -- Name of the dealership
    Dealer_Region NVARCHAR(255),        -- Region where the dealer is located
    -- Metadata columns
    -- FIXED by AI [2023-10-27]
    -- Date and time of ingestion into Bronze layer
    Tanggal_Ingesti_Bronze DATETIME2(7) DEFAULT GETDATE(),
    Nama_File_Sumber NVARCHAR(255)     -- Name of the source file ingested
);
-- Example of how to insert data (for testing purposes,
-- actual ingestion will be done by a pipeline)
/*
INSERT INTO bronze.raw_car_sales_transactions (
    Transaction_ID, Date, Sales_Price, Car_ID, Make, Model, Year, Color,
    Body_Style, Engine_Type, Transmission, Customer_ID, Customer_Name,
    Gender, Annual_Income, City, Dealer_ID, Dealer_Name, Dealer_Region,
    Nama_File_Sumber
) VALUES (
    'TX1001', '2023-10-26', '25000', 'CAR001', 'Toyota', 'Camry', '2021',
    'Red', 'Sedan', 'Petrol', 'Automatic', 'CUST001', 'John Doe', 'Male',
    '60000', 'New York', 'DLR001', 'City Toyota', 'East',
    'sales_data_20231026.csv'
);
*/
-- Verify table creation (optional, for manual checking)
/*
SELECT TOP 10 * FROM bronze.raw_car_sales_transactions;
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'raw_car_sales_transactions';
*/
