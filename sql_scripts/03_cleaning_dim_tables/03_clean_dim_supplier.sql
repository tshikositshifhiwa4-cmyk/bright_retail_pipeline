if object_id('[stg_bright_retail].[dbo].[clean_supplier]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_supplier] (
        supplier_id   int primary key,
        supplier      varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_supplier] (supplier_id, supplier)
select
    d.supplier_id,
    ltrim(rtrim(d.supplier))
from [stg_bright_retail].[dbo].[dim_supplier] as d
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_supplier] c where c.supplier_id = d.supplier_id
);
go

--verify the insert
select *
from [stg_bright_retail].[dbo].[clean_supplier]
