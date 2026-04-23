drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- drop table if exists ${SCHEMA}.dwd_risk_br_openfinance_record_df;
create external table if not exists ${SCHEMA}.dwd_risk_br_openfinance_record_df (
    flow_no             string comment 'flow no'
    ,consent_id         string comment 'consent id'
    ,platform_user_id   string comment 'platform_user_id'
    ,url                string comment ''
    ,req_data           string comment ''
    ,resp_raw_data      string comment 'openfinance record'
    ,req_time           string comment 'local time'
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_openfinance_record_df/grass_region=BR';
-- msck repair table ${SCHEMA}.dwd_risk_br_openfinance_record_df;

-- 需要一张新的dwd表包括consent_id + platfomr_user_id + url + resp_raw_data
insert overwrite table ${SCHEMA}.dwd_risk_br_openfinance_record_df partition(grass_date='${ds}')
select  get_json_object(header_data, '$.FlowNo')                    as flow_no,                  
        get_json_object(req_data, '$.ConsentId')                    as consent_id,
        get_json_object(header_data, '$.PlatformUserId')            as platform_user_id,
        get_json_object(req_data, '$.Url') AS url,
        req_data,
        resp_raw_data,
        format_time(create_time, '${grass_region}')                 as req_time
from    risk.ods__credit_risk_datafetch_br_db__identity_data_history_tab__df
where   grass_date = '${ds}'
AND data_source_name = 'Openfinance'
