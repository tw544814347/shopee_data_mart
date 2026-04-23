create or replace temporary function get_ip_to_city as 'com.shopee.de.udf.IP.v1.IP2LocLookupWithProxy' using jar 'hdfs://R2/projects/risk/hdfs/udf/shopee-de-udf-0.0.19.jar';
create or replace temporary function parse_city_name as 'com.shopee.udf.ParseCityNameUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

with base as (
    select
        buyer_id,
        grass_region,
        get_ip_to_city(checkout_ip) as ip_info,
        is_physical_product_order,
        order_id,
        shipping_city_name
    from ${SCHEMA}.dwd_risk_order_complete_di
    where grass_date <= date('${bizdate}')
      and grass_date > date_sub(date('${bizdate}'), 180)
      and coalesce(checkout_ip, '') <> ''
      and tz_type = 'local'
      and grass_region = '${grass_region}'
      and is_physical_product_order = 'Y'
)

insert overwrite table ${SCHEMA}.dws_risk_buyer_city_complete_df partition (tz_type='local', grass_region, grass_date)
select
    buyer_id,
    ip_info[4] as city_name,
    ip_info[4] as checkout_city_name,
    count(case when is_physical_product_order = 'Y' then order_id end) as complete_physical_product_ord_cnt_6m,
    count(case 
          when is_physical_product_order = 'Y'
           and parse_city_name(ip_info[4], grass_region) = shipping_city_name
          then order_id end
    ) as checkout_shipping_same_city_of_complete_physical_product_ord_cnt_6m,
    count(case when is_physical_product_order = 'Y' and ip_info[8] = 0 then order_id end) as complete_physical_product_ord_cnt_without_proxy_6m,
    count(case 
          when is_physical_product_order = 'Y'
           and parse_city_name(ip_info[4], grass_region) = shipping_city_name
           and ip_info[8] = 0
          then order_id end
    ) as checkout_shipping_same_city_of_complete_physical_product_ord_cnt_without_proxy_6m,
    grass_region,
    date('${bizdate}') as grass_date
from base
where ip_info[4] is not null
group by
    buyer_id,
    grass_region,
    ip_info[4];
