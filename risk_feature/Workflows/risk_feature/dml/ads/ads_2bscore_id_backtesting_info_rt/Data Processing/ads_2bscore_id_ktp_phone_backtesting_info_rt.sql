--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-01-12
-- Theme Domain：       Credit 2BSCore
-- Description:         Biz side write user's id_no and phone_no to db
--                      the data runs batch to get the score blacklist hits and other data is written to S3 and returned to BE.
-- Data Granularity:    task_id
-- Jira:                https://jira.shopee.io/browse/SPFDT-28170
-- update by zongyi.lu@shopee.com 因为下游需要将multihead的数据放在同一个文件,因此将传数据的s3任务重新开发 - ads_risk_id_multihead_backtesting_to_s3
-- update by zongyi.lu@shopee.com 20241119 jira: https://jira.shopee.io/browse/SPFDT-46220 将根据credit_risk_open_platform_id/ph_db__auto_backtesting_task_tab里的hash_method的value(emu: sha256; base64; "")来对ktp_no、phone等敏感字段做加密关联匹配后返回
-- update by chengguo.liu@shopee.com  2025-03-17  不同加密方式撞库，join条件里写or逻辑性能差，拆开分别join
-- 2026-04-01 taowei 新增 id  方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
--********************************************************************--


-- drop table if exists ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_info_rt;
create external table if not exists ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_info_rt (
    ktp_no string
    ,phone_no string
    ,backtest_date string
    ,hit_list_type int
    ,reason_code int
    ,score string
    ,is_ktp_match int
    ,is_phone_match int
    ,create_date string
    ,score_v3 int
    ,id bigint
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd'
    ,task_id string comment 'backtest task_id'
    ) stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_2bscore_ktp_phone_backtesting_info_rt/grass_region=${grass_region}'
;
-- msck repair table ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_info_rt;


add jar hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-sha-256.jar;
create or replace temporary function sha256 as 'com.shopee.udf.RiskSha256';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

uncache table if exists t_backtesting_task_id_list;
cache table t_backtesting_task_id_list options ('storageLevel' 'MEMORY_AND_DISK')
select
    t1.task_id
    ,t1.task_status
    ,t1.create_date
    ,t1.hash_method
    ,t2.id
    ,get_json_object(t2.task_data, '$.ktp_no') as ktp_no
    ,get_json_object(t2.task_data, '$.msisdn') as phone_no
    ,get_json_object(t2.task_data, '$.backtest_date') as backtest_date
