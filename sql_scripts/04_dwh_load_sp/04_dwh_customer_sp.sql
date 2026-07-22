if object_id('[dwh_bright_retail].[dbo].[dwh_customer]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_customer] (
        customer_id            int primary key,
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

create or alter procedure dbo.usp_load_dwh_customer
as
begin
    set nocount on;

    -- close out dwh rows that clean_customer has since closed
    update w
    set w.effective_end_date = c.effective_end_date,
        w.is_current = 0
    from [dwh_bright_retail].[dbo].[dwh_customer] as w
    join [stg_bright_retail].[dbo].[clean_customer] as c
        on w.customer_id = c.customer_id
    where w.is_current = 1
      and c.is_current = 0;

    -- insert new / changed customer rows
    insert into [dwh_bright_retail].[dbo].[dwh_customer] (
        customer_id, first_name, last_name, email, phone_number,
        loyalty_tier, customer_since, customer_city, customer_province,
        effective_start_date, effective_end_date, is_current
    )
    select
        c.customer_id, c.first_name, c.last_name, c.email, c.phone_number,
        c.loyalty_tier, c.customer_since, c.customer_city, c.customer_province,
        c.effective_start_date, c.effective_end_date, c.is_current
    from [stg_bright_retail].[dbo].[clean_customer] as c
    where not exists (
        select 1 from [dwh_bright_retail].[dbo].[dwh_customer] w where w.customer_id = c.customer_id
    );
end
go

exec dbo.usp_load_dwh_customer