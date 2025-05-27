-- File: 06_Gold_Layer_Load_Procedure.sql (Versi dbo.LoadGoldLayerData_V2 Final yang Direvisi)
USE [pt-mobilita-nusantara];
GO

-- Membuat atau Mengubah Stored Procedure untuk memuat data ke Gold Layer
CREATE OR ALTER PROCEDURE dbo.LoadGoldLayerData_V2
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '--- Memulai Proses LoadGoldLayerData_V2 ---';

    DECLARE @SilverCount INT;
    SELECT @SilverCount = COUNT(*) FROM silver.transformed_car_sales_transactions;
    PRINT 'Jumlah baris di silver.transformed_car_sales_transactions: ' + CAST(@SilverCount AS VARCHAR(10));

    IF @SilverCount = 0
    BEGIN
        PRINT 'PERINGATAN: Tidak ada data di silver.transformed_car_sales_transactions. Proses pemuatan ke gold dihentikan.';
        RETURN;
    END

    --------------------------------------------------------------------------
    -- 1. Populasi gold.dim_date
    --------------------------------------------------------------------------
    PRINT 'Memulai populasi gold.dim_date...';
    -- Jika Anda ingin dim_date di-refresh total setiap kali, uncomment TRUNCATE di bawah.
    -- Untuk pemuatan awal atau jika Anda ingin data tanggal bertambah terus, biarkan seperti ini.
    -- TRUNCATE TABLE gold.dim_date;
    -- IF @@ROWCOUNT > 0 PRINT 'Tabel gold.dim_date telah di-TRUNCATE.';

    INSERT INTO gold.dim_date (date_key, [date], year, month, day, weekday, month_name, quarter)
    SELECT DISTINCT
        CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112)) AS date_key,
        s.Sales_Date,
        YEAR(s.Sales_Date) AS year,
        MONTH(s.Sales_Date) AS month,
        DAY(s.Sales_Date) AS day,
        DATENAME(dw, s.Sales_Date) AS weekday,
        DATENAME(month, s.Sales_Date) AS month_name,
        DATEPART(qq, s.Sales_Date) AS quarter
    FROM
        silver.transformed_car_sales_transactions s
    WHERE
        NOT EXISTS ( -- Hanya masukkan tanggal yang belum ada di dim_date
            SELECT 1
            FROM gold.dim_date dd
            WHERE dd.date_key = CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112))
        )
        AND s.Sales_Date IS NOT NULL;
    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris baru ditambahkan ke gold.dim_date.';

    --------------------------------------------------------------------------
    -- 2. Populasi gold.dim_car
    --------------------------------------------------------------------------
    PRINT 'Memulai populasi gold.dim_car...';
    MERGE gold.dim_car AS Target
    USING (
        SELECT DISTINCT
            Car_ID, Car_Make, Car_Model, Engine_Type,
            Transmission_Type, Car_Color, Body_Style
        FROM silver.transformed_car_sales_transactions
        WHERE Car_ID IS NOT NULL AND Car_ID != '' -- Pastikan Car_ID valid
    ) AS Source
    ON Target.car_id = Source.Car_ID
    WHEN MATCHED THEN
        UPDATE SET
            Target.make = Source.Car_Make,
            Target.model = Source.Car_Model,
            Target.engine_type = Source.Engine_Type,
            Target.transmission_type = Source.Transmission_Type,
            Target.color = Source.Car_Color,
            Target.body_style = Source.Body_Style
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (car_id, make, model, engine_type, transmission_type, color, body_style)
        VALUES (Source.Car_ID, Source.Car_Make, Source.Car_Model, Source.Engine_Type, Source.Transmission_Type, Source.Car_Color, Source.Body_Style);
    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris terpengaruh (INSERT/UPDATE) di gold.dim_car.';

    --------------------------------------------------------------------------
    -- 3. Populasi gold.dim_dealer (Dengan Perbaikan Duplikasi)
    --------------------------------------------------------------------------
    PRINT 'Memulai populasi gold.dim_dealer...';
    MERGE gold.dim_dealer AS Target
    USING (
        SELECT Dealer_Number, Dealer_Name, Dealer_Region
        FROM (
            SELECT
                Dealer_Number, Dealer_Name, Dealer_Region,
                ROW_NUMBER() OVER(PARTITION BY Dealer_Number ORDER BY Dealer_Name DESC, Dealer_Region DESC) as rn -- Ambil yang paling "lengkap" atau "terbaru" jika ada variasi
            FROM silver.transformed_car_sales_transactions
            WHERE Dealer_Number IS NOT NULL AND Dealer_Number != ''
        ) AS RankedDealers
        WHERE rn = 1 -- Ambil hanya satu baris unik per Dealer_Number
    ) AS Source
    ON Target.dealer_number = Source.Dealer_Number
    WHEN MATCHED THEN
        UPDATE SET
            Target.dealer_name = Source.Dealer_Name,
            Target.dealer_region = Source.Dealer_Region
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (dealer_number, dealer_name, dealer_region)
        VALUES (Source.Dealer_Number, Source.Dealer_Name, Source.Dealer_Region);
    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris terpengaruh (INSERT/UPDATE) di gold.dim_dealer.';

    --------------------------------------------------------------------------
    -- 4. Populasi gold.dim_customer
    --------------------------------------------------------------------------
    PRINT 'Memulai populasi gold.dim_customer...';
    MERGE gold.dim_customer AS Target
    USING (
        SELECT DISTINCT
            Customer_Name, Gender, Annual_Income, Customer_Phone
        FROM silver.transformed_car_sales_transactions
        WHERE (Customer_Name IS NOT NULL AND Customer_Name != '') OR (Customer_Phone IS NOT NULL AND Customer_Phone != '') -- Minimal ada nama atau telepon valid
    ) AS Source
    ON Target.customer_name = Source.Customer_Name AND ISNULL(Target.customer_phone, 'N/A_PHONE') = ISNULL(Source.Customer_Phone, 'N/A_PHONE') -- Handle NULL pada telepon dengan lebih baik
    WHEN MATCHED THEN
        UPDATE SET
            Target.gender = Source.Gender,
            Target.annual_income = Source.Annual_Income
            -- Pertimbangkan apakah customer_phone perlu diupdate jika berubah untuk nama yang sama
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (customer_name, gender, annual_income, customer_phone)
        VALUES (Source.Customer_Name, Source.Gender, Source.Annual_Income, Source.Customer_Phone);
    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris terpengaruh (INSERT/UPDATE) di gold.dim_customer.';

    --------------------------------------------------------------------------
    -- 5. Populasi gold.fact_car_sales
    --------------------------------------------------------------------------
    PRINT 'Memulai populasi gold.fact_car_sales...';
    TRUNCATE TABLE gold.fact_car_sales;
    PRINT 'Tabel gold.fact_car_sales telah di-TRUNCATE.';

    INSERT INTO gold.fact_car_sales (
        car_id_original, date_key, car_key, dealer_key, customer_key, sales_price
    )
    SELECT
        s.Car_ID,
        dd.date_key,
        dc.car_key,
        ddl.dealer_key,
        dcu.customer_key,
        s.Sales_Price
    FROM
        silver.transformed_car_sales_transactions s
    INNER JOIN -- Menggunakan INNER JOIN untuk memastikan semua kunci dimensi ditemukan
        gold.dim_date dd ON dd.date_key = CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112))
    INNER JOIN
        gold.dim_car dc ON dc.car_id = s.Car_ID
    INNER JOIN
        gold.dim_dealer ddl ON ddl.dealer_number = s.Dealer_Number
    INNER JOIN
        gold.dim_customer dcu ON dcu.customer_name = s.Customer_Name AND ISNULL(dcu.customer_phone, 'N/A_PHONE') = ISNULL(s.Customer_Phone, 'N/A_PHONE')
    WHERE
        s.Sales_Price IS NOT NULL; -- Pastikan ada harga jual untuk fakta

    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris berhasil dimasukkan ke gold.fact_car_sales.';
    PRINT '--- Proses LoadGoldLayerData_V2 Selesai ---';

END
GO

PRINT 'Stored procedure dbo.LoadGoldLayerData_V2 berhasil dibuat/diperbarui.';
