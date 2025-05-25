IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO


IF OBJECT_ID('silver.load_silver_data', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE silver.load_silver_data;
END
GO

CREATE PROCEDURE silver.load_silver_data
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        MERGE silver.conformed_customers AS Target
        USING (
            SELECT DISTINCT
                Customer_ID AS Customer_ID_Source,
                ISNULL(NULLIF(UPPER(TRIM(Customer_Name)), ''), 'UNKNOWN') 
                    AS Customer_Name_Cleaned,
                CASE 
                    WHEN LTRIM(RTRIM(UPPER(Gender))) IN ('MALE', 'M') THEN 'Male' 
                    WHEN LTRIM(RTRIM(UPPER(Gender))) IN ('FEMALE', 'F') THEN 'Female' 
                    ELSE 'Unknown' 
                END AS Gender_Standardized,
                NULL AS Age_Cleaned,
                NULL AS Full_Address,
                ISNULL(UPPER(TRIM(City)), 'UNKNOWN') AS City_Cleaned,
                NULL AS State_Cleaned,
                NULL AS Zip_Code_Cleaned,
                NULL AS Phone_Formatted,
                NULL AS Email_Validated,
                
                ISNULL(
                    TRY_CAST(
                        TRIM(REPLACE(REPLACE(bronze.Annual_Income, '$', ''), ',', '')) 
                        AS DECIMAL(18, 2)                                           
                    ), 
                    0.00                                                            
                ) AS Annual_Income_Cleaned
            FROM bronze.raw_car_sales_transactions
            WHERE Customer_ID IS NOT NULL AND Customer_ID <> '' 
        ) AS Source
        ON Target.Customer_ID_Source = Source.Customer_ID_Source
        WHEN MATCHED THEN
            UPDATE SET
                Customer_Name_Cleaned = Source.Customer_Name_Cleaned,
                Gender_Standardized = Source.Gender_Standardized,
                Age_Cleaned = Source.Age_Cleaned,
                Full_Address = Source.Full_Address,
                City_Cleaned = Source.City_Cleaned,
                State_Cleaned = Source.State_Cleaned,
                Zip_Code_Cleaned = Source.Zip_Code_Cleaned,
                Phone_Formatted = Source.Phone_Formatted,
                Email_Validated = Source.Email_Validated,
                Annual_Income_Cleaned = Source.Annual_Income_Cleaned
                
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                Customer_ID_Source, Customer_Name_Cleaned, Gender_Standardized, Age_Cleaned,
                Full_Address, City_Cleaned, State_Cleaned, Zip_Code_Cleaned,
                Phone_Formatted, Email_Validated, Annual_Income_Cleaned
            )
            VALUES (
                Source.Customer_ID_Source, Source.Customer_Name_Cleaned, Source.Gender_Standardized, 
                Source.Age_Cleaned, Source.Full_Address, Source.City_Cleaned, Source.State_Cleaned, 
                Source.Zip_Code_Cleaned, Source.Phone_Formatted, Source.Email_Validated, 
                Source.Annual_Income_Cleaned
            );
        PRINT 'silver.conformed_customers populated/updated.';


        MERGE silver.conformed_vehicles AS Target
        USING (
            SELECT DISTINCT
                Car_ID AS Car_ID_Source,
                ISNULL(NULLIF(UPPER(TRIM(Make)), ''), 'UNKNOWN') AS Make_Standardized,
                ISNULL(NULLIF(UPPER(TRIM(Model)), ''), 'UNKNOWN') AS Model_Standardized,
                CASE 
                    WHEN TRY_CAST(Year AS INT) < 1900 OR TRY_CAST(Year AS INT) > (YEAR(GETDATE()) + 1) 
                        THEN NULL 
                    ELSE TRY_CAST(Year AS INT) 
                END AS Year_Production,
                ISNULL(NULLIF(UPPER(TRIM(Color)), ''), 'UNKNOWN') AS Color_Cleaned,
                ISNULL(NULLIF(UPPER(TRIM(Body_Style)), ''), 'STANDARD') AS Body_Style_Standardized,
                ISNULL(NULLIF(UPPER(TRIM(Engine_Type)), ''), 'UNKNOWN') AS Engine_Type_Cleaned,
                ISNULL(NULLIF(UPPER(TRIM(Transmission)), ''), 'UNKNOWN') AS Transmission_Standardized,
                NULL AS Fuel_Type_Standardized,
                NULL AS Mileage_Cleaned 
            FROM bronze.raw_car_sales_transactions
            WHERE Car_ID IS NOT NULL AND Car_ID <> ''
        ) AS Source
        ON Target.Car_ID_Source = Source.Car_ID_Source
        WHEN MATCHED THEN
            UPDATE SET
                Make_Standardized = Source.Make_Standardized,
                Model_Standardized = Source.Model_Standardized,
                Year_Production = Source.Year_Production,
                Color_Cleaned = Source.Color_Cleaned,
                Body_Style_Standardized = Source.Body_Style_Standardized,
                Engine_Type_Cleaned = Source.Engine_Type_Cleaned,
                Transmission_Standardized = Source.Transmission_Standardized,
                Fuel_Type_Standardized = Source.Fuel_Type_Standardized,
                Mileage_Cleaned = Source.Mileage_Cleaned
                 
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                Car_ID_Source, Make_Standardized, Model_Standardized, Year_Production, Color_Cleaned,
                Body_Style_Standardized, Engine_Type_Cleaned, Transmission_Standardized,
                Fuel_Type_Standardized, Mileage_Cleaned
            )
            VALUES (
                Source.Car_ID_Source, Source.Make_Standardized, Source.Model_Standardized, Source.Year_Production, 
                Source.Color_Cleaned, Source.Body_Style_Standardized, Source.Engine_Type_Cleaned, 
                Source.Transmission_Standardized, Source.Fuel_Type_Standardized, Source.Mileage_Cleaned
            );
        PRINT 'silver.conformed_vehicles populated/updated.';

        
        MERGE silver.conformed_dealers AS Target
        USING (
            SELECT DISTINCT
                Dealer_ID AS Dealer_ID_Source,
                ISNULL(NULLIF(UPPER(TRIM(Dealer_Name)), ''), 'UNKNOWN') AS Dealer_Name_Cleaned,
                NULL AS Dealer_Location_Cleaned,
                ISNULL(NULLIF(UPPER(TRIM(Dealer_Region)), ''), 'UNKNOWN') AS Dealer_Region_Standardized 
            FROM bronze.raw_car_sales_transactions
            WHERE Dealer_ID IS NOT NULL AND Dealer_ID <> '' 
        ) AS Source
        ON Target.Dealer_ID_Source = Source.Dealer_ID_Source
        WHEN MATCHED THEN
            UPDATE SET
                Dealer_Name_Cleaned = Source.Dealer_Name_Cleaned,
                Dealer_Location_Cleaned = Source.Dealer_Location_Cleaned,
                Dealer_Region_Standardized = Source.Dealer_Region_Standardized
                
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (Dealer_ID_Source, Dealer_Name_Cleaned, Dealer_Location_Cleaned, Dealer_Region_Standardized)
            VALUES (Source.Dealer_ID_Source, Source.Dealer_Name_Cleaned, Source.Dealer_Location_Cleaned, Source.Dealer_Region_Standardized);
        PRINT 'silver.conformed_dealers populated/updated.';

        
        TRUNCATE TABLE silver.clean_sales_transactions;
        PRINT 'silver.clean_sales_transactions truncated.';

        INSERT INTO silver.clean_sales_transactions (
            Transaction_ID_Source,
            Date_Source,
            Customer_ID_Source,
            Car_ID_Source,
            Dealer_ID_Source,
            Sales_Price_Cleaned,
            Discount_Cleaned,
            Net_Sales_Price,
            Cost_Price_Cleaned,
            Payment_Type_Standardized
        )
        SELECT
            bronze.Transaction_ID,
            TRY_CAST(bronze.Date AS DATE) AS Date_Source, 
            bronze.Customer_ID,
            bronze.Car_ID,
            bronze.Dealer_ID,
            ISNULL(TRY_CAST(bronze.Sales_Price AS DECIMAL(18, 2)), 0.00) AS Sales_Price_Cleaned,
            0.00 AS Discount_Cleaned, 
            ISNULL(TRY_CAST(bronze.Sales_Price AS DECIMAL(18, 2)), 0.00) - 0.00 AS Net_Sales_Price, 
            0.00 AS Cost_Price_Cleaned, 
            'UNKNOWN' AS Payment_Type_Standardized 
        FROM bronze.raw_car_sales_transactions bronze
        WHERE bronze.Transaction_ID IS NOT NULL AND bronze.Transaction_ID <> '' 
            AND TRY_CAST(bronze.Date AS DATE) IS NOT NULL 
            AND bronze.Customer_ID IS NOT NULL AND bronze.Customer_ID <> '' 
            AND bronze.Car_ID IS NOT NULL AND bronze.Car_ID <> '' 
            AND bronze.Dealer_ID IS NOT NULL AND bronze.Dealer_ID <> '' 
            AND ISNULL(TRY_CAST(bronze.Sales_Price AS DECIMAL(18, 2)), 0.00) > 0; 
        
        PRINT 'silver.clean_sales_transactions populated.';

        COMMIT TRANSACTION;
        PRINT 'Silver layer load process completed successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error occurred during Silver layer load process.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        
        
        THROW;
    END CATCH
END
GO
