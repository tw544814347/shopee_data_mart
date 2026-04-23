create or replace temporary function geo_to_h3 as 'com.shopee.udf.Geo2H3UDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';


insert overwrite table ${SCHEMA}.dws_risk_spp_txn_hex_di partition(grass_region, grass_date)
select 
  user_id
  ,transaction_id
  ,storeid
  ,payment_channel_name
  ,payment_method_name
  ,location
  ,location_status
  ,cast(latitude as double) as latitude
  ,cast(longitude as double) as longitude
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 1)) as gps_hex_1
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 2)) as gps_hex_2
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 3)) as gps_hex_3
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 4)) as gps_hex_4
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 5)) as gps_hex_5
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 6)) as gps_hex_6
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 7)) as gps_hex_7
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 8)) as gps_hex_8
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 9)) as gps_hex_9
  ,if(coalesce(latitude,'')='' or coalesce(longitude,'')='', null, geo_to_h3(latitude, longitude, 10)) as gps_hex_10
  ,create_time
  ,'${region}' as grass_region
  ,date_format(from_unixtime(create_time), 'yyyy-MM-dd') as grass_date
from
(
    select  shopeepay_user_id as user_id
            ,as_transaction_id as transaction_id
            ,store_id as storeid
            ,apm_payment_channel_name as payment_channel_name
            ,payment_method_name as payment_method_name
            ,user_location as location
            ,get_json_object(user_location, '$.status') as location_status
            ,get_json_object(user_location, '$.latitude') as latitude
            ,get_json_object(user_location, '$.longitude') as longitude
            ,create_time
    from    shopeepay.mart_dwd_wide_user_order_acquiring_all_ent_df__sg
    where   date_format(from_unixtime(create_time), 'yyyy-MM-dd') >= date_sub('${ds}',2)
      and   date_format(from_unixtime(create_time), 'yyyy-MM-dd') <= '${ds}'
      and   transaction_type = 1
      and   ((transaction_type = 1 and partner_type_name = 'Merchant Payment') or transaction_type = 7)
      and   transaction_status in (4,6)
      and   user_scope_name <> 'Off_us User'
) t
;


