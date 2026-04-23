-- drop 表改 view 

drop table if exists risk.dwd_risk_${region}_af_kafka_workflow_step_di;

-- create external table risk.dwd_risk_${region}_af_kafka_workflow_step_di
-- (
--     id                     bigint               comment ''
--     ,wfid                  string               comment '实际上是flow_no'
--     ,flow_no               string               comment ''
--     ,platform_user_id      string               comment ''
--     ,step                  string               comment ''
--     ,status                bigint               comment ''
--     ,input                 string               comment ''
--     ,output                string               comment ''
--     ,next                  string               comment ''
--     ,version               bigint               comment ''
--     ,create_time           bigint               comment ''
--     ,update_time           bigint               comment ''
--     ,req_type              string               comment ''
-- ) PARTITIONED BY(
--         product_name string comment 'credit or shopeepay'
--         ,grass_date string comment 'create_time,YYYY-MM-dd')  
-- stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_af_kafka_workflow_step_di/grass_region=${upper_region}'
--     ;
--     MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_${region}_af_kafka_workflow_step_di;