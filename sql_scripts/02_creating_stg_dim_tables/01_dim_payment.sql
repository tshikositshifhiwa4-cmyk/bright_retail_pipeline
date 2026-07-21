

--creating stg dim_payment

if object_id ('[stg_bright_retail].[dbo].[dim_payment]', 'U') is null
begin
    create table [stg_bright_retail].[dbo].[dim_payment] (
        payment_id int identity(1,1) primary key,
        payment_method varchar(250) 
    );
end
go

truncate table [stg_bright_retail].[dbo].[dim_payment]

--inserting the data from the raw dataset to the dim_payment
    insert into [stg_bright_retail].[dbo].[dim_payment] (payment_method)

    select distinct payment_method
    from [stg_bright_retail].[dbo].[bright_retail_raw_data];
go

--verifying if the insert worked
select *
from [stg_bright_retail].[dbo].[dim_payment];