drop table if exists ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di;

create external table if not exists ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di
(
    shopeepay_userid string comment ''
    ,workflow_flow_no string comment ''
    ,verify_method string comment ''
    ,verify_result int comment ''
    ,lc_fail_reason string comment 'liveness check fail reason'
    ,device_fingerprint string comment 'device fingerprint'
    ,szdf string comment 'SZ device fingerprint'
    ,create_time string comment 'work flow create time'
    ,update_time string comment 'work flow update time'
) 
partitioned by
(
    grass_date string comment 'create_time,YYYY-MM-dd'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dwd/ads_product_risk_region_af_workflow_2fa_di/grass_region=${region_upper}'
;

msck repair table ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di
;

