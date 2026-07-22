if object_id('[stg_bright_retail].[dbo].[clean_cashier]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_cashier] (
        cashier_id          int primary key,
        cashier_name   varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_cashier] (cashier_id,cashier_name)
select
    d.cashier_id,
    ltrim(rtrim(d.cashier_name))
from [stg_bright_retail].[dbo].[dim_cashier] as d
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_cashier] c where c.cashier_id = d.cashier_id
);
go

--verify the insert
select *
from [stg_bright_retail].[dbo].[clean_cashier]