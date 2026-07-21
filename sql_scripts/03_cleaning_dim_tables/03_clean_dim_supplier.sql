-- dim supplier no cleaning needed, verified clean
if object_id('[stg_bright_retail].[dbo].[clean_supplier]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_supplier] (
        supplier_id   int identity(1,1) primary key,
        supplier      varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_supplier] (supplier)
select s.supplier
from (
    select distinct ltrim(rtrim(supplier)) as supplier
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) as s
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_supplier] d where d.supplier = s.supplier
);
go

--verify the insert 
select *
from [stg_bright_retail].[dbo].[clean_supplier]