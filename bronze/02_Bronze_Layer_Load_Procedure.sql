USE [pt-mobilita-nusantara];
GO


INSERT INTO bronze.raw_car_sales_transactions (
    Car_id,
    [Date],
    [Customer Name],
    Gender,
    [Annual Income],
    Dealer_Name,
    Company,
    Model,
    Engine,
    Transmission,
    Color,
    [Price ($)],
    [Dealer_No],     
    [Body Style],
    Phone,
    Dealer_Region
)
SELECT
    [Car_id],         
    [Date],           
    [Customer Name],  
    [Gender],         
    [Annual Income],  
    [Dealer_Name],    
    [Company],        
    [Model],          
    [Engine],         
    [Transmission],   
    [Color],          
    [Price ($)],      
    [Dealer_No],    
    [Body Style],     
    [Phone],          
    [Dealer_Region]   
FROM
    ['Car Sales#xlsx - car_data$']; 
GO

SELECT COUNT(*) AS TotalRowsLoadedInBronze FROM bronze.raw_car_sales_transactions;
GO

SELECT TOP 10 * FROM bronze.raw_car_sales_transactions;
GO
