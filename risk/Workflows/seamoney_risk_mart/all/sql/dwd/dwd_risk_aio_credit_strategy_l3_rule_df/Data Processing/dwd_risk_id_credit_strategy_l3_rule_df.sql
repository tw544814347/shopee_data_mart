
-- show create table risk.ods__credit_risk_control_${region}_db__strategy_l3_rule_tab__df;
-- hdfs：${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_strategy_l3_rule_df
add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- DROP TABLE IF EXISTS risk.dwd_risk_${region}_credit_strategy_l3_rule_df;
-- CREATE TABLE risk.dwd_risk_${region}_credit_strategy_l3_rule_df
-- (
--     `id` BIGINT COMMENT '',
--     `ori_id` BIGINT COMMENT '',
--     `l3_rule_name` STRING COMMENT '',
--     `l3_rule_script` STRING COMMENT '',
--     `l2_ruls` STRING COMMENT '',
--     `expression` STRING COMMENT '',
--     `extention` STRING COMMENT '',
--     `version` BIGINT COMMENT '',
--     `description` STRING COMMENT '',
--     `status` BIGINT COMMENT '',
--     `creator` STRING COMMENT '',
--     `create_time` STRING COMMENT '',
--     `update_time` STRING COMMENT '',
--     `category` BIGINT COMMENT '',
--     `version_status` BIGINT COMMENT '',
--     `error_default` STRING COMMENT '',
--     `_event` STRING,
--     `grass_date` STRING
-- )
-- USING orc
-- PARTITIONED BY (`grass_date`)
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_strategy_l3_rule_df'
-- TBLPROPERTIES (
--     'orc.stripe.size' = '268435456',
--     'orc.compress' = 'zstd'
-- );


insert overwrite table risk.dwd_risk_${region}_credit_strategy_l3_rule_df 
SELECT
    id,
    ori_id,
    l3_rule_name,
    l3_rule_script,
    l2_ruls,
    expression,
    extention,
    version,
    description,
    status,
    creator,
    format_time(create_time, UPPER('${region}')) as create_time,
    format_time(update_time, UPPER('${region}')) as update_time,
    category,
    version_status,
    error_default,
    _event,
    grass_date
FROM risk.ods__credit_risk_control_${region}_db__strategy_l3_rule_tab__df
WHERE grass_date = '${ds}';