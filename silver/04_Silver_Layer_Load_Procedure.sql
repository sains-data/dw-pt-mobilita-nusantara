-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Membuat atau Mengubah Stored Procedure untuk memuat data ke Silver Layer
CREATE OR ALTER PROCEDURE dbo.LoadSilverLayerCarSalesTransactions_V2
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '--- Memulai Proses LoadSilverLayerCarSalesTransactions_V2 ---';

    DECLARE @BronzeCount INT;
    SELECT @BronzeCount = COUNT(*) FROM bronze.raw_car_sales_transactions;
    PRINT 'Jumlah baris di bronze.raw_car_sales_transactions: ' + CAST(@BronzeCount AS VARCHAR(10));

    IF @BronzeCount = 0
    BEGIN
        PRINT 'PERINGATAN: Tidak ada data di bronze.raw_car_sales_transactions. Proses pemuatan ke silver dihentikan.';
        RETURN; -- Keluar dari prosedur jika bronze kosong
    END

    -- Opsional: Kosongkan tabel silver sebelum memuat data baru
    TRUNCATE TABLE silver.transformed_car_sales_transactions;
    PRINT 'Tabel silver.transformed_car_sales_transactions telah di-TRUNCATE.';

    PRINT 'Mencoba INSERT ke silver.transformed_car_sales_transactions...';
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
        -- Last_Updated akan diisi oleh DEFAULT GETDATE() dari definisi tabel
    )
    SELECT
        b.Car_id,                               -- Kolom dari bronze
        b.[Date],                               -- Kolom dari bronze
        b.[Customer Name],                      -- Kolom dari bronze
        b.Gender,                               -- Kolom dari bronze
        TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(b.[Annual Income], '$', ''), ',', '')), -- Konversi Annual Income
        b.Dealer_Name,                          -- Kolom dari bronze
        b.Company,                              -- Menggunakan Company dari bronze sebagai Car_Make
        b.Model,                                -- Kolom dari bronze
        b.Engine,                               -- Kolom dari bronze
        b.Transmission,                         -- Kolom dari bronze
        b.Color,                                -- Kolom dari bronze
        TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(b.[Price ($)], '$', ''), ',', '')), -- Konversi Price
        b.[Dealer_No],                          -- Kolom dari bronze
        b.[Body Style],                         -- Kolom dari bronze
        b.Phone,                                -- Kolom dari bronze
        b.Dealer_Region,                        -- Kolom dari bronze
        YEAR(b.[Date]),                         -- Turunan: Tahun dari Sales_Date
        MONTH(b.[Date]),                        -- Turunan: Bulan dari Sales_Date
        DAY(b.[Date])                           -- Turunan: Hari dari Sales_Date
    FROM
        bronze.raw_car_sales_transactions AS b
    WHERE
        -- Filter dasar untuk memastikan data minimal yang diperlukan ada
        b.Car_id IS NOT NULL AND b.Car_id != '' AND b.[Date] IS NOT NULL;

    DECLARE @RowsLoaded INT;
    SET @RowsLoaded = @@ROWCOUNT;
    PRINT 'Jumlah baris yang berhasil dimasukkan ke silver.transformed_car_sales_transactions: ' + CAST(@RowsLoaded AS VARCHAR(10));

    IF @RowsLoaded = 0 AND @BronzeCount > 0
    BEGIN
        PRINT 'PERINGATAN PENTING: Tidak ada baris yang dimuat ke silver, meskipun bronze memiliki data. Periksa kondisi WHERE atau masalah konversi data yang mungkin membuat semua baris gagal (meskipun TRY_CONVERT seharusnya menghasilkan NULL).';
        PRINT 'Coba jalankan bagian SELECT dari INSERT secara manual untuk melihat hasilnya.';
    END
    ELSE IF @RowsLoaded > 0
    BEGIN
        PRINT 'BERHASIL: Data telah dimuat ke silver.transformed_car_sales_transactions.';
    END

    PRINT '--- Proses LoadSilverLayerCarSalesTransactions_V2 Selesai ---';
END
GO
