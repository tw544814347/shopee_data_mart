
-- show create table risk.ods__credit_risk_control_${region}_db__strategy_l3_rule_group_tab__df;
-- hdfs：${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_strategy_l3_rule_group_df
add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- DROP TABLE IF EXISTS risk.dwd_risk_${region}_credit_strategy_l3_rule_group_df;
-- CREATE TABLE risk.dwd_risk_${region}_credit_strategy_l3_rule_group_df
-- (
--   `id` BIGINT COMMENT '',
--   `ori_id` BIGINT COMMENT '',
--   `group_name` STRING COMMENT '',
--   `group_script` STRING COMMENT '',
--   `l3_rules` STRING COMMENT '',
--   `default_result_id` BIGINT COMMENT '',
--   `version` BIGINT COMMENT '',
--   `status` BIGINT COMMENT '',
--   `description` STRING COMMENT '',
--   `creator` STRING COMMENT '',
--   `create_time` STRING COMMENT '',
--   `update_time` STRING COMMENT '',
--   `category` BIGINT COMMENT '',
--   `version_status` BIGINT COMMENT '',
--   `list_config` STRING COMMENT '',
--   `serial_type` BIGINT COMMENT '',
--   `app_id` STRING COMMENT '',
--   `scene_id` BIGINT COMMENT '',
--   `strategy_type` BIGINT COMMENT '',
--   `group_script_v2` STRING COMMENT '',
--   `rets` STRING COMMENT '',
--   `_event` STRING,
--   `grass_date` STRING
-- )
-- USING orc 
-- PARTITIONED BY (grass_date) 
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_strategy_l3_rule_group_df' 
-- TBLPROPERTIES (
--   'orc.stripe.size' = '268435456',
--   'orc.compress' = 'zstd'
-- );


INSERT OVERWRITE TABLE risk.dwd_risk_${region}_credit_strategy_l3_rule_group_df
SELECT
    id,
    ori_id,
    group_name,
    group_script,
    l3_rules,
    default_result_id,
    version,
    status,
    description,
    creator,
    format_time(create_time, UPPER('${region}')) as create_time,
    format_time(update_time, UPPER('${region}')) as update_time,
    category,
    version_status,
    list_config,
    serial_type,
    app_id,
    scene_id,
    strategy_type,
    group_script_v2,
    rets,
    _event,
    grass_date
FROM risk.ods__credit_risk_control_${region}_db__strategy_l3_rule_group_tab__df
WHERE grass_date = '${ds}';