drop table if exists [stg_bright_retail].[dbo].[dim_cashier];
go


if object_id('[stg_bright_retail].[dbo].[dim_date]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_date] (
        date_id         int identity(1,1) primary key,
        transaction_date date not null,
        month_name       varchar(20) not null,
        month            int not null
    );
end
go

--truncate table
truncate table [stg_bright_retail].[dbo].[dim_date]
go

--inserting the data
insert into [stg_bright_retail].[dbo].[dim_date] (transaction_date, month_name, month)
select distinct 
       try_convert(date, transaction_date),
        datename(month, try_convert(date, transaction_date)),
         month(try_convert(date, transaction_date))
from stg_bright_retail.dbo.bright_retail_raw_data
where try_convert(date, transaction_date) is not null;
go

--verify the insert
select *
from [stg_bright_retail].[dbo].[dim_date] 