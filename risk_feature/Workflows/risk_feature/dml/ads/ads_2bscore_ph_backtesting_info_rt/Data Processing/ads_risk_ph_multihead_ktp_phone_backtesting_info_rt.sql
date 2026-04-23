-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-12-04
-- Theme Domain:        Risk Topic MultiHead Backtesting
-- Data Granularity:    task_id, id_type, id_no, phone_no, backtest_date, grass_date
-- Description:         MultiHead KTP and Phone backtesting result table         
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-12-04 - chengguo.liu - 初始化 - Jira: https://jira.shopee.io/browse/SPFDT-57525
--  2026-04-01 taowei 新增 id 方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
-- =============================================================================

add jar hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-sha-256.jar;
create or replace temporary function sha256 as 'com.shopee.udf.RiskSha256';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
 
-- drop table if exists ${SCHEMA}.ads_risk_ph_multihead_ktp_phone_backtesting_info_rt;
create external table if not exists ${SCHEMA}.ads_risk_ph_multihead_ktp_phone_backtesting_info_rt
(
    create_date string comment 'task create date'
    ,backtest_date string comment 'backtesting date'
    ,id_type string comment 'id type'
    ,id_no string comment 'id number'
    ,phone_no string comment 'phone number'
    ,dob string comment 'date of birth'
    ,name string comment 'user name'
    ,mh_query_count_7d bigint comment 'multihead query count in 7 days'
    ,mh_query_count_14d bigint comment 'multihead query count in 14 days'
    ,mh_query_count_30d bigint comment 'multihead query count in 30 days'
    ,mh_query_count_90d bigint comment 'multihead query count in 90 days'
    ,mh_query_count_180d bigint comment 'multihead query count in 180 days'
    ,mh_query_count_360d bigint comment 'multihead query count in 360 days'
    ,mh_query_count_720d bigint comment 'multihead query count in 720 days'
    ,mh_query_count_1440d bigint comment 'multihead query count in 1440 days'
    ,mh_query_hr_count_7d bigint comment 'multihead high risk query count in 7 days'
    ,mh_query_hr_count_14d bigint comment 'multihead high risk query count in 14 days'
    ,mh_query_hr_count_30d bigint comment 'multihead high risk query count in 30 days'
    ,mh_query_hr_count_90d bigint comment 'multihead high risk query count in 90 days'
    ,mh_query_hr_count_180d bigint comment 'multihead high risk query count in 180 days'
    ,mh_query_hr_count_360d bigint comment 'multihead high risk query count in 360 days'
    ,mh_query_hr_count_720d bigint comment 'multihead high risk query count in 720 days'
    ,mh_query_hr_count_1440d bigint comment 'multihead high risk query count in 1440 days'
    ,mh_latest_query_to_now_days bigint comment 'days from latest query to now'
    ,mh_first_query_to_now_days bigint comment 'days from first query to now'
    ,mh_consecutive_query_day_min_7d bigint comment 'min consecutive query days in 7 days'
    ,mh_consecutive_query_day_min_14d bigint comment 'min consecutive query days in 14 days'
    ,mh_consecutive_query_day_min_30d bigint comment 'min consecutive query days in 30 days'
    ,mh_consecutive_query_day_min_90d bigint comment 'min consecutive query days in 90 days'
    ,mh_consecutive_query_day_min_180d bigint comment 'min consecutive query days in 180 days'
    ,mh_consecutive_query_day_min_360d bigint comment 'min consecutive query days in 360 days'
    ,mh_consecutive_query_day_min_720d bigint comment 'min consecutive query days in 720 days'
    ,id bigint comment 'id 用于排序'
)
comment 'Tag:risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
    ,task_id string comment 'backtesting task id'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/ads/ads_risk_ph_multihead_ktp_phone_backtesting_info_rt';
-- msck repair table ${SCHEMA}.ads_risk_ph_multihead_ktp_phone_backtesting_info_rt;

drop table if exists risk_feature.tmp_t_backtesting_task_id_list;
create table risk_feature.tmp_t_backtesting_task_id_list stored as orc as
select
    t1.task_id
    ,t2.id
    ,t1.task_status
    ,t1.create_date
    ,t1.hash_method
    ,get_json_object(t2.task_data, '$.id_type') as id_type
    ,get_json_object(t2.task_data, '$.id_no') as id_no
    ,get_json_object(t2.task_data, '$.msisdn') as phone_no
    ,get_json_object(t2.task_data, '$.backtest_date') as backtest_date
    ,get_json_object(t2.task_data, '$.dob') as dob
    ,get_json_object(t2.task_data, '$.name') as name
