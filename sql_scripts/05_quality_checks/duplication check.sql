-- PAYMENT

select 'dim_payment' as tbl, payment_method, count(*) as cnt
from [stg_bright_retail].[dbo].[dim_payment]
group by payment_method having count(*) > 1;

select 'clean_payment' as tbl, payment_id, count(*) as cnt
from [stg_bright_retail].[dbo].[clean_payment]
group by payment_id having count(*) > 1;

select 'dwh_payment' as tbl, payment_id, count(*) as cnt
from [dwh_bright_retail].[dbo].[dwh_payment]
group by payment_id having count(*) > 1;

-- STORE (Type 2 — check only current rows)

select 'dim_store' as tbl, store_name, count(distinct store_id) as id_count
from [stg_bright_retail].[dbo].[dim_store]
where is_current = 1
group by store_name having count(distinct store_id) > 1;

select 'clean_store' as tbl, store_id, count(*) as cnt
from [stg_bright_retail].[dbo].[clean_store]
where is_current = 1
group by store_id having count(*) > 1;

select 'dwh_store' as tbl, store_id, count(*) as cnt
from [dwh_bright_retail].[dbo].[dwh_store]
where is_current = 1
group by store_id having count(*) > 1;

-- SUPPLIER

select 'dim_supplier' as tbl, supplier, count(*) as cnt
from [stg_bright_retail].[dbo].[dim_supplier]
group by supplier having count(*) > 1;

select 'clean_supplier' as tbl, supplier_id, count(*) as cnt
from [stg_bright_retail].[dbo].[clean_supplier]
group by supplier_id having count(*) > 1;

select 'dwh_supplier' as tbl, supplier_id, count(*) as cnt
from [dwh_bright_retail].[dbo].[dwh_supplier]
group by supplier_id having count(*) > 1;

-- CUSTOMER (Type 2 — check only current rows)

select 'dim_customer' as tbl, email, count(distinct customer_id) as id_count
from [stg_bright_retail].[dbo].[dim_customer]
where is_current = 1
group by email having count(distinct customer_id) > 1;

select 'clean_customer' as tbl, customer_id, count(*) as cnt
from [stg_bright_retail].[dbo].[clean_customer]
where is_current = 1
group by customer_id having count(*) > 1;

select 'dwh_customer' as tbl, customer_id, count(*) as cnt
from [dwh_bright_retail].[dbo].[dwh_customer]
where is_current = 1
group by customer_id having count(*) > 1;

-- PRODUCT

select 'dim_product' as tbl, sku, count(distinct product_id) as id_count
from [stg_bright_retail].[dbo].[dim_product]
group by sku having count(distinct product_id) > 1;

select 'clean_product' as tbl, product_id, count(*) as cnt
from [stg_bright_retail].[dbo].[clean_product]
group by product_id having count(*) > 1;

select 'dwh_product' as tbl, product_id, count(*) as cnt
from [dwh_bright_retail].[dbo].[dwh_product]
group by product_id having count(*) > 1;

-- CASHIER

select 'dim_cashier' as tbl, cashier_name, count(distinct cashier_id) as id_count
from [stg_bright_retail].[dbo].[dim_cashier]
group by cashier_name having count(distinct cashier_id) > 1;

select 'clean_cashier' as tbl, cashier_id, count(*) as cnt
from [stg_bright_retail].[dbo].[clean_cashier]
group by cashier_id having count(*) > 1;

select 'dwh_cashier' as tbl, cashier_id, count(*) as cnt
from [dwh_bright_retail].[dbo].[dwh_cashier]
group by cashier_id having count(*) > 1;

-- DATE

select 'clean_date' as tbl, transaction_date, count(distinct date_id) as id_count
from [stg_bright_retail].[dbo].[clean_date]
group by transaction_date having count(distinct date_id) > 1;

select 'dwh_date' as tbl, transaction_date, count(distinct date_id) as id_count
from [dwh_bright_retail].[dbo].[dwh_date]
group by transaction_date having count(distinct date_id) > 1;