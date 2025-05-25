IF NOT EXISTS (
    SELECT name
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC ('CREATE SCHEMA silver');
END
GO


IF OBJECT_ID('silver.clean_sales_transactions', 'U') IS NULL
BEGIN
    CREATE TABLE silver.clean_sales_transactions (
        transaction_id_source NVARCHAR(255) NOT NULL,
        date_source DATE,
        customer_id_source NVARCHAR(255),
        car_id_source NVARCHAR(255),
        dealer_id_source NVARCHAR(255),
        sales_price_cleaned DECIMAL(18, 2),
        discount_cleaned DECIMAL(18, 2) NULL,
        net_sales_price DECIMAL(18, 2),
        cost_price_cleaned DECIMAL(18, 2) NULL,
        payment_type_standardized NVARCHAR(50),
        dwh_silver_insert_timestamp DATETIME2(7) DEFAULT GETDATE(),
        CONSTRAINT pk_clean_sales_transactions PRIMARY KEY (transaction_id_source)
    );
    PRINT 'Table silver.clean_sales_transactions created.';
END
ELSE
BEGIN
    PRINT 'Table silver.clean_sales_transactions already exists.';
END
GO


IF OBJECT_ID('silver.conformed_customers', 'U') IS NULL
BEGIN
    CREATE TABLE silver.conformed_customers (
        customer_id_source NVARCHAR(255) NOT NULL,
        customer_name_cleaned NVARCHAR(255),
        gender_standardized NVARCHAR(10),
        age_cleaned INT NULL,
        full_address NVARCHAR(500) NULL,
        city_cleaned NVARCHAR(100),
        state_cleaned NVARCHAR(100) NULL,
        zip_code_cleaned NVARCHAR(20) NULL,
        phone_formatted NVARCHAR(50) NULL,
        email_validated NVARCHAR(255) NULL,
        annual_income_cleaned DECIMAL(18, 2) NULL,
        dwh_silver_insert_timestamp DATETIME2(7) DEFAULT GETDATE(),
        CONSTRAINT pk_conformed_customers PRIMARY KEY (customer_id_source)
    );
    PRINT 'Table silver.conformed_customers created.';
END
ELSE
BEGIN
    PRINT 'Table silver.conformed_customers already exists.';
END
GO


IF OBJECT_ID('silver.conformed_vehicles', 'U') IS NULL
BEGIN
    CREATE TABLE silver.conformed_vehicles (
        car_id_source NVARCHAR(255) NOT NULL,
        make_standardized NVARCHAR(100),
        model_standardized NVARCHAR(100),
        year_production INT,
        color_cleaned NVARCHAR(50),
        body_style_standardized NVARCHAR(50),
        engine_type_cleaned NVARCHAR(50) NULL,
        transmission_standardized NVARCHAR(50),
        fuel_type_standardized NVARCHAR(50) NULL,
        mileage_cleaned INT NULL,
        dwh_silver_insert_timestamp DATETIME2(7) DEFAULT GETDATE(),
        CONSTRAINT pk_conformed_vehicles PRIMARY KEY (car_id_source)
    );
    PRINT 'Table silver.conformed_vehicles created.';
END
ELSE
BEGIN
    PRINT 'Table silver.conformed_vehicles already exists.';
END
GO


IF OBJECT_ID('silver.conformed_dealers', 'U') IS NULL
BEGIN
    CREATE TABLE silver.conformed_dealers (
        dealer_id_source NVARCHAR(255) NOT NULL,
        dealer_name_cleaned NVARCHAR(255),
        dealer_location_cleaned NVARCHAR(255) NULL,
        dealer_region_standardized NVARCHAR(100) NULL,
        dwh_silver_insert_timestamp DATETIME2(7) DEFAULT GETDATE(),
        CONSTRAINT pk_conformed_dealers PRIMARY KEY (dealer_id_source)
    );
    PRINT 'Table silver.conformed_dealers created.';
END
ELSE
BEGIN
    PRINT 'Table silver.conformed_dealers already exists.';
END
GO

PRINT 'Silver layer DDL script execution completed.';
GO
