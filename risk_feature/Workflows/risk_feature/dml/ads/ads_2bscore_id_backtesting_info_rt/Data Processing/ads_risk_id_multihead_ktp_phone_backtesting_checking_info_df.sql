-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-02-14
-- Theme Domain:        
-- Data Granularity:    
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-14 - chengguo.liu - 
--  2026-04-01 taowei 新增 id  方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
-- =============================================================================

-- drop table if exists ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_checking_info_df;
create external table if not exists ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_checking_info_df (
    hash_method string comment 'hash_method'
    ,ktp_no string comment 'ktp_no'
    ,phone_no string comment 'phone_no'
    ,is_ktp_match int comment '是否ktp匹配'
    ,is_phone_match int comment '是否phone匹配'
    ,id bigint comment 'id'
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd'
    ,task_id string comment 'backtest task_id'
    )
stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_2bscore_aio_ktp_phone_backtesting_checking_info_df/grass_region=ID'
;
-- msck repair table ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_checking_info_df;


create or replace temporary view backtesting_task_info_tmp as 
select
    t1.task_id
    ,t2.id
    ,lower(t1.hash_method) as hash_method
    ,get_json_object(t2.task_data, '$.ktp_no') as ktp_no
    ,get_json_object(t2.task_data, '$.msisdn') as phone_no
from
(
    select
        task_id
        ,task_status
        ,hash_method
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_tab__spark
    where task_status = 9
    and service_name_list like '%MultiHead%'
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
limit 100
;

create or replace temporary view t_backtesting_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.hash_method
    ,t1.ktp_no
    ,t1.phone_no
    ,case when t2.ktp_no is not null then 1 else 0 end as is_ktp_match
    ,case when t3.phone_no is not null then 1 else 0 end as is_phone_match
from backtesting_task_info_tmp t1
left join (
    select
        ktp_no
    from risk_feature.ads_risk_id_multihead_ktp_phone_info_df
    where grass_date = date_sub('${grass_date}',1)
    group by ktp_no
) t2
on t1.ktp_no = t2.ktp_no
left join (
    select
        phone_no
    from risk_feature.ads_risk_id_multihead_ktp_phone_info_df
    where grass_date = date_sub('${grass_date}',1)
    group by phone_no
) t3
on t1.phone_no = t3.phone_no
where coalesce(t1.hash_method, '') = ''
;

create or replace temporary view t_backtesting_sha256_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.hash_method
    ,t1.ktp_no
    ,t1.phone_no
    ,case when t2.ktp_no_sha256 is not null then 1 else 0 end as is_ktp_match
    ,case when t3.phone_no_sha256 is not null then 1 else 0 end as is_phone_match
from backtesting_task_info_tmp t1
left join (
    select
        ktp_no_sha256
    from risk_feature.ads_risk_id_multihead_ktp_phone_info_df
    where grass_date = date_sub('${grass_date}',1)
    group by ktp_no_sha256
) t2
on t1.ktp_no = t2.ktp_no_sha256
left join (
    select
        phone_no_sha256
    from risk_feature.ads_risk_id_multihead_ktp_phone_info_df
    where grass_date = date_sub('${grass_date}',1)
    group by phone_no_sha256
) t3
on t1.phone_no = t3.phone_no_sha256
where t1.hash_method = 'sha256'
;

create or replace temporary view t_backtesting_base64_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.hash_method
    ,t1.ktp_no
    ,t1.phone_no
    ,case when t2.ktp_no_base64 is not null then 1 else 0 end as is_ktp_match
    ,case when t3.phone_no_base64 is not null then 1 else 0 end as is_phone_match
from backtesting_task_info_tmp t1
left join (
    select
        ktp_no_base64
    from risk_feature.ads_risk_id_multihead_ktp_phone_info_df
    where grass_date = date_sub('${grass_date}',1)
    group by ktp_no_base64
) t2
on t1.ktp_no = t2.ktp_no_base64
left join (
    select
        phone_no_base64
    from risk_feature.ads_risk_id_multihead_ktp_phone_info_df
    where grass_date = date_sub('${grass_date}',1)
    group by phone_no_base64
) t3
on t1.phone_no = t3.phone_no_base64
where t1.hash_method = 'base64'
;

insert overwrite table ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_checking_info_df partition(grass_date, task_id)
select
    hash_method
    ,ktp_no
    ,phone_no
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${grass_date}' as grass_date
    ,task_id
from t_backtesting_task_result
union all
select
    hash_method
    ,ktp_no
    ,phone_no
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${grass_date}' as grass_date
    ,task_id
from t_backtesting_sha256_task_result
union all
select
    hash_method
    ,ktp_no
    ,phone_no
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${grass_date}' as grass_date
    ,task_id
from t_backtesting_base64_task_result
;
