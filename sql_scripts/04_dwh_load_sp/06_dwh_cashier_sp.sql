if object_id('[dwh_bright_retail].[dbo].[dwh_cashier]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_cashier] (
        cashier_id          int primary key,
        cashier_name   varchar(250) not null
    );
end
go

create or alter procedure dbo.usp_load_dwh_cashier
as
begin
    set nocount on;

    insert into [dwh_bright_retail].[dbo].[dwh_cashier] (cashier_id, cashier_name)
    select c.cashier_id, c.cashier_name
    from [stg_bright_retail].[dbo].[clean_cashier] as c
    where not exists (
        select 1 from [dwh_bright_retail].[dbo].[dwh_cashier] w where w.cashier_id = c.cashier_id
    );
end
go

exec dbo.usp_load_dwh_cashier