from
(
    select
        task_id
        ,task_status
        ,format_time (cast(create_time / 1000 as bigint), 'PH') as create_date
        ,lower(hash_method) as hash_method
    from risk.view__credit_risk_open_platform_ph_db__auto_backtesting_task_tab__spark
    where task_status = 5
    and service_name_list = 'MultiHead'
) t1
left join
(
    select
        task_id
        ,task_data
        ,id
    from risk.view__credit_risk_open_platform_ph_db__auto_backtesting_task_data_tab__spark
) t2
on t1.task_id = t2.task_id
left join
(
    select
        task_id
    from ${SCHEMA}.ads_risk_ph_multihead_ktp_phone_backtesting_info_rt
    where grass_date = '${ds}'
    group by task_id
) t3
on t1.task_id = t3.task_id
where t3.task_id is null
;

--明文backtesting
create or replace temporary view t_backtesting_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.create_date
    ,t1.backtest_date
    ,t1.id_type
    ,t1.id_no
    ,t1.phone_no
    ,t1.dob
    ,t1.name
    ,coalesce(t3.mh_query_count_7d, t4.mh_query_count_7d) as mh_query_count_7d
    ,coalesce(t3.mh_query_count_14d, t4.mh_query_count_14d) as mh_query_count_14d
    ,coalesce(t3.mh_query_count_30d, t4.mh_query_count_30d) as mh_query_count_30d
    ,coalesce(t3.mh_query_count_90d, t4.mh_query_count_90d) as mh_query_count_90d
    ,coalesce(t3.mh_query_count_180d, t4.mh_query_count_180d) as mh_query_count_180d
    ,coalesce(t3.mh_query_count_360d, t4.mh_query_count_360d) as mh_query_count_360d
    ,coalesce(t3.mh_query_count_720d, t4.mh_query_count_720d) as mh_query_count_720d
    ,coalesce(t3.mh_query_count_1440d, t4.mh_query_count_1440d) as mh_query_count_1440d
    ,coalesce(t3.mh_query_hr_count_7d, t4.mh_query_hr_count_7d) as mh_query_hr_count_7d
    ,coalesce(t3.mh_query_hr_count_14d, t4.mh_query_hr_count_14d) as mh_query_hr_count_14d
    ,coalesce(t3.mh_query_hr_count_30d, t4.mh_query_hr_count_30d) as mh_query_hr_count_30d
    ,coalesce(t3.mh_query_hr_count_90d, t4.mh_query_hr_count_90d) as mh_query_hr_count_90d
    ,coalesce(t3.mh_query_hr_count_180d, t4.mh_query_hr_count_180d) as mh_query_hr_count_180d
    ,coalesce(t3.mh_query_hr_count_360d, t4.mh_query_hr_count_360d) as mh_query_hr_count_360d
    ,coalesce(t3.mh_query_hr_count_720d, t4.mh_query_hr_count_720d) as mh_query_hr_count_720d
    ,coalesce(t3.mh_query_hr_count_1440d, t4.mh_query_hr_count_1440d) as mh_query_hr_count_1440d
    ,coalesce(t3.mh_latest_query_to_now_days, t4.mh_latest_query_to_now_days) as mh_latest_query_to_now_days
    ,coalesce(t3.mh_first_query_to_now_days, t4.mh_first_query_to_now_days) as mh_first_query_to_now_days
    ,coalesce(t3.mh_consecutive_query_day_min_7d, t4.mh_consecutive_query_day_min_7d) as mh_consecutive_query_day_min_7d
    ,coalesce(t3.mh_consecutive_query_day_min_14d, t4.mh_consecutive_query_day_min_14d) as mh_consecutive_query_day_min_14d
    ,coalesce(t3.mh_consecutive_query_day_min_30d, t4.mh_consecutive_query_day_min_30d) as mh_consecutive_query_day_min_30d
    ,coalesce(t3.mh_consecutive_query_day_min_90d, t4.mh_consecutive_query_day_min_90d) as mh_consecutive_query_day_min_90d
    ,coalesce(t3.mh_consecutive_query_day_min_180d, t4.mh_consecutive_query_day_min_180d) as mh_consecutive_query_day_min_180d
    ,coalesce(t3.mh_consecutive_query_day_min_360d, t4.mh_consecutive_query_day_min_360d) as mh_consecutive_query_day_min_360d
    ,coalesce(t3.mh_consecutive_query_day_min_720d, t4.mh_consecutive_query_day_min_720d) as mh_consecutive_query_day_min_720d
