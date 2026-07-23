--BQ-01 What were the top 5 best-selling products by total revenue between January and June 2024?
select top 5
    p.product_name,
    p.category,
    sum(f.line_amount) as total_revenue
from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
join [dwh_bright_retail].[dbo].[dwh_product] as p on f.product_id = p.product_id
join [dwh_bright_retail].[dbo].[dwh_date] as d on f.date_id = d.date_id
where d.transaction_date between '2024-01-01' and '2024-06-30'
group by p.product_name, p.category
order by total_revenue desc;


--BQ-02 What was the total revenue per store, broken down by month, for the January–June 2024 period?
select
    st.store_name,
    d.month,
    d.month_name,
    sum(f.line_amount) as total_revenue
from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
join [dwh_bright_retail].[dbo].[dwh_store] as st on f.store_id = st.store_id
join [dwh_bright_retail].[dbo].[dwh_date] as d on f.date_id = d.date_id
where d.transaction_date between '2024-01-01' and '2024-06-30'
group by st.store_name, d.month, d.month_name
order by st.store_name, d.month;

--BQ-03	What is the month-over-month revenue growth rate across all stores combined?
with monthly_revenue as (
    select
        d.month,
        d.month_name,
        sum(f.line_amount) as total_revenue
    from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
    join [dwh_bright_retail].[dbo].[dwh_date] as d on f.date_id = d.date_id
    where d.transaction_date between '2024-01-01' and '2024-06-30'
    group by d.month, d.month_name
)
select
    month,
    month_name,
    total_revenue,
    lag(total_revenue) over (order by month) as prev_month_revenue,
    round(
        (total_revenue - lag(total_revenue) over (order by month))
        / nullif(lag(total_revenue) over (order by month), 0) * 100
    , 2) as mom_growth_pct
from monthly_revenue
order by month;

--BQ-04 Who are the top 10 loyalty customers ranked by total spend over the reporting period?
select top 10
    c.first_name,
    c.last_name,
    c.loyalty_tier,
    sum(f.line_amount) as total_spend
from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
join [dwh_bright_retail].[dbo].[dwh_customer] as c on f.customer_id = c.customer_id
where c.email <> 'unknown@brightlearn.co.za' 
group by c.first_name, c.last_name, c.loyalty_tier
order by total_spend desc;

--BQ-5 Which registered loyalty customers have not made a purchase since 28 April 2024? 
--These customers must be flagged for a targeted win-back campaign.

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.loyalty_tier,
    max(d.transaction_date) as last_purchase_date
from [dwh_bright_retail].[dbo].[dwh_customer] as c
left join [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
    on c.customer_id = f.customer_id
left join [dwh_bright_retail].[dbo].[dwh_date] as d
    on f.date_id = d.date_id
where c.is_current = 1
  and c.email <> 'unknown@brightlearn.co.za'
group by
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.loyalty_tier
having
    max(d.transaction_date) < '2024-04-28'
    or max(d.transaction_date) is null
order by last_purchase_date;

--BQ-06 What is the average transaction value broken down by customer loyalty tier (Bronze, Silver, Gold)?
select
    c.loyalty_tier,
    avg(f.line_amount) as avg_transaction_value,
    count(*) as transaction_count
from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
join [dwh_bright_retail].[dbo].[dwh_customer] as c on f.customer_id = c.customer_id
group by c.loyalty_tier
order by avg_transaction_value desc;


-- BQ-07 What is the total quantity sold per product category, per store, for the reporting period? 
select
    st.store_name,
    p.category,
    sum(f.qty) as total_quantity_sold
from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
join [dwh_bright_retail].[dbo].[dwh_store] as st on f.store_id = st.store_id
join [dwh_bright_retail].[dbo].[dwh_product] as p on f.product_id = p.product_id
group by st.store_name, p.category
order by st.store_name, total_quantity_sold desc;

--BQ-08 	Based on the June 2026 inventory snapshot embedded in the source data, 
--which store-product combinations currently have stock levels below their reorder threshold?
with june_snapshot as (
    select
        st.store_name,
        p.product_name,
        f.stock_on_hand,
        f.reorder_threshold,
        row_number() over (
            partition by f.store_id, f.product_id
            order by d.transaction_date desc
        ) as rn
    from [dwh_bright_retail].[dbo].[dwh_fact_sales] as f
    join [dwh_bright_retail].[dbo].[dwh_store] as st on f.store_id = st.store_id
    join [dwh_bright_retail].[dbo].[dwh_product] as p on f.product_id = p.product_id
    join [dwh_bright_retail].[dbo].[dwh_date] as d on f.date_id = d.date_id
    where d.month = 6 and d.transaction_date between '2024-06-01' and '2024-06-30'
)
select store_name, product_name, stock_on_hand, reorder_threshold
from june_snapshot
where rn = 1
  and stock_on_hand < reorder_threshold
order by store_name, product_name;