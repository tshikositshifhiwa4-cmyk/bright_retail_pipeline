
if object_id('[stg_bright_retail].[dbo].[clean_product]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_product] (
        product_id     int primary key,
        product_name   varchar(250) not null,
        category       varchar(250) null,
        sub_category   varchar(250) null,
        sku            varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_product] (
    product_id, product_name, category, sub_category, sku
)
select
    d.product_id,
    d.product_name,
    coalesce(nullif(d.category, ''), max(nullif(d.category, '')) over (partition by d.sku)) as category,
    d.sub_category,
    d.sku
from [stg_bright_retail].[dbo].[dim_product] as d
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_product] c where c.product_id = d.product_id
);
go

--verify the insert
select * from [stg_bright_retail].[dbo].[clean_product];