from (
    select
        task_id
        ,id
        ,create_date
        ,backtest_date
        ,id_type
        ,id_no
        ,phone_no
        ,dob
        ,name
    from risk_feature.tmp_t_backtesting_task_id_list
    where coalesce(hash_method, '') = ''
) t1
    left join (
        select
            grass_date
            ,id_type
            ,id_no
            ,mh_query_count_7d
            ,mh_query_count_14d
            ,mh_query_count_30d
            ,mh_query_count_90d
            ,mh_query_count_180d
            ,mh_query_count_360d
            ,mh_query_count_720d
            ,mh_query_count_1440d
            ,mh_query_hr_count_7d
            ,mh_query_hr_count_14d
            ,mh_query_hr_count_30d
            ,mh_query_hr_count_90d
            ,mh_query_hr_count_180d
            ,mh_query_hr_count_360d
            ,mh_query_hr_count_720d
            ,mh_query_hr_count_1440d
            ,mh_latest_query_to_now_days
            ,mh_first_query_to_now_days
            ,mh_consecutive_query_day_min_7d
            ,mh_consecutive_query_day_min_14d
            ,mh_consecutive_query_day_min_30d
            ,mh_consecutive_query_day_min_90d
            ,mh_consecutive_query_day_min_180d
            ,mh_consecutive_query_day_min_360d
            ,mh_consecutive_query_day_min_720d
        from risk.dws_risk_ph_ktp_multiloan_df
        where coalesce(id_no, '') <> ''  -- 右表过滤空值，避免数据倾斜
    ) t3 on t1.backtest_date = t3.grass_date
    and t1.id_type = t3.id_type 
    and t1.id_no = t3.id_no
    and coalesce(t1.id_no, '') <> ''  -- 左表空值不参与JOIN
    left join (
        select
            grass_date
            ,phone as phone_no
            ,mh_query_count_7d
            ,mh_query_count_14d
            ,mh_query_count_30d
            ,mh_query_count_90d
            ,mh_query_count_180d
            ,mh_query_count_360d
            ,mh_query_count_720d
            ,mh_query_count_1440d
            ,mh_query_hr_count_7d
            ,mh_query_hr_count_14d
            ,mh_query_hr_count_30d
            ,mh_query_hr_count_90d
            ,mh_query_hr_count_180d
            ,mh_query_hr_count_360d
            ,mh_query_hr_count_720d
            ,mh_query_hr_count_1440d
            ,mh_latest_query_to_now_days
            ,mh_first_query_to_now_days
            ,mh_consecutive_query_day_min_7d
            ,mh_consecutive_query_day_min_14d
            ,mh_consecutive_query_day_min_30d
            ,mh_consecutive_query_day_min_90d
            ,mh_consecutive_query_day_min_180d
            ,mh_consecutive_query_day_min_360d
            ,mh_consecutive_query_day_min_720d
        from risk.dws_risk_ph_phone_multiloan_df
        where coalesce(phone, '') <> ''  -- 右表过滤空值，避免数据倾斜
    ) t4 on t1.backtest_date = t4.grass_date
    and t1.phone_no = t4.phone_no
    and coalesce(t1.phone_no, '') <> ''  -- 左表空值不参与JOIN
;

