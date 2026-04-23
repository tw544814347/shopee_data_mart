-- 统一成模板： for SG/US 地区，不同业务线处理逻辑相同

create or replace temporary view checkout_today as
select
    buyer_id
    ,checkout_id
    ,checkout_ip
    ,shopee_device_id
    ,checkout_timestamp
    ,grass_region
from (
    select
        *
        ,row_number() over(partition by buyer_id, grass_region,checkout_id order by checkout_timestamp asc) as asc_rn
    from ${SCHEMA}.dwd_risk_checkout_di
    where grass_date = date('${bizdate}')
      and tz_type = 'local'
      and grass_region = '${grass_region}'
      and coalesce(checkout_id, '') <>  ''
) a1
where asc_rn = 1;

insert overwrite table ${SCHEMA}.dwd_risk_checkout_df partition (tz_type='local', grass_region, grass_date)
select
    if(a2.checkout_id is not null, a2.buyer_id, a1.buyer_id) as buyer_id
    ,if(a2.checkout_id is not null, a2.checkout_id, a1.checkout_id) as checkout_id
    ,if(a2.checkout_id is not null, a2.checkout_ip, a1.checkout_ip) as checkout_ip
    ,if(a2.checkout_id is not null, a2.shopee_device_id, a1.shopee_device_id) as shopee_device_id
    ,if(a2.checkout_id is not null, a2.checkout_timestamp, a1.checkout_timestamp) as checkout_timestamp
    ,if(a2.checkout_id is not null, a2.grass_region, a1.grass_region) as grass_region
    ,date('${bizdate}') as grass_date
from (
    select
        *
    from (
        select
            *
            ,row_number() over(partition by buyer_id, grass_region,checkout_id order by checkout_timestamp asc) as asc_rn
        from ${SCHEMA}.dwd_risk_checkout_df
        where grass_date = date_sub(date('${bizdate}'), 1)
          and tz_type = 'local'
          and grass_region = '${grass_region}'
          and checkout_timestamp > unix_timestamp(date_sub(date('${bizdate}'), 365))
          and coalesce(checkout_id, '') <>  ''
    )
    where asc_rn = 1
) a1
full outer join checkout_today a2
  on a1.checkout_id = a2.checkout_id
    and a1.grass_region = a2.grass_region
    and a1.buyer_id = a2.buyer_id;