from
(
    select
        task_id
        ,task_status
        ,format_time (cast(create_time / 1000 as bigint), 'ID') as create_date
        ,lower(hash_method) as hash_method
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_tab__spark
    where task_status = 5
    and service_name_list in ('CreditScore', 'Blacklist', 'CreditScore,Blacklist')
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
    from ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_info_rt
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

create or replace temporary view t_backtesting_task_result as
select
    task_id
    ,id
    ,ktp_no
    ,phone_no
    ,backtest_date
    ,case
        when list_type = 1 and is_blacklist_hit = 1 then 1
        when list_type = 2 and is_blacklist_hit = 1 then 2
        else null
    end as hit_list_type
    ,reason_code
    ,score
    ,is_ktp_match
    ,is_phone_match
    ,create_date
    ,score_v3
from
    (
        select
            t1.task_id
            ,t1.id
            ,t1.create_date
            ,t1.ktp_no
            ,t1.phone_no
            ,t1.backtest_date
            ,case when t3.is_blacklist_hit = 1 then t3.is_blacklist_hit else t4.is_blacklist_hit end as is_blacklist_hit
            ,coalesce(t3.list_type, t4.list_type) as list_type
            ,coalesce(t3.reason_code, t4.reason_code) as reason_code
            ,case when t3.ktp_no is not null then t3.score else t4.score end as score
            ,if(t3.ktp_no is null, 0, 1) as is_ktp_match
            ,if(t4.phone_no is null, 0, 1) as is_phone_match
            ,case when t3.ktp_no is not null then t3.score_v3 else t4.score_v3 end as score_v3
        from (
            select
                task_id
                ,id
                ,create_date
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
                ,ktp_no_sha256
                ,ktp_no_base64
                ,score
                ,score_v3
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,grass_date
            from risk.ads_2bscore_id_user_ktp_info_df
            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
        ) t3 on t1.backtest_date = t3.grass_date
        and t1.ktp_no = t3.ktp_no
        left join (
            select
                phone_no
                ,phone_no_sha256
                ,phone_no_base64
                ,score
                ,score_v3
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,grass_date
            from risk.ads_2bscore_id_user_phone_info_df
            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
        ) t4 on t1.backtest_date = t4.grass_date
        and t1.phone_no = t4.phone_no
    )
;

--sha256撞库
create or replace temporary view t_backtesting_sha256_task_result as
select
    task_id
    ,id
    ,ktp_no
    ,phone_no
    ,backtest_date
    ,case
        when list_type = 1 and is_blacklist_hit = 1 then 1
        when list_type = 2 and is_blacklist_hit = 1 then 2
        else null
    end as hit_list_type
    ,reason_code
    ,score
    ,is_ktp_match
    ,is_phone_match
    ,create_date
    ,score_v3
from
    (
        select
            t1.task_id
            ,t1.id
            ,t1.create_date
            ,t1.ktp_no
            ,t1.phone_no
            ,t1.backtest_date
            ,case when t3.is_blacklist_hit = 1 then t3.is_blacklist_hit else t4.is_blacklist_hit end as is_blacklist_hit
            ,coalesce(t3.list_type, t4.list_type) as list_type
            ,coalesce(t3.reason_code, t4.reason_code) as reason_code
            ,case when t3.ktp_no is not null then t3.score else t4.score end as score
            ,if(t3.ktp_no is null, 0, 1) as is_ktp_match
            ,if(t4.phone_no is null, 0, 1) as is_phone_match
            ,case when t3.ktp_no is not null then t3.score_v3 else t4.score_v3 end as score_v3
        from (
            select
                task_id
                ,id
                ,create_date
                ,hash_method
                ,ktp_no
                ,phone_no
                ,backtest_date
            from t_backtesting_task_id_list
            where hash_method = 'sha256'
        ) t1
        left join (
            select
                ktp_no
                ,ktp_no_sha256
                ,ktp_no_base64
                ,score
                ,score_v3
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,grass_date
            from risk.ads_2bscore_id_user_ktp_info_df
            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
        ) t3 on t1.backtest_date = t3.grass_date
        and t1.ktp_no = t3.ktp_no_sha256
        left join (
            select
                phone_no
                ,phone_no_sha256
                ,phone_no_base64
                ,score
                ,score_v3
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,grass_date
            from risk.ads_2bscore_id_user_phone_info_df
            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
        ) t4 on t1.backtest_date = t4.grass_date
        and t1.phone_no = t4.phone_no_sha256
    )
;

--base64撞库
create or replace temporary view t_backtesting_base64_task_result as
select
    task_id
    ,id
    ,ktp_no
    ,phone_no
    ,backtest_date
    ,case
        when list_type = 1 and is_blacklist_hit = 1 then 1
        when list_type = 2 and is_blacklist_hit = 1 then 2
        else null
    end as hit_list_type
    ,reason_code
    ,score
    ,is_ktp_match
    ,is_phone_match
    ,create_date
    ,score_v3
from
    (
        select
            t1.task_id
            ,t1.id
            ,t1.create_date
            ,t1.ktp_no
            ,t1.phone_no
            ,t1.backtest_date
            ,case when t3.is_blacklist_hit = 1 then t3.is_blacklist_hit else t4.is_blacklist_hit end as is_blacklist_hit
            ,coalesce(t3.list_type, t4.list_type) as list_type
            ,coalesce(t3.reason_code, t4.reason_code) as reason_code
            ,case when t3.ktp_no is not null then t3.score else t4.score end as score
            ,if(t3.ktp_no is null, 0, 1) as is_ktp_match
            ,if(t4.phone_no is null, 0, 1) as is_phone_match
            ,case when t3.ktp_no is not null then t3.score_v3 else t4.score_v3 end as score_v3
        from (
            select
                task_id
                ,id
                ,create_date
                ,hash_method
                ,ktp_no
                ,phone_no
                ,backtest_date
            from t_backtesting_task_id_list
            where hash_method = 'base64'
        ) t1
        left join (
            select
                ktp_no
                ,ktp_no_sha256
                ,ktp_no_base64
                ,score
                ,score_v3
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,grass_date
            from risk.ads_2bscore_id_user_ktp_info_df
            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
        ) t3 on t1.backtest_date = t3.grass_date
        and t1.ktp_no = t3.ktp_no_base64
        left join (
            select
                phone_no
                ,phone_no_sha256
                ,phone_no_base64
                ,score
                ,score_v3
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,grass_date
            from risk.ads_2bscore_id_user_phone_info_df
            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
        ) t4 on t1.backtest_date = t4.grass_date
        and t1.phone_no = t4.phone_no_base64
    )
;

insert overwrite table ${SCHEMA}.ads_2bscore_id_ktp_phone_backtesting_info_rt partition (grass_date, task_id)
select
    ktp_no
    ,phone_no
    ,backtest_date
    ,hit_list_type
    ,reason_code
    ,score
    ,is_ktp_match
    ,is_phone_match
    ,create_date
    ,score_v3
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_task_result
union all
select
    ktp_no
    ,phone_no
    ,backtest_date
    ,hit_list_type
    ,reason_code
    ,score
    ,is_ktp_match
    ,is_phone_match
    ,create_date
    ,score_v3
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_base64_task_result
union all
select
    ktp_no
    ,phone_no
    ,backtest_date
    ,hit_list_type
    ,reason_code
    ,score
    ,is_ktp_match
    ,is_phone_match
    ,create_date
    ,score_v3
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_sha256_task_result
;


