IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END
GO

IF OBJECT_ID('bronze.load_raw_car_sales', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE bronze.load_raw_car_sales;
END
GO

CREATE PROCEDURE bronze.load_raw_car_sales
    @CsvFilePath NVARCHAR(1000) -- Full path to the CSV file to be loaded
AS
BEGIN
    SET NOCOUNT ON;

   
    IF @CsvFilePath IS NULL OR @CsvFilePath = ''
    BEGIN
        RAISERROR('CSV file path must be provided.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        INSERT INTO bronze.raw_car_sales_transactions (
            Transaction_ID, Date, Sales_Price, Car_ID, Make, Model, Year, Color, Body_Style, Engine_Type, Transmission,
            Customer_ID, Customer_Name, Gender, Annual_Income, City, Dealer_ID, Dealer_Name, Dealer_Region,
            Nama_File_Sumber 
        )
        SELECT
            csv.Transaction_ID, csv.Date, csv.Sales_Price, csv.Car_ID, csv.Make, csv.Model, csv.Year, csv.Color, csv.Body_Style, csv.Engine_Type, csv.Transmission,
            csv.Customer_ID, csv.Customer_Name, csv.Gender, csv.Annual_Income, csv.City, csv.Dealer_ID, csv.Dealer_Name, csv.Dealer_Region,
            @CsvFilePath 
        FROM OPENROWSET(
            BULK @CsvFilePath,
            FORMAT = 'CSV',         -- Requires SQL Server 2017+
            FIRSTROW = 2,           -- Skip the header row in the CSV file
            FIELDTERMINATOR = ',',  -- CSVs are comma-delimited
            ROWTERMINATOR = '0x0a',   -- Standard line ending for CSV files (handles 
 and 
). Using '\\n' for explicit backslash-n.
            TABLOCK                 -- Added for potentially better performance on bulk load, can be removed if problematic.
        ) 
        WITH (
            Transaction_ID NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Date NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Sales_Price NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Car_ID NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Make NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Model NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Year NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Color NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Body_Style NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Engine_Type NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Transmission NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Customer_ID NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Customer_Name NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Gender NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Annual_Income NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            City NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Dealer_ID NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Dealer_Name NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
            Dealer_Region NVARCHAR(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8
        ) AS csv;

        PRINT 'Successfully loaded data from ' + @CsvFilePath + ' into bronze.raw_car_sales_transactions.';

    END TRY
    BEGIN CATCH
        PRINT 'Error loading data from ' + @CsvFilePath + '.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        THROW; 
    END CATCH
END
GO
