--creating stg dim_store

if object_id ('[stg_bright_retail].[dbo].[dim_store]', 'U') is null
begin
    create table [stg_bright_retail].[dbo].[dim_store] (
       store_key int identity(1,1) primary key,
       store_id int not null,
       store_name varchar(250) not null,
       store_province varchar(250) not null,
       store_region varchar(250) not null,
       store_manager varchar(250) not null
    );
end
go

--loading the data into dim_store

insert into [stg_bright_retail].[dbo].[dim_store] (
       store_id ,
       store_name ,
       store_province ,
       store_region ,
       store_manager 

)
select
    row_number() over (order by 
                                store_name ,
                                store_province ,
                                store_region ,
                                store_manager ) as store_id,
         store_name ,
         store_province ,
         store_region ,
         store_manager
from stg_bright_retail.dbo.bright_retail_raw_data
go