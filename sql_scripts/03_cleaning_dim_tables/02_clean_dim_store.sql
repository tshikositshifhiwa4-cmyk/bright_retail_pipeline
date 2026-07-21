
if object_id('[stg_bright_retail].[dbo].[clean_store]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_store] (
        store_key             int identity(1,1) primary key,
        store_id              int not null,
        store_name            varchar(250) not null,
        store_province        varchar(250) not null,
        store_region          varchar(50)  not null,
        store_manager         varchar(100) not null,
        effective_start_date  date not null,
        effective_end_date    date null,
        is_current            bit not null
    );
end
go

-- close out rows where manager changed
update s
set s.effective_end_date = getdate(), s.is_current = 0
from [stg_bright_retail].[dbo].[clean_store] s
join (
    select distinct ltrim(rtrim(store_name)) as store_name, ltrim(rtrim(store_manager)) as store_manager
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) b
    on s.store_name = b.store_name
where s.is_current = 1 and s.store_manager <> s.store_manager;
go

--inserting the data to the table
insert into [stg_bright_retail].[dbo].[clean_store] (
    store_id, store_name, store_province, store_region, store_manager,
    effective_start_date, effective_end_date, is_current
)
select
    row_number() over (order by b.store_name) + isnull((select max(store_id) from [stg_bright_retail].[dbo].[clean_store]), 0),
    b.store_name, b.store_province, b.store_region, b.store_manager,
    cast(getdate() as date), null, 1
from (
    select distinct
        ltrim(rtrim(store_name)) as store_name,
        ltrim(rtrim(store_province)) as store_province,
        ltrim(rtrim(store_region)) as store_region,
        ltrim(rtrim(store_manager)) as store_manager
    from [stg_bright_retail].[dbo].[bright_retail_raw_data]
) as b
where not exists (
    select 1 from [stg_bright_retail].[dbo].[clean_store] s where s.store_name = b.store_name and s.is_current = 1
);
go

--validating the insert
select *
from [stg_bright_retail].[dbo].[clean_store]