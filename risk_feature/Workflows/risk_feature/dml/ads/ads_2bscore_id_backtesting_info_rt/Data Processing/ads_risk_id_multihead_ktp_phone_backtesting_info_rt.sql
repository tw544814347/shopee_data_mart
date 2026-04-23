--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-08-07
-- Theme Domain：       Risk multihead
-- Description:         Multi-Head Product需要对外部商户做feature自动的回溯
-- Data Granularity:    task_id
-- Jira:                https://jira.shopee.io/browse/SPFDT-40668
-- update by zongyi.lu@shopee.com 20240909 将key_type=3的关联条件改成 phone = phone or ktp=ktp
-- update by zongyi.lu@shopee.com 20241119 jira: https://jira.shopee.io/browse/SPFDT-46220 将根据credit_risk_open_platform_id/ph_db__auto_backtesting_task_tab里的hash_method的value(emu: sha256; base64; "")来对ktp_no、phone等敏感字段做加密关联匹配后返回
-- update by chengguo.liu@shopee.com 20251209 多头回溯dwd_risk_id_tob_service_di数据源部分，跟线上逻辑保持一致
--                                   jira: https://jira.shopee.io/browse/SPFDT-58318
-- update by wei.tao@shopee.com 20251218 更改 mh_latest/first_query_to_now_days 兜底逻辑 0/null -> -9999
-- update by chengguo.liu@shopee.com 20251209  迁移至risk_feature项目
-- 2026-04-01 taowei 新增 id  方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
--********************************************************************--


--drop table if exists ${SCHEMA}.ads_risk_id_multihead_ktp_phone_backtesting_info_rt;
create external table if not exists ${SCHEMA}.ads_risk_id_multihead_ktp_phone_backtesting_info_rt (
    backtest_date string comment 'backtest_date'
    ,ktp_no string comment 'ktp_no'
    ,phone_no string comment 'phone_no'
    ,mh_latest_query_to_now_days bigint comment '最近一次查询距离当前时间天数'
    ,mh_first_query_to_now_days bigint comment '第一次查询距离当前时间天数'
    ,mh_query_cnt_7d bigint comment '最近7天总查询次数'
    ,mh_query_cnt_30d bigint comment '最近30天总查询次数'
    ,mh_query_cnt_90d bigint comment '最近90天总查询次数'
    ,mh_query_cnt_180d bigint comment '最近180天总查询次数'
    ,mh_query_cnt_360d bigint comment '最近360天总查询次数'
    ,mh_query_cnt_720d bigint comment '最近720天总查询次数'
    ,mh_institution_cnt_7d bigint comment '最近7天查询机构数'
    ,mh_institution_cnt_30d bigint comment '最近30天查询机构数'
    ,mh_institution_cnt_90d bigint comment '最近90天查询机构数'
    ,mh_institution_cnt_180d bigint comment '最近180天查询机构数'
    ,mh_institution_cnt_360d bigint comment '最近360天查询机构数'
    ,mh_institution_cnt_720d bigint comment '最近720天查询机构数'
    ,mh_attempted_institutions_day_max_7d bigint comment '最近7天同一天最多查询机构数'
    ,mh_attempted_institutions_day_max_30d bigint comment '最近30天同一天最多查询机构数'
    ,mh_attempted_institutions_day_max_90d bigint comment '最近90天同一天最多查询机构数'
    ,mh_attempted_institutions_day_max_180d bigint comment '最近180天同一天最多查询机构数'
    ,mh_attempted_institutions_day_max_360d bigint comment '最近360天同一天最多查询机构数'
    ,mh_attempted_institutions_day_max_720d bigint comment '最近720天同一天最多查询机构数'
    ,mh_attempted_institutions_month_max_7d bigint comment '最近7天同一月最多查询机构数'
    ,mh_attempted_institutions_month_max_30d bigint comment '最近30天同一月最多查询机构数'
    ,mh_attempted_institutions_month_max_90d bigint comment '最近90天同一月最多查询机构数'
    ,mh_attempted_institutions_month_max_180d bigint comment '最近180天同一月最多查询机构数'
    ,mh_attempted_institutions_month_max_360d bigint comment '最近360天同一月最多查询机构数'
    ,mh_attempted_institutions_month_max_720d bigint comment '最近720天同一月最多查询机构数'
    ,mh_consecutive_query_day_min_7d bigint comment '最近7天连续两次查询距离最短天数'
    ,mh_consecutive_query_day_min_30d bigint comment '最近30天连续两次查询距离最短天数'
    ,mh_consecutive_query_day_min_90d bigint comment '最近90天连续两次查询距离最短天数'
    ,mh_consecutive_query_day_min_180d bigint comment '最近180天连续两次查询距离最短天数'
    ,mh_consecutive_query_day_min_360d bigint comment '最近360天连续两次查询距离最短天数'
    ,mh_consecutive_query_day_min_720d bigint comment '最近720天连续两次查询距离最短天数'
    ,id bigint comment 'id 用于排序'
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd'
    ,task_id string comment 'task_id'
    ) stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_risk_aio_multihead_ktp_phone_backtesting_info_rt/grass_region=ID'
