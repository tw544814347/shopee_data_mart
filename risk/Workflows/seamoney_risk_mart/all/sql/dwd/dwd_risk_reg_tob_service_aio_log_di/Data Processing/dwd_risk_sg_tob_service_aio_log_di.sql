--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-12
-- Theme Domain：       toB service
-- Description:         https://confluence.shopee.io/pages/viewpage.action?pageId=1464790497
-- Data Granularity:    
-- 变更历史：
-- update by wei.taou@shopee.com 业务反馈 trace_id 数据缺失，问题定位是 BE 重复发，DE 有根据 trace 去重逻辑，加上正则
-- update by wei.taou@shopee.com 20250820 BE 问题修复，相关正则 filter condition 去掉 
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


-- drop table if exists ${SCHEMA}.dwd_risk_${region}_tob_service_aio_log_di;

CREATE TABLE if not exists  ${SCHEMA}.dwd_risk_${region}_tob_service_aio_log_di (
    `flow_no` STRING COMMENT 'flow_no',
    `trace_id` STRING COMMENT 'trace_id',
    `customer_id` STRING COMMENT 'customer_id',
    `app_id` STRING COMMENT 'app_id',
    `service_id` STRING COMMENT 'service_id',
    `service_name` STRING COMMENT 'service_name',
    `api_method` STRING COMMENT 'api_method',
    `req_time` STRING COMMENT 'req_time',
    `rsp_time` STRING COMMENT 'rsp_time',
    `ktp_no` STRING COMMENT 'ktp_no',
    `msisdn` STRING COMMENT 'msisdn',
    `shopee_uid` STRING COMMENT 'shopee_uid',
    `gps_coordinate` STRING COMMENT 'gps_coordinate',
    `scenario` STRING COMMENT 'scenario',
    `product` STRING COMMENT 'product',
    `biz_code` STRING COMMENT 'biz_code',
    `biz_msg` STRING COMMENT 'biz_msg',
    `score` STRING COMMENT 'score',
    `score_v3` STRING COMMENT 'score_v3',
    `hit_flag` STRING COMMENT 'hit_flag',
    `list_type` STRING COMMENT 'list_type',
    `hit_reason_code` STRING COMMENT 'hit_reason_code',
    `match_type` STRING COMMENT 'match_type',
    `match_score` STRING COMMENT 'match_score',
    `confidence_level` STRING COMMENT 'confidence_level',
    `call_source` STRING COMMENT 'call_source',
    `subscribe_service_type` STRING COMMENT 'subscribe_service_type',
    `match_with` STRING COMMENT 'match_with',
    `platform_user_id` STRING COMMENT 'platform_user_id',
    `ktp_no_platform_user_id` STRING COMMENT 'ktp_no_platform_user_id',
    `mobile_no_platform_user_id` STRING COMMENT 'mobile_no_platform_user_id',
    `repeat_type` STRING COMMENT 'repeat_type',
    `idempotent_call_md5` STRING COMMENT 'idempotent_call_md5',
    `client_ip` STRING COMMENT 'client_ip',
    `sign` STRING COMMENT 'sign',
    `biz_data` STRING COMMENT 'biz_data',
    `rsp_data` STRING COMMENT 'rsp_data',
    `req_data` STRING COMMENT 'req_data',
    json_result STRING COMMENT 'json_result'
) partitioned by (
    grass_date string comment 'Date of refreshed data, contains recent 190 days data',
    `process_date` STRING COMMENT 'process_date'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dwd_risk_reg_tob_service_aio_log_di/grass_region=${REGION}'
;

-- msck repair table ${SCHEMA}.dwd_risk_${region}_tob_service_aio_log_di;
refresh table ${SCHEMA}.dwd_risk_${region}_tob_service_aio_log_di;


insert overwrite table ${SCHEMA}.dwd_risk_${region}_tob_service_aio_log_di partition(grass_date,process_date)
select 
     get_json_object(json_result,'$.flow_no')                                                                                            as flow_no      
    ,get_json_object(json_result,'$.trace_id')                                                                                           as trace_id       
    ,get_json_object(json_result,'$.customer_id')                                                                                        as customer_id    
    ,get_json_object(json_result,'$.app_id')                                                                                             as app_id         
    ,get_json_object(json_result,'$.service_id')                                                                                         as service_id     
    ,get_json_object(json_result,'$.service_name')                                                                                       as service_name   
    ,get_json_object(json_result,'$.api_method')                                                                                         as api_method     
    ,get_json_object(json_result,'$.req_time')                                                                                           as req_time       
    ,get_json_object(json_result,'$.rsp_time')                                                                                           as rsp_time 
    ,get_json_object(get_json_object(json_result,'$.req_data'),'$.ktp_no')                                                               as ktp_no 
    ,get_json_object(get_json_object(json_result,'$.req_data'),'$.msisdn')                                                               as msisdn 
    ,get_json_object(get_json_object(json_result,'$.req_data'),'$.shopee_uid')                                                           as shopee_uid 
    ,get_json_object(get_json_object(json_result,'$.req_data'),'$.gps_coordinate')                                                       as gps_coordinate
    ,get_json_object(get_json_object(json_result,'$.req_data'),'$.scenario')                                             as scenario         
    ,get_json_object(get_json_object(json_result,'$.req_data'),'$.product')                                                  as product
    ,get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_code')                                                             as biz_code
    ,get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_msg')                                                              as biz_msg 
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.score')                      as score
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.score_v3')                   as score_v3                    
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.hit_flag')                   as hit_flag 
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.list_type')                  as list_type      
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.hit_reason_code')                        as hit_reason_code
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.match_type')                 as match_type 
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.match_score')                as match_score 
    ,get_json_object(get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data'),'$.confidence_level')           as confidence_level 
    ,get_json_object(json_result,'$.call_source')                                                                                        as call_source       
    ,get_json_object(json_result,'$.subscribe_service_type')                                                                 as subscribe_service_type 
    ,get_json_object(json_result,'$.match_with')                                                                as match_with  
    ,get_json_object(json_result,'$.platform_user_id')                                                          as platform_user_id  
    ,get_json_object(json_result,'$.ktp_no_platform_user_id')                                                   as ktp_no_platform_user_id   
    ,get_json_object(json_result,'$.mobile_no_platform_user_id')                                                as mobile_no_platform_user_id     
    ,case when '${REGION}'='ID' then get_json_object(get_json_object(json_result,'$.tag'),'$.repeat_type') else get_json_object(json_result,'$.repeat_type') end as repeat_type    
    ,get_json_object(json_result,'$.idempotent_call_md5')                                                       as idempotent_call_md5    
    ,case when '${REGION}'='ID' then get_json_object(get_json_object(json_result,'$.tag'),'$.client_ip') else get_json_object(json_result,'$.client_ip') end as client_ip    
    ,case when '${REGION}'='ID' then get_json_object(get_json_object(json_result,'$.tag'),'$.sign') else get_json_object(json_result,'$.sign') end as sign    
    ,get_json_object(get_json_object(json_result,'$.rsp_data'),'$.biz_data')                                    as biz_data
    ,get_json_object(json_result, '$.rsp_data')                                                                 as rsp_data
    ,get_json_object(json_result, '$.req_data')                                                                 as req_data
    ,json_result                                                                                                as json_result
    ,to_date(format_time(cast(get_json_object(json_result, '$.req_time')/1000 as bigint),upper('${region}')))   as grass_date    
    ,dt                                                                                                         as process_date 
from (
    select 
        cast(unbase64(get_json_object(value,'$.Body')) as string) as json_result
        ,dt
    from risk.${region}_risk_tob_service_call_log_data__reg_continuous_s0_live
    where dt >=date_sub('${grass_date}',3)
    and dt <='${grass_date}'
) a 
;