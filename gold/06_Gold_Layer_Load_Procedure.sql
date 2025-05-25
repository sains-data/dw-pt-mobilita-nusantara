IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC ('CREATE SCHEMA gold'); 
END
GO

IF OBJECT_ID('gold.load_gold_data', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE gold.load_gold_data;
END
GO

CREATE PROCEDURE gold.load_gold_data
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        PRINT 'Populating gold.dim_waktu...';
        MERGE gold.dim_waktu AS target
        USING (
            SELECT DISTINCT
                TRY_CONVERT(INT, FORMAT(sct.date_source, 'yyyyMMdd')) AS date_key,
                sct.date_source AS full_date,
                DAY(sct.date_source) AS day_number,
                MONTH(sct.date_source) AS month_number,
                FORMAT(sct.date_source, 'MMMM', 'en-US') AS month_name,
                YEAR(sct.date_source) AS year_number,
                DATEPART(QUARTER, sct.date_source) AS quarter_number,
                FORMAT(sct.date_source, 'dddd', 'en-US') AS day_of_week_name
            FROM
                silver.clean_sales_transactions AS sct
            WHERE
                sct.date_source IS NOT NULL
        ) AS source
        ON target.date_key = source.date_key
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                date_key, full_date, day_number, month_number, month_name,
                year_number, quarter_number, day_of_week_name
            )
            VALUES (
                source.date_key, source.full_date, source.day_number, source.month_number, source.month_name,
                source.year_number, source.quarter_number, source.day_of_week_name
            );
        PRINT 'gold.dim_waktu populated.';

        PRINT 'Populating gold.dim_pelanggan...';
        MERGE gold.dim_pelanggan AS target
        USING (
            SELECT
                sc.customer_id_source,
                sc.customer_name_cleaned,
                sc.gender_standardized,
                CASE
                    WHEN sc.age_cleaned IS NULL THEN 'Unknown'
                    WHEN sc.age_cleaned BETWEEN 18 AND 25 THEN '18-25'
                    WHEN sc.age_cleaned BETWEEN 26 AND 35 THEN '26-35'
                    WHEN sc.age_cleaned BETWEEN 36 AND 45 THEN '36-45'
                    WHEN sc.age_cleaned BETWEEN 46 AND 55 THEN '46-55'
                    WHEN sc.age_cleaned BETWEEN 56 AND 65 THEN '56-65'
                    WHEN sc.age_cleaned > 65 THEN '65+'
                    ELSE 'Unknown'
                END AS age_group,
                sc.city_cleaned,
                sc.state_cleaned,
                CASE
                    WHEN sc.annual_income_cleaned IS NULL THEN 'Unknown'
                    WHEN sc.annual_income_cleaned < 30000 THEN 'Low'
                    WHEN sc.annual_income_cleaned BETWEEN 30000 AND 59999 THEN 'Medium-Low'
                    WHEN sc.annual_income_cleaned BETWEEN 60000 AND 89999 THEN 'Medium'
                    WHEN sc.annual_income_cleaned BETWEEN 90000 AND 119999 THEN 'Medium-High'
                    WHEN sc.annual_income_cleaned >= 120000 THEN 'High'
                    ELSE 'Unknown'
                END AS income_category
            FROM
                silver.conformed_customers AS sc 
            WHERE
                sc.customer_id_source IS NOT NULL
                AND sc.customer_id_source NOT IN ('UNKNOWN_CUSTOMER_ID', 'NA_CUSTOMER_ID')
        ) AS source
        ON target.customer_id_source = source.customer_id_source AND target.customer_key > 0
        WHEN MATCHED AND (
                target.customer_name <> source.customer_name_cleaned
                OR ISNULL(target.gender, '') <> ISNULL(source.gender_standardized, '')
                OR ISNULL(target.age_group, '') <> ISNULL(source.age_group, '')
                OR ISNULL(target.city, '') <> ISNULL(source.city_cleaned, '')
                OR ISNULL(target.state, '') <> ISNULL(source.state_cleaned, '')
                OR ISNULL(target.income_category, '') <> ISNULL(source.income_category, '')
            ) THEN
            UPDATE SET
                customer_name = source.customer_name_cleaned,
                gender = source.gender_standardized,
                age_group = source.age_group,
                city = source.city_cleaned,
                state = source.state_cleaned,
                income_category = source.income_category,
                dwh_gold_update_timestamp = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                customer_id_source, customer_name, gender, age_group, city, state,
                income_category, dwh_gold_insert_timestamp, dwh_gold_update_timestamp
            )
            VALUES (
                source.customer_id_source, source.customer_name_cleaned, source.gender_standardized,
                source.age_group, source.city_cleaned, source.state_cleaned, source.income_category,
                GETDATE(), GETDATE()
            );
        PRINT 'gold.dim_pelanggan populated.';

        PRINT 'Populating gold.dim_kendaraan...';
        MERGE gold.dim_kendaraan AS target
        USING (
            SELECT
                sv.car_id_source,
                sv.make_standardized,
                sv.model_standardized,
                sv.year_production,
                sv.color_cleaned,
                sv.body_style_standardized,
                sv.engine_type_cleaned,
                sv.transmission_standardized,
                sv.fuel_type_standardized,
                CASE
                    WHEN sv.mileage_cleaned IS NULL THEN 'Unknown'
                    WHEN sv.mileage_cleaned < 25000 THEN 'Low'
                    WHEN sv.mileage_cleaned BETWEEN 25000 AND 74999 THEN 'Medium'
                    WHEN sv.mileage_cleaned >= 75000 THEN 'High'
                    ELSE 'Unknown'
                END AS mileage_category
            FROM
                silver.conformed_vehicles AS sv 
            WHERE
                sv.car_id_source IS NOT NULL
                AND sv.car_id_source NOT IN ('UNKNOWN_CAR_ID', 'NA_CAR_ID')
        ) AS source
        ON target.car_id_source = source.car_id_source AND target.vehicle_key > 0
        WHEN MATCHED AND (
                target.make <> source.make_standardized
                OR target.model <> source.model_standardized
                OR ISNULL(target.year_production, 0) <> ISNULL(source.year_production, 0)
                OR ISNULL(target.color, '') <> ISNULL(source.color_cleaned, '')
                OR ISNULL(target.body_style, '') <> ISNULL(source.body_style_standardized, '')
                OR ISNULL(target.engine_type, '') <> ISNULL(source.engine_type_cleaned, '')
                OR ISNULL(target.transmission, '') <> ISNULL(source.transmission_standardized, '')
                OR ISNULL(target.fuel_type, '') <> ISNULL(source.fuel_type_standardized, '')
                OR ISNULL(target.mileage_category, '') <> ISNULL(source.mileage_category, '')
            ) THEN
            UPDATE SET
                make = source.make_standardized,
                model = source.model_standardized,
                year_production = source.year_production,
                color = source.color_cleaned,
                body_style = source.body_style_standardized,
                engine_type = source.engine_type_cleaned,
                transmission = source.transmission_standardized,
                fuel_type = source.fuel_type_standardized,
                mileage_category = source.mileage_category,
                dwh_gold_update_timestamp = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                car_id_source, make, model, year_production, color, body_style,
                engine_type, transmission, fuel_type, mileage_category,
                dwh_gold_insert_timestamp, dwh_gold_update_timestamp
            )
            VALUES (
                source.car_id_source, source.make_standardized, source.model_standardized,
                source.year_production, source.color_cleaned, source.body_style_standardized,
                source.engine_type_cleaned, source.transmission_standardized, source.fuel_type_standardized,
                source.mileage_category, GETDATE(), GETDATE()
            );
        PRINT 'gold.dim_kendaraan populated.';

        PRINT 'Populating gold.dim_dealer...';
        MERGE gold.dim_dealer AS target
        USING (
            SELECT
                sd.dealer_id_source,
                sd.dealer_name_cleaned,
                sd.dealer_location_cleaned,
                sd.dealer_region_standardized
            FROM
                silver.conformed_dealers AS sd 
            WHERE
                sd.dealer_id_source IS NOT NULL
                AND sd.dealer_id_source NOT IN ('UNKNOWN_DEALER_ID', 'NA_DEALER_ID')
        ) AS source
        ON target.dealer_id_source = source.dealer_id_source AND target.dealer_key > 0
        WHEN MATCHED AND (
                target.dealer_name <> source.dealer_name_cleaned
                OR ISNULL(target.dealer_location, '') <> ISNULL(source.dealer_location_cleaned, '')
                OR ISNULL(target.dealer_region, '') <> ISNULL(source.dealer_region_standardized, '')
            ) THEN
            UPDATE SET
                dealer_name = source.dealer_name_cleaned,
                dealer_location = source.dealer_location_cleaned,
                dealer_region = source.dealer_region_standardized,
                dwh_gold_update_timestamp = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                dealer_id_source, dealer_name, dealer_location, dealer_region,
                dwh_gold_insert_timestamp, dwh_gold_update_timestamp
            )
            VALUES (
                source.dealer_id_source, source.dealer_name_cleaned, source.dealer_location_cleaned,
                source.dealer_region_standardized, GETDATE(), GETDATE()
            );
        PRINT 'gold.dim_dealer populated.';

        PRINT 'Populating gold.fact_penjualan...';
        TRUNCATE TABLE gold.fact_penjualan; 
        PRINT 'gold.fact_penjualan truncated.';

        INSERT INTO gold.fact_penjualan (
            date_key, customer_key, vehicle_key, dealer_key, transaction_id_source,
            units_sold, sales_amount_usd, cost_amount_usd, profit_amount_usd, discount_amount_usd,
            dwh_gold_insert_timestamp
        )
        SELECT
            COALESCE(dw.date_key, 0) AS date_key,
            COALESCE(dp.customer_key, 0) AS customer_key,
            COALESCE(dv.vehicle_key, 0) AS vehicle_key,
            COALESCE(dd.dealer_key, 0) AS dealer_key,
            sct.transaction_id_source,
            1 AS units_sold, 
            sct.net_sales_price AS sales_amount_usd,
            sct.cost_price_cleaned AS cost_amount_usd,
            (sct.net_sales_price - sct.cost_price_cleaned) AS profit_amount_usd,
            sct.discount_cleaned AS discount_amount_usd,
            GETDATE() AS dwh_gold_insert_timestamp
        FROM
            silver.clean_sales_transactions AS sct 
            LEFT JOIN gold.dim_waktu AS dw 
                ON TRY_CONVERT(INT, FORMAT(sct.date_source, 'yyyyMMdd')) = dw.date_key
            LEFT JOIN gold.dim_pelanggan AS dp 
                ON sct.customer_id_source = dp.customer_id_source AND dp.customer_key > 0
            LEFT JOIN gold.dim_kendaraan AS dv 
                ON sct.car_id_source = dv.car_id_source AND dv.vehicle_key > 0
            LEFT JOIN gold.dim_dealer AS dd
                ON sct.dealer_id_source = dd.dealer_id_source AND dd.dealer_key > 0;
        PRINT 'gold.fact_penjualan populated.';

        COMMIT TRANSACTION;
        PRINT 'Gold layer load process completed successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error occurred during Gold layer load process:';

        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(MAX));
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(MAX));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(MAX));
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-');
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(MAX));
        PRINT 'Error Message: ' + ERROR_MESSAGE();

        THROW;
    END CATCH; 
END; 
GO
