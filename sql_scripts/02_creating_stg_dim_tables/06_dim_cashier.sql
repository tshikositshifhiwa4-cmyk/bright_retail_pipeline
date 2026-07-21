drop table if exists [stg_bright_retail].[dbo].[dim_cashier];
go

if object_id('[stg_bright_retail].[dbo].[dim_cashier]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_cashier] (
        cashier_id         int identity(1,1) primary key,
        cashier_name   varchar(250) not null
    );
end
go


insert into [stg_bright_retail].[dbo].[dim_cashier] (cashier_name)

select distinct 
        cashier_name
from stg_bright_retail.dbo.bright_retail_raw_data
;
go


--verify the insert
select *
from [stg_bright_retail].[dbo].[dim_cashier] 