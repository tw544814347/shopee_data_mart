
-- show create table risk.ods__credit_risk_control_${region}_db__fe_strategy_rule_tab__df;
-- hdfs：${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_fe_strategy_rule_df

add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- DROP TABLE IF EXISTS risk.dwd_risk_${region}_credit_fe_strategy_rule_df;
-- CREATE TABLE risk.dwd_risk_${region}_credit_fe_strategy_rule_df
-- (
--     `id`             BIGINT   COMMENT '',
--     `name`           STRING   COMMENT '',
--     `description`    STRING   COMMENT '',
--     `level`          BIGINT   COMMENT '',
--     `metrics`        STRING   COMMENT '',
--     `expression`     STRING   COMMENT '',
--     `error_default`  STRING   COMMENT '',
--     `version`        BIGINT   COMMENT '',
--     `version_status` BIGINT   COMMENT '',
--     `status`         BIGINT   COMMENT '',
--     `category`       BIGINT   COMMENT '',
--     `creator`        STRING   COMMENT '',
--     `create_time`    STRING   COMMENT '',
--     `update_time`    STRING   COMMENT '',
--     -- `sub_category`   BIGINT   COMMENT '',
--     `_event`         STRING,
--     `grass_date`     STRING
-- )
-- USING orc
-- PARTITIONED BY (grass_date)
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region}_credit_fe_strategy_rule_df'
-- TBLPROPERTIES (
--     'orc.stripe.size'         = '268435456',
--     'orc.compress'            = 'zstd'
-- );


INSERT OVERWRITE TABLE risk.dwd_risk_${region}_credit_fe_strategy_rule_df
SELECT
    id,
    name,
    description,
    level,
    metrics,
    expression,
    error_default,
    version,
    version_status,
    status,
    category,
    creator,
    format_time(create_time, UPPER('${region}')) as create_time,
    format_time(update_time, UPPER('${region}')) as update_time,
    -- sub_category,
    _event,
    grass_date
FROM risk.ods__credit_risk_control_${region}_db__fe_strategy_rule_tab__df
WHERE grass_date = '${ds}';