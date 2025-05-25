INSERT INTO bronze.raw_car_sales_transactions (
    Transaction_ID,
    Date,
    Sales_Price,
    Car_ID,
    Make,
    Model,
    Year,
    Color,
    Body_Style
)
VALUES (
    @Transaction_ID,
    @Date,
    @Sales_Price,
    @Car_ID,
    @Make,
    @Model,
    @Year,
    @Color,
    @Body_Style
);
