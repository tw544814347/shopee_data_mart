-- show create table risk.ods__credit_risk_control_${region}_db__strategy_to_l3_group_tab__df;
-- hdfs：${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_strategy_to_l3_group_df
add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- DROP TABLE IF EXISTS risk.dwd_risk_${region}_credit_strategy_to_l3_group_df;
-- CREATE TABLE risk.dwd_risk_${region}_credit_strategy_to_l3_group_df
-- (
--   `id` DECIMAL(20, 0) COMMENT '',
--   `strategy_id` DECIMAL(20, 0) COMMENT '',
--   `l3_group_id` DECIMAL(20, 0) COMMENT '',
--   `relate_status` BIGINT COMMENT '',
--   `version` BIGINT COMMENT '',
--   `create_time` STRING COMMENT '',
--   `update_time` STRING COMMENT '',
--   `_event` STRING,
--   `grass_date` STRING
-- )
-- USING orc 
-- PARTITIONED BY (grass_date) 
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_strategy_to_l3_group_df' 
-- TBLPROPERTIES (
--   'orc.stripe.size' = '268435456',
--   'orc.compress' = 'zstd'
-- )
-- ;

INSERT OVERWRITE TABLE risk.dwd_risk_${region}_credit_strategy_to_l3_group_df
SELECT
    id,
    strategy_id,
    l3_group_id,
    relate_status,
    version,
    format_time(create_time, UPPER('${region}')) as create_time,
    format_time(update_time, UPPER('${region}')) as update_time,
    _event,
    grass_date
FROM risk.ods__credit_risk_control_${region}_db__strategy_to_l3_group_tab__df
WHERE grass_date = '${ds}';