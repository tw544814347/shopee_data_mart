-- =====================================================
-- 优化说明：
-- 1. 原问题：tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live 表数据量太大，全表扫描导致任务跑不动
-- 2. 优化方案：将全表扫描拆分为4个时间段，每段先落临时表，最后再UNION ALL合并
-- =====================================================

create or replace temporary function json_to_map as 'com.shopee.seamoney.udf.JsonToMap' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';
create or replace temporary function json_to_array as 'com.shopee.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function dps_decrypt as 'com.shopee.udf.AESDecryptUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function interval_merge as 'com.shopee.udf.IntervalMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function range_merge as 'com.shopee.udf.RangeMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

-- =====================================================
-- 第一部分：构建temp1表 - 按时间段分批处理，每段先落临时表再合并
-- =====================================================

-- 批次1：
drop table if exists risk.dwd_datapoint_applist_zi_init_temp1_batch1;
create table risk.dwd_datapoint_applist_zi_init_temp1_batch1
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
/*+REPARTITION(500)*/
    advertisement_id,app_version,client_id,client_ip,country,device_fingerprint,deviceid,env,event_timestamp,log_timestamp,platform,platform_id,trigger_source,userid,grass_date
from
(
    select
        advertisement_id,app_version,client_id,client_ip,country,device_fingerprint,deviceid,env,event_timestamp,log_timestamp,platform,app_id as platform_id,trigger_source,userid,grass_date
        ,row_number() over (partition by userid,deviceid,grass_date order by event_timestamp desc) rn
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date < '2023-01-01'
        and userid is not null
) t
where rn = 1
;

-- 批次2：
drop table if exists risk.dwd_datapoint_applist_zi_init_temp1_batch2;
create table risk.dwd_datapoint_applist_zi_init_temp1_batch2
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
/*+REPARTITION(500)*/
    advertisement_id,app_version,client_id,client_ip,country,device_fingerprint,deviceid,env,event_timestamp,log_timestamp,platform,platform_id,trigger_source,userid,grass_date
from
(
    select
        advertisement_id,app_version,client_id,client_ip,country,device_fingerprint,deviceid,env,event_timestamp,log_timestamp,platform,app_id as platform_id,trigger_source,userid,grass_date
        ,row_number() over (partition by userid,deviceid,grass_date order by event_timestamp desc) rn
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date >= '2023-01-01' and grass_date < '2025-01-01'
        and userid is not null
) t
where rn = 1
;

-- 批次3：
drop table if exists risk.dwd_datapoint_applist_zi_init_temp1_batch3;
create table risk.dwd_datapoint_applist_zi_init_temp1_batch3
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
/*+REPARTITION(500)*/
    advertisement_id,app_version,client_id,client_ip,country,device_fingerprint,deviceid,env,event_timestamp,log_timestamp,platform,platform_id,trigger_source,userid,grass_date
from
(
    select
        advertisement_id,app_version,client_id,client_ip,country,device_fingerprint,deviceid,env,event_timestamp,log_timestamp,platform,app_id as platform_id,trigger_source,userid,grass_date
        ,row_number() over (partition by userid,deviceid,grass_date order by event_timestamp desc) rn
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date >= '2025-01-01' and grass_date <= '2026-02-03'
        and userid is not null
) t
where rn = 1
;

-- 合并所有批次到最终temp1表
drop table if exists risk.dwd_datapoint_applist_zi_init_temp1;
create table risk.dwd_datapoint_applist_zi_init_temp1
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select * from risk.dwd_datapoint_applist_zi_init_temp1_batch1
union all
select * from risk.dwd_datapoint_applist_zi_init_temp1_batch2
union all
select * from risk.dwd_datapoint_applist_zi_init_temp1_batch3
;


-- =====================================================
-- 第二部分：构建temp2表 - 按时间段分批处理，每段先落临时表再合并
-- =====================================================

-- 批次1：
drop table if exists risk.dwd_datapoint_applist_zi_init_temp2_batch1;
create table risk.dwd_datapoint_applist_zi_init_temp2_batch1
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
    userid
    ,deviceid
    ,event_timestamp
    ,get_json_object(app,'$.app_id') as app_id
    ,get_json_object(app,'$.app_name') as app_name
    ,get_json_object(app,'$.first_installed_time') as first_installed_time
    ,get_json_object(app,'$.last_updated_time') as last_updated_time
from
(
    select
        userid
        ,deviceid
        ,event_timestamp
        ,json_to_array(nvl(get_json_object(dps_decrypt(data),'$.app_info'),get_json_object(dps_decrypt(data),'$.a'))) as app_list
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date < '2023-01-01'
        and userid is not null
) t LATERAL VIEW explode(app_list) A as app
;

