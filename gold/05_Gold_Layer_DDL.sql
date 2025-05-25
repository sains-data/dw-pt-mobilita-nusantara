IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Schema gold created.';
END
ELSE
BEGIN
    PRINT 'Schema gold already exists.';
END
GO

IF OBJECT_ID('gold.dim_waktu', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_waktu (
        Date_Key INT NOT NULL PRIMARY KEY,
        Full_Date DATE NOT NULL,
        Day_Number INT NOT NULL,
        Month_Number INT NOT NULL,
        Month_Name NVARCHAR(20) NOT NULL,
        Year_Number INT NOT NULL,
        Quarter_Number INT NOT NULL,
        Day_of_Week_Name NVARCHAR(20) NOT NULL
    );
    PRINT 'Table gold.dim_waktu created.';

    IF NOT EXISTS (SELECT 1 FROM gold.dim_waktu WHERE Date_Key = 0)
    BEGIN
        INSERT INTO gold.dim_waktu (Date_Key, Full_Date, Day_Number, Month_Number, Month_Name, Year_Number, Quarter_Number, Day_of_Week_Name)
        VALUES (0, '1900-01-01', 0, 0, 'Unknown', 0, 0, 'Unknown');
    END
    IF NOT EXISTS (SELECT 1 FROM gold.dim_waktu WHERE Date_Key = -1)
    BEGIN
        INSERT INTO gold.dim_waktu (Date_Key, Full_Date, Day_Number, Month_Number, Month_Name, Year_Number, Quarter_Number, Day_of_Week_Name)
        VALUES (-1, '1899-01-01', 0, 0, 'Not Applicable', 0, 0, 'Not Applicable');
    END
    PRINT 'Default records for gold.dim_waktu ensured.';
END
ELSE
BEGIN
    PRINT 'Table gold.dim_waktu already exists.';
END
GO

IF OBJECT_ID('gold.dim_pelanggan', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_pelanggan (
        Customer_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Customer_ID_Source NVARCHAR(255) NOT NULL,
        Customer_Name NVARCHAR(255) NOT NULL,
        Gender NVARCHAR(10) NULL,
        Age_Group NVARCHAR(20) NULL,
        City NVARCHAR(100) NULL,
        State NVARCHAR(100) NULL,
        Income_Category NVARCHAR(50) NULL,
        DWH_Gold_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(),
        DWH_Gold_Update_Timestamp DATETIME2(7) DEFAULT GETDATE()
    );
    PRINT 'Table gold.dim_pelanggan created.';

    SET IDENTITY_INSERT gold.dim_pelanggan ON;
    IF NOT EXISTS (SELECT 1 FROM gold.dim_pelanggan WHERE Customer_Key = 0)
    BEGIN
        INSERT INTO gold.dim_pelanggan (Customer_Key, Customer_ID_Source, Customer_Name, Gender, Age_Group, City, State, Income_Category, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
        VALUES (0, 'UNKNOWN_CUSTOMER_ID', 'Unknown Customer', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'Unknown', GETDATE(), GETDATE());
    END
    IF NOT EXISTS (SELECT 1 FROM gold.dim_pelanggan WHERE Customer_Key = -1)
    BEGIN
        INSERT INTO gold.dim_pelanggan (Customer_Key, Customer_ID_Source, Customer_Name, Gender, Age_Group, City, State, Income_Category, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
        VALUES (-1, 'NA_CUSTOMER_ID', 'Not Applicable Customer', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', GETDATE(), GETDATE());
    END
    SET IDENTITY_INSERT gold.dim_pelanggan OFF;
    PRINT 'Default records for gold.dim_pelanggan inserted.';
END
ELSE
BEGIN
    PRINT 'Table gold.dim_pelanggan already exists.';
END
GO

IF OBJECT_ID('gold.dim_kendaraan', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_kendaraan (
        Vehicle_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Car_ID_Source NVARCHAR(255) NOT NULL,
        Make NVARCHAR(100) NOT NULL,
        Model NVARCHAR(100) NOT NULL,
        Year_Production INT NULL,
        Color NVARCHAR(50) NULL,
        Body_Style NVARCHAR(50) NULL,
        Engine_Type NVARCHAR(50) NULL,
        Transmission NVARCHAR(50) NULL,
        Fuel_Type NVARCHAR(50) NULL,
        Mileage_Category NVARCHAR(50) NULL,
        DWH_Gold_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(),
        DWH_Gold_Update_Timestamp DATETIME2(7) DEFAULT GETDATE()
    );
    PRINT 'Table gold.dim_kendaraan created.';

    SET IDENTITY_INSERT gold.dim_kendaraan ON;
    IF NOT EXISTS (SELECT 1 FROM gold.dim_kendaraan WHERE Vehicle_Key = 0)
    BEGIN
        INSERT INTO gold.dim_kendaraan (Vehicle_Key, Car_ID_Source, Make, Model, Year_Production, Color, Body_Style, Engine_Type, Transmission, Fuel_Type, Mileage_Category, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
        VALUES (0, 'UNKNOWN_CAR_ID', 'Unknown Make', 'Unknown Model', 0, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', GETDATE(), GETDATE());
    END
    IF NOT EXISTS (SELECT 1 FROM gold.dim_kendaraan WHERE Vehicle_Key = -1)
    BEGIN
        INSERT INTO gold.dim_kendaraan (Vehicle_Key, Car_ID_Source, Make, Model, Year_Production, Color, Body_Style, Engine_Type, Transmission, Fuel_Type, Mileage_Category, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
        VALUES (-1, 'NA_CAR_ID', 'Not Applicable Make', 'Not Applicable Model', 0, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', GETDATE(), GETDATE());
    END
    SET IDENTITY_INSERT gold.dim_kendaraan OFF;
    PRINT 'Default records for gold.dim_kendaraan inserted.';
END
ELSE
BEGIN
    PRINT 'Table gold.dim_kendaraan already exists.';
END
GO

IF OBJECT_ID('gold.dim_dealer', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_dealer (
        Dealer_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Dealer_ID_Source NVARCHAR(255) NOT NULL,
        Dealer_Name NVARCHAR(255) NOT NULL,
        Dealer_Location NVARCHAR(255) NULL,
        Dealer_Region NVARCHAR(100) NULL,
        DWH_Gold_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(),
        DWH_Gold_Update_Timestamp DATETIME2(7) DEFAULT GETDATE()
    );
    PRINT 'Table gold.dim_dealer created.';

    SET IDENTITY_INSERT gold.dim_dealer ON;
    IF NOT EXISTS (SELECT 1 FROM gold.dim_dealer WHERE Dealer_Key = 0)
    BEGIN
        INSERT INTO gold.dim_dealer (Dealer_Key, Dealer_ID_Source, Dealer_Name, Dealer_Location, Dealer_Region, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
        VALUES (0, 'UNKNOWN_DEALER_ID', 'Unknown Dealer', 'Unknown Location', 'Unknown Region', GETDATE(), GETDATE());
    END
    IF NOT EXISTS (SELECT 1 FROM gold.dim_dealer WHERE Dealer_Key = -1)
    BEGIN
        INSERT INTO gold.dim_dealer (Dealer_Key, Dealer_ID_Source, Dealer_Name, Dealer_Location, Dealer_Region, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
        VALUES (-1, 'NA_DEALER_ID', 'Not Applicable Dealer', 'N/A Location', 'N/A Region', GETDATE(), GETDATE());
    END
    SET IDENTITY_INSERT gold.dim_dealer OFF;
    PRINT 'Default records for gold.dim_dealer inserted.';
END
ELSE
BEGIN
    PRINT 'Table gold.dim_dealer already exists.';
END
GO

IF OBJECT_ID('gold.fact_penjualan', 'U') IS NULL
BEGIN
    CREATE TABLE gold.fact_penjualan (
        Sales_Fact_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Date_Key INT NOT NULL,
        Customer_Key INT NOT NULL,
        Vehicle_Key INT NOT NULL,
        Dealer_Key INT NOT NULL,
        Transaction_ID_Source NVARCHAR(255) NULL,
        Units_Sold INT DEFAULT 1 NOT NULL,
        Sales_Amount_USD DECIMAL(18, 2) NOT NULL,
        Cost_Amount_USD DECIMAL(18, 2) NULL,
        Profit_Amount_USD DECIMAL(18, 2) NULL,
        Discount_Amount_USD DECIMAL(18, 2) NULL,
        DWH_Gold_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(),
        CONSTRAINT FK_fact_penjualan_dim_waktu FOREIGN KEY (Date_Key) REFERENCES gold.dim_waktu(Date_Key),
        CONSTRAINT FK_fact_penjualan_dim_pelanggan FOREIGN KEY (Customer_Key) REFERENCES gold.dim_pelanggan(Customer_Key),
        CONSTRAINT FK_fact_penjualan_dim_kendaraan FOREIGN KEY (Vehicle_Key) REFERENCES gold.dim_kendaraan(Vehicle_Key),
        CONSTRAINT FK_fact_penjualan_dim_dealer FOREIGN KEY (Dealer_Key) REFERENCES gold.dim_dealer(Dealer_Key)
    );
    PRINT 'Table gold.fact_penjualan created.';
END
ELSE
BEGIN
    PRINT 'Table gold.fact_penjualan already exists.';
END
GO

PRINT 'Gold layer DDL script execution completed.';
GO
