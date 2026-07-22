if object_id('[dwh_bright_retail].[dbo].[dwh_supplier]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_supplier] (
        supplier_id   int primary key,
        supplier      varchar(250) not null
    );
end
go

create or alter procedure dbo.usp_load_dwh_supplier
as
begin
    set nocount on;

    insert into [dwh_bright_retail].[dbo].[dwh_supplier] (supplier_id, supplier)
    select c.supplier_id, c.supplier
    from [stg_bright_retail].[dbo].[clean_supplier] as c
    where not exists (
        select 1 from [dwh_bright_retail].[dbo].[dwh_supplier] w where w.supplier_id = c.supplier_id
    );
end
go

exec dbo.usp_load_dwh_supplier

