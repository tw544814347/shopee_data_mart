
--jira: https://jira.shopee.io/browse/SPFDT-58121
--author: wei.tao@shopee.com
--date: 2025-12-04
--change log:
/*
    1.deployed by template in version1 for all 9 regions, note: DataType = 1 means tob model report datasource, need to obtained in filter condition.
*/


-- drop table if exists risk.dwd_risk_${reg}_tob_model_report_di;
CREATE TABLE if not exists risk.dwd_risk_${reg}_tob_model_report_di  (
    app_id string comment '',
    scene_id string comment '',
    flow_no string comment '',
    req_time string comment '',
    req_data string comment '',
    rsq_data string comment '',
    trace_id string comment '',
    url string comment ''
)
PARTITIONED BY ( 
    grass_date string comment 'req date(local)'
    ,process_date string comment 'DE ingestion date'
)    
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/dwd/dwd_risk_reg_tob_model_report_di/grass_region=${upper_region}'
;


-- msck repair table ${SCHEMA}.dwd_risk_${reg}_tob_model_report_di;
-- refresh table ${SCHEMA}.dwd_risk_${reg}_tob_model_report_di;


ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dwd_risk_${reg}_tob_model_report_di partition(grass_date, process_date)
select 
    app_id, 
    scene_id, 
    flow_no, 
    req_time,
    get_json_object(data_json,'$.Req') as req_data,
    get_json_object(data_json,'$.Resp') as rsq_data,
    get_json_object(data_json,'$.TraceID') as trace_id,
    get_json_object(data_json,'$.Url') as url,
    cast(date(format_time(req_time,UPPER('${reg}'))) as string) as grass_date,
    dt as process_date
from 
(
    select 
        get_json_object(value, '$.Header.AppID')      as app_id,
        get_json_object(value, '$.Header.SceneID')    as scene_id,
        get_json_object(value, '$.Header.FlowNo')     as flow_no,
        cast(get_json_object(value, '$.Header.ReqTime') as bigint) as req_time,
        cast(unbase64(get_json_object(value, '$.Data')) as string) as data_json,
        dt
    from ${SCHEMA}.${kafka_dump_hdfs_table}
    where get_json_object(value, '$.Header.DataType') = 1
        and dt >=date_sub('${grass_date}',1)
        and dt <=date_add('${grass_date}',1)
) tmp 