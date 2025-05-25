-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Membuat atau Mengubah Stored Procedure untuk memuat data ke Silver Layer
CREATE OR ALTER PROCEDURE dbo.LoadSilverLayerCarSalesTransactions
AS
BEGIN
    SET NOCOUNT ON;

    -- Opsional: Kosongkan tabel silver sebelum memuat data baru (jika Anda ingin refresh total setiap kali)
    -- Jika Anda ingin melakukan pembaruan inkremental, logika ini perlu lebih kompleks (misalnya dengan MERGE)
    TRUNCATE TABLE silver.transformed_car_sales_transactions;

    -- Memasukkan data dari tabel bronze ke tabel silver dengan transformasi
    INSERT INTO silver.transformed_car_sales_transactions (
        Car_ID,
        Sales_Date,
        Customer_Name,
        Gender,
        Annual_Income,
        Dealer_Name,
        Car_Make,
        Car_Model,
        Engine_Type,
        Transmission_Type,
        Car_Color,
        Sales_Price,
        Dealer_Number,
        Body_Style,
        Customer_Phone,
        Dealer_Region,
        Sales_Year,
        Sales_Month,
        Sales_Day
        -- Last_Updated akan diisi oleh DEFAULT GETDATE()
    )
    SELECT
        b.Car_id,                               -- Dari bronze.raw_car_sales_transactions
        b.[Date],                               -- Dari bronze.raw_car_sales_transactions
        b.[Customer Name],                      -- Dari bronze.raw_car_sales_transactions
        b.Gender,                               -- Dari bronze.raw_car_sales_transactions
        TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(b.[Annual Income], '$', ''), ',', '')), -- Konversi dan bersihkan Annual Income
        b.Dealer_Name,                          -- Dari bronze.raw_car_sales_transactions
        b.Company,                              -- Menggunakan Company dari bronze sebagai Car_Make
        b.Model,                                -- Dari bronze.raw_car_sales_transactions
        b.Engine,                               -- Dari bronze.raw_car_sales_transactions
        b.Transmission,                         -- Dari bronze.raw_car_sales_transactions
        b.Color,                                -- Dari bronze.raw_car_sales_transactions
        TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(b.[Price ($)], '$', ''), ',', '')), -- Konversi dan bersihkan Price ($)
        b.[Dealer_No],                          -- Dari bronze.raw_car_sales_transactions
        b.[Body Style],                         -- Dari bronze.raw_car_sales_transactions
        b.Phone,                                -- Dari bronze.raw_car_sales_transactions
        b.Dealer_Region,                        -- Dari bronze.raw_car_sales_transactions
        YEAR(b.[Date]),                         -- Turunan: Tahun dari Sales_Date
        MONTH(b.[Date]),                        -- Turunan: Bulan dari Sales_Date
        DAY(b.[Date])                           -- Turunan: Hari dari Sales_Date
    FROM
        bronze.raw_car_sales_transactions AS b
    WHERE
        b.Car_id IS NOT NULL AND b.Car_id != ''; -- Contoh filter sederhana, data yang tidak valid tidak dimasukkan

    SELECT @@ROWCOUNT AS RowsLoadedIntoSilver;

END
GO

-- Cara Menjalankan Stored Procedure:
-- EXEC dbo.LoadSilverLayerCarSalesTransactions;
-- GO

-- Verifikasi data setelah Stored Procedure dijalankan (jalankan secara manual setelah EXEC)
-- SELECT TOP 100 * FROM silver.transformed_car_sales_transactions;
-- GO
-- SELECT COUNT(*) FROM silver.transformed_car_sales_transactions;
-- GO
