if object_id('[stg_bright_retail].[dbo].[dim_customer]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_customer] (
        customer_key           int identity(1,1) primary key,
        customer_id            int not null,
        first_name             varchar(250) not null,
        last_name              varchar(250) not null,
        email                  varchar(250) not null,
        phone_number           varchar(20) not null,
        loyalty_tier           varchar(50) not null,
        customer_since         date not null,
        customer_city          varchar(250) not null,
        customer_province      varchar(250) not null,

        effective_start_date   date not null,
        effective_end_date     date null,
        is_current             bit not null
    );
end
go

-- close out rows where loyalty_tier changed
update c
set c.effective_end_date = getdate(),
    c.is_current = 0
from [stg_bright_retail].[dbo].[dim_customer] as c
join (
    select customer_email, customer_loyalty_tier,
           row_number() over (partition by customer_email order by customer_first_name) as rn
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) as b
    on c.email = b.customer_email
where b.rn = 1
  and c.is_current = 1
  and c.loyalty_tier <> b.customer_loyalty_tier;
go

-- inserting data
insert into [stg_bright_retail].[dbo].[dim_customer] (
    customer_id, first_name, last_name, email, phone_number,
    loyalty_tier, customer_since, customer_city, customer_province,
    effective_start_date, effective_end_date, is_current
)
select
    row_number() over (order by b.customer_email) + isnull((select max(customer_id) from [stg_bright_retail].[dbo].[dim_customer]), 0),
    b.customer_first_name,
    b.customer_last_name,
    b.customer_email,
    b.customer_phone,
    b.customer_loyalty_tier,
    cast(b.customer_since as date),
    b.customer_city,
    b.customer_province,
    cast(getdate() as date),
    null,
    1
from (
    select
        customer_first_name, customer_last_name, customer_email,
        customer_phone, customer_loyalty_tier, customer_since,
        customer_city, customer_province,
        row_number() over (partition by customer_email order by customer_first_name) as rn
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) as b
where b.rn = 1
  and not exists (
      select 1
      from [stg_bright_retail].[dbo].[dim_customer] as c
      where c.email = b.customer_email
        and c.is_current = 1
  );
go

--verify
select * 
from [stg_bright_retail].[dbo].[dim_customer]