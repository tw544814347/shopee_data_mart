-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-12-04
-- Theme Domain:        Income Prediction Backtesting
-- Data Granularity:    task_id, ktp_no, phone_no, backtest_date, grass_date
-- Description:         Income prediction backtesting for KTP and Phone
--                      Retrieve predicted_label and predicted_label_posthoc from KTP or Phone info
--                      Support SHA256/Base64 hash matching with fallback to Phone when KTP not available
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-12-04 - chengguo.liu - 修复 income prediction backtesting逻辑 - Jira: https://jira.shopee.io/browse/SPFDT-58191
--  2026-04-01 taowei 新增 id  方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
-- =============================================================================

-- drop table if exists ${SCHEMA}.ads_risk_${region}_income_prediction_ktp_phone_backtesting_info_rt;
create external table if not exists ${SCHEMA}.ads_risk_${region}_income_prediction_ktp_phone_backtesting_info_rt
(
    ktp_no string comment 'ktp number (raw, sha256 or base64)'
    ,phone_no string comment 'phone number (raw, sha256 or base64)'
    ,backtest_date string comment 'backtest date yyyy-MM-dd'
    ,predicted_label_posthoc string comment 'predicted label posthoc from ktp or phone info'
    ,predicted_label string comment 'predicted label from ktp or phone info'
    ,is_ktp_match int comment '1 match, 0 no-match'
    ,is_phone_match int comment '1 match, 0 no-match'
    ,id bigint comment 'id'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
    ,task_id string comment 'task_id'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${region}_income_prediction_ktp_phone_backtesting_info_rt';
-- msck repair table ${SCHEMA}.ads_risk_${region}_income_prediction_ktp_phone_backtesting_info_rt;


uncache table if exists t_backtesting_task_id_list;
cache table t_backtesting_task_id_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    t1.task_id
    ,t2.id
    ,t1.task_status
    ,t1.hash_method
    ,t2.ktp_no
    ,t2.phone_no
    ,t2.backtest_date
from
(
    select
        task_id
        ,task_status
        ,lower(hash_method) as hash_method
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_tab__spark
    where task_status = 5
    and service_name_list in ('IncomePrediction', 'IncomePredictionPosthoc')
) t1
left join
(
    select
        task_id
        ,id
        ,get_json_object(task_data, '$.ktp_no') as ktp_no
        ,get_json_object(task_data, '$.msisdn') as phone_no
        ,get_json_object(task_data, '$.backtest_date') as backtest_date
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_data_tab__spark
) t2
on t1.task_id = t2.task_id
left join
(
    select
        task_id
    from ${SCHEMA}.ads_risk_${region}_income_prediction_ktp_phone_backtesting_info_rt
    where grass_date = '${ds}'
    group by task_id
) t3
on t1.task_id = t3.task_id
where t3.task_id is null
;

uncache table if exists t_backtesting_backtest_date_list;
cache table t_backtesting_backtest_date_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    backtest_date
from t_backtesting_task_id_list
group by backtest_date
;

--明文撞库
create or replace temporary view t_backtesting_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.ktp_no
    ,t1.phone_no
    ,t1.backtest_date
    ,coalesce(t2.predicted_label_posthoc, t3.predicted_label_posthoc) as predicted_label_posthoc
    ,coalesce(t2.predicted_label, t3.predicted_label) as predicted_label
    ,if(t2.ktp_no is null, 0, 1) as is_ktp_match
    ,if(t3.phone_no is null, 0, 1) as is_phone_match
from (
    select
        task_id
        ,id
        ,hash_method
        ,ktp_no
        ,phone_no
        ,backtest_date
    from t_backtesting_task_id_list
    where coalesce(hash_method, '') = ''
) t1
left join (
    select
        ktp_no
        ,predicted_label_posthoc
        ,predicted_label
        ,grass_date
    from risk.ads_2bscore_id_user_ktp_info_df
    where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
) t2 on t1.backtest_date = t2.grass_date
and t1.ktp_no = t2.ktp_no
left join (
    select
        phone_no
        ,predicted_label_posthoc
        ,predicted_label
        ,grass_date
    from risk.ads_2bscore_id_user_phone_info_df
    where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
) t3 on t1.backtest_date = t3.grass_date
and t1.phone_no = t3.phone_no
;

--sha256撞库
create or replace temporary view t_backtesting_sha256_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.ktp_no
    ,t1.phone_no
    ,t1.backtest_date
    ,coalesce(t2.predicted_label_posthoc, t3.predicted_label_posthoc) as predicted_label_posthoc
    ,coalesce(t2.predicted_label, t3.predicted_label) as predicted_label
    ,if(t2.ktp_no_sha256 is null, 0, 1) as is_ktp_match
    ,if(t3.phone_no_sha256 is null, 0, 1) as is_phone_match
from (
    select
        task_id
        ,id
        ,hash_method
        ,ktp_no
        ,phone_no
        ,backtest_date
    from t_backtesting_task_id_list
    where hash_method = 'sha256'
) t1
left join (
    select
        ktp_no_sha256
        ,predicted_label_posthoc
        ,predicted_label
        ,grass_date
    from risk.ads_2bscore_id_user_ktp_info_df
    where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
) t2 on t1.backtest_date = t2.grass_date
and t1.ktp_no = t2.ktp_no_sha256
left join (
    select
        phone_no_sha256
        ,predicted_label_posthoc
        ,predicted_label
        ,grass_date
    from risk.ads_2bscore_id_user_phone_info_df
    where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
) t3 on t1.backtest_date = t3.grass_date
and t1.phone_no = t3.phone_no_sha256
;

--base64撞库
create or replace temporary view t_backtesting_base64_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.ktp_no
    ,t1.phone_no
    ,t1.backtest_date
    ,coalesce(t2.predicted_label_posthoc, t3.predicted_label_posthoc) as predicted_label_posthoc
    ,coalesce(t2.predicted_label, t3.predicted_label) as predicted_label
    ,if(t2.ktp_no_base64 is null, 0, 1) as is_ktp_match
    ,if(t3.phone_no_base64 is null, 0, 1) as is_phone_match
from (
    select
        task_id
        ,id
        ,hash_method
        ,ktp_no
        ,phone_no
        ,backtest_date
    from t_backtesting_task_id_list
    where hash_method = 'base64'
) t1
left join (
    select
        ktp_no_base64
        ,predicted_label_posthoc
        ,predicted_label
        ,grass_date
    from risk.ads_2bscore_id_user_ktp_info_df
    where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
) t2 on t1.backtest_date = t2.grass_date
and t1.ktp_no = t2.ktp_no_base64
left join (
    select
        phone_no_base64
        ,predicted_label_posthoc
        ,predicted_label
        ,grass_date
    from risk.ads_2bscore_id_user_phone_info_df
    where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
) t3 on t1.backtest_date = t3.grass_date
and t1.phone_no = t3.phone_no_base64
;

insert overwrite ${SCHEMA}.ads_risk_${region}_income_prediction_ktp_phone_backtesting_info_rt partition (grass_date, task_id)
select
    ktp_no
    ,phone_no
    ,backtest_date
    ,predicted_label_posthoc
    ,predicted_label
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_task_result
union all
select
    ktp_no
    ,phone_no
    ,backtest_date
    ,predicted_label_posthoc
    ,predicted_label
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_sha256_task_result
union all
select
    ktp_no
    ,phone_no
    ,backtest_date
    ,predicted_label_posthoc
    ,predicted_label
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_base64_task_result
;

