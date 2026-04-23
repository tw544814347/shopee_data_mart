create or replace temporary function json_to_map as 'com.shopee.seamoney.udf.JsonToMap' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';
create or replace temporary function json_to_array as 'com.shopee.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function dps_decrypt as 'com.shopee.udf.AESDecryptUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function interval_merge as 'com.shopee.udf.IntervalMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function range_merge as 'com.shopee.udf.RangeMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

drop table if exists risk.dwd_datapoint_applist_interval_merge_temp1;
create table risk.dwd_datapoint_applist_interval_merge_temp1
stored as orc as
select
    /*+REPARTITION(1000)*/
    coalesce(t1.userid,t2.userid,t3.userid,t4.userid) as userid
    ,coalesce(t1.deviceid,t2.deviceid,t3.deviceid,t4.deviceid) as deviceid
    ,coalesce(t1.appid,t2.appid,t3.appid,t4.appid) as appid
    ,sort_array(array_union(array_union(array_union(json_to_array(nvl(t1.datelist,'[]')), json_to_array(nvl(t2.datelist,'[]'))), json_to_array(nvl(t3.datelist,'[]'))), json_to_array(nvl(t4.datelist,'[]'))  )) as datelist
from risk.dwd_risk_applist_1 t1
full outer join risk.dwd_risk_applist_2 t2
on t1.userid = t2.userid
    and t1.deviceid = t2.deviceid
    and t1.appid = t2.appid
full outer join risk.dwd_risk_applist_3 t3
on coalesce(t1.userid,t2.userid) = t3.userid
    and coalesce(t1.deviceid,t2.deviceid) = t3.deviceid
    and coalesce(t1.appid,t2.appid) = t3.appid
full outer join risk.dwd_risk_applist_4 t4
on coalesce(t1.userid,t2.userid,t3.userid) = t4.userid
    and coalesce(t1.deviceid,t2.deviceid,t3.deviceid) = t4.deviceid
    and coalesce(t1.appid,t2.appid,t3.appid) = t4.appid
;

drop table if exists risk.dwd_datapoint_applist_interval_merge_temp2;
create table risk.dwd_datapoint_applist_interval_merge_temp2
stored as orc as
select
    userid
    ,deviceid
    ,appid
    ,interval_merge(datelist) as datelist
from risk.dwd_datapoint_applist_interval_merge_temp1
;

drop table if exists risk.dwd_datapoint_applist_interval_merge;
create table risk.dwd_datapoint_applist_interval_merge
stored as orc as
select
    userid
    ,deviceid
    ,appid
    ,json_to_array(applist_interval)[0] as start_date
    ,json_to_array(applist_interval)[1] as end_date
from
(
    select
        userid
        ,deviceid
        ,appid
        ,json_to_array(datelist) as datelist
    from risk.dwd_datapoint_applist_interval_merge_temp2
) t LATERAL VIEW explode(datelist) A as applist_interval
;