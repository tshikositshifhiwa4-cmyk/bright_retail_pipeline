if object_id('[stg_bright_retail].[dbo].[clean_customer]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_customer] (
        customer_key           int primary key,
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

insert into [stg_bright_retail].[dbo].[clean_customer] (
    customer_key, customer_id, first_name, last_name, email, phone_number,
    loyalty_tier, customer_since, customer_city, customer_province,
    effective_start_date, effective_end_date, is_current
)
select
    d.customer_key,
    d.customer_id,
    coalesce(nullif(ltrim(rtrim(d.first_name)), ''), 'Unknown'),
    coalesce(nullif(ltrim(rtrim(d.last_name)), ''), 'Unknown'),
    coalesce(nullif(ltrim(rtrim(d.email)), ''), 'unknown@brightlearn.co.za'),
    coalesce(nullif(ltrim(rtrim(d.phone_number)), ''), '0000000000'),
    coalesce(nullif(ltrim(rtrim(d.loyalty_tier)), ''), 'None'),
    d.customer_since,
    coalesce(nullif(ltrim(rtrim(d.customer_city)), ''), 'Unknown'),
    coalesce(nullif(ltrim(rtrim(d.customer_province)), ''), 'Unknown'),
    d.effective_start_date,
    d.effective_end_date,
    d.is_current
from [stg_bright_retail].[dbo].[dim_customer] as d
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_customer] c where c.customer_key = d.customer_key
);
go

--verify
select * from [stg_bright_retail].[dbo].[clean_customer];