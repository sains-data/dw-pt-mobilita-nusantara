-- Pastikan Anda berada di database yang benar: pt-mobilita-nusantara
USE [pt-mobilita-nusantara];
GO

-- Kosongkan tabel bronze sebelum memuat data baru (opsional, tergantung kebutuhan)
-- TRUNCATE TABLE bronze.raw_car_sales_transactions;
-- GO

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
    [Car_id],         -- Sesuaikan jika nama di sumber berbeda
    [Date],           -- Sesuaikan jika nama di sumber berbeda
    [Customer Name],  -- Sesuaikan jika nama di sumber berbeda
    [Gender],         -- Sesuaikan jika nama di sumber berbeda
    [Annual Income],  -- Sesuaikan jika nama di sumber berbeda
    [Dealer_Name],    -- Sesuaikan jika nama di sumber berbeda
    [Company],        -- Sesuaikan jika nama di sumber berbeda
    [Model],          -- Sesuaikan jika nama di sumber berbeda
    [Engine],         -- Sesuaikan jika nama di sumber berbeda
    [Transmission],   -- Sesuaikan jika nama di sumber berbeda
    [Color],          -- Sesuaikan jika nama di sumber berbeda
    [Price ($)],      -- Sesuaikan jika nama di sumber berbeda
    [Dealer_No],    -- Sesuaikan jika nama di sumber berbeda (nama di CSV punya spasi sebelum Dealer_No)
    [Body Style],     -- Sesuaikan jika nama di sumber berbeda
    [Phone],          -- Sesuaikan jika nama di sumber berbeda
    [Dealer_Region]   -- Sesuaikan jika nama di sumber berbeda
FROM
    [Car Sales#xlsx - car_data$]; -- Tabel sumber Anda yang sudah diimpor
GO

SELECT COUNT(*) AS TotalRowsLoaded FROM bronze.raw_car_sales_transactions;
GO
