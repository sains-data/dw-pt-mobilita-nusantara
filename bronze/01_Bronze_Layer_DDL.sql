USE [pt-mobilita-nusantara];
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
   EXEC('CREATE SCHEMA bronze');
END
GO

IF OBJECT_ID('bronze.raw_car_sales_transactions', 'U') IS NOT NULL
   DROP TABLE bronze.raw_car_sales_transactions;
GO

CREATE TABLE bronze.raw_car_sales_transactions (
   Car_id VARCHAR(255),
   [Date] DATE,
   [Customer Name] VARCHAR(255),
   Gender VARCHAR(50),
   [Annual Income] VARCHAR(255),
   Dealer_Name VARCHAR(255),
   Company VARCHAR(255),
   Model VARCHAR(255),
   Engine VARCHAR(255),
   Transmission VARCHAR(255),
   Color VARCHAR(255),
   [Price ($)] VARCHAR(255),
   [Dealer_No] VARCHAR(255),
   [Body Style] VARCHAR(255),
   Phone VARCHAR(50),
   Dealer_Region VARCHAR(255)
);
GO

PRINT 'Tabel bronze.raw_car_sales_transactions berhasil dibuat/diperbarui.';
