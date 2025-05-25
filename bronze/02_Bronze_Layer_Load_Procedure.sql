INSERT INTO bronze.raw_car_sales_transactions (
    transaction_id,
    date,
    sales_price,
    car_id,
    make,
    model,
    year,
    color,
    body_style
)
VALUES (
    @transaction_id,
    @date,
    @sales_price,
    @car_id,
    @make,
    @model,
    @year,
    @color,
    @body_style
);
