if object_id ('[stg_bright_retail].[dbo].[clean_payment]', 'U') is null
begin
    create table [stg_bright_retail].[dbo].[clean_payment] (
        payment_id      int primary key,
        payment_method  varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[clean_payment] (payment_id, payment_method)
select
    d.payment_id,
    case upper(ltrim(rtrim(d.payment_method)))
        when 'CASH'         then 'Cash'
        when 'CREDIT CARD'  then 'Credit Card'
        when 'DEBIT CARD'   then 'Debit Card'
        when 'EFT'          then 'EFT'
        when 'STORE CREDIT' then 'Store Credit'
        else ltrim(rtrim(d.payment_method))
    end as payment_method
from [stg_bright_retail].[dbo].[dim_payment] as d
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_payment] c where c.payment_id = d.payment_id
);
go
--validating insert
select *
from [stg_bright_retail].[dbo].[clean_payment] 

