--修改点
--1.tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live 的地区
--2.第30行，分时间段跑的区间

create or replace temporary function json_to_map as 'com.shopee.seamoney.udf.JsonToMap' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';
create or replace temporary function json_to_array as 'com.shopee.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function dps_decrypt as 'com.shopee.udf.AESDecryptUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function interval_merge as 'com.shopee.udf.IntervalMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function range_merge as 'com.shopee.udf.RangeMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';


drop table if exists risk.dwd_risk_applist_temp11;
create table risk.dwd_risk_applist_temp11
stored as orc as
select
	userid
	,deviceid
	,concat_ws(',',collect_set(get_json_object(app,'$.app_id'))) as applist
	,grass_date
from
(
    select
        userid
        ,deviceid
        ,json_to_array(nvl(get_json_object(dps_decrypt(data),'$.app_info'),get_json_object(dps_decrypt(data),'$.a'))) as app_list
        ,grass_date
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__id_s1_live
    where grass_date >= '2022-08-01'
        and grass_date < '2024-02-01'
        and userid is not null
        and deviceid is not null
) t LATERAL VIEW explode(app_list) A as app
group by userid,deviceid,grass_date
;

drop table if exists risk.dwd_risk_applist_temp22;
create table risk.dwd_risk_applist_temp22
stored as orc as
select
    userid
    ,deviceid
    ,range_merge('','',date_applist) as applist_date
from
(
    select
        userid
        ,deviceid
        ,sort_array(collect_list(concat(cast(grass_date as string), ':' ,applist))) as date_applist
    from risk.dwd_risk_applist_temp11
    where coalesce(trim(applist), '') <> ''
    group by userid
            ,deviceid
) t
;

drop table if exists risk.dwd_risk_applist_2;
create table risk.dwd_risk_applist_2
stored as orc as
select
    userid
    ,deviceid
    ,appid
    ,datelist
from
(
	select
	    userid
	    ,deviceid
	    ,json_to_map(applist_date) as applist_date
	from risk.dwd_risk_applist_temp22
) t LATERAL VIEW explode(applist_date) A as appid, datelist
;
