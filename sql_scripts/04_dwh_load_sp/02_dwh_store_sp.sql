if object_id('[dwh_bright_retail].[dbo].[dwh_store]', 'u') is null
begin
    create table [dwh_bright_retail].[dbo].[dwh_store] (
        store_id              int primary key,
        store_name            varchar(250) not null,
        store_city            varchar(250) not null,
        store_province        varchar(250) not null,
        store_region          varchar(250) not null,
        store_manager         varchar(250) not null,
        effective_start_date  date not null,
        effective_end_date    date null,
        is_current            bit not null
    );
end
go

create or alter procedure dbo.usp_load_dwh_store
as
begin
    set nocount on;

    update d
    set d.effective_end_date = c.effective_end_date,
        d.is_current = 0
    from [dwh_bright_retail].[dbo].[dwh_store] as d
    join [stg_bright_retail].[dbo].[clean_store] as c
        on d.store_id = c.store_id
    where d.is_current = 1
      and c.is_current = 0;

    insert into [dwh_bright_retail].[dbo].[dwh_store] (
        store_id,
        store_name,
        store_city,
        store_province,
        store_region,
        store_manager,
        effective_start_date,
        effective_end_date,
        is_current
    )
    select
        c.store_id,
        c.store_name,
        c.store_city,
        c.store_province,
        c.store_region,
        c.store_manager,
        c.effective_start_date,
        c.effective_end_date,
        c.is_current
    from [stg_bright_retail].[dbo].[clean_store] as c
    where not exists (
        select 1
        from [dwh_bright_retail].[dbo].[dwh_store] as d
        where d.store_id = c.store_id
    );
end
go

exec dbo.usp_load_dwh_store;



