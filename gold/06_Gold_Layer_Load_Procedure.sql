USE [pt-mobilita-nusantara];
GO

CREATE OR ALTER PROCEDURE dbo.LoadGoldLayerData_V2
AS
BEGIN
   SET NOCOUNT ON;
   PRINT '--- Memulai Proses LoadGoldLayerData_V2 ---';

   DECLARE @SilverCount INT;
   SELECT @SilverCount = COUNT(*) FROM silver.transformed_car_sales_transactions;
   PRINT 'Jumlah baris di silver.transformed_car_sales_transactions: ' + CAST(@SilverCount AS VARCHAR(10));
   IF @SilverCount = 0 BEGIN PRINT 'PERINGATAN: Tidak ada data di silver. Proses dihentikan.'; RETURN; END

   PRINT 'Memulai populasi gold.dim_date...';
   INSERT INTO gold.dim_date (date_key, [date], year, month, day, weekday, month_name, quarter)
   SELECT DISTINCT 
          CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112)), 
          s.Sales_Date, 
          YEAR(s.Sales_Date),
          MONTH(s.Sales_Date), 
          DAY(s.Sales_Date), 
          DATENAME(dw, s.Sales_Date),
          DATENAME(month, s.Sales_Date), 
          DATEPART(qq, s.Sales_Date)
   FROM silver.transformed_car_sales_transactions s
   WHERE NOT EXISTS (
       SELECT 1 FROM gold.dim_date dd 
       WHERE dd.date_key = CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112))
   )
     AND s.Sales_Date IS NOT NULL;
   PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris baru ditambahkan ke gold.dim_date.';

   PRINT 'Memulai populasi gold.dim_car...';
   MERGE gold.dim_car AS T 
   USING (
       SELECT DISTINCT Car_ID, Car_Make, Car_Model, Engine_Type, Transmission_Type, Car_Color, Body_Style 
       FROM silver.transformed_car_sales_transactions 
       WHERE Car_ID IS NOT NULL
   ) AS S
   ON T.car_id = S.Car_ID
   WHEN MATCHED THEN 
       UPDATE SET T.make=S.Car_Make, T.model=S.Car_Model, T.engine_type=S.Engine_Type, 
                  T.transmission_type=S.Transmission_Type, T.color=S.Car_Color, T.body_style=S.Body_Style
   WHEN NOT MATCHED BY TARGET THEN 
       INSERT (car_id,make,model,engine_type,transmission_type,color,body_style) 
       VALUES (S.Car_ID,S.Car_Make,S.Car_Model,S.Engine_Type,S.Transmission_Type,S.Car_Color,S.Body_Style);
   PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris terpengaruh (INSERT/UPDATE) di gold.dim_car.';

   PRINT 'Memulai populasi gold.dim_dealer...';
   MERGE gold.dim_dealer AS T 
   USING (
       SELECT Dealer_Number,Dealer_Name,Dealer_Region 
       FROM (
           SELECT Dealer_Number,Dealer_Name,Dealer_Region,
                  ROW_NUMBER()OVER(PARTITION BY Dealer_Number ORDER BY Dealer_Name,Dealer_Region) as rn 
           FROM silver.transformed_car_sales_transactions 
           WHERE Dealer_Number IS NOT NULL AND Dealer_Number != ''
       ) AS RD 
       WHERE rn=1
   ) AS S
   ON T.dealer_number=S.Dealer_Number
   WHEN MATCHED THEN 
       UPDATE SET T.dealer_name=S.Dealer_Name, T.dealer_region=S.Dealer_Region
   WHEN NOT MATCHED BY TARGET THEN 
       INSERT (dealer_number,dealer_name,dealer_region)
       VALUES(S.Dealer_Number,S.Dealer_Name,S.Dealer_Region);
   PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris terpengaruh (INSERT/UPDATE) di gold.dim_dealer.';

   PRINT 'Memulai populasi gold.dim_customer...';
   MERGE gold.dim_customer AS T 
   USING (
       SELECT DISTINCT Customer_Name,Gender,Annual_Income,Customer_Phone 
       FROM silver.transformed_car_sales_transactions 
       WHERE (Customer_Name IS NOT NULL AND Customer_Name != '')
          OR (Customer_Phone IS NOT NULL AND Customer_Phone != '')
   ) AS S
   ON T.customer_name=S.Customer_Name AND ISNULL(T.customer_phone,'N/A')=ISNULL(S.Customer_Phone,'N/A')
   WHEN MATCHED THEN 
       UPDATE SET T.gender=S.Gender, T.annual_income=S.Annual_Income
   WHEN NOT MATCHED BY TARGET THEN 
       INSERT (customer_name,gender,annual_income,customer_phone)
       VALUES(S.Customer_Name,S.Gender,S.Annual_Income,S.Customer_Phone);
   PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris terpengaruh (INSERT/UPDATE) di gold.dim_customer.';

   PRINT 'Memulai populasi gold.fact_car_sales...';
   TRUNCATE TABLE gold.fact_car_sales;
   PRINT 'Tabel gold.fact_car_sales telah di-TRUNCATE.';
   INSERT INTO gold.fact_car_sales (car_id_original,date_key,car_key,dealer_key,customer_key,sales_price)
   SELECT s.Car_ID, dd.date_key, dc.car_key, ddl.dealer_key, dcu.customer_key, s.Sales_Price
   FROM silver.transformed_car_sales_transactions s
   INNER JOIN gold.dim_date dd ON dd.date_key = CONVERT(INT, CONVERT(VARCHAR(8), s.Sales_Date, 112))
   INNER JOIN gold.dim_car dc ON dc.car_id = s.Car_ID
   INNER JOIN gold.dim_dealer ddl ON ddl.dealer_number = s.Dealer_Number
   INNER JOIN gold.dim_customer dcu ON dcu.customer_name = s.Customer_Name 
                                   AND ISNULL(dcu.customer_phone, 'N/A') = ISNULL(s.Customer_Phone, 'N/A')
   WHERE s.Sales_Price IS NOT NULL;
   PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' baris berhasil dimasukkan ke gold.fact_car_sales.';

   PRINT '--- Proses LoadGoldLayerData_V2 Selesai ---';
END
GO
PRINT 'Stored procedure dbo.LoadGoldLayerData_V2 berhasil dibuat/diperbarui.';