--sha256撞库
create or replace temporary view t_backtesting_sha256_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.create_date
    ,t1.backtest_date
    ,t1.id_type
    ,t1.id_no
    ,t1.phone_no
    ,t1.dob
    ,t1.name
    ,coalesce(t3.mh_query_count_7d, t4.mh_query_count_7d) as mh_query_count_7d
    ,coalesce(t3.mh_query_count_14d, t4.mh_query_count_14d) as mh_query_count_14d
    ,coalesce(t3.mh_query_count_30d, t4.mh_query_count_30d) as mh_query_count_30d
    ,coalesce(t3.mh_query_count_90d, t4.mh_query_count_90d) as mh_query_count_90d
    ,coalesce(t3.mh_query_count_180d, t4.mh_query_count_180d) as mh_query_count_180d
    ,coalesce(t3.mh_query_count_360d, t4.mh_query_count_360d) as mh_query_count_360d
    ,coalesce(t3.mh_query_count_720d, t4.mh_query_count_720d) as mh_query_count_720d
    ,coalesce(t3.mh_query_count_1440d, t4.mh_query_count_1440d) as mh_query_count_1440d
    ,coalesce(t3.mh_query_hr_count_7d, t4.mh_query_hr_count_7d) as mh_query_hr_count_7d
    ,coalesce(t3.mh_query_hr_count_14d, t4.mh_query_hr_count_14d) as mh_query_hr_count_14d
    ,coalesce(t3.mh_query_hr_count_30d, t4.mh_query_hr_count_30d) as mh_query_hr_count_30d
    ,coalesce(t3.mh_query_hr_count_90d, t4.mh_query_hr_count_90d) as mh_query_hr_count_90d
    ,coalesce(t3.mh_query_hr_count_180d, t4.mh_query_hr_count_180d) as mh_query_hr_count_180d
    ,coalesce(t3.mh_query_hr_count_360d, t4.mh_query_hr_count_360d) as mh_query_hr_count_360d
    ,coalesce(t3.mh_query_hr_count_720d, t4.mh_query_hr_count_720d) as mh_query_hr_count_720d
    ,coalesce(t3.mh_query_hr_count_1440d, t4.mh_query_hr_count_1440d) as mh_query_hr_count_1440d
    ,coalesce(t3.mh_latest_query_to_now_days, t4.mh_latest_query_to_now_days) as mh_latest_query_to_now_days
    ,coalesce(t3.mh_first_query_to_now_days, t4.mh_first_query_to_now_days) as mh_first_query_to_now_days
    ,coalesce(t3.mh_consecutive_query_day_min_7d, t4.mh_consecutive_query_day_min_7d) as mh_consecutive_query_day_min_7d
    ,coalesce(t3.mh_consecutive_query_day_min_14d, t4.mh_consecutive_query_day_min_14d) as mh_consecutive_query_day_min_14d
    ,coalesce(t3.mh_consecutive_query_day_min_30d, t4.mh_consecutive_query_day_min_30d) as mh_consecutive_query_day_min_30d
    ,coalesce(t3.mh_consecutive_query_day_min_90d, t4.mh_consecutive_query_day_min_90d) as mh_consecutive_query_day_min_90d
    ,coalesce(t3.mh_consecutive_query_day_min_180d, t4.mh_consecutive_query_day_min_180d) as mh_consecutive_query_day_min_180d
    ,coalesce(t3.mh_consecutive_query_day_min_360d, t4.mh_consecutive_query_day_min_360d) as mh_consecutive_query_day_min_360d
    ,coalesce(t3.mh_consecutive_query_day_min_720d, t4.mh_consecutive_query_day_min_720d) as mh_consecutive_query_day_min_720d
