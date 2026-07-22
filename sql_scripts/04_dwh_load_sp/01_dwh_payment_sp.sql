
if object_id('[dwh_bright_retail].[dbo].[dwh_payment]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_payment] (
        payment_id      int primary key,
        payment_method  varchar(250) not null
    );
end
go

create or alter procedure dbo.usp_load_dwh_payment
as
begin
    set nocount on;
    insert into [dwh_bright_retail].[dbo].[dwh_payment] (payment_id, payment_method)
    select cp.payment_id, cp.payment_method
    from [stg_bright_retail].[dbo].[clean_payment] as cp
    where not exists (
        select 1 from [dwh_bright_retail].[dbo].[dwh_payment] as dp where dp.payment_id = cp.payment_id
    );
end
go

exec dbo.usp_load_dwh_payment
