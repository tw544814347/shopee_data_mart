--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-08-15
-- Theme Domain：       buyer order_id
-- Description:         用户最近180天的city_name,因为udf get_ip_to_city不太稳定可能会某天拿不到用户的cityname,因此新增兜底逻辑,取最近180天的用户cityname
--                      下游业务反馈，在order 表中直接解析city_name,不用回刷历史,就从加字段的当天开始往后刷-- ganlin跟用户达成一致了
-- Data Granularity:   
-- jira: https://jira.shopee.io/browse/SPFDT-42574 (讨论后是新做一个feature,frequency_city_name_list_6m_new) 
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-08-15 1. 新增注释 2.新增checkout_city_name
--********************************************************************--
create or replace temporary function get_ip_to_city as 'com.shopee.de.udf.IP.v1.IP2LocLookupWithProxy' using jar 'hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/shopee-de-udf-0.0.19.jar';

create or replace temporary view order_table as
select
    a.buyer_id                                  as buyer_id
    ,a.checkout_id                              as checkout_id
    ,a.order_id                                 as order_id
    ,a.buyer_shipping_address_city              as shipping_city_name
    ,a.complete_timestamp                       as complete_timestamp
    ,a.grass_region                             as grass_region
    ,a.create_timestamp                         as create_timestamp
    ,to_date(a.complete_datetime)               as complete_date 
    ,a.complete_timestamp - a.create_timestamp  as complete_duration
    ,a.shop_id                                  as shop_id 
    ,if(nvl(b.is_official_store_tag,0) 
        + nvl(b.is_cross_border_tag,0) 
        + nvl(b.is_preferred,0) 
        + nvl(b.is_b2c,0) >= 1, 1, 0)           as big_shop_flag 
from
(
    select
        buyer_id
        ,checkout_id
        ,order_id
        ,buyer_shipping_address_city
        ,complete_timestamp
        ,create_timestamp
        ,complete_datetime
        ,shop_id
        ,grass_region
    from mp_order.dwd_order_place_pay_complete_di__reg_s0_live
    where tz_type='local'
        and grass_region = '${grass_region}'
        and grass_date = date('${bizdate}')
        and is_completed = 1
) a
left join (
    select 
      shop_id
      ,is_official_store_tag
      ,is_cross_border_tag
      ,is_preferred
      ,is_b2c
      ,grass_region
    from ${SCHEMA}.dim_risk_shop_df
    where grass_date= date('${bizdate}')
      and tz_type='local'
      and grass_region = '${grass_region}'
) b 
  on a.shop_id = b.shop_id 
  and a.grass_region = b.grass_region
;

create or replace temporary view order_physical as
select
    order_id                  as order_id
    ,grass_region             as grass_region
    ,max(is_physical_product) as is_physical_product_order
from ${SCHEMA}.dwd_risk_order_item_complete_di
where grass_date = date('${bizdate}')
  and tz_type='local'
  and grass_region = '${grass_region}'
group by
    order_id
    ,grass_region;

create or replace temporary view check_table as
select
    checkout_id
    ,grass_region
    ,checkout_ip
    ,shopee_device_id
    ,checkout_timestamp
from ${SCHEMA}.dwd_risk_checkout_df
where grass_date = date('${bizdate}')
  and tz_type='local'
  and grass_region = '${grass_region}';

insert overwrite table ${SCHEMA}.dwd_risk_order_complete_di partition (tz_type='local', grass_region, grass_date)
select
     a1.buyer_id                     as buyer_id                  
    ,a1.checkout_id                  as checkout_id               
    ,a2.checkout_ip                  as checkout_ip               
    ,a2.shopee_device_id             as shopee_device_id          
    ,a2.checkout_timestamp           as checkout_timestamp        
    ,a1.order_id                     as order_id                  
    ,a3.is_physical_product_order    as is_physical_product_order 
    ,a1.shipping_city_name           as shipping_city_name        
    ,a1.complete_timestamp           as complete_timestamp        
    ,a1.create_timestamp             as create_timestamp
    ,a1.complete_date                as complete_date 
    ,a1.complete_duration            as complete_duration
    ,a1.shop_id                      as shop_id 
    ,a1.big_shop_flag                as big_shop_flag 
    ,case when coalesce(a2.checkout_ip, '') <> '' then get_ip_to_city(a2.checkout_ip)[4] 
          else '' end                as checkout_city_name
    ,spp.shopeepay_user_id
    ,a1.grass_region                 as grass_region
    ,date('${bizdate}')              as grass_date
from order_table a1
left outer join check_table a2
  on a1.checkout_id = a2.checkout_id
  and a1.grass_region = a2.grass_region
left outer join order_physical a3
  on a1.order_id = a3.order_id
  and a1.grass_region = a3.grass_region
left join (
    select
    *
    from risk.dim_risk_${region}_sp_to_spp_id_mapping_df
    where grass_date = '${ds}'
) spp 
on (a1.buyer_id=spp.shopee_user_id)
;