from (
    select
        task_id
        ,id
        ,create_date
        ,backtest_date
        ,id_type
        ,id_no
        ,phone_no
        ,dob
        ,name
    from risk_feature.tmp_t_backtesting_task_id_list
    where hash_method = 'sha256'
) t1
    left join (
        select
            grass_date
            ,id_type
            ,id_no
            ,mh_query_count_7d
            ,mh_query_count_14d
            ,mh_query_count_30d
            ,mh_query_count_90d
            ,mh_query_count_180d
            ,mh_query_count_360d
            ,mh_query_count_720d
            ,mh_query_count_1440d
            ,mh_query_hr_count_7d
            ,mh_query_hr_count_14d
            ,mh_query_hr_count_30d
            ,mh_query_hr_count_90d
            ,mh_query_hr_count_180d
            ,mh_query_hr_count_360d
            ,mh_query_hr_count_720d
            ,mh_query_hr_count_1440d
            ,mh_latest_query_to_now_days
            ,mh_first_query_to_now_days
            ,mh_consecutive_query_day_min_7d
            ,mh_consecutive_query_day_min_14d
            ,mh_consecutive_query_day_min_30d
            ,mh_consecutive_query_day_min_90d
            ,mh_consecutive_query_day_min_180d
            ,mh_consecutive_query_day_min_360d
            ,mh_consecutive_query_day_min_720d
        from risk.dws_risk_ph_ktp_multiloan_df
        where coalesce(id_no, '') <> ''  -- 右表过滤空值，避免数据倾斜
    ) t3 on t1.backtest_date = t3.grass_date
    and t1.id_type = t3.id_type 
    and t1.id_no = sha256(t3.id_no)
    and coalesce(t1.id_no, '') <> ''  -- 左表空值不参与JOIN
    left join (
        select
            grass_date
            ,phone as phone_no
            ,mh_query_count_7d
            ,mh_query_count_14d
            ,mh_query_count_30d
            ,mh_query_count_90d
            ,mh_query_count_180d
            ,mh_query_count_360d
            ,mh_query_count_720d
            ,mh_query_count_1440d
            ,mh_query_hr_count_7d
            ,mh_query_hr_count_14d
            ,mh_query_hr_count_30d
            ,mh_query_hr_count_90d
            ,mh_query_hr_count_180d
            ,mh_query_hr_count_360d
            ,mh_query_hr_count_720d
            ,mh_query_hr_count_1440d
            ,mh_latest_query_to_now_days
            ,mh_first_query_to_now_days
            ,mh_consecutive_query_day_min_7d
            ,mh_consecutive_query_day_min_14d
            ,mh_consecutive_query_day_min_30d
            ,mh_consecutive_query_day_min_90d
            ,mh_consecutive_query_day_min_180d
            ,mh_consecutive_query_day_min_360d
            ,mh_consecutive_query_day_min_720d
        from risk.dws_risk_ph_phone_multiloan_df
        where coalesce(phone, '') <> ''  -- 右表过滤空值，避免数据倾斜
    ) t4 on t1.backtest_date = t4.grass_date
    and t1.phone_no = sha256(t4.phone_no)
    and coalesce(t1.phone_no, '') <> ''  -- 左表空值不参与JOIN
;

--base64撞库
create or replace temporary view t_backtesting_base64_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.create_date
    ,t1.backtest_date
    ,t1.id_type
    ,t1.id_no
    ,t1.phone_no
    ,t1.dob
    ,t1.name
    ,coalesce(t3.mh_query_count_7d, t4.mh_query_count_7d) as mh_query_count_7d
    ,coalesce(t3.mh_query_count_14d, t4.mh_query_count_14d) as mh_query_count_14d
    ,coalesce(t3.mh_query_count_30d, t4.mh_query_count_30d) as mh_query_count_30d
    ,coalesce(t3.mh_query_count_90d, t4.mh_query_count_90d) as mh_query_count_90d
    ,coalesce(t3.mh_query_count_180d, t4.mh_query_count_180d) as mh_query_count_180d
    ,coalesce(t3.mh_query_count_360d, t4.mh_query_count_360d) as mh_query_count_360d
    ,coalesce(t3.mh_query_count_720d, t4.mh_query_count_720d) as mh_query_count_720d
    ,coalesce(t3.mh_query_count_1440d, t4.mh_query_count_1440d) as mh_query_count_1440d
    ,coalesce(t3.mh_query_hr_count_7d, t4.mh_query_hr_count_7d) as mh_query_hr_count_7d
    ,coalesce(t3.mh_query_hr_count_14d, t4.mh_query_hr_count_14d) as mh_query_hr_count_14d
    ,coalesce(t3.mh_query_hr_count_30d, t4.mh_query_hr_count_30d) as mh_query_hr_count_30d
    ,coalesce(t3.mh_query_hr_count_90d, t4.mh_query_hr_count_90d) as mh_query_hr_count_90d
    ,coalesce(t3.mh_query_hr_count_180d, t4.mh_query_hr_count_180d) as mh_query_hr_count_180d
    ,coalesce(t3.mh_query_hr_count_360d, t4.mh_query_hr_count_360d) as mh_query_hr_count_360d
    ,coalesce(t3.mh_query_hr_count_720d, t4.mh_query_hr_count_720d) as mh_query_hr_count_720d
    ,coalesce(t3.mh_query_hr_count_1440d, t4.mh_query_hr_count_1440d) as mh_query_hr_count_1440d
    ,coalesce(t3.mh_latest_query_to_now_days, t4.mh_latest_query_to_now_days) as mh_latest_query_to_now_days
    ,coalesce(t3.mh_first_query_to_now_days, t4.mh_first_query_to_now_days) as mh_first_query_to_now_days
    ,coalesce(t3.mh_consecutive_query_day_min_7d, t4.mh_consecutive_query_day_min_7d) as mh_consecutive_query_day_min_7d
    ,coalesce(t3.mh_consecutive_query_day_min_14d, t4.mh_consecutive_query_day_min_14d) as mh_consecutive_query_day_min_14d
    ,coalesce(t3.mh_consecutive_query_day_min_30d, t4.mh_consecutive_query_day_min_30d) as mh_consecutive_query_day_min_30d
    ,coalesce(t3.mh_consecutive_query_day_min_90d, t4.mh_consecutive_query_day_min_90d) as mh_consecutive_query_day_min_90d
    ,coalesce(t3.mh_consecutive_query_day_min_180d, t4.mh_consecutive_query_day_min_180d) as mh_consecutive_query_day_min_180d
    ,coalesce(t3.mh_consecutive_query_day_min_360d, t4.mh_consecutive_query_day_min_360d) as mh_consecutive_query_day_min_360d
    ,coalesce(t3.mh_consecutive_query_day_min_720d, t4.mh_consecutive_query_day_min_720d) as mh_consecutive_query_day_min_720d
