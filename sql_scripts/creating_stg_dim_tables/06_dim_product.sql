drop table if exists [stg_bright_retail].[dbo].[dim_store];
go

if object_id('[stg_bright_retail].[dbo].[dim_product]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_product] (
        product_id    int identity(1,1) primary key,
        product_name   varchar(250) not null,
        category       varchar(250) null,
        sub_category   varchar(250) null,
        sku            varchar(250) not null
    );
end
go

--truncate table
truncate table [stg_bright_retail].[dbo].[dim_product]

insert into [stg_bright_retail].[dbo].[dim_product] (
     product_name, category, sub_category, sku
)

select distinct 
     product_name, 
     category, 
     sub_category, 
     sku
from stg_bright_retail.dbo.bright_retail_raw_data
;
go

--verify the insert
select *
from [stg_bright_retail].[dbo].[dim_product]