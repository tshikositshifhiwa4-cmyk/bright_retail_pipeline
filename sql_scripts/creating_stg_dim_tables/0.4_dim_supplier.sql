drop table if exists [stg_bright_retail].[dbo].[dim_store];
go

--creating dim_supplier table
if object_id('[stg_bright_retail].[dbo].[dim_supplier]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[dim_supplier] (  
        supplier_id     int identity(1,1) primary key,
        supplier           varchar(250) not null
);
end
go

--inerting the data
insert into [stg_bright_retail].[dbo].[dim_supplier] (
   supplier
)
select distinct
    supplier
from stg_bright_retail.dbo.bright_retail_raw_data
       