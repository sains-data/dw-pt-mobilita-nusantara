-- Tabel mentah dari data penjualan mobil (tanpa skema)
CREATE TABLE raw_car_sales_transactions (
    Car_ID TEXT,
    Transaction_Date TEXT,
    Customer_Name TEXT,
    Gender TEXT,
    Annual_Income INTEGER,
    Dealer_Name TEXT,
    Car_Brand TEXT,
    Car_Model TEXT,
    Engine_Type TEXT,
    Transmission_Type TEXT,
    Car_Color TEXT,
    Price_USD INTEGER,
    Dealer_No TEXT,
    Body_Style TEXT,
    Phone_Number INTEGER,
    Dealer_Region TEXT,
    Tanggal_Ingesti_Bronze TEXT DEFAULT (datetime('now')),
    Nama_File_Sumber TEXT
);

-- Contoh insert data
INSERT INTO raw_car_sales_transactions (
    Car_ID, Transaction_Date, Customer_Name, Gender, Annual_Income, Dealer_Name,
    Car_Brand, Car_Model, Engine_Type, Transmission_Type, Car_Color, Price_USD,
    Dealer_No, Body_Style, Phone_Number, Dealer_Region, Nama_File_Sumber
) VALUES (
    'C_CND_000001', '2022-02-01', 'Geraldine', 'Male', 13500,
    'Buddy Storbeck''s Diesel Service Inc', 'Ford', 'Expedition',
    'Double Overhead Camshaft', 'Auto', 'Black', 26000,
    '06457-3834', 'SUV', 8264678, 'Middletown',
    'car_data.xlsx - Car Sales.xlsx - car_data.csv'
);

-- Melihat 10 data pertama
SELECT * FROM raw_car_sales_transactions;