from (
    select
        task_id
        ,id
        ,create_date
        ,backtest_date
        ,id_type
        ,id_no
        ,phone_no
        ,dob
        ,name
    from risk_feature.tmp_t_backtesting_task_id_list
    where hash_method = 'base64'
) t1
    left join (
        select
            grass_date
            ,id_type
            ,id_no
            ,mh_query_count_7d
            ,mh_query_count_14d
            ,mh_query_count_30d
            ,mh_query_count_90d
            ,mh_query_count_180d
            ,mh_query_count_360d
            ,mh_query_count_720d
            ,mh_query_count_1440d
            ,mh_query_hr_count_7d
            ,mh_query_hr_count_14d
            ,mh_query_hr_count_30d
            ,mh_query_hr_count_90d
            ,mh_query_hr_count_180d
            ,mh_query_hr_count_360d
            ,mh_query_hr_count_720d
            ,mh_query_hr_count_1440d
            ,mh_latest_query_to_now_days
            ,mh_first_query_to_now_days
            ,mh_consecutive_query_day_min_7d
            ,mh_consecutive_query_day_min_14d
            ,mh_consecutive_query_day_min_30d
            ,mh_consecutive_query_day_min_90d
            ,mh_consecutive_query_day_min_180d
            ,mh_consecutive_query_day_min_360d
            ,mh_consecutive_query_day_min_720d
        from risk.dws_risk_ph_ktp_multiloan_df
        where coalesce(id_no, '') <> ''  -- 右表过滤空值，避免数据倾斜
    ) t3 on t1.backtest_date = t3.grass_date
    and t1.id_type = t3.id_type 
    and t1.id_no = base64(t3.id_no)
    and coalesce(t1.id_no, '') <> ''  -- 左表空值不参与JOIN
    left join (
        select
            grass_date
            ,phone as phone_no
            ,mh_query_count_7d
            ,mh_query_count_14d
            ,mh_query_count_30d
            ,mh_query_count_90d
            ,mh_query_count_180d
            ,mh_query_count_360d
            ,mh_query_count_720d
            ,mh_query_count_1440d
            ,mh_query_hr_count_7d
            ,mh_query_hr_count_14d
            ,mh_query_hr_count_30d
            ,mh_query_hr_count_90d
            ,mh_query_hr_count_180d
            ,mh_query_hr_count_360d
            ,mh_query_hr_count_720d
            ,mh_query_hr_count_1440d
            ,mh_latest_query_to_now_days
            ,mh_first_query_to_now_days
            ,mh_consecutive_query_day_min_7d
            ,mh_consecutive_query_day_min_14d
            ,mh_consecutive_query_day_min_30d
            ,mh_consecutive_query_day_min_90d
            ,mh_consecutive_query_day_min_180d
            ,mh_consecutive_query_day_min_360d
            ,mh_consecutive_query_day_min_720d
        from risk.dws_risk_ph_phone_multiloan_df
        where coalesce(phone, '') <> ''  -- 右表过滤空值，避免数据倾斜
    ) t4 on t1.backtest_date = t4.grass_date
    and t1.phone_no = base64(t4.phone_no)
    and coalesce(t1.phone_no, '') <> ''  -- 左表空值不参与JOIN
