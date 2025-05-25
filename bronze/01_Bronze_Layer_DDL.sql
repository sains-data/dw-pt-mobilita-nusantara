CREATE SCHEMA IF NOT EXISTS bronze;
CREATE TABLE bronze.raw_car_sales_transactions (
    Transaction_ID NVARCHAR(255),       
    Date NVARCHAR(255),                 
    Sales_Price NVARCHAR(255),          
    Car_ID NVARCHAR(255),               
    Make NVARCHAR(255),                 
    Model NVARCHAR(255),                
    Year NVARCHAR(255),                 
    Color NVARCHAR(255),                
    Body_Style NVARCHAR(255),           
    Engine_Type NVARCHAR(255),          
    Transmission NVARCHAR(255),         
    Customer_ID NVARCHAR(255),         
    Customer_Name NVARCHAR(255),        
    Gender NVARCHAR(255),               
    Annual_Income NVARCHAR(255),        
    City NVARCHAR(255),                 
    Dealer_ID NVARCHAR(255),           
    Dealer_Name NVARCHAR(255),          
    Dealer_Region NVARCHAR(255),        
    Tanggal_Ingesti_Bronze DATETIME2(7) DEFAULT GETDATE(),
    Nama_File_Sumber NVARCHAR(255)     
);

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
