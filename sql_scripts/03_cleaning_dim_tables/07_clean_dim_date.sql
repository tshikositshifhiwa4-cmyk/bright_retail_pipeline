if object_id('[stg_bright_retail].[dbo].[clean_date]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_date] (
        date_id           int identity(1,1) primary key,
        transaction_date  date not null,
        month_name        varchar(20) not null,
        month             int not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_date] (transaction_date, month_name, month)
select
    s.clean_date,
    datename(month, s.clean_date),
    month(s.clean_date)
from (
    select distinct
        coalesce(
            try_convert(date, transaction_date, 23),   
            try_convert(date, transaction_date, 103),  
            try_convert(date, transaction_date, 105),  
            try_convert(date, transaction_date, 106)   
        ) as clean_date
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) as s
where s.clean_date is not null
  and not exists (
      select 1 from [stg_bright_retail].[dbo].[clean_date] d where d.transaction_date = s.clean_date
  );
go

--verify the insert
select * from [stg_bright_retail].[dbo].[clean_date];