;

-- 统一撞库逻辑：根据hash_method动态匹配对应字段
insert overwrite table ${SCHEMA}.ads_risk_ph_multihead_ktp_phone_backtesting_info_rt partition (grass_date, task_id)
select
    create_date
    ,backtest_date
    ,id_type
    ,id_no
    ,phone_no
    ,dob
    ,name
    ,mh_query_count_7d
    ,mh_query_count_14d
    ,mh_query_count_30d
    ,mh_query_count_90d
    ,mh_query_count_180d
    ,mh_query_count_360d
    ,mh_query_count_720d
    ,mh_query_count_1440d
    ,mh_query_hr_count_7d
    ,mh_query_hr_count_14d
    ,mh_query_hr_count_30d
    ,mh_query_hr_count_90d
    ,mh_query_hr_count_180d
    ,mh_query_hr_count_360d
    ,mh_query_hr_count_720d
    ,mh_query_hr_count_1440d
    ,mh_latest_query_to_now_days
    ,mh_first_query_to_now_days
    ,mh_consecutive_query_day_min_7d
    ,mh_consecutive_query_day_min_14d
    ,mh_consecutive_query_day_min_30d
    ,mh_consecutive_query_day_min_90d
    ,mh_consecutive_query_day_min_180d
    ,mh_consecutive_query_day_min_360d
    ,mh_consecutive_query_day_min_720d
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_task_result
union all
select
    create_date
    ,backtest_date
    ,id_type
    ,id_no
    ,phone_no
    ,dob
    ,name
    ,mh_query_count_7d
    ,mh_query_count_14d
    ,mh_query_count_30d
    ,mh_query_count_90d
    ,mh_query_count_180d
    ,mh_query_count_360d
    ,mh_query_count_720d
    ,mh_query_count_1440d
    ,mh_query_hr_count_7d
    ,mh_query_hr_count_14d
    ,mh_query_hr_count_30d
    ,mh_query_hr_count_90d
    ,mh_query_hr_count_180d
    ,mh_query_hr_count_360d
    ,mh_query_hr_count_720d
    ,mh_query_hr_count_1440d
    ,mh_latest_query_to_now_days
    ,mh_first_query_to_now_days
    ,mh_consecutive_query_day_min_7d
    ,mh_consecutive_query_day_min_14d
    ,mh_consecutive_query_day_min_30d
    ,mh_consecutive_query_day_min_90d
    ,mh_consecutive_query_day_min_180d
    ,mh_consecutive_query_day_min_360d
    ,mh_consecutive_query_day_min_720d
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_sha256_task_result
union all
select
    create_date
    ,backtest_date
    ,id_type
    ,id_no
    ,phone_no
    ,dob
    ,name
    ,mh_query_count_7d
    ,mh_query_count_14d
    ,mh_query_count_30d
    ,mh_query_count_90d
    ,mh_query_count_180d
    ,mh_query_count_360d
    ,mh_query_count_720d
    ,mh_query_count_1440d
    ,mh_query_hr_count_7d
    ,mh_query_hr_count_14d
    ,mh_query_hr_count_30d
    ,mh_query_hr_count_90d
    ,mh_query_hr_count_180d
    ,mh_query_hr_count_360d
    ,mh_query_hr_count_720d
    ,mh_query_hr_count_1440d
    ,mh_latest_query_to_now_days
    ,mh_first_query_to_now_days
    ,mh_consecutive_query_day_min_7d
    ,mh_consecutive_query_day_min_14d
    ,mh_consecutive_query_day_min_30d
    ,mh_consecutive_query_day_min_90d
    ,mh_consecutive_query_day_min_180d
    ,mh_consecutive_query_day_min_360d
    ,mh_consecutive_query_day_min_720d
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_base64_task_result
;