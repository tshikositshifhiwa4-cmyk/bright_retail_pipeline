--creating stg dim_payment
if object_id ('[stg_bright_retail].[dbo].[dim_payment]', 'U') is null
begin
    create table [stg_bright_retail].[dbo].[dim_payment] (
        payment_id int identity(1,1) primary key,
        payment_method varchar(250) 
    );
end
go

--inserting the data from the raw dataset to the dim_payment 
insert into [stg_bright_retail].[dbo].[dim_payment] (payment_method)
select s.payment_method
from (
    select distinct payment_method
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) as s
where not exists (
    select 1 from [stg_bright_retail].[dbo].[dim_payment] d where d.payment_method = s.payment_method
);
go

--verifying if the insert worked
select *
from [stg_bright_retail].[dbo].[dim_payment];