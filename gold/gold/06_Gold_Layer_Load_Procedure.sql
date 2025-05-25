IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
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
        MERGE gold.dim_waktu AS Target
        USING (
            SELECT DISTINCT
                TRY_CONVERT(INT, FORMAT(sct.Date_Source, 'yyyyMMdd')) AS Date_Key,
                sct.Date_Source AS Full_Date,
                DAY(sct.Date_Source) AS Day_Number,
                MONTH(sct.Date_Source) AS Month_Number,
                FORMAT(sct.Date_Source, 'MMMM', 'en-US') AS Month_Name, 
                YEAR(sct.Date_Source) AS Year_Number,
                DATEPART(QUARTER, sct.Date_Source) AS Quarter_Number,
                FORMAT(sct.Date_Source, 'dddd', 'en-US') AS Day_of_Week_Name 
            FROM silver.clean_sales_transactions sct
            WHERE sct.Date_Source IS NOT NULL
        ) AS Source
        ON Target.Date_Key = Source.Date_Key
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (Date_Key, Full_Date, Day_Number, Month_Number, Month_Name, Year_Number, Quarter_Number, Day_of_Week_Name)
            VALUES (Source.Date_Key, Source.Full_Date, Source.Day_Number, Source.Month_Number, Source.Month_Name, Source.Year_Number, Source.Quarter_Number, Source.Day_of_Week_Name);
        PRINT 'gold.dim_waktu populated.';

        PRINT 'Populating gold.dim_pelanggan...';
        MERGE gold.dim_pelanggan AS Target
        USING (
            SELECT
                sc.Customer_ID_Source,
                sc.Customer_Name_Cleaned,
                sc.Gender_Standardized,
                CASE
                    WHEN sc.Age_Cleaned IS NULL THEN 'Unknown'
                    WHEN sc.Age_Cleaned BETWEEN 18 AND 25 THEN '18-25'
                    WHEN sc.Age_Cleaned BETWEEN 26 AND 35 THEN '26-35'
                    WHEN sc.Age_Cleaned BETWEEN 36 AND 45 THEN '36-45'
                    WHEN sc.Age_Cleaned BETWEEN 46 AND 55 THEN '46-55'
                    WHEN sc.Age_Cleaned BETWEEN 56 AND 65 THEN '56-65'
                    WHEN sc.Age_Cleaned > 65 THEN '65+'
                    ELSE 'Unknown' 
                END AS Age_Group,
                sc.City_Cleaned,
                sc.State_Cleaned, 
                CASE
                    WHEN sc.Annual_Income_Cleaned IS NULL THEN 'Unknown'
                    WHEN sc.Annual_Income_Cleaned < 30000 THEN 'Low'
                    WHEN sc.Annual_Income_Cleaned BETWEEN 30000 AND 59999 THEN 'Medium-Low'
                    WHEN sc.Annual_Income_Cleaned BETWEEN 60000 AND 89999 THEN 'Medium'
                    WHEN sc.Annual_Income_Cleaned BETWEEN 90000 AND 119999 THEN 'Medium-High'
                    WHEN sc.Annual_Income_Cleaned >= 120000 THEN 'High'
                    ELSE 'Unknown'
                END AS Income_Category
            FROM silver.conformed_customers sc
            WHERE sc.Customer_ID_Source IS NOT NULL AND sc.Customer_ID_Source NOT IN ('UNKNOWN_CUSTOMER_ID', 'NA_CUSTOMER_ID')
        ) AS Source
        ON Target.Customer_ID_Source = Source.Customer_ID_Source AND Target.Customer_Key > 0 
        WHEN MATCHED AND (
            Target.Customer_Name <> Source.Customer_Name_Cleaned OR
            ISNULL(Target.Gender, '') <> ISNULL(Source.Gender_Standardized, '') OR
            ISNULL(Target.Age_Group, '') <> ISNULL(Source.Age_Group, '') OR
            ISNULL(Target.City, '') <> ISNULL(Source.City_Cleaned, '') OR
            ISNULL(Target.State, '') <> ISNULL(Source.State_Cleaned, '') OR
            ISNULL(Target.Income_Category, '') <> ISNULL(Source.Income_Category, '')
        ) THEN
            UPDATE SET
                Customer_Name = Source.Customer_Name_Cleaned,
                Gender = Source.Gender_Standardized,
                Age_Group = Source.Age_Group,
                City = Source.City_Cleaned,
                State = Source.State_Cleaned,
                Income_Category = Source.Income_Category,
                DWH_Gold_Update_Timestamp = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (Customer_ID_Source, Customer_Name, Gender, Age_Group, City, State, Income_Category, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
            VALUES (Source.Customer_ID_Source, Source.Customer_Name_Cleaned, Source.Gender_Standardized, Source.Age_Group, Source.City_Cleaned, Source.State_Cleaned, Source.Income_Category, GETDATE(), GETDATE());
        PRINT 'gold.dim_pelanggan populated.';

        PRINT 'Populating gold.dim_kendaraan...';
        MERGE gold.dim_kendaraan AS Target
        USING (
            SELECT
                sv.Car_ID_Source,
                sv.Make_Standardized,
                sv.Model_Standardized,
                sv.Year_Production,
                sv.Color_Cleaned,
                sv.Body_Style_Standardized,
                sv.Engine_Type_Cleaned,
                sv.Transmission_Standardized,
                sv.Fuel_Type_Standardized, 
                CASE
                    WHEN sv.Mileage_Cleaned IS NULL THEN 'Unknown'
                    WHEN sv.Mileage_Cleaned < 25000 THEN 'Low'
                    WHEN sv.Mileage_Cleaned BETWEEN 25000 AND 74999 THEN 'Medium'
                    WHEN sv.Mileage_Cleaned >= 75000 THEN 'High'
                    ELSE 'Unknown'
                END AS Mileage_Category
            FROM silver.conformed_vehicles sv
            WHERE sv.Car_ID_Source IS NOT NULL AND sv.Car_ID_Source NOT IN ('UNKNOWN_CAR_ID', 'NA_CAR_ID')
        ) AS Source
        ON Target.Car_ID_Source = Source.Car_ID_Source AND Target.Vehicle_Key > 0 
        WHEN MATCHED AND (
            Target.Make <> Source.Make_Standardized OR
            Target.Model <> Source.Model_Standardized OR
            ISNULL(Target.Year_Production, 0) <> ISNULL(Source.Year_Production, 0) OR
            ISNULL(Target.Color, '') <> ISNULL(Source.Color_Cleaned, '') OR
            ISNULL(Target.Body_Style, '') <> ISNULL(Source.Body_Style_Standardized, '') OR
            ISNULL(Target.Engine_Type, '') <> ISNULL(Source.Engine_Type_Cleaned, '') OR
            ISNULL(Target.Transmission, '') <> ISNULL(Source.Transmission_Standardized, '') OR
            ISNULL(Target.Fuel_Type, '') <> ISNULL(Source.Fuel_Type_Standardized, '') OR
            ISNULL(Target.Mileage_Category, '') <> ISNULL(Source.Mileage_Category, '')
        ) THEN
            UPDATE SET
                Make = Source.Make_Standardized,
                Model = Source.Model_Standardized,
                Year_Production = Source.Year_Production,
                Color = Source.Color_Cleaned,
                Body_Style = Source.Body_Style_Standardized,
                Engine_Type = Source.Engine_Type_Cleaned,
                Transmission = Source.Transmission_Standardized,
                Fuel_Type = Source.Fuel_Type_Standardized,
                Mileage_Category = Source.Mileage_Category,
                DWH_Gold_Update_Timestamp = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (Car_ID_Source, Make, Model, Year_Production, Color, Body_Style, Engine_Type, Transmission, Fuel_Type, Mileage_Category, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
            VALUES (Source.Car_ID_Source, Source.Make_Standardized, Source.Model_Standardized, Source.Year_Production, Source.Color_Cleaned, Source.Body_Style_Standardized, Source.Engine_Type_Cleaned, Source.Transmission_Standardized, Source.Fuel_Type_Standardized, Source.Mileage_Category, GETDATE(), GETDATE());
        PRINT 'gold.dim_kendaraan populated.';

        PRINT 'Populating gold.dim_dealer...';
        MERGE gold.dim_dealer AS Target
        USING (
            SELECT
                sd.Dealer_ID_Source,
                sd.Dealer_Name_Cleaned,
                sd.Dealer_Location_Cleaned, 
                sd.Dealer_Region_Standardized
            FROM silver.conformed_dealers sd
            WHERE sd.Dealer_ID_Source IS NOT NULL AND sd.Dealer_ID_Source NOT IN ('UNKNOWN_DEALER_ID', 'NA_DEALER_ID')
        ) AS Source
        ON Target.Dealer_ID_Source = Source.Dealer_ID_Source AND Target.Dealer_Key > 0 
        WHEN MATCHED AND (
            Target.Dealer_Name <> Source.Dealer_Name_Cleaned OR
            ISNULL(Target.Dealer_Location, '') <> ISNULL(Source.Dealer_Location_Cleaned, '') OR
            ISNULL(Target.Dealer_Region, '') <> ISNULL(Source.Dealer_Region_Standardized, '')
        ) THEN
            UPDATE SET
                Dealer_Name = Source.Dealer_Name_Cleaned,
                Dealer_Location = Source.Dealer_Location_Cleaned,
                Dealer_Region = Source.Dealer_Region_Standardized,
                DWH_Gold_Update_Timestamp = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (Dealer_ID_Source, Dealer_Name, Dealer_Location, Dealer_Region, DWH_Gold_Insert_Timestamp, DWH_Gold_Update_Timestamp)
            VALUES (Source.Dealer_ID_Source, Source.Dealer_Name_Cleaned, Source.Dealer_Location_Cleaned, Source.Dealer_Region_Standardized, GETDATE(), GETDATE());
        PRINT 'gold.dim_dealer populated.';

        PRINT 'Populating gold.fact_penjualan...';
        TRUNCATE TABLE gold.fact_penjualan;
        PRINT 'gold.fact_penjualan truncated.';

        INSERT INTO gold.fact_penjualan (
            Date_Key, Customer_Key, Vehicle_Key, Dealer_Key, Transaction_ID_Source,
            Units_Sold, Sales_Amount_USD, Cost_Amount_USD, Profit_Amount_USD, Discount_Amount_USD,
            DWH_Gold_Insert_Timestamp
        )
        SELECT
            COALESCE(dw.Date_Key, 0) AS Date_Key, 
            COALESCE(dp.Customer_Key, 0) AS Customer_Key, 
            COALESCE(dv.Vehicle_Key, 0) AS Vehicle_Key, 
            COALESCE(dd.Dealer_Key, 0) AS Dealer_Key,
            sct.Transaction_ID_Source,
            1 AS Units_Sold, 
            sct.Net_Sales_Price AS Sales_Amount_USD,
            sct.Cost_Price_Cleaned AS Cost_Amount_USD,
            (sct.Net_Sales_Price - sct.Cost_Price_Cleaned) AS Profit_Amount_USD,
            sct.Discount_Cleaned AS Discount_Amount_USD,
            GETDATE() AS DWH_Gold_Insert_Timestamp
        FROM silver.clean_sales_transactions sct
        LEFT JOIN gold.dim_waktu dw ON TRY_CONVERT(INT, FORMAT(sct.Date_Source, 'yyyyMMdd')) = dw.Date_Key
        LEFT JOIN gold.dim_pelanggan dp ON sct.Customer_ID_Source = dp.Customer_ID_Source AND dp.Customer_Key > 0
        LEFT JOIN gold.dim_kendaraan dv ON sct.Car_ID_Source = dv.Car_ID_Source AND dv.Vehicle_Key > 0
        LEFT JOIN gold.dim_dealer dd ON sct.Dealer_ID_Source = dd.Dealer_ID_Source AND dd.Dealer_Key > 0;
        PRINT 'gold.fact_penjualan populated.';

        COMMIT TRANSACTION;
        PRINT 'Gold layer load process completed successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error occurred during Gold layer load process:';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-');
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        
        THROW;
    END CATCH
END
GO
      
SELECT Mileage_Category, COUNT(*) FROM gold.dim_kendaraan GROUP BY Mileage_Category;
*/
GO
