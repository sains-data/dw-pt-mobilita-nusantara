/*
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
*/


CREATE TABLE raw_car_sales_transactions (
    Car_id TEXT,
    Date TEXT,
    Customer_Name TEXT,
    Gender TEXT,
    Annual_Income INTEGER, -- Opsi: simpan sebagai INTEGER
    Dealer_Name TEXT,
    Company TEXT,
    Model TEXT,
    Engine TEXT,
    Transmission TEXT,
    Color TEXT,
    "Price ($)" INTEGER, -- Opsi: simpan sebagai INTEGER (perhatikan tanda kutip karena ada spasi)
    Dealer_No TEXT,
    Body_Style TEXT,
    Phone INTEGER, -- Opsi: simpan sebagai INTEGER
    Dealer_Region TEXT,
    Tanggal_Ingesti_Bronze TEXT DEFAULT CURRENT_TIMESTAMP,
    Nama_File_Sumber TEXT
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
    'car_data.xlsx - Car Sales.xlsx - car_data.csv'  -- Nama file yang diperbarui
);
*/



INSERT INTO raw_car_sales_transactions (
    Car_id, Date, Customer_Name, Gender, Annual_Income, Dealer_Name,
    Company, Model, Engine, Transmission, Color, "Price ($)",
    Dealer_No, Body_Style, Phone, Dealer_Region, Nama_File_Sumber
) VALUES (
    'C_CND_000001', '2022-02-01', 'Geraldine', 'Male', 13500,
    'Buddy Storbeck''s Diesel Service Inc', 'Ford', 'Expedition',
    'DoubleÃ‚Â Overhead Camshaft', 'Auto', 'Black', 26000,
    '06457-3834', 'SUV', 8264678, 'Middletown',
    'car_data.xlsx - Car Sales.xlsx - car_data.csv'  -- Nama file yang diperbarui
);
.
SELECT * FROM raw_car_sales_transactions LIMIT 10;

