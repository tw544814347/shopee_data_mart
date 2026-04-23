create or replace temporary function json_to_map as 'com.shopee.seamoney.udf.JsonToMap' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';
create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';
create or replace temporary function dps_decrypt as 'com.shopee.udf.AESDecryptUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function interval_merge as 'com.shopee.udf.IntervalMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function range_merge as 'com.shopee.udf.RangeMergeUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

create or replace temporary view dwd_risk_applist_di as
select
        advertisement_id
        ,app_version
        ,client_id
        ,client_ip
        ,country
        ,device_fingerprint
        ,deviceid as device_id
        ,env
        ,event_timestamp
        ,log_timestamp
        ,platform
        ,trigger_source
        ,userid as user_id
        ,get_json_object(app,'$.app_id') as app_id
        ,get_json_object(app,'$.app_name') as app_name
        ,get_json_object(app,'$.first_installed_time') as first_installed_time
        ,get_json_object(app,'$.last_updated_time') as last_updated_time
        ,app_id as platform_id
        ,grass_date
from
(
    select
        *
        ,json_to_array(nvl(get_json_object(dps_decrypt(data),'$.app_info'),get_json_object(dps_decrypt(data),'$.a'))) as app_list
    from tracking.shopee_tracking_ods_dps_merge_installed_app_di__my_s1_live
    where grass_date = '${bizdate}'
        and userid is not null
) t LATERAL VIEW explode(app_list) A as app
;

drop table if exists ${SCHEMA}.dwd_risk_applist_dist_my_di;
create table ${SCHEMA}.dwd_risk_applist_dist_my_di stored as orc as 
select * from
(
select
        *
        ,row_number() over (partition by user_id,device_id,app_id order by event_timestamp desc) rn
from dwd_risk_applist_di
) t
where rn = 1
;

create or replace temporary view dwd_risk_applist_temp1 as
select
	user_id
	,device_id
	,concat_ws(',',collect_set(app_id)) as applist
	,grass_date
from ${SCHEMA}.dwd_risk_applist_dist_my_di
group by user_id,device_id,grass_date
;

create or replace temporary view dwd_risk_applist_temp2 as
select
    user_id
    ,device_id
    ,concat_ws(',',collect_set(app_id)) as applist
    ,date_sub('${bizdate}',1) as grass_date
from risk.dwd_datapoint_applist_zi
where grass_region = 'MY'
    and end_date = '9999-12-31'
group by user_id,device_id
;

create or replace temporary view dwd_risk_applist_temp3 as
select
    user_id
    ,device_id
    ,range_merge('','',date_applist) as applist_date
from
(
    select /*+REPARTITION(2000)*/
        user_id
        ,device_id
        ,sort_array(collect_list(concat(cast(grass_date as string), ':' ,applist))) as date_applist
    from
        (
            select
                user_id
                ,device_id
                ,applist
                ,grass_date
            from dwd_risk_applist_temp1
            union all
            select
                user_id
                ,device_id
                ,applist
                ,grass_date
            from dwd_risk_applist_temp2
        )
    group by user_id
            ,device_id
) t
;

create or replace temporary view dwd_risk_applist_temp4 as
select
    user_id
    ,device_id
    ,app_id
    ,datelist
from
(
	select
	    user_id
	    ,device_id
	    ,json_to_map(applist_date) as applist_date
	from dwd_risk_applist_temp3
) t LATERAL VIEW explode(applist_date) A as app_id, datelist
;

create or replace temporary view dwd_risk_my_applist_temp5 as
select
    user_id
    ,device_id
    ,app_id
    ,replace(json_to_array(applist_interval)[0],'"','') as start_date
    ,replace(json_to_array(applist_interval)[1],'"','') as end_date
from
(
    select
        user_id
        ,device_id
        ,app_id
        ,json_to_array(datelist) as datelist
    from dwd_risk_applist_temp4
) t LATERAL VIEW explode(datelist) A as applist_interval
;


INSERT OVERWRITE TABLE ${SCHEMA}.dwd_datapoint_applist_zi PARTITION(grass_region, end_date)
select /*+REPARTITION(3000)*/
	coalesce(t3.advertisement_id,t2.advertisement_id) as advertisement_id
	,coalesce(t3.app_version,t2.app_version) as app_version
	,coalesce(t3.client_id,t2.client_id) as client_id
	,coalesce(t3.client_ip,t2.client_ip) as client_ip
	,coalesce(t3.country,t2.country) as country
	,coalesce(t3.device_fingerprint,t2.device_fingerprint) as device_fingerprint
	,t1.device_id
	,coalesce(t3.env,t2.env) as env
	,coalesce(t3.event_timestamp,t2.event_timestamp) as event_timestamp
	,coalesce(t3.log_timestamp,t2.log_timestamp) as log_timestamp
	,coalesce(t3.platform,t2.platform) as platform
	,coalesce(t3.trigger_source,t2.trigger_source) as trigger_source
	,t1.user_id
    ,t1.app_id
    ,coalesce(t3.app_name,t2.app_name) as app_name
    ,cast(coalesce(t3.first_installed_time,t2.first_installed_time) as string) as first_installed_time
    ,cast(coalesce(t3.last_updated_time,t2.last_updated_time) as string) as last_updated_time
    ,case when t1.start_date = date_sub('${bizdate}',1) then t2.start_date else '${bizdate}' end as start_date
    ,coalesce(t3.platform_id,t2.platform_id) as platform_id
    ,'MY' as grass_region
    ,t1.end_date
from dwd_risk_my_applist_temp5 t1
left join
(
    select
        *
    from risk.dwd_datapoint_applist_zi
    where grass_region = 'MY'
        and end_date = '9999-12-31'
) t2
on t1.user_id = t2.user_id
    and t1.device_id = t2.device_id
    and t1.app_id = t2.app_id
left join ${SCHEMA}.dwd_risk_applist_dist_my_di t3
on t1.user_id = t3.user_id
    and t1.device_id = t3.device_id
    and t1.app_id = t3.app_id
;