;
--msck repair table ${SCHEMA}.ads_risk_id_multihead_ktp_phone_backtesting_info_rt;

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


uncache table if exists backtesting_task_info_tmp;
cache table backtesting_task_info_tmp options ('storageLevel' 'MEMORY_AND_DISK')
select
t1.task_id
,t2.id
,t1.create_date
,t2.backtest_date
,t1.hash_method
,case when t2.ktp_no is not null and t2.phone_no is null then 1 
      when t2.ktp_no is null and t2.phone_no is not null then 2
      when t2.ktp_no is not null and t2.phone_no is not null then 3 end key_type
,t2.ktp_no
,t2.phone_no
from
(
    select
        task_id
        ,task_status
        ,format_time (cast(create_time / 1000 as bigint), 'ID') as create_date
        ,lower(hash_method) as hash_method
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_tab__spark
    where task_status = 5
    and service_name_list like '%MultiHead%'
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
    from ${SCHEMA}.ads_risk_id_multihead_ktp_phone_backtesting_info_rt
    where grass_date = '${ds}'
    group by task_id
) t3
on t1.task_id = t3.task_id
where coalesce(t1.hash_method, '') = ''
and t3.task_id is null
distribute by task_id, backtest_date
;

-- 先获取所有的ktp+phone
drop table if exists ktp_phone_info_tmp;
create table if not exists  ktp_phone_info_tmp as
select  
    ktp_no
    ,phone_no
    ,req_date
    ,req_time
    ,app_id
    ,customer_id
    ,ktp_no_sha256
    ,ktp_no_base64
    ,phone_no_sha256
    ,phone_no_base64
from risk_feature.ads_risk_${region}_multihead_ktp_phone_info_df
where grass_date = '${grass_date}'
;

-- 计算一部分ktp的指标 
drop table if exists ktp_metric_tmp;
create table if not exists  ktp_metric_tmp as
select 
t3.task_id       
,t3.id
,t3.backtest_date
,ktp_no
,phone_no
,max(t3.mh_attempted_institutions_day_max_7d )   as mh_attempted_institutions_month_max_7d   
,max(t3.mh_attempted_institutions_day_max_30d )  as mh_attempted_institutions_month_max_30d  
,max(t3.mh_attempted_institutions_day_max_90d )  as mh_attempted_institutions_month_max_90d  
,max(t3.mh_attempted_institutions_day_max_180d ) as mh_attempted_institutions_month_max_180d 
,max(t3.mh_attempted_institutions_day_max_360d ) as mh_attempted_institutions_month_max_360d 
,max(t3.mh_attempted_institutions_day_max_720d ) as mh_attempted_institutions_month_max_720d 
from (
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no 
    ,t1.phone_no
    ,t1.hash_method
    ,substr(t2.req_date,1,7) as req_month 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.customer_id else null end )   as mh_attempted_institutions_day_max_7d   
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.customer_id else null end )  as mh_attempted_institutions_day_max_30d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.customer_id else null end )  as mh_attempted_institutions_day_max_90d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_180d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_360d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_720d 
    from backtesting_task_info_tmp t1 
    left join ktp_phone_info_tmp t2 on t1.ktp_no = t2.ktp_no
    where t1.key_type =1 
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no
    ,t1.phone_no
    ,t1.hash_method
    ,substr(t2.req_date,1,7)
) t3 
group by t3.task_id       
,t3.id
,t3.backtest_date
,ktp_no  
,phone_no
distribute by task_id, backtest_date
;

