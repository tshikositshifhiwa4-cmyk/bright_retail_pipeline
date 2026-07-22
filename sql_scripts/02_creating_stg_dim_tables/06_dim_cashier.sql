if object_id('[stg_bright_retail].[dbo].[dim_cashier]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_cashier] (
        cashier_id     int identity(1,1) primary key,
        cashier_name   varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[dim_cashier] (cashier_name)
select s.cashier_name
from (
    select distinct cashier_name
    from stg_bright_retail.dbo.bright_retail_raw_data
) as s
where not exists (
    select 1 from [stg_bright_retail].[dbo].[dim_cashier] d where d.cashier_name = s.cashier_name
);
go

--verify the insert
select *
from [stg_bright_retail].[dbo].[dim_cashier]