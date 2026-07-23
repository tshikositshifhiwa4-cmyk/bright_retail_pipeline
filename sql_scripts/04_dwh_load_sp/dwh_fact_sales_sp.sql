-- ============================================================
-- DWH_FACT_SALES
-- ============================================================
if object_id('[dwh_bright_retail].[dbo].[dwh_fact_sales]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_fact_sales] (
        sales_id              int identity(1,1) primary key,
        store_id              int not null,
        date_id               int not null,
        payment_id            int not null,
        cashier_id            int not null,
        supplier_id           int not null,
        product_id            int not null,
        customer_id           int not null,

        transaction_amount    decimal(12,2) not null,
        transaction_discount  decimal(5,2)  null,
        unit_price            decimal(12,2) not null,
        cost_price            decimal(12,2) not null,
        qty             int not null,
        line_amount           decimal(12,2) not null,
        stock_on_hand         int null,
        reorder_threshold     int null
    );
end
go

create or alter procedure dbo.usp_load_dwh_fact_sales
as
begin
    set nocount on;

    insert into [dwh_bright_retail].[dbo].[dwh_fact_sales] (
        store_id, date_id, payment_id, cashier_id, supplier_id, product_id, customer_id,
        transaction_amount, transaction_discount, unit_price, cost_price,
        qty, line_amount, stock_on_hand, reorder_threshold
    )
    select
        st.store_id,
        dt.date_id,
        pm.payment_id,
        ca.cashier_id,
        sp.supplier_id,
        pr.product_id,
        cu.customer_id,

        try_convert(decimal(12,2), b.transaction_amount),
        try_convert(decimal(5,2), b.transaction_discount),
        try_convert(decimal(12,2), b.unit_price),
        try_convert(decimal(12,2), b.cost_price),
        b.qty,
        try_convert(decimal(12,2), b.line_amount),
        b.stock_on_hand,
        b.reorder_threshold

    from [stg_bright_retail].[dbo].[bright_retail_raw_data] as b

    inner join [dwh_bright_retail].[dbo].[dwh_store] as st
        on ltrim(rtrim(b.store_name)) = st.store_name
       and st.is_current = 1

    inner join [dwh_bright_retail].[dbo].[dwh_date] as dt
        on coalesce(
            try_convert(date, b.transaction_date, 23),
            try_convert(date, b.transaction_date, 103),
            try_convert(date, b.transaction_date, 105),
            try_convert(date, b.transaction_date, 106)
        ) = dt.transaction_date

    inner join [dwh_bright_retail].[dbo].[dwh_payment] as pm
        on upper(ltrim(rtrim(b.payment_method))) = upper(pm.payment_method)

    inner join [dwh_bright_retail].[dbo].[dwh_cashier] as ca
        on ltrim(rtrim(b.cashier_name)) = ca.cashier_name

    inner join [dwh_bright_retail].[dbo].[dwh_supplier] as sp
        on ltrim(rtrim(b.supplier)) = sp.supplier

    inner join [dwh_bright_retail].[dbo].[dwh_product] as pr
        on b.sku = pr.sku

    inner join [dwh_bright_retail].[dbo].[dwh_customer] as cu
        on coalesce(nullif(ltrim(rtrim(b.customer_email)), ''), 'unknown@brightlearn.co.za') = cu.email
       and cu.is_current = 1

    where not exists (
        select 1
        from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
        where f.store_id     = st.store_id
          and f.date_id      = dt.date_id
          and f.payment_id   = pm.payment_id
          and f.cashier_id   = ca.cashier_id
          and f.supplier_id  = sp.supplier_id
          and f.product_id   = pr.product_id
          and f.customer_id  = cu.customer_id
          and f.qty     = b.qty
          and f.line_amount  = try_convert(decimal(12,2), b.line_amount)
   );
end
go

exec dbo.usp_load_dwh_fact_sales
