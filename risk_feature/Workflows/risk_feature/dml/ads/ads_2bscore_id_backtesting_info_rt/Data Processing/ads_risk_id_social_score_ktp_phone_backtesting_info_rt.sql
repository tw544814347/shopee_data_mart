--********************************************************************--
-- Author:              zhicheng.chen@shopee.com
-- Created Time:        2025-08-27T15:00:00
-- Description:         [ID] tob backtesting新增social score任务类型 * 1
-- Data Granularity:    
-- PRD                  https://jira.shopee.io/browse/SPFDT-54939
-- Jira                 https://jira.shopee.io/browse/SPFDT-54939
-- Jira                 https://jira.shopee.io/browse/SPFDT-59804  phone维度分数，DS按月度刷新，单份切片20亿+数据量太大，保留月切片做回溯
-- 2026-03-19  chengguo.liu@shopee.com  新增ktp_no从task_data中透传，新增is_phone_match字段
-- 2026-04-01 taowei 新增 id  方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
--********************************************************************--


-- drop table if exists risk_feature.ads_risk_id_social_score_ktp_phone_backtesting_info_rt;
create external table if not exists risk_feature.ads_risk_id_social_score_ktp_phone_backtesting_info_rt (
    backtest_date   string comment 'task_data.backtest_date'
    ,phone_no        string comment 'task_data.msisdn'
    ,social_score    bigint comment 'social score'
    ,ktp_no          string comment 'ktp number'
    ,is_phone_match int comment '1 match, 0 no-match'
    ,id             bigint comment 'id'
)
partitioned by (
    grass_date string
    ,task_id string
) 
stored as orc 
comment ''
tblproperties
(
    "orc.compress" = "zstd"
)
location 'hdfs://R2/projects/risk_feature/hdfs/prod/risk_feature/ads/ads_risk_social_score_ktp_phone_backtesting_info_rt/grass_region=ID'
;
-- msck repair table risk_feature.ads_risk_id_social_score_ktp_phone_backtesting_info_rt;


add jar hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-sha-256.jar;
create or replace temporary function sha256 as 'com.shopee.udf.RiskSha256';

uncache table if exists t_backtesting_task_id_list;
cache table t_backtesting_task_id_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    t1.task_id
    ,t2.id
    ,t1.hash_method
    ,get_json_object(t2.task_data, '$.backtest_date') as backtest_date
    ,date_format(get_json_object(t2.task_data, '$.backtest_date'), 'yyyy-MM-01') as backtest_month_date
    ,get_json_object(t2.task_data, '$.msisdn') as phone_no
    ,get_json_object(t2.task_data, '$.ktp_no') as ktp_no
from
(
    select
        task_id
        ,lower(hash_method) as hash_method
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_tab__spark
    where service_name_list = 'SocialScore'
    and task_status = 5
) t1
left join
(
    select
        task_id
        ,task_data
        ,id
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_data_tab__spark
) t2
on t1.task_id = t2.task_id
left join
(
    select
        task_id
    from risk_feature.ads_risk_id_social_score_ktp_phone_backtesting_info_rt
    where grass_date = '${grass_date}'
    group by task_id
) t3
on t1.task_id = t3.task_id
where t3.task_id is null
;

uncache table if exists t_backtesting_backtest_date_list;
cache table t_backtesting_backtest_date_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    backtest_month_date
from t_backtesting_task_id_list
group by backtest_month_date
;

insert overwrite risk_feature.ads_risk_id_social_score_ktp_phone_backtesting_info_rt  partition (grass_date, task_id)
 select  t1.backtest_date
        ,t1.phone_no
        ,t2.social_score
        ,t1.ktp_no
        ,if(t2.phone_no is null, 0, 1) as is_phone_match
        ,t1.id
        ,'${grass_date}' as grass_date
        ,t1.task_id
from t_backtesting_task_id_list t1
left join 
(
    select phone_no
           ,social_score
           ,grass_date
    from risk.ads_risk_id_social_score_phone_info_df
    where grass_date in (select backtest_month_date from t_backtesting_backtest_date_list)
) t2
on t1.backtest_month_date = t2.grass_date
and t1.phone_no = t2.phone_no
where coalesce(t1.hash_method, '') = ''

union all 

 select  t1.backtest_date
        ,t1.phone_no
        ,t2.social_score
        ,t1.ktp_no
        ,if(t2.phone_no_base64 is null, 0, 1) as is_phone_match
        ,t1.id
        ,'${grass_date}' as grass_date
        ,t1.task_id
from t_backtesting_task_id_list t1
left join 
(
    select phone_no_base64
           ,social_score
           ,grass_date
    from risk.ads_risk_id_social_score_phone_info_df
    where grass_date in (select backtest_month_date from t_backtesting_backtest_date_list)
) t2
on t1.backtest_month_date = t2.grass_date
and t1.phone_no = t2.phone_no_base64
where t1.hash_method = 'base64'

union all 

 select  t1.backtest_date
        ,t1.phone_no
        ,t2.social_score
        ,t1.ktp_no
        ,if(t2.phone_no_sha256 is null, 0, 1) as is_phone_match
        ,t1.id
        ,'${grass_date}' as grass_date
        ,t1.task_id
from t_backtesting_task_id_list t1
left join 
(
    select phone_no_sha256
           ,social_score
           ,grass_date
    from risk.ads_risk_id_social_score_phone_info_df
    where grass_date in (select backtest_month_date from t_backtesting_backtest_date_list)
) t2
on t1.backtest_month_date = t2.grass_date
and t1.phone_no = t2.phone_no_sha256
where t1.hash_method = 'sha256'
;
