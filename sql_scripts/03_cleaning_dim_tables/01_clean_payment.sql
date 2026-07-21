--standardize casing

drop table if exists [stg_bright_retail].[dbo].[clean_payment];
go

if object_id ('[stg_bright_retail].[dbo].[clean_payment]', 'U') is null
begin
    create table [stg_bright_retail].[dbo].[clean_payment] (
        payment_id int identity(1,1) primary key,
        payment_method varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_payment] (payment_method)
select distinct
        case upper(ltrim(rtrim(payment_method)))
            when 'CASH'         then 'Cash'
            when 'CREDIT CARD'  then 'Credit Card'
            when 'DEBIT CARD'   then 'Debit Card'
            when 'EFT'          then 'EFT'
            when 'STORE CREDIT' then 'Store Credit'
            else ltrim(rtrim(payment_method))
        end as payment_method
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
as s
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_payment] d where d.payment_method = s.payment_method
);
go

--validating insert
select *
from [stg_bright_retail].[dbo].[clean_payment] 