IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END
GO

IF OBJECT_ID('bronze.load_raw_car_sales', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE bronze.load_raw_car_sales;
END
GO

CREATE PROCEDURE bronze.load_raw_car_sales
    @CsvFilePath NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    IF @CsvFilePath IS NULL OR @CsvFilePath = ''
    BEGIN
        RAISERROR('CSV file path must be provided.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        INSERT INTO bronze.raw_car_sales_transactions (
            Transaction_ID,
            Date,
            Sales_Price,
            Car_ID,
            Make,
            Model,
            Year,
            Color,
            Body_Style,
