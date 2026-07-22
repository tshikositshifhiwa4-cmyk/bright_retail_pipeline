if object_id('[stg_bright_retail].[dbo].[dim_product]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_product] (
        product_id     int identity(1,1) primary key,
        product_name   varchar(250) not null,
        category       varchar(250) null,
        sub_category   varchar(250) null,
        sku            varchar(250) not null
    );
end
go

-- inserting data (no truncate — only adds products not already in the table)
insert into [stg_bright_retail].[dbo].[dim_product] (
    product_name, category, sub_category, sku
)
select s.product_name, s.category, s.sub_category, s.sku
from (
    select distinct product_name, category, sub_category, sku
    from stg_bright_retail.dbo.bright_retail_raw_data
) as s
where not exists (
    select 1 from [stg_bright_retail].[dbo].[dim_product] d where d.sku = s.sku
);
go

--verify the insert
select *
from [stg_bright_retail].[dbo].[dim_product]