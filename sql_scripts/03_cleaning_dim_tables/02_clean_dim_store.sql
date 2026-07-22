if object_id('[stg_bright_retail].[dbo].[clean_store]', 'u') is null
begin
    create table [stg_bright_retail].[dbo].[clean_store] (
        store_id              int primary key,
        store_name            varchar(250) not null,
        store_province        varchar(250) not null,
        store_city            varchar(250) not null,
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
from [stg_bright_retail].[dbo].[clean_store] as s
join [stg_bright_retail].[dbo].[dim_store] as d
    on s.store_id = d.store_id
where s.is_current = 1
  and d.is_current = 1
  and s.store_manager <> ltrim(rtrim(d.store_manager));
go

-- inserting the data to the table
insert into [stg_bright_retail].[dbo].[clean_store] (
    store_id, store_name,  store_city, store_province, store_region, store_manager,
    effective_start_date, effective_end_date, is_current
)
select
    d.store_id,
    ltrim(rtrim(d.store_name)),
    ltrim(rtrim(d.store_city)),
    ltrim(rtrim(d.store_province)),
    ltrim(rtrim(d.store_region)),
    ltrim(rtrim(d.store_manager)),
    d.effective_start_date,
    d.effective_end_date,
    d.is_current
from [stg_bright_retail].[dbo].[dim_store] as d
where d.is_current = 1
  and not exists (
      select 1 from [stg_bright_retail].[dbo].[clean_store] s
      where s.store_id = d.store_id and s.is_current = 1
  );
go

--validating the insert
select *
from [stg_bright_retail].[dbo].[clean_store]