-- 计算一部分phone的指标 
drop table if exists phone_metric_tmp;
create table if not exists  phone_metric_tmp as
select 
t3.task_id       
,t3.id
,t3.backtest_date
,ktp_no     
,phone_no
,max(t3.mh_attempted_institutions_day_max_7d )   as mh_attempted_institutions_month_max_7d   
,max(t3.mh_attempted_institutions_day_max_30d )  as mh_attempted_institutions_month_max_30d  
,max(t3.mh_attempted_institutions_day_max_90d )  as mh_attempted_institutions_month_max_90d  
,max(t3.mh_attempted_institutions_day_max_180d ) as mh_attempted_institutions_month_max_180d 
,max(t3.mh_attempted_institutions_day_max_360d ) as mh_attempted_institutions_month_max_360d 
,max(t3.mh_attempted_institutions_day_max_720d ) as mh_attempted_institutions_month_max_720d 
from (
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no       
    ,t1.phone_no
    ,t1.hash_method
    ,substr(t2.req_date,1,7) as req_month 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.customer_id else null end )   as mh_attempted_institutions_day_max_7d   
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.customer_id else null end )  as mh_attempted_institutions_day_max_30d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.customer_id else null end )  as mh_attempted_institutions_day_max_90d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_180d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_360d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_720d 
    from backtesting_task_info_tmp t1 
    left join ktp_phone_info_tmp t2 on t1.phone_no = t2.phone_no
    where t1.key_type =2
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no       
    ,t1.phone_no 
    ,t1.hash_method
    ,substr(t2.req_date,1,7)
) t3 
group by t3.task_id       
,t3.id
,t3.backtest_date
,ktp_no
,phone_no
distribute by task_id, backtest_date
;


-- 计算一部分ktp+phone的指标 
drop table if exists ktp_phone_metric_tmp;
create table if not exists ktp_phone_metric_tmp as
select 
t3.task_id       
,t3.id
,t3.backtest_date
,ktp_no
,phone_no
,max(t3.mh_attempted_institutions_day_max_7d )   as mh_attempted_institutions_month_max_7d   
,max(t3.mh_attempted_institutions_day_max_30d )  as mh_attempted_institutions_month_max_30d  
,max(t3.mh_attempted_institutions_day_max_90d )  as mh_attempted_institutions_month_max_90d  
,max(t3.mh_attempted_institutions_day_max_180d ) as mh_attempted_institutions_month_max_180d 
,max(t3.mh_attempted_institutions_day_max_360d ) as mh_attempted_institutions_month_max_360d 
,max(t3.mh_attempted_institutions_day_max_720d ) as mh_attempted_institutions_month_max_720d 
from (
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no   
    ,t1.phone_no 
    ,t1.hash_method
    ,substr(t2.req_date,1,7) as req_month 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.customer_id else null end )   as mh_attempted_institutions_day_max_7d   
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.customer_id else null end )  as mh_attempted_institutions_day_max_30d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.customer_id else null end )  as mh_attempted_institutions_day_max_90d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_180d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_360d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.customer_id else null end ) as mh_attempted_institutions_day_max_720d 
    from backtesting_task_info_tmp t1 
    left join ktp_phone_info_tmp t2 
    on t1.ktp_no = t2.ktp_no or t1.phone_no = t2.phone_no
    where t1.key_type =3
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no   
    ,t1.phone_no
    ,t1.hash_method
    ,substr(t2.req_date,1,7)
) t3 
group by t3.task_id       
,t3.id
,t3.backtest_date
,ktp_no
,phone_no
distribute by task_id, backtest_date
;

insert overwrite table ${SCHEMA}.ads_risk_id_multihead_ktp_phone_backtesting_info_rt partition(grass_date, task_id)
select 
t5.backtest_date
,t5.ktp_no,t5.phone_no   
,max(nvl(nullif(datediff(t5.backtest_date, t5.max_query_date), 0),-9999)) as mh_latest_query_to_now_days
,max(nvl(nullif(datediff(t5.backtest_date, t5.min_query_date), 0),-9999)) as mh_first_query_to_now_days
,max(nvl(t5.mh_query_cnt_7d,0)                              ) as mh_query_cnt_7d
,max(nvl(t5.mh_query_cnt_30d ,0)                            ) as mh_query_cnt_30d  
,max(nvl(t5.mh_query_cnt_90d ,0)                            ) as mh_query_cnt_90d  
,max(nvl(t5.mh_query_cnt_180d,0)                            ) as mh_query_cnt_180d 
,max(nvl(t5.mh_query_cnt_360d,0)                            ) as mh_query_cnt_360d 
,max(nvl(t5.mh_query_cnt_720d,0)                            ) as mh_query_cnt_720d 
,max(nvl(t5.mh_institution_cnt_7d ,0)                       ) as mh_institution_cnt_7d  
,max(nvl(t5.mh_institution_cnt_30d,0)                       ) as mh_institution_cnt_30d 
,max(nvl(t5.mh_institution_cnt_90d,0)                       ) as mh_institution_cnt_90d 
,max(nvl(t5.mh_institution_cnt_180d,0)                      ) as mh_institution_cnt_180d
,max(nvl(t5.mh_institution_cnt_360d,0)                      ) as mh_institution_cnt_360d
,max(nvl(t5.mh_institution_cnt_720d,0)                      ) as mh_institution_cnt_720d
,max(nvl(t5.mh_attempted_institutions_day_max_7d  ,0)       ) as mh_attempted_institutions_day_max_7d   
,max(nvl(t5.mh_attempted_institutions_day_max_30d ,0)       ) as mh_attempted_institutions_day_max_30d  
,max(nvl(t5.mh_attempted_institutions_day_max_90d ,0)       ) as mh_attempted_institutions_day_max_90d  
,max(nvl(t5.mh_attempted_institutions_day_max_180d,0)       ) as mh_attempted_institutions_day_max_180d 
,max(nvl(t5.mh_attempted_institutions_day_max_360d,0)       ) as mh_attempted_institutions_day_max_360d 
,max(nvl(t5.mh_attempted_institutions_day_max_720d,0)       ) as mh_attempted_institutions_day_max_720d 
,max(nvl(t5.mh_attempted_institutions_month_max_7d ,0)      ) as mh_attempted_institutions_month_max_7d   
,max(nvl(t5.mh_attempted_institutions_month_max_30d,0)      ) as mh_attempted_institutions_month_max_30d  
,max(nvl(t5.mh_attempted_institutions_month_max_90d,0)      ) as mh_attempted_institutions_month_max_90d  
,max(nvl(t5.mh_attempted_institutions_month_max_180d,0)     ) as mh_attempted_institutions_month_max_180d 
,max(nvl(t5.mh_attempted_institutions_month_max_360d,0)     ) as mh_attempted_institutions_month_max_360d 
,max(nvl(t5.mh_attempted_institutions_month_max_720d,0)     ) as mh_attempted_institutions_month_max_720d 
,max(case when nvl(t5.mh_query_cnt_7d, 0) = 0 then -9999 when t5.mh_consecutive_query_day_min_7d is null then -1 else t5.mh_consecutive_query_day_min_7d end) as mh_consecutive_query_day_min_7d
,max(case when nvl(t5.mh_query_cnt_30d, 0) = 0 then -9999 when t5.mh_consecutive_query_day_min_30d is null then -1 else t5.mh_consecutive_query_day_min_30d end) as mh_consecutive_query_day_min_30d  
,max(case when nvl(t5.mh_query_cnt_90d, 0) = 0 then -9999 when t5.mh_consecutive_query_day_min_90d is null then -1 else t5.mh_consecutive_query_day_min_90d end) as mh_consecutive_query_day_min_90d  
,max(case when nvl(t5.mh_query_cnt_180d, 0) = 0 then -9999 when t5.mh_consecutive_query_day_min_180d is null then -1 else t5.mh_consecutive_query_day_min_180d end) as mh_consecutive_query_day_min_180d 
,max(case when nvl(t5.mh_query_cnt_360d, 0) = 0 then -9999 when t5.mh_consecutive_query_day_min_360d is null then -1 else t5.mh_consecutive_query_day_min_360d end) as mh_consecutive_query_day_min_360d 
,max(case when nvl(t5.mh_query_cnt_720d, 0) = 0 then -9999 when t5.mh_consecutive_query_day_min_720d is null then -1 else t5.mh_consecutive_query_day_min_720d end) as mh_consecutive_query_day_min_720d 
,t5.id
,'${ds}' as grass_date
,t5.task_id
from (
    -- key_type=1: 仅使用ktp_no
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
    ,max(case when t2.req_date<t1.backtest_date then t2.req_date else null end)  as max_query_date
    ,min(case when t2.req_date<t1.backtest_date then t2.req_date else null end ) as min_query_date
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.req_date else null end  )              as mh_query_cnt_7d
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.req_date else null end  )             as mh_query_cnt_30d  
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.req_date else null end  )             as mh_query_cnt_90d  
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_180d 
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_360d 
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_720d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )       as mh_institution_cnt_7d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )      as mh_institution_cnt_30d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )      as mh_institution_cnt_90d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_180d
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_360d
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_720d
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,7) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )   as mh_attempted_institutions_day_max_7d   
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,30) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )  as mh_attempted_institutions_day_max_30d  
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,90) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )  as mh_attempted_institutions_day_max_90d  
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,180) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_180d 
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,360) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_360d 
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,720) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_720d 
    ,max(mh_attempted_institutions_month_max_7d  )                                                                                              as mh_attempted_institutions_month_max_7d   
    ,max(mh_attempted_institutions_month_max_30d )                                                                                              as mh_attempted_institutions_month_max_30d  
    ,max(mh_attempted_institutions_month_max_90d )                                                                                              as mh_attempted_institutions_month_max_90d  
    ,max(mh_attempted_institutions_month_max_180d)                                                                                              as mh_attempted_institutions_month_max_180d 
    ,max(mh_attempted_institutions_month_max_360d)                                                                                              as mh_attempted_institutions_month_max_360d 
    ,max(mh_attempted_institutions_month_max_720d)                                                                                              as mh_attempted_institutions_month_max_720d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.pre_req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )     as mh_consecutive_query_day_min_7d
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.pre_req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )   as mh_consecutive_query_day_min_30d  
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.pre_req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )   as mh_consecutive_query_day_min_90d  
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.pre_req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_180d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.pre_req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_360d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.pre_req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_720d 
    from backtesting_task_info_tmp t1 
    left join (
        -- 先 JOIN 样本再计算 LAG（按 task_id + backtest_date + ktp_no 分区）
        select
            t1_inner.task_id
            ,t1_inner.backtest_date
            ,t2_inner.ktp_no
            ,t2_inner.phone_no
            ,t2_inner.req_date
            ,t2_inner.customer_id
            ,lag(t2_inner.req_date) over (partition by t1_inner.backtest_date, t2_inner.ktp_no order by t2_inner.req_time) as pre_req_date
        from backtesting_task_info_tmp t1_inner
        left join ktp_phone_info_tmp t2_inner on t1_inner.ktp_no = t2_inner.ktp_no
        where t1_inner.key_type = 1
    ) t2 
    on t1.ktp_no = t2.ktp_no
    left join (
        select
        ktp_no  
        ,req_date
        ,count(distinct app_id) as query_institutions_cnt
        from ktp_phone_info_tmp
        group by ktp_no  
        ,req_date
    ) t3 on t1.ktp_no = t3.ktp_no
    left join ktp_metric_tmp t4 on t1.ktp_no = t4.ktp_no 
    where t1.key_type =1 
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
    union all 
    -- key_type=2: 仅使用phone_no
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no  
    ,max(case when t2.req_date<t1.backtest_date then t2.req_date else null end)  as max_query_date
    ,min(case when t2.req_date<t1.backtest_date then t2.req_date else null end ) as min_query_date
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.req_date else null end  )              as mh_query_cnt_7d
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.req_date else null end  )             as mh_query_cnt_30d  
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.req_date else null end  )             as mh_query_cnt_90d  
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_180d 
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_360d 
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_720d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )       as mh_institution_cnt_7d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )      as mh_institution_cnt_30d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )      as mh_institution_cnt_90d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_180d
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_360d
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_720d
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,7) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )   as mh_attempted_institutions_day_max_7d   
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,30) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )  as mh_attempted_institutions_day_max_30d  
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,90) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )  as mh_attempted_institutions_day_max_90d  
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,180) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_180d 
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,360) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_360d 
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,720) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_720d 
    ,max(mh_attempted_institutions_month_max_7d  )                                                                                              as mh_attempted_institutions_month_max_7d   
    ,max(mh_attempted_institutions_month_max_30d )                                                                                              as mh_attempted_institutions_month_max_30d  
    ,max(mh_attempted_institutions_month_max_90d )                                                                                              as mh_attempted_institutions_month_max_90d  
    ,max(mh_attempted_institutions_month_max_180d)                                                                                              as mh_attempted_institutions_month_max_180d 
    ,max(mh_attempted_institutions_month_max_360d)                                                                                              as mh_attempted_institutions_month_max_360d 
    ,max(mh_attempted_institutions_month_max_720d)                                                                                              as mh_attempted_institutions_month_max_720d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.pre_req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )     as mh_consecutive_query_day_min_7d
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.pre_req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )   as mh_consecutive_query_day_min_30d  
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.pre_req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )   as mh_consecutive_query_day_min_90d  
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.pre_req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_180d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.pre_req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_360d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.pre_req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_720d 
    from backtesting_task_info_tmp t1 
    left join (
        -- 先 JOIN 样本再计算 LAG（按 task_id + backtest_date + phone_no 分区）
        select
            t1_inner.task_id
            ,t1_inner.backtest_date
            ,t2_inner.ktp_no
            ,t2_inner.phone_no
            ,t2_inner.req_date
            ,t2_inner.customer_id
            ,lag(t2_inner.req_date) over (partition by t1_inner.backtest_date, t2_inner.phone_no order by t2_inner.req_time) as pre_req_date
        from backtesting_task_info_tmp t1_inner
        left join ktp_phone_info_tmp t2_inner on t1_inner.phone_no = t2_inner.phone_no
        where t1_inner.key_type = 2
    ) t2 
    on t1.phone_no = t2.phone_no
    left join (
        select
        phone_no  
        ,req_date
        ,count(distinct app_id) as query_institutions_cnt
        from ktp_phone_info_tmp
        group by phone_no  
        ,req_date
    ) t3 on t1.phone_no = t3.phone_no
    left join phone_metric_tmp t4 on t1.phone_no = t4.phone_no 
    where t1.key_type =2 
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
    union all 
    -- key_type=3: 使用ktp_no或phone_no
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no 
    ,max(case when t2.req_date<t1.backtest_date then t2.req_date else null end)  as max_query_date
    ,min(case when t2.req_date<t1.backtest_date then t2.req_date else null end ) as min_query_date
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.req_date else null end  )              as mh_query_cnt_7d
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.req_date else null end  )             as mh_query_cnt_30d  
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.req_date else null end  )             as mh_query_cnt_90d  
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_180d 
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_360d 
    ,count(case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.req_date else null end  )            as mh_query_cnt_720d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )       as mh_institution_cnt_7d  
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )      as mh_institution_cnt_30d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )      as mh_institution_cnt_90d 
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_180d
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_360d
    ,count(distinct case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date then t2.customer_id else null end  )     as mh_institution_cnt_720d
    ,null  as mh_attempted_institutions_day_max_7d   
    ,null  as mh_attempted_institutions_day_max_30d  
    ,null  as mh_attempted_institutions_day_max_90d  
    ,null  as mh_attempted_institutions_day_max_180d 
    ,null  as mh_attempted_institutions_day_max_360d 
    ,null  as mh_attempted_institutions_day_max_720d 
    ,null  as mh_attempted_institutions_month_max_7d   
    ,null  as mh_attempted_institutions_month_max_30d  
    ,null  as mh_attempted_institutions_month_max_90d  
    ,null  as mh_attempted_institutions_month_max_180d 
    ,null  as mh_attempted_institutions_month_max_360d 
    ,null  as mh_attempted_institutions_month_max_720d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,7) and t2.pre_req_date>=date_sub(t1.backtest_date,7) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )     as mh_consecutive_query_day_min_7d
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,30) and t2.pre_req_date>=date_sub(t1.backtest_date,30) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )   as mh_consecutive_query_day_min_30d  
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,90) and t2.pre_req_date>=date_sub(t1.backtest_date,90) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end )   as mh_consecutive_query_day_min_90d  
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,180) and t2.pre_req_date>=date_sub(t1.backtest_date,180) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_180d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,360) and t2.pre_req_date>=date_sub(t1.backtest_date,360) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_360d 
    ,min(case when t2.req_date>=date_sub(t1.backtest_date,720) and t2.pre_req_date>=date_sub(t1.backtest_date,720) and t2.req_date<t1.backtest_date and t2.pre_req_date<t1.backtest_date then datediff(t2.req_date, t2.pre_req_date) else null end ) as mh_consecutive_query_day_min_720d 
    from backtesting_task_info_tmp t1 
    left join (
        -- 先 JOIN 样本再计算 LAG（按 task_id + backtest_date + ktp_no + phone_no 分区）
        select
            t1_inner.task_id
            ,t1_inner.backtest_date
            ,t2_inner.ktp_no
            ,t2_inner.phone_no
            ,t2_inner.req_date
            ,t2_inner.customer_id
            ,lag(t2_inner.req_date) over (partition by t1_inner.backtest_date, t2_inner.ktp_no, t2_inner.phone_no order by t2_inner.req_time) as pre_req_date
        from backtesting_task_info_tmp t1_inner
        left join ktp_phone_info_tmp t2_inner on t1_inner.ktp_no = t2_inner.ktp_no or t1_inner.phone_no = t2_inner.phone_no
        where t1_inner.key_type = 3
    ) t2 
    on t1.ktp_no = t2.ktp_no or t1.phone_no = t2.phone_no
    where t1.key_type =3
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
    union all 
    -- key_type=3: 补充mh_attempted_institutions_day_max指标
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no  
    ,null as max_query_date
    ,null as min_query_date
    ,null as mh_query_cnt_7d
    ,null as mh_query_cnt_30d  
    ,null as mh_query_cnt_90d  
    ,null as mh_query_cnt_180d 
    ,null as mh_query_cnt_360d 
    ,null as mh_query_cnt_720d 
    ,null as mh_institution_cnt_7d  
    ,null as mh_institution_cnt_30d 
    ,null as mh_institution_cnt_90d 
    ,null as mh_institution_cnt_180d
    ,null as mh_institution_cnt_360d
    ,null as mh_institution_cnt_720d
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,7) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )   as mh_attempted_institutions_day_max_7d   
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,30) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )  as mh_attempted_institutions_day_max_30d  
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,90) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end )  as mh_attempted_institutions_day_max_90d  
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,180) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_180d 
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,360) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_360d 
    ,max(case when t3.req_date>=date_sub(t1.backtest_date,720) and t3.req_date<t1.backtest_date then t3.query_institutions_cnt else null end ) as mh_attempted_institutions_day_max_720d 
    ,null  as mh_attempted_institutions_month_max_7d   
    ,null  as mh_attempted_institutions_month_max_30d  
    ,null  as mh_attempted_institutions_month_max_90d  
    ,null  as mh_attempted_institutions_month_max_180d 
    ,null  as mh_attempted_institutions_month_max_360d 
    ,null  as mh_attempted_institutions_month_max_720d 
    ,null  as mh_consecutive_query_day_min_7d
    ,null  as mh_consecutive_query_day_min_30d  
    ,null  as mh_consecutive_query_day_min_90d  
    ,null  as mh_consecutive_query_day_min_180d 
    ,null  as mh_consecutive_query_day_min_360d 
    ,null  as mh_consecutive_query_day_min_720d 
    from backtesting_task_info_tmp t1 
    left join (
        select
        ktp_no
        ,phone_no  
        ,req_date
        ,count(distinct app_id) as query_institutions_cnt
        from ktp_phone_info_tmp
        group by ktp_no,phone_no  
        ,req_date
    ) t3 on t1.ktp_no = t3.ktp_no
             or t1.phone_no = t3.phone_no
    where t1.key_type =3
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
    union all 
    -- key_type=3
    select 
    t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
    ,null as max_query_date
    ,null as min_query_date
    ,null as mh_query_cnt_7d
    ,null as mh_query_cnt_30d  
    ,null as mh_query_cnt_90d  
    ,null as mh_query_cnt_180d 
    ,null as mh_query_cnt_360d 
    ,null as mh_query_cnt_720d 
    ,null as mh_institution_cnt_7d  
    ,null as mh_institution_cnt_30d 
    ,null as mh_institution_cnt_90d 
    ,null as mh_institution_cnt_180d
    ,null as mh_institution_cnt_360d
    ,null as mh_institution_cnt_720d
    ,null as mh_attempted_institutions_day_max_7d   
    ,null as mh_attempted_institutions_day_max_30d  
    ,null as mh_attempted_institutions_day_max_90d  
    ,null as mh_attempted_institutions_day_max_180d 
    ,null as mh_attempted_institutions_day_max_360d 
    ,null as mh_attempted_institutions_day_max_720d 
    ,max(mh_attempted_institutions_month_max_7d  )                                                                                              as mh_attempted_institutions_month_max_7d   
    ,max(mh_attempted_institutions_month_max_30d )                                                                                              as mh_attempted_institutions_month_max_30d  
    ,max(mh_attempted_institutions_month_max_90d )                                                                                              as mh_attempted_institutions_month_max_90d  
    ,max(mh_attempted_institutions_month_max_180d)                                                                                              as mh_attempted_institutions_month_max_180d 
    ,max(mh_attempted_institutions_month_max_360d)                                                                                              as mh_attempted_institutions_month_max_360d 
    ,max(mh_attempted_institutions_month_max_720d)                                                                                              as mh_attempted_institutions_month_max_720d 
    ,null as mh_consecutive_query_day_min_7d
    ,null as mh_consecutive_query_day_min_30d  
    ,null as mh_consecutive_query_day_min_90d  
    ,null as mh_consecutive_query_day_min_180d 
    ,null as mh_consecutive_query_day_min_360d 
    ,null as mh_consecutive_query_day_min_720d 
    from backtesting_task_info_tmp t1 
    left join ktp_phone_metric_tmp t4 on t1.ktp_no = t4.ktp_no or t1.phone_no = t4.phone_no 
    where t1.key_type =3
    group by t1.task_id       
    ,t1.id
    ,t1.backtest_date
    ,t1.ktp_no,t1.phone_no
) t5 
group by t5.task_id       
,t5.id
,t5.backtest_date
,t5.ktp_no,t5.phone_no
distribute by t5.task_id, t5.backtest_date
;
