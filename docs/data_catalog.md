# 📑Katalog Data - Data Warehouse Mobilita Nusantara

Dokumen ini berfungsi sebagai katalog data untuk Data Warehouse (DW) Mobilita Nusantara. Ini mendeskripsikan skema, tabel, dan kolom di setiap lapisan data: Bronze, Silver, dan Gold.

## Daftar Isi
1.  [Lapisan Bronze (Bronze Layer)](#lapisan-bronze-bronze-layer)
    * [Tabel: `bronze.raw_car_sales_transactions`](#tabel-bronzeraw_car_sales_transactions)
2.  [Lapisan Silver (Silver Layer)](#lapisan-silver-silver-layer)
    * [Tabel: `silver.transformed_car_sales_transactions`](#tabel-silvertransformed_car_sales_transactions)
3.  [Lapisan Gold (Gold Layer)](#lapisan-gold-gold-layer)
    * [Tabel: `gold.dim_date`](#tabel-golddim_date)
    * [Tabel: `gold.dim_car`](#tabel-golddim_car)
    * [Tabel: `gold.dim_dealer`](#tabel-golddim_dealer)
    * [Tabel: `gold.dim_customer`](#tabel-golddim_customer)
    * [Tabel: `gold.fact_car_sales`](#tabel-goldfact_car_sales)

---

## Lapisan Bronze (Bronze Layer)

Lapisan Bronze berisi data mentah yang diambil langsung dari sistem sumber dengan transformasi minimal.

### Tabel: `bronze.raw_car_sales_transactions`
Menyimpan data transaksi penjualan mobil mentah seperti yang diimpor dari sumber.

| Nama Kolom      | Tipe Data    | Deskripsi                                           | Contoh Nilai         | Catatan                                     |
|-----------------|--------------|-----------------------------------------------------|----------------------|---------------------------------------------|
| `Car_id`        | VARCHAR(255) | ID unik untuk mobil yang terlibat dalam transaksi. | `C_CND_000001`       | Dari sumber asli.                           |
| `[Date]`        | DATE         | Tanggal transaksi penjualan.                        | `2022-01-02`         | Dari sumber asli.                           |
| `[Customer Name]`| VARCHAR(255) | Nama pelanggan yang melakukan pembelian.            | `Geraldine`          | Dari sumber asli.                           |
| `Gender`        | VARCHAR(50)  | Jenis kelamin pelanggan.                            | `Male`               | Dari sumber asli.                           |
| `[Annual Income]`| VARCHAR(255) | Pendapatan tahunan pelanggan (format mentah).       | `13500`              | Dari sumber asli, akan dikonversi di Silver. |
| `Dealer_Name`   | VARCHAR(255) | Nama dealer tempat transaksi terjadi.               | `Buddy Storbeck's...`| Dari sumber asli.                           |
| `Company`       | VARCHAR(255) | Merek atau perusahaan pembuat mobil.                | `Ford`               | Dari sumber asli, menjadi `Car_Make` di Silver. |
| `Model`         | VARCHAR(255) | Model mobil.                                        | `Expedition`         | Dari sumber asli.                           |
| `Engine`        | VARCHAR(255) | Tipe mesin mobil.                                   | `Double Overhead...` | Dari sumber asli.                           |
| `Transmission`  | VARCHAR(255) | Jenis transmisi mobil.                              | `Auto`               | Dari sumber asli.                           |
| `Color`         | VARCHAR(255) | Warna mobil.                                        | `Black`              | Dari sumber asli.                           |
| `[Price ($)]`   | VARCHAR(255) | Harga jual mobil dalam USD (format mentah).         | `26000`              | Dari sumber asli, akan dikonversi di Silver. |
| `[Dealer_No]`   | VARCHAR(255) | Nomor identifikasi dealer.                          | `06457-3834`         | Dari sumber asli.                           |
| `[Body Style]`  | VARCHAR(255) | Gaya bodi mobil.                                    | `SUV`                | Dari sumber asli.                           |
| `Phone`         | VARCHAR(50)  | Nomor telepon pelanggan.                            | `8264678`            | Dari sumber asli.                           |
| `Dealer_Region` | VARCHAR(255) | Wilayah atau regional dealer.                       | `Middletown`         | Dari sumber asli.                           |

---

## Lapisan Silver (Silver Layer)

Lapisan Silver berisi data yang telah dibersihkan, ditransformasi, dan distandarisasi dari Bronze Layer. Tipe data telah disesuaikan dan beberapa kolom turunan mungkin ditambahkan.

### Tabel: `silver.transformed_car_sales_transactions`
Menyimpan data transaksi penjualan mobil yang telah dibersihkan dan ditransformasi.

| Nama Kolom        | Tipe Data     | Deskripsi                                           | Contoh Nilai         | Transformasi dari Bronze                                                                 |
|-------------------|---------------|-----------------------------------------------------|----------------------|------------------------------------------------------------------------------------------|
| `Car_ID`          | VARCHAR(255)  | ID unik mobil (Primary Key).                        | `C_CND_000001`       | Diambil dari `Car_id`.                                                                    |
| `Sales_Date`      | DATE          | Tanggal transaksi penjualan.                        | `2022-01-02`         | Diambil dari `[Date]`.                                                                    |
| `Customer_Name`   | VARCHAR(255)  | Nama pelanggan.                                     | `Geraldine`          | Diambil dari `[Customer Name]`.                                                           |
| `Gender`          | VARCHAR(50)   | Jenis kelamin pelanggan.                            | `Male`               | Diambil dari `Gender`.                                                                    |
| `Annual_Income`   | DECIMAL(18,2) | Pendapatan tahunan pelanggan (sudah bersih).        | `13500.00`           | Dikonversi dari `[Annual Income]` (menghilangkan simbol mata uang/pemisah jika ada).       |
| `Dealer_Name`     | VARCHAR(255)  | Nama dealer.                                        | `Buddy Storbeck's...`| Diambil dari `Dealer_Name`.                                                               |
| `Car_Make`        | VARCHAR(255)  | Merek mobil.                                        | `Ford`               | Diambil dari `Company`.                                                                   |
| `Car_Model`       | VARCHAR(255)  | Model mobil.                                        | `Expedition`         | Diambil dari `Model`.                                                                     |
| `Engine_Type`     | VARCHAR(255)  | Tipe mesin mobil.                                   | `Double Overhead...` | Diambil dari `Engine`.                                                                    |
| `Transmission_Type`| VARCHAR(255)  | Jenis transmisi mobil.                              | `Auto`               | Diambil dari `Transmission`.                                                              |
| `Car_Color`       | VARCHAR(255)  | Warna mobil.                                        | `Black`              | Diambil dari `Color`.                                                                     |
| `Sales_Price`     | DECIMAL(18,2) | Harga jual mobil (sudah bersih).                    | `26000.00`           | Dikonversi dari `[Price ($)]` (menghilangkan simbol mata uang/pemisah jika ada).         |
| `Dealer_Number`   | VARCHAR(255)  | Nomor identifikasi dealer.                          | `06457-3834`         | Diambil dari `[Dealer_No]`.                                                               |
| `Body_Style`      | VARCHAR(255)  | Gaya bodi mobil.                                    | `SUV`                | Diambil dari `[Body Style]`.                                                              |
| `Customer_Phone`  | VARCHAR(50)   | Nomor telepon pelanggan.                            | `8264678`            | Diambil dari `Phone`.                                                                     |
| `Dealer_Region`   | VARCHAR(255)  | Wilayah dealer.                                     | `Middletown`         | Diambil dari `Dealer_Region`.                                                             |
| `Sales_Year`      | INT           | Tahun dari `Sales_Date`.                            | `2022`               | Diturunkan dari `Sales_Date` menggunakan `YEAR()`.                                         |
| `Sales_Month`     | INT           | Bulan dari `Sales_Date` (1-12).                     | `1`                  | Diturunkan dari `Sales_Date` menggunakan `MONTH()`.                                        |
| `Sales_Day`       | INT           | Hari dari `Sales_Date` (1-31).                      | `2`                  | Diturunkan dari `Sales_Date` menggunakan `DAY()`.                                          |
| `Last_Updated`    | DATETIME      | Tanggal dan waktu baris terakhir diperbarui/dimasukkan. | `2025-05-26 ...`     | Diisi otomatis dengan `GETDATE()` (nilai default).                                      |

---

## Lapisan Gold (Gold Layer)

Lapisan Gold berisi data yang telah diagregasi dan dimodelkan (biasanya dalam skema bintang atau snowflake) untuk tujuan analisis dan pelaporan.

### Tabel: `gold.dim_date`
Tabel dimensi untuk atribut-atribut tanggal.

| Nama Kolom   | Tipe Data   | Deskripsi                                  | Contoh Nilai | Sumber/Catatan                                        |
|--------------|-------------|--------------------------------------------|--------------|-------------------------------------------------------|
| `date_key`   | INT         | Kunci primer surrogate, format YYYYMMDD.   | `20220102`   | Diturunkan dari `Sales_Date` di Silver.                |
| `[date]`     | DATE        | Tanggal aktual.                            | `2022-01-02` | Sama dengan `Sales_Date` di Silver.                   |
| `year`       | INT         | Tahun.                                     | `2022`       | Diturunkan dari `Sales_Date`.                         |
| `month`      | INT         | Bulan dalam angka (1-12).                  | `1`          | Diturunkan dari `Sales_Date`.                         |
| `day`        | INT         | Hari dalam bulan (1-31).                   | `2`          | Diturunkan dari `Sales_Date`.                         |
| `weekday`    | VARCHAR(20) | Nama hari dalam seminggu.                  | `Sunday`     | Diturunkan dari `Sales_Date` menggunakan `DATENAME()`. |
| `month_name` | VARCHAR(20) | Nama bulan.                                | `January`    | Diturunkan dari `Sales_Date` menggunakan `DATENAME()`. |
| `quarter`    | INT         | Kuartal dalam tahun (1-4).                 | `1`          | Diturunkan dari `Sales_Date` menggunakan `DATEPART()`. |

### Tabel: `gold.dim_car`
Tabel dimensi untuk atribut-atribut mobil.

| Nama Kolom          | Tipe Data    | Deskripsi                             | Contoh Nilai         | Sumber/Catatan                                      |
|---------------------|--------------|---------------------------------------|----------------------|-----------------------------------------------------|
| `car_key`           | INT          | Kunci primer surrogate (IDENTITY).    | `1 (auto)`           | Dihasilkan otomatis.                                |
| `car_id`            | VARCHAR(255) | ID unik mobil dari sumber (UNIQUE).   | `C_CND_000001`       | Dari `Car_ID` di Silver.                           |
| `make`              | VARCHAR(255) | Merek mobil.                          | `Ford`               | Dari `Car_Make` di Silver.                         |
| `model`             | VARCHAR(255) | Model mobil.                          | `Expedition`         | Dari `Car_Model` di Silver.                        |
| `engine_type`       | VARCHAR(255) | Tipe mesin mobil.                     | `Double Overhead...` | Dari `Engine_Type` di Silver.                      |
| `transmission_type` | VARCHAR(255) | Jenis transmisi mobil.                | `Auto`               | Dari `Transmission_Type` di Silver.                |
| `color`             | VARCHAR(255) | Warna mobil.                          | `Black`              | Dari `Car_Color` di Silver.                        |
| `body_style`        | VARCHAR(255) | Gaya bodi mobil.                      | `SUV`                | Dari `Body_Style` di Silver.                       |

### Tabel: `gold.dim_dealer`
Tabel dimensi untuk atribut-atribut dealer.

| Nama Kolom      | Tipe Data    | Deskripsi                             | Contoh Nilai         | Sumber/Catatan                                 |
|-----------------|--------------|---------------------------------------|----------------------|------------------------------------------------|
| `dealer_key`    | INT          | Kunci primer surrogate (IDENTITY).    | `1 (auto)`           | Dihasilkan otomatis.                           |
| `dealer_number` | VARCHAR(255) | Nomor identifikasi dealer (UNIQUE).   | `06457-3834`         | Dari `Dealer_Number` di Silver.                 |
| `dealer_name`   | VARCHAR(255) | Nama dealer.                          | `Buddy Storbeck's...`| Dari `Dealer_Name` di Silver.                   |
| `dealer_region` | VARCHAR(255) | Wilayah dealer.                       | `Middletown`         | Dari `Dealer_Region` di Silver.                 |

### Tabel: `gold.dim_customer`
Tabel dimensi untuk atribut-atribut pelanggan.

| Nama Kolom        | Tipe Data     | Deskripsi                             | Contoh Nilai | Sumber/Catatan                                  |
|-------------------|---------------|---------------------------------------|--------------|-------------------------------------------------|
| `customer_key`    | INT           | Kunci primer surrogate (IDENTITY).    | `1 (auto)`   | Dihasilkan otomatis.                            |
| `customer_name`   | VARCHAR(255)  | Nama pelanggan.                       | `Geraldine`  | Dari `Customer_Name` di Silver.                  |
| `gender`          | VARCHAR(50)   | Jenis kelamin pelanggan.                | `Male`       | Dari `Gender` di Silver.                         |
| `annual_income`   | DECIMAL(18,2) | Pendapatan tahunan pelanggan.         | `13500.00`   | Dari `Annual_Income` di Silver.                  |
| `customer_phone`  | VARCHAR(50)   | Nomor telepon pelanggan.                | `8264678`    | Dari `Customer_Phone` di Silver.                 |

### Tabel: `gold.fact_car_sales`
Tabel fakta yang menyimpan metrik penjualan dan menghubungkan ke tabel dimensi.

| Nama Kolom        | Tipe Data     | Deskripsi                                       | Contoh Nilai   | Sumber/Catatan                                                |
|-------------------|---------------|-------------------------------------------------|----------------|---------------------------------------------------------------|
| `sales_id`        | INT           | Kunci primer surrogate untuk fakta penjualan (IDENTITY). | `1 (auto)`     | Dihasilkan otomatis.                                          |
| `car_id_original` | VARCHAR(255)  | ID mobil asli dari sumber, untuk referensi.     | `C_CND_000001` | Dari `Car_ID` di Silver.                                     |
| `date_key`        | INT           | Foreign key ke `gold.dim_date`.                 | `20220102`     | Hasil lookup dari `dim_date` berdasarkan tanggal penjualan.   |
| `car_key`         | INT           | Foreign key ke `gold.dim_car`.                  | `1`            | Hasil lookup dari `dim_car` berdasarkan `Car_ID`.             |
| `dealer_key`      | INT           | Foreign key ke `gold.dim_dealer`.               | `1`            | Hasil lookup dari `dim_dealer` berdasarkan `Dealer_Number`.   |
| `customer_key`    | INT           | Foreign key ke `gold.dim_customer`.             | `1`            | Hasil lookup dari `dim_customer` berdasarkan detail pelanggan. |
| `sales_price`     | DECIMAL(18,2) | Harga jual mobil (metrik utama).                | `26000.00`     | Dari `Sales_Price` di Silver.                                |

---

Katalog data ini dapat diperbarui seiring dengan perkembangan atau perubahan pada skema Data Warehouse.
