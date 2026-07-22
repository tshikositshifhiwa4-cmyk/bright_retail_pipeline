if object_id('[dwh_bright_retail].[dbo].[dwh_product]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_product] (
        product_id     int primary key,
        product_name   varchar(250) not null,
        category       varchar(250) null,
        sub_category   varchar(250) null,
        sku            varchar(250) not null
    );
end
go

create or alter procedure dbo.usp_load_dwh_product
as
begin
    set nocount on;

    insert into [dwh_bright_retail].[dbo].[dwh_product] (product_id, product_name, category, sub_category, sku)
    select c.product_id, c.product_name, c.category, c.sub_category, c.sku
    from [stg_bright_retail].[dbo].[clean_product] as c
    where not exists (
        select 1 from [dwh_bright_retail].[dbo].[dwh_product] w where w.product_id = c.product_id
    );
end
go

exec dbo.usp_load_dwh_product