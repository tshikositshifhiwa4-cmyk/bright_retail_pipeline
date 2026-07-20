if object_id('[stg_bright_retail].[dbo].[dim_customer_location]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_customer_location] (
        customer_location_key    int identity(1,1) primary key,
        customer_location_id     int not null,
        customer_city            varchar(250) null,
        customer_province        varchar(250) not null
    );
end
go

insert into [stg_bright_retail].[dbo].[dim_customer_location] (
    customer_location_id, customer_city, customer_province
)
select
    row_number() over (order by customer_city, customer_province) as customer_location_id,
    customer_city,
    customer_province
from stg_bright_retail.dbo.bright_retail_raw_data
where customer_city is not null
  and customer_province is not null;
go
