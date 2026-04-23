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
--  2026-04-01 taowei 新增 id 方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032 
-- =============================================================================

-- drop table if exists ${SCHEMA}.ads_2bscore_ph_ktp_phone_backtesting_checking_info_df;
create external table if not exists ${SCHEMA}.ads_2bscore_ph_ktp_phone_backtesting_checking_info_df (
    hash_method string comment 'hash_method'
    ,id_type string comment 'id_type'
    ,id_no string comment 'id_no'
    ,phone_no string comment 'phone_no'
    ,is_id_match int comment '是否id匹配'
    ,is_phone_match int comment '是否phone匹配'
    ,id bigint comment ''
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd'
    ,task_id string comment 'backtest task_id'
    )
stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_2bscore_aio_ktp_phone_backtesting_checking_info_df/grass_region=PH'
;
-- msck repair table ${SCHEMA}.ads_2bscore_ph_ktp_phone_backtesting_checking_info_df;


uncache table if exists t_backtesting_task_id_list;
cache table t_backtesting_task_id_list options ('storageLevel' 'MEMORY_AND_DISK') as
select
    task_id
    ,id
    ,hash_method
    ,id_type
    ,id_no
    ,phone_no
from
(
    select
        t1.task_id
        ,t2.id
        ,lower(t1.hash_method) as hash_method
        ,get_json_object(t2.task_data, '$.id_type') as id_type
        ,get_json_object(t2.task_data, '$.id_no') as id_no
        ,get_json_object(t2.task_data, '$.msisdn') as phone_no
        ,row_number() over (partition by t1.task_id order by rand()) as rn
    from
    (
        select
            task_id
            ,task_status
            ,hash_method
        from risk.view__credit_risk_open_platform_ph_db__auto_backtesting_task_tab__spark
        where task_status = 9
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
)
where rn <= 100
;

create or replace temporary view t_backtesting_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.hash_method
    ,t1.id_type
    ,t1.id_no
    ,t1.phone_no
    ,case when t2.id_no is not null then 1 else 0 end as is_id_match
    ,case when t3.phone_no is not null then 1 else 0 end as is_phone_match
from t_backtesting_task_id_list t1
left join (
    select
        id_type
        ,id_no
    from risk.dws_risk_ph_ktp_multiloan_df
    where grass_date = '${grass_date}'
) t2
on t1.id_type = t2.id_type
and t1.id_no = t2.id_no
left join (
    select
        phone as phone_no
    from risk.dws_risk_ph_phone_multiloan_df
    where grass_date = '${grass_date}'
) t3
on t1.phone_no = t3.phone_no
where coalesce(t1.hash_method, '') = ''
;

--sha256撞库
create or replace temporary view t_backtesting_sha256_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.hash_method
    ,t1.id_type
    ,t1.id_no
    ,t1.phone_no
    ,case when t2.id_no_sha256 is not null then 1 else 0 end as is_id_match
    ,case when t3.phone_no_sha256 is not null then 1 else 0 end as is_phone_match
from t_backtesting_task_id_list t1
left join (
    select
        id_type
        ,sha2(id_no,256) as id_no_sha256
    from risk.dws_risk_ph_ktp_multiloan_df
    where grass_date = '${grass_date}'
) t2
on t1.id_type = t2.id_type
and t1.id_no = t2.id_no_sha256
left join (
    select
        sha2(phone,256) as phone_no_sha256
    from risk.dws_risk_ph_phone_multiloan_df
    where grass_date = '${grass_date}'
) t3
on t1.phone_no = t3.phone_no_sha256
where t1.hash_method = 'sha256'
;

--base64撞库
create or replace temporary view t_backtesting_base64_task_result as
select
    t1.task_id
    ,t1.id
    ,t1.hash_method
    ,t1.id_type
    ,t1.id_no
    ,t1.phone_no
    ,case when t2.id_no_base64 is not null then 1 else 0 end as is_id_match
    ,case when t3.phone_no_base64 is not null then 1 else 0 end as is_phone_match
from t_backtesting_task_id_list t1
left join (
    select
        id_type
        ,base64(id_no) as id_no_base64
    from risk.dws_risk_ph_ktp_multiloan_df
    where grass_date = '${grass_date}'
) t2
on t1.id_type = t2.id_type
and t1.id_no = t2.id_no_base64
left join (
    select
        base64(phone) as phone_no_base64
    from risk.dws_risk_ph_phone_multiloan_df
    where grass_date = '${grass_date}'
) t3
on t1.phone_no = t3.phone_no_base64
where t1.hash_method = 'base64'
;

insert overwrite table ${SCHEMA}.ads_2bscore_ph_ktp_phone_backtesting_checking_info_df partition(grass_date, task_id)
select
    hash_method
    ,id_type
    ,id_no
    ,phone_no
    ,is_id_match
    ,is_phone_match
    ,id
    ,'${grass_date}' as grass_date
    ,task_id
from t_backtesting_task_result
union all
select
    hash_method
    ,id_type
    ,id_no
    ,phone_no
    ,is_id_match
    ,is_phone_match
    ,id
    ,'${grass_date}' as grass_date
    ,task_id
from t_backtesting_sha256_task_result
union all
select
    hash_method
    ,id_type
    ,id_no
    ,phone_no
    ,is_id_match
    ,is_phone_match
    ,id
    ,'${grass_date}' as grass_date
    ,task_id
from t_backtesting_base64_task_result
;