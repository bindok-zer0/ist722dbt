WITH
stg_orders AS (
    SELECT
        OrderID,
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} AS employeekey,
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} AS customerkey,
        REPLACE(TO_DATE(orderdate)::VARCHAR, '-', '')::INT AS orderdatekey
    FROM {{source('northwind','Orders')}}
),
 
stg_order_details AS (
    SELECT
        orderid,
        productid,
        {{ dbt_utils.generate_surrogate_key(['productid']) }} AS productkey,
        CONCAT(orderid, '_', productid) AS compositeid,  
        SUM(Quantity) AS quantity,
        SUM(Quantity * UnitPrice) AS extendedpriceamount,
        SUM(Quantity * UnitPrice * Discount) AS discountamount,
        SUM(Quantity * UnitPrice * (1 - Discount)) AS soldamount
    FROM {{source('northwind','Order_Details')}}
    GROUP BY  productid,orderid
)
 
SELECT compositeid, o.*, od.productkey, od.quantity, od.extendedpriceamount, od.discountamount, od.soldamount
FROM stg_orders o
JOIN stg_order_details od ON o.orderid = od.orderid
