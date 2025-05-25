-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Membuat atau Mengubah Stored Procedure untuk memuat data ke Gold Layer
CREATE OR ALTER PROCEDURE dbo.LoadGoldLayerData
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------------
    -- 1. Populasi gold.dim_date
    --------------------------------------------------------------------------
    INSERT INTO gold.dim_date (date_key, [date], year, month, day, weekday, month_name, quarter)
    SELECT DISTINCT
        CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112)) AS date_key, -- YYYYMMDD format
        s.Sales_Date,
        YEAR(s.Sales_Date) AS year,
        MONTH(s.Sales_Date) AS month,
        DAY(s.Sales_Date) AS day,
        DATENAME(dw, s.Sales_Date) AS weekday,
        DATENAME(month, s.Sales_Date) AS month_name, -- Mengisi kolom month_name
        DATEPART(qq, s.Sales_Date) AS quarter        -- Mengisi kolom quarter
    FROM
        silver.transformed_car_sales_transactions s
    WHERE
        NOT EXISTS (
            SELECT 1
            FROM gold.dim_date dd
            WHERE dd.date_key = CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112))
        )
        AND s.Sales_Date IS NOT NULL;

    PRINT 'gold.dim_date populated/updated.';

    --------------------------------------------------------------------------
    -- 2. Populasi gold.dim_car
    --------------------------------------------------------------------------
    MERGE gold.dim_car AS Target
    USING (
        SELECT DISTINCT
            Car_ID,
            Car_Make,
            Car_Model,
            Engine_Type,         -- Kolom dari silver
            Transmission_Type,   -- Kolom dari silver
            Car_Color,
            Body_Style
        FROM silver.transformed_car_sales_transactions
        WHERE Car_ID IS NOT NULL
    ) AS Source
    ON Target.car_id = Source.Car_ID
    WHEN MATCHED THEN
        UPDATE SET
            Target.make = Source.Car_Make,
            Target.model = Source.Car_Model,
            Target.engine_type = Source.Engine_Type,               -- Mengisi kolom engine_type
            Target.transmission_type = Source.Transmission_Type,   -- Mengisi kolom transmission_type
            Target.color = Source.Car_Color,
            Target.body_style = Source.Body_Style
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (car_id, make, model, engine_type, transmission_type, color, body_style)
        VALUES (Source.Car_ID, Source.Car_Make, Source.Car_Model, Source.Engine_Type, Source.Transmission_Type, Source.Car_Color, Source.Body_Style);

    PRINT 'gold.dim_car populated/updated.';

    --------------------------------------------------------------------------
    -- 3. Populasi gold.dim_dealer
    --------------------------------------------------------------------------
    MERGE gold.dim_dealer AS Target
    USING (
        SELECT DISTINCT
            Dealer_Number,
            Dealer_Name,
            Dealer_Region
        FROM silver.transformed_car_sales_transactions
        WHERE Dealer_Number IS NOT NULL
    ) AS Source
    ON Target.dealer_number = Source.Dealer_Number
    WHEN MATCHED THEN
        UPDATE SET
            Target.dealer_name = Source.Dealer_Name,
            Target.dealer_region = Source.Dealer_Region
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (dealer_number, dealer_name, dealer_region)
        VALUES (Source.Dealer_Number, Source.Dealer_Name, Source.Dealer_Region);

    PRINT 'gold.dim_dealer populated/updated.';

    --------------------------------------------------------------------------
    -- 4. Populasi gold.dim_customer
    --------------------------------------------------------------------------
    MERGE gold.dim_customer AS Target
    USING (
        SELECT DISTINCT
            Customer_Name,
            Gender,
            Annual_Income,
            Customer_Phone
        FROM silver.transformed_car_sales_transactions
        WHERE Customer_Name IS NOT NULL OR Customer_Phone IS NOT NULL
    ) AS Source
    ON Target.customer_name = Source.Customer_Name AND ISNULL(Target.customer_phone, '') = ISNULL(Source.Customer_Phone, '')
    WHEN MATCHED THEN
        UPDATE SET
            Target.gender = Source.Gender,
            Target.annual_income = Source.Annual_Income
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (customer_name, gender, annual_income, customer_phone)
        VALUES (Source.Customer_Name, Source.Gender, Source.Annual_Income, Source.Customer_Phone);

    PRINT 'gold.dim_customer populated/updated.';

    --------------------------------------------------------------------------
    -- 5. Populasi gold.fact_car_sales
    --------------------------------------------------------------------------
    TRUNCATE TABLE gold.fact_car_sales;

    INSERT INTO gold.fact_car_sales (
        car_id_original,
        date_key,
        car_key,
        dealer_key,
        customer_key,
        sales_price
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
    LEFT JOIN
        gold.dim_date dd ON dd.date_key = CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112))
    LEFT JOIN
        gold.dim_car dc ON dc.car_id = s.Car_ID
    LEFT JOIN
        gold.dim_dealer ddl ON ddl.dealer_number = s.Dealer_Number
    LEFT JOIN
        gold.dim_customer dcu ON dcu.customer_name = s.Customer_Name AND ISNULL(dcu.customer_phone, '') = ISNULL(s.Customer_Phone, '')
    WHERE
        s.Car_ID IS NOT NULL AND s.Sales_Date IS NOT NULL;

    PRINT 'gold.fact_car_sales populated.';
    SELECT @@ROWCOUNT AS RowsLoadedIntoFactSales;

END
GO

-- Cara Menjalankan Stored Procedure:
-- EXEC dbo.LoadGoldLayerData;
-- GO
