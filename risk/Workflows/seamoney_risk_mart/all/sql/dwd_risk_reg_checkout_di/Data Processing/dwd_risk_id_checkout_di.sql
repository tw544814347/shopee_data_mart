-- 统一成模板： for SG 地区，不同业务线处理逻辑相同

set spark.sql.hive.convertMetastoreOrc = false;
insert overwrite table ${SCHEMA}.dwd_risk_checkout_di partition (tz_type = 'local', grass_region, grass_date)
select
    userid as buyer_id
    ,get_json_object(data, '$.checkoutid') as checkout_id
    ,client_ip as checkout_ip
    ,deviceid as shopee_device_id
    ,log_timestamp as checkout_timestamp
    ,a1.grass_region
    ,cast('${bizdate}' as date) as grass_date
from traffic.shopee_traffic_dwd_click_hi__reg_s1_live a1
where
    grass_region = '${grass_region}'
    and regional_date >= date(date_sub('${bizdate}', 1))
    and regional_date <= date(date_add('${bizdate}', 1))
    and local_date = date('${bizdate}')
    and page_type = 'checkout_page'
    and operation = 'action_place_order_success'
    and get_json_object(data, '$.checkoutid') is not null
;