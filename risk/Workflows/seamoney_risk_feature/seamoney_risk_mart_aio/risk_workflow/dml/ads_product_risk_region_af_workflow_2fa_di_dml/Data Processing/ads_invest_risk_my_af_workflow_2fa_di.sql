-- drop table if exists ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di;

-- create external table if not exists ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di
-- (
--     shopeepay_userid string comment ''
--     ,workflow_flow_no string comment ''
--     ,verify_method string comment ''
--     ,verify_result int comment ''
--     ,lc_fail_reason string comment 'liveness check fail reason'
--     ,device_fingerprint string comment 'device fingerprint'
--     ,szdf string comment 'SZ device fingerprint'
--     ,create_time string comment 'work flow create time'
--     ,update_time string comment 'work flow update time'
-- ) 
-- partitioned by
-- (
--     grass_date string comment 'create_time,YYYY-MM-dd'
-- )
-- stored as orc
-- tblproperties
-- (
--     "orc.compress" = "zstd"
-- )
-- location '${HDFS_PATH}/risk_mart/dwd/ads_${product}_risk_region_af_workflow_2fa_di/grass_region=${region_upper}'
-- ;

-- msck repair table ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di
-- ;

WITH
dwd_workflow AS (
    SELECT    
            id,
            get_json_object(
                cast(unbase64(get_json_object(input, '$.Params')) AS string), 
                '$.CommonHeader.shopeepay_user_id'
            ) AS shopeepay_userid,
            get_json_object(
                cast(unbase64(get_json_object(input, '$.Params')) AS string),
                '$.CommonHeader.extension_process_data.sz_dfp.device_id'
            ) AS szdf,
            get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string),
                '$.CommonHeader.device_fingerprint') as device_fingerprint,
            flow_no
                , create_time
                , update_time
    FROM      risk.dwd_risk_${region_lower}_af_${product}_workflow_di
    where grass_date = '${grass_date}'

),
dwd_workflow_step AS (
    SELECT    
            *
    FROM      risk.dwd_risk_${region_lower}_af_${product}_workflow_step_di
    WHERE    (lower(output) LIKE '%return_result_standard_reject%' 
                OR     lower(output) LIKE '%return_result_standard_pass%')
            and grass_date = '${grass_date}'
)

INSERT OVERWRITE TABLE risk.ads_${product}_risk_${region_lower}_af_workflow_2fa_di PARTITION(grass_date)

SELECT    
          t1.shopeepay_userid,
          t1.flow_no          AS workflow_flow_no,
          CASE 
              WHEN lower(t2.output) LIKE '%liveness_check_init%' THEN 'LC'
              WHEN lower(t2.output) LIKE '%otp_init%'           THEN 'OTP'
              ELSE NULL 
          END                 AS verify_method,
          CASE 
              WHEN lower(t2.output) LIKE '%return_result_standard_reject%' THEN 0
              WHEN lower(t2.output) LIKE '%return_result_standard_pass%'   THEN 1 
              ELSE NULL 
          END                 AS verify_result,
        case when lower(t2.output) like '%liveness_check_init%'
                and lower(t2.output) like '%return_result_standard_reject%'
                and lower(t2.output) not like '%antifraud_60001%'
            then 'lc_timeout'
                when lower(t2.output) like '%liveness_check_init%'
                and lower(t2.output) like '%return_result_standard_reject%'
                and lower(t2.output) like '%antifraud_60001%'
            then 'lc_model_reject'
        else null end as lc_fail_reason
        ,t1.device_fingerprint
        ,t1.szdf
        ,t1.create_time
        ,t1.update_time
        ,date(t2.create_time) AS grass_date
FROM      dwd_workflow        AS t1
JOIN      dwd_workflow_step   AS t2 ON t1.id = t2.wfid
;