-- 批次2：
drop table if exists risk.dwd_datapoint_applist_zi_init_temp2_batch2;
create table risk.dwd_datapoint_applist_zi_init_temp2_batch2
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
    userid
    ,deviceid
    ,event_timestamp
    ,get_json_object(app,'$.app_id') as app_id
    ,get_json_object(app,'$.app_name') as app_name
    ,get_json_object(app,'$.first_installed_time') as first_installed_time
    ,get_json_object(app,'$.last_updated_time') as last_updated_time
from
(
    select
        userid
        ,deviceid
        ,event_timestamp
        ,json_to_array(nvl(get_json_object(dps_decrypt(data),'$.app_info'),get_json_object(dps_decrypt(data),'$.a'))) as app_list
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date >= '2023-01-01' and grass_date < '2025-01-01'
        and userid is not null
) t LATERAL VIEW explode(app_list) A as app
;

-- 批次3：
drop table if exists risk.dwd_datapoint_applist_zi_init_temp2_batch3;
create table risk.dwd_datapoint_applist_zi_init_temp2_batch3
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
    userid
    ,deviceid
    ,event_timestamp
    ,get_json_object(app,'$.app_id') as app_id
    ,get_json_object(app,'$.app_name') as app_name
    ,get_json_object(app,'$.first_installed_time') as first_installed_time
    ,get_json_object(app,'$.last_updated_time') as last_updated_time
from
(
    select
        userid
        ,deviceid
        ,event_timestamp
        ,json_to_array(nvl(get_json_object(dps_decrypt(data),'$.app_info'),get_json_object(dps_decrypt(data),'$.a'))) as app_list
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date >= '2025-01-01' and grass_date <= '2026-02-03'
        and userid is not null
) t LATERAL VIEW explode(app_list) A as app
;

-- 合并所有批次并去重，生成最终temp2表
drop table if exists risk.dwd_datapoint_applist_zi_init_temp2;
create table risk.dwd_datapoint_applist_zi_init_temp2
stored as orc
tblproperties ("orc.compress"="SNAPPY")
as
select
    userid
    ,deviceid
    ,app_id
    ,app_name
    ,first_installed_time
    ,last_updated_time
from
(
    select
        userid
        ,deviceid
        ,event_timestamp
        ,app_id
        ,app_name
        ,first_installed_time
        ,last_updated_time
        ,row_number() over (partition by userid,deviceid,app_id order by event_timestamp desc) rn
    from
    (
        select * from risk.dwd_datapoint_applist_zi_init_temp2_batch1
        union all
        select * from risk.dwd_datapoint_applist_zi_init_temp2_batch2
        union all
        select * from risk.dwd_datapoint_applist_zi_init_temp2_batch3
    ) combined
) a
where a.rn = 1
;

-- =====================================================
-- 第三部分：生成最终结果表
-- =====================================================

drop table if exists risk.dwd_datapoint_applist_zi_uat;
create table risk.dwd_datapoint_applist_zi_uat
stored as orc as
select
	t2.advertisement_id
	,t2.app_version
	,t2.client_id
	,t2.client_ip
	,t2.country
	,t2.device_fingerprint
	,t1.deviceid as device_id
	,t2.env
	,t2.event_timestamp
	,t2.log_timestamp
	,t2.platform
	,t2.trigger_source
	,t1.userid as user_id
    ,t1.appid as app_id
    ,t3.app_name
    ,cast(t3.first_installed_time as string) as first_installed_time
    ,cast(t3.last_updated_time as string) as last_updated_time
    ,replace(t1.start_date,'"','') as start_date
    ,t2.platform_id
    ,'ID' as grass_region
    ,replace(t1.end_date,'"','') as end_date
from
(
    select
        userid
        ,deviceid
        ,appid
        ,start_date
        ,end_date
    from risk.dwd_datapoint_applist_interval_merge
) t1
left join risk.dwd_datapoint_applist_zi_init_temp1 t2
on t1.userid = t2.userid
    and t1.deviceid = t2.deviceid
    and replace(t1.start_date,'"','') = t2.grass_date
left join
(
    select
        userid
        ,deviceid
        ,app_id
        ,app_name
        ,first_installed_time
        ,last_updated_time
    from risk.dwd_datapoint_applist_zi_init_temp2
) t3
on t1.userid = t3.userid
    and t1.deviceid = t3.deviceid
    and t1.appid = t3.app_id
;