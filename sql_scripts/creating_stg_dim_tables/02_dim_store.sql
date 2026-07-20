drop table if exists [stg_bright_retail].[dbo].[dim_store];
go

--creating stg dim_store using scd type 2 on store manager

if object_id ('[stg_bright_retail].[dbo].[dim_store]', 'U') is null
begin
    create table [stg_bright_retail].[dbo].[dim_store] (
       store_key int identity(1,1) primary key,
       store_id int not null,
       store_name varchar(250) not null,
       store_province varchar(250) not null,
       store_region varchar(250) not null,
       store_manager varchar(250) not null,

       effective_start_date date not null,
       effective_end_date date null,
       is_current bit not null
    );
end
go

--truncate table
truncate table [stg_bright_retail].[dbo].[dim_store]

--closing out the rows where manager changed
update s
set s.effective_end_date = getdate(), s.is_current = 0
from [stg_bright_retail].[dbo].[dim_store] as s
join (select distinct store_name, store_manager from [stg_bright_retail].[dbo].[bright_retail_raw_data]) as b
    on s.store_name = b.store_name
where s.is_current = 1 and s.store_manager <> b.store_manager;
go

--inserting the data to the table

insert into [stg_bright_retail].[dbo].[dim_store] (
       store_id ,
       store_name ,
       store_province ,
       store_region ,
       store_manager,
       effective_start_date,
       effective_end_date,
       is_current

)
select distinct
    row_number() over (order by 
                                b.store_name ,
                                b.store_province ,
                                b.store_region ,
                                b.store_manager )
                                    +  isnull((select max(store_id) from [stg_bright_retail].[dbo].[dim_store]), 0) as store_id,
         b.store_name ,
         b.store_province ,
         b.store_region ,
         b.store_manager,
         cast(getdate() as date) as effective_start_date,
         null as effective_end_date,
         1 as is_current
from [stg_bright_retail].[dbo].[bright_retail_raw_data] as b
where not exists (
                select 1
                from [stg_bright_retail].[dbo].[dim_store] as s
                where b.store_name = s.store_name 
                    and s.is_current = 1
);
go

--validating the insert
select *
from [stg_bright_retail].[dbo].[dim_store]