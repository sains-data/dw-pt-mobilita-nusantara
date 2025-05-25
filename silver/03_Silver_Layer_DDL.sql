
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO


IF OBJECT_ID('silver.clean_sales_transactions', 'U') IS NULL
BEGIN
    CREATE TABLE silver.clean_sales_transactions (
        Transaction_ID_Source NVARCHAR(255) NOT NULL,      
        Date_Source DATE,                                  
        Customer_ID_Source NVARCHAR(255),                  
        Car_ID_Source NVARCHAR(255),                       
        Dealer_ID_Source NVARCHAR(255),                    
        Sales_Price_Cleaned DECIMAL(18, 2),                
        Discount_Cleaned DECIMAL(18, 2) NULL,              
        Net_Sales_Price DECIMAL(18, 2),                    
        Cost_Price_Cleaned DECIMAL(18, 2) NULL,            
        Payment_Type_Standardized NVARCHAR(50),            
        
       
        DWH_Silver_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(), 
        
        CONSTRAINT PK_clean_sales_transactions PRIMARY KEY (Transaction_ID_Source)
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
        Customer_ID_Source NVARCHAR(255) NOT NULL,        
        Customer_Name_Cleaned NVARCHAR(255),              
        Gender_Standardized NVARCHAR(10),                
                                                           
        Age_Cleaned INT NULL,                             
        Full_Address NVARCHAR(500) NULL,                   
        City_Cleaned NVARCHAR(100),                        
        State_Cleaned NVARCHAR(100) NULL,                  
        Zip_Code_Cleaned NVARCHAR(20) NULL,               
        Phone_Formatted NVARCHAR(50) NULL,                 
        Email_Validated NVARCHAR(255) NULL,                
        Annual_Income_Cleaned DECIMAL(18, 2) NULL,         
        
       
        DWH_Silver_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(), 
        
        CONSTRAINT PK_conformed_customers PRIMARY KEY (Customer_ID_Source)
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
        Car_ID_Source NVARCHAR(255) NOT NULL,              
        Make_Standardized NVARCHAR(100),                   
        Model_Standardized NVARCHAR(100),                  
        Year_Production INT,                          
        Color_Cleaned NVARCHAR(50),                        
        Body_Style_Standardized NVARCHAR(50),             
        Engine_Type_Cleaned NVARCHAR(50) NULL,            
        Transmission_Standardized NVARCHAR(50),
        Fuel_Type_Standardized NVARCHAR(50) NULL,    
        Mileage_Cleaned INT NULL,                       
        
       
        DWH_Silver_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(), 
        
        CONSTRAINT PK_conformed_vehicles PRIMARY KEY (Car_ID_Source)
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
        Dealer_ID_Source NVARCHAR(255) NOT NULL,           
        Dealer_Name_Cleaned NVARCHAR(255),                 
        Dealer_Location_Cleaned NVARCHAR(255) NULL,        
        Dealer_Region_Standardized NVARCHAR(100) NULL,     
        
        
        DWH_Silver_Insert_Timestamp DATETIME2(7) DEFAULT GETDATE(), 
        
        CONSTRAINT PK_conformed_dealers PRIMARY KEY (Dealer_ID_Source)
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
