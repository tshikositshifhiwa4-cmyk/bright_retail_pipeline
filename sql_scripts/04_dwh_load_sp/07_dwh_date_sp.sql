if object_id('[dwh_bright_retail].[dbo].[dwh_date]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_date] (
        date_id           int primary key,
        transaction_date  date not null,
        month_name        varchar(20) not null,
        month             int not null
    );
end
go

create or alter procedure dbo.usp_load_dwh_date
as
begin
    set nocount on;

    insert into [dwh_bright_retail].[dbo].[dwh_date] (date_id, transaction_date, month_name, month)
    select c.date_id, c.transaction_date, c.month_name, c.month
    from [stg_bright_retail].[dbo].[clean_date] as c
    where not exists (
        select 1 from [dwh_bright_retail].[dbo].[dwh_date] w where w.date_id = c.date_id
    );
end
go

exec dbo.usp_load_dwh_date