# Panduan Lengkap Pengerjaan Data Warehouse Mobilita Nusantara (SQL Server)

**Database Target**: `pt-mobilita-nusantara`

## 📋 Daftar Isi

1. [Persiapan Awal: Impor Data Sumber](#persiapan-awal-impor-data-sumber)
2. [Langkah 01: Membuat Struktur Tabel Bronze Layer (DDL)](#langkah-01-membuat-struktur-tabel-bronze-layer-ddl)
3. [Langkah 02: Memuat Data ke Bronze Layer](#langkah-02-memuat-data-ke-bronze-layer)
4. [Langkah 03: Membuat Struktur Tabel Silver Layer (DDL)](#langkah-03-membuat-struktur-tabel-silver-layer-ddl)
5. [Langkah 04: Membuat Stored Procedure dan Memuat Data ke Silver Layer](#langkah-04-membuat-stored-procedure-dan-memuat-data-ke-silver-layer)
6. [Langkah 05: Membuat Struktur Tabel Gold Layer (DDL)](#langkah-05-membuat-struktur-tabel-gold-layer-ddl)
7. [Langkah 06: Membuat Stored Procedure dan Memuat Data ke Gold Layer](#langkah-06-membuat-stored-procedure-dan-memuat-data-ke-gold-layer)
8. [Verifikasi Akhir](#verifikasi-akhir)

---

## 📥 Persiapan Awal: Impor Data Sumber

Sebelum memulai script SQL, pastikan Anda telah melakukan hal berikut:

1. Data sumber (misalnya dari file `car_data.xlsx` atau `car_data.csv`) telah diimpor ke dalam database `pt-mobilita-nusantara` menggunakan **SQL Server Import and Export Wizard**.
2. Hasil impor data tersebut diasumsikan berada dalam tabel dengan nama `[Car Sales#xlsx - car_data$]`. 

> ⚠️ **Catatan**: Nama ini mungkin berbeda tergantung proses impor Anda; sesuaikan jika perlu pada Langkah 02.

### Kolom Data yang Diharapkan

Kolom-kolom yang diharapkan dari data sumber adalah:
- `Car_id`
- `Date`
- `Customer Name`
- `Gender`
- `Annual Income`
- `Dealer_Name`
- `Company`
- `Model`
- `Engine`
- `Transmission`
- `Color`
- `Price ($)`
- `Dealer_No`
- `Body Style`
- `Phone`
- `Dealer_Region`

---

## 🥉 Langkah 01: Membuat Struktur Tabel Bronze Layer (DDL)

Script ini (`01_Bronze_Layer_DDL.sql`) mendefinisikan tabel `bronze.raw_car_sales_transactions` untuk menyimpan data mentah.

### Cara Menjalankan:

1. Buka SQL Server Management Studio (SSMS) dan hubungkan ke server Anda.
2. Buka jendela *New Query*.
3. Pastikan Anda menggunakan database yang benar dengan perintah `USE [pt-mobilita-nusantara];`.
4. Salin dan tempel kode di bawah ini, lalu eksekusi (tekan F5 atau tombol Execute).

```sql
-- File: 01_Bronze_Layer_DDL.sql (Versi Disesuaikan)
USE [pt-mobilita-nusantara];
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
   EXEC('CREATE SCHEMA bronze');
END
GO

IF OBJECT_ID('bronze.raw_car_sales_transactions', 'U') IS NOT NULL
   DROP TABLE bronze.raw_car_sales_transactions;
GO

CREATE TABLE bronze.raw_car_sales_transactions (
   Car_id VARCHAR(255),
   [Date] DATE,
   [Customer Name] VARCHAR(255),
   Gender VARCHAR(50),
   [Annual Income] VARCHAR(255),
   Dealer_Name VARCHAR(255),
   Company VARCHAR(255),
   Model VARCHAR(255),
   Engine VARCHAR(255),
   Transmission VARCHAR(255),
   Color VARCHAR(255),
   [Price ($)] VARCHAR(255),
   [Dealer_No] VARCHAR(255),
   [Body Style] VARCHAR(255),
   Phone VARCHAR(50),
   Dealer_Region VARCHAR(255)
);
GO

PRINT 'Tabel bronze.raw_car_sales_transactions berhasil dibuat/diperbarui.';
```

---

## 📤 Langkah 02: Memuat Data ke Bronze Layer

Script ini memindahkan data dari tabel hasil impor (`[Car Sales#xlsx - car_data$]`) ke tabel `bronze.raw_car_sales_transactions`.

### Cara Menjalankan:

1. Di SSMS, buka jendela New Query (pastikan database `pt-mobilita-nusantara` dipilih).
2. Salin dan tempel kode di bawah ini. 
   
   > ⚠️ **PENTING**: Verifikasi nama tabel sumber `[Car Sales#xlsx - car_data$]` dan sesuaikan jika nama tabel hasil impor Anda berbeda.

3. Eksekusi script.

```sql
-- File: (Pengganti untuk 02_Bronze_Layer_Load_Procedure.sql)
USE [pt-mobilita-nusantara];
GO

-- Opsional: Kosongkan tabel bronze sebelum memuat data baru.
-- TRUNCATE TABLE bronze.raw_car_sales_transactions;
-- GO

INSERT INTO bronze.raw_car_sales_transactions (
   Car_id, [Date], [Customer Name], Gender, [Annual Income], Dealer_Name,
   Company, Model, Engine, Transmission, Color, [Price ($)],
   [Dealer_No], [Body Style], Phone, Dealer_Region
)
SELECT
   [Car_id], [Date], [Customer Name], [Gender], [Annual Income], [Dealer_Name],
   [Company], [Model], [Engine], [Transmission], [Color], [Price ($)],
   [Dealer_No], [Body Style], [Phone], [Dealer_Region]
FROM
   [Car Sales#xlsx - car_data$]; -- PASTIKAN NAMA TABEL INI BENAR!
GO

PRINT 'Proses pemuatan data ke bronze.raw_car_sales_transactions selesai.';
SELECT COUNT(*) AS TotalRowsInBronze FROM bronze.raw_car_sales_transactions;
SELECT TOP 10 * FROM bronze.raw_car_sales_transactions;
GO
```

### Output yang Diharapkan:
Sekitar **23.906 baris** di `TotalRowsInBronze`.

---

## 🥈 Langkah 03: Membuat Struktur Tabel Silver Layer (DDL)

Script ini (`03_Silver_Layer_DDL.sql`) mendefinisikan tabel `silver.transformed_car_sales_transactions` dengan pembersihan tipe data dan penambahan kolom turunan.

### Cara Menjalankan:

1. Di SSMS, buka jendela New Query.
2. Salin dan tempel kode di bawah ini, lalu eksekusi.

```sql
-- File: 03_Silver_Layer_DDL.sql (Versi Disesuaikan)
USE [pt-mobilita-nusantara];
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
   EXEC('CREATE SCHEMA silver');
END
GO

IF OBJECT_ID('silver.transformed_car_sales_transactions', 'U') IS NOT NULL
   DROP TABLE silver.transformed_car_sales_transactions;
GO

CREATE TABLE silver.transformed_car_sales_transactions (
   Car_ID VARCHAR(255) PRIMARY KEY,
   Sales_Date DATE,
   Customer_Name VARCHAR(255),
   Gender VARCHAR(50),
   Annual_Income DECIMAL(18, 2),
   Dealer_Name VARCHAR(255),
   Car_Make VARCHAR(255),
   Car_Model VARCHAR(255),
   Engine_Type VARCHAR(255),
   Transmission_Type VARCHAR(255),
   Car_Color VARCHAR(255),
   Sales_Price DECIMAL(18, 2),
   Dealer_Number VARCHAR(255),
   Body_Style VARCHAR(255),
   Customer_Phone VARCHAR(50),
   Dealer_Region VARCHAR(255),
   Sales_Year INT,
   Sales_Month INT,
   Sales_Day INT,
   Last_Updated DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Tabel silver.transformed_car_sales_transactions berhasil dibuat/diperbarui.';
```

---

## ⚙️ Langkah 04: Membuat Stored Procedure dan Memuat Data ke Silver Layer

Script ini (`04_Silver_Layer_Load_Procedure.sql`) membuat stored procedure `dbo.LoadSilverLayerCarSalesTransactions_V2` untuk memproses data dari Bronze ke Silver.

### Cara Menjalankan (Tahap 1: Membuat Stored Procedure):

1. Di SSMS, buka jendela New Query.
2. Salin dan tempel kode di bawah ini, lalu eksekusi untuk membuat stored procedure.

```sql
-- File: 04_Silver_Layer_Load_Procedure.sql (Versi dbo.LoadSilverLayerCarSalesTransactions_V2)
USE [pt-mobilita-nusantara];
GO

CREATE OR ALTER PROCEDURE dbo.LoadSilverLayerCarSalesTransactions_V2
AS
BEGIN
   SET NOCOUNT ON;
   PRINT '--- Memulai Proses LoadSilverLayerCarSalesTransactions_V2 ---';

   DECLARE @BronzeCount INT;
   SELECT @BronzeCount = COUNT(*) FROM bronze.raw_car_sales_transactions;
   PRINT 'Jumlah baris di bronze.raw_car_sales_transactions: ' + CAST(@BronzeCount AS VARCHAR(10));

   IF @BronzeCount = 0
   BEGIN
       PRINT 'PERINGATAN: Tidak ada data di bronze. Proses pemuatan ke silver dihentikan.';
       RETURN;
   END

   TRUNCATE TABLE silver.transformed_car_sales_transactions;
   PRINT 'Tabel silver.transformed_car_sales_transactions telah di-TRUNCATE.';

   PRINT 'Mencoba INSERT ke silver.transformed_car_sales_transactions...';
   INSERT INTO silver.transformed_car_sales_transactions (
       Car_ID, Sales_Date, Customer_Name, Gender, Annual_Income, Dealer_Name, Car_Make, Car_Model,
       Engine_Type, Transmission_Type, Car_Color, Sales_Price, Dealer_Number, Body_Style,
       Customer_Phone, Dealer_Region, Sales_Year, Sales_Month, Sales_Day
   )
   SELECT
       b.Car_id, b.[Date], b.[Customer Name], b.Gender,
       TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(b.[Annual Income], '$', ''), ',', '')),
       b.Dealer_Name, b.Company, b.Model, b.Engine, b.Transmission, b.Color,
       TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(b.[Price ($)], '$', ''), ',', '')),
       b.[Dealer_No], b.[Body Style], b.Phone, b.Dealer_Region,
       YEAR(b.[Date]), MONTH(b.[Date]), DAY(b.[Date])
   FROM
       bronze.raw_car_sales_transactions AS b
   WHERE
       b.Car_id IS NOT NULL AND b.Car_id != '' AND b.[Date] IS NOT NULL;

   DECLARE @RowsLoaded INT;
   SET @RowsLoaded = @@ROWCOUNT;
   PRINT 'Jumlah baris yang berhasil dimasukkan ke silver: ' + CAST(@RowsLoaded AS VARCHAR(10));

   IF @RowsLoaded = 0 AND @BronzeCount > 0
       PRINT 'PERINGATAN: Tidak ada baris dimuat ke silver meskipun bronze memiliki data. Periksa kondisi WHERE.';
   ELSE IF @RowsLoaded > 0
       PRINT 'BERHASIL: Data telah dimuat ke silver.';
   
   PRINT '--- Proses LoadSilverLayerCarSalesTransactions_V2 Selesai ---';
END
GO
PRINT 'Stored procedure dbo.LoadSilverLayerCarSalesTransactions_V2 berhasil dibuat/diperbarui.';
```

### Cara Menjalankan (Tahap 2: Mengeksekusi Stored Procedure untuk Memuat Data):

1. Setelah stored procedure dibuat, buka jendela New Query baru.
2. Salin dan tempel kode berikut, lalu eksekusi.

```sql
USE [pt-mobilita-nusantara];
GO
EXEC dbo.LoadSilverLayerCarSalesTransactions_V2;
GO

-- Verifikasi Data di Silver
SELECT COUNT(*) AS TotalRowsInSilver FROM silver.transformed_car_sales_transactions;
SELECT TOP 10 * FROM silver.transformed_car_sales_transactions;
GO
```

### Output yang Diharapkan:
Tab "Messages" akan menampilkan "Jumlah baris yang berhasil dimasukkan ke silver: **9780**". `TotalRowsInSilver` juga akan **9780**.

---

## 🥇 Langkah 05: Membuat Struktur Tabel Gold Layer (DDL)

Script ini (`05_Gold_Layer_DDL.sql`) mendefinisikan tabel dimensi dan fakta untuk Gold Layer.

### Cara Menjalankan:

1. Di SSMS, buka jendela New Query.
2. Salin dan tempel kode di bawah ini, lalu eksekusi.

```sql
-- File: 05_Gold_Layer_DDL.sql (Versi Disesuaikan dan Direvisi)
USE [pt-mobilita-nusantara];
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
   EXEC('CREATE SCHEMA gold');
END
GO

IF OBJECT_ID('gold.fact_car_sales', 'U') IS NOT NULL DROP TABLE gold.fact_car_sales;
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL DROP TABLE gold.dim_date;
IF OBJECT_ID('gold.dim_car', 'U') IS NOT NULL DROP TABLE gold.dim_car;
IF OBJECT_ID('gold.dim_dealer', 'U') IS NOT NULL DROP TABLE gold.dim_dealer;
IF OBJECT_ID('gold.dim_customer', 'U') IS NOT NULL DROP TABLE gold.dim_customer;
GO

CREATE TABLE gold.dim_date (
   date_key INT PRIMARY KEY, 
   [date] DATE NOT NULL, 
   year INT NOT NULL, 
   month INT NOT NULL,
   day INT NOT NULL, 
   weekday VARCHAR(20) NOT NULL, 
   month_name VARCHAR(20) NOT NULL, 
   quarter INT NOT NULL
);
GO
PRINT 'Tabel gold.dim_date berhasil dibuat/diperbarui.';

CREATE TABLE gold.dim_car (
   car_key INT PRIMARY KEY IDENTITY(1,1), 
   car_id VARCHAR(255) NOT NULL UNIQUE, 
   make VARCHAR(255),
   model VARCHAR(255), 
   engine_type VARCHAR(255), 
   transmission_type VARCHAR(255),
   color VARCHAR(255), 
   body_style VARCHAR(255)
);
GO
PRINT 'Tabel gold.dim_car berhasil dibuat/diperbarui.';

CREATE TABLE gold.dim_dealer (
   dealer_key INT PRIMARY KEY IDENTITY(1,1), 
   dealer_number VARCHAR(255) UNIQUE,
   dealer_name VARCHAR(255), 
   dealer_region VARCHAR(255)
);
GO
PRINT 'Tabel gold.dim_dealer berhasil dibuat/diperbarui.';

CREATE TABLE gold.dim_customer (
   customer_key INT PRIMARY KEY IDENTITY(1,1), 
   customer_name VARCHAR(255), 
   gender VARCHAR(50),
   annual_income DECIMAL(18,2), 
   customer_phone VARCHAR(50)
);
GO
PRINT 'Tabel gold.dim_customer berhasil dibuat/diperbarui.';

CREATE TABLE gold.fact_car_sales (
   sales_id INT PRIMARY KEY IDENTITY(1,1), 
   car_id_original VARCHAR(255), 
   date_key INT NOT NULL,
   car_key INT NOT NULL, 
   dealer_key INT NOT NULL, 
   customer_key INT NOT NULL,
   sales_price DECIMAL(18, 2),
   FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key),
   FOREIGN KEY (car_key) REFERENCES gold.dim_car(car_key),
   FOREIGN KEY (dealer_key) REFERENCES gold.dim_dealer(dealer_key),
   FOREIGN KEY (customer_key) REFERENCES gold.dim_customer(customer_key)
);
GO
PRINT 'Tabel gold.fact_car_sales berhasil dibuat/diperbarui.';
PRINT 'Struktur tabel Gold Layer berhasil dibuat/diperbarui.';
```

---

## 🔄 Langkah 06: Membuat Stored Procedure dan Memuat Data ke Gold Layer

Script ini (`06_Gold_Layer_Load_Procedure.sql`) membuat stored procedure `dbo.LoadGoldLayerData_V2` untuk mempopulasikan tabel dimensi dan fakta di Gold Layer dari Silver Layer.

### Cara Menjalankan (Tahap 1: Membuat Stored Procedure):

1. Di SSMS, buka jendela New Query.
2. Salin dan tempel kode di bawah ini, lalu eksekusi untuk membuat stored procedure.

```sql
-- File: 06_Gold_Layer_Load_Procedure.sql (Versi dbo.LoadGoldLayerData_V2 Direvisi)
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
   -- Opsional: TRUNCATE TABLE gold.dim_date; -- Jika ingin refresh total dim_date
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
```

### Cara Menjalankan (Tahap 2: Mengeksekusi Stored Procedure untuk Memuat Data):

1. Setelah stored procedure dibuat, buka jendela New Query baru.
2. Salin dan tempel kode berikut, lalu eksekusi.

```sql
USE [pt-mobilita-nusantara];
GO
EXEC dbo.LoadGoldLayerData_V2;
GO

-- Verifikasi Data di Gold
SELECT 'dim_date' AS TableName, COUNT(*) AS TotalRows FROM gold.dim_date UNION ALL
SELECT 'dim_car', COUNT(*) FROM gold.dim_car UNION ALL
SELECT 'dim_dealer', COUNT(*) FROM gold.dim_dealer UNION ALL
SELECT 'dim_customer', COUNT(*) FROM gold.dim_customer UNION ALL
SELECT 'fact_car_sales', COUNT(*) FROM gold.fact_car_sales;
GO
SELECT TOP 10 * FROM gold.fact_car_sales;
GO
```

### Output yang Diharapkan:
Tab "Messages" akan menampilkan jumlah baris yang berhasil dimuat untuk setiap tabel dimensi dan fakta:
- `dim_date`: **238**
- `dim_car`: **9780**
- `dim_dealer`: **7**
- `dim_customer`: **9780**
- `fact_car_sales`: **9780**

---

## ✅ Verifikasi Akhir

Setelah menjalankan semua langkah di atas, Anda akan memiliki Data Warehouse yang berfungsi dengan data yang telah diproses melalui lapisan:

- **🥉 Bronze Layer**: Data mentah yang belum diproses
- **🥈 Silver Layer**: Data yang sudah dibersihkan dan ditransformasi
- **🥇 Gold Layer**: Data yang telah dimodel dalam bentuk star schema dengan tabel dimensi dan fakta

### Struktur Akhir Data Warehouse:

#### Bronze Layer
- `bronze.raw_car_sales_transactions` - Tabel data mentah

#### Silver Layer
- `silver.transformed_car_sales_transactions` - Tabel data yang sudah dibersihkan

#### Gold Layer
- `gold.dim_date` - Dimensi tanggal
- `gold.dim_car` - Dimensi mobil
- `gold.dim_dealer` - Dimensi dealer
- `gold.dim_customer` - Dimensi pelanggan
- `gold.fact_car_sales` - Tabel fakta penjualan mobil

### Stored Procedures yang Dibuat:
- `dbo.LoadSilverLayerCarSalesTransactions_V2` - Untuk memuat data dari Bronze ke Silver
- `dbo.LoadGoldLayerData_V2` - Untuk memuat data dari Silver ke Gold

---

## 📝 Catatan Penting

- Pastikan nama tabel sumber sesuai dengan hasil impor Anda
- Semua script menggunakan database `pt-mobilita-nusantara`
- Proses ETL mengikuti arsitektur medallion (Bronze → Silver → Gold)
- Data yang diharapkan sekitar 23.906 baris di Bronze, 9.780 baris di Silver dan Gold

---

## 🔧 Troubleshooting

Jika mengalami masalah:

1. **Periksa koneksi database** - Pastikan terhubung ke database yang benar
2. **Verifikasi nama tabel sumber** - Sesuaikan nama tabel hasil impor
3. **Cek permission** - Pastikan user memiliki hak akses untuk membuat schema dan tabel
4. **Review error messages** - Baca pesan error dengan teliti untuk identifikasi masalah

---

*Data Warehouse Mobilita Nusantara - SQL Server Implementation*
