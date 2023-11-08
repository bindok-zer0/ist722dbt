with
    stg_products as (
        select
            {{ dbt_utils.generate_surrogate_key(["p.productid"]) }} as productkey,
            p.productid,
            p.productname,
            p.supplierid as supplierkey,
            c.categoryname,
            c.description
        from {{ source("northwind", "Products") }} p
        left join
            {{ source("northwind", "Categories") }} c on p.categoryid = c.categoryid
    )
select productkey, productid, productname, supplierkey, categoryname, description
from stg_products
