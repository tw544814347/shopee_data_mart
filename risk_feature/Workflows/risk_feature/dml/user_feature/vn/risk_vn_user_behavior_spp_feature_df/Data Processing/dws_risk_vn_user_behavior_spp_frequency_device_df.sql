------------------------------------------------------------------------
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-02-03
-- Description:         用户行为主题域，Risk ToC主题
-- Data Granularity:    shopeepay user id 
-- PRD:                 
------------------------------------------------------------------------


-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_frequency_device_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_frequency_device_df
(
    shopeepay_user_id string comment 'shopeepay_user_id' ,
    spdf_list string comment 'spdf_list' ,
    szdf_list string comment 'szdf_list' 
) 
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_${region}_user_behavior_spp_frequency_device_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_frequency_device_df;


add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


create or replace temporary view tmp_risk_strategy_final_result as
    select 
    a.flow_no
    ,a.platform_user_id
    ,a.shopeepay_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'${grass_region}') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'${grass_region}'                                                                                 as grass_region
from risk.dwd_risk_${region}_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = '${grass_region}'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
        topic_name
        ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=date_sub('${grass_date}',190)
and grass_date<='${grass_date}'
-- and device_fingerprint is not null
-- and device_fingerprint <>''
-- and device_fingerprint <>' '
group by a.flow_no
        ,a.platform_user_id
        ,a.shopeepay_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'${grass_region}')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')
;

create or replace temporary view tmp_workflow_tab as
select 
    flow_no
    ,'${grass_region}' as grass_region
from  risk.dwd_risk_${region}_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',190)
--and from_unixtime(create_time)>= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by  flow_no
;

with tmp1 as (
    select 
        cast(t1.shopeepay_user_id as string) as shopeepay_user_id
        ,case when t1.shopeepay_user_id is not null and t1.spdf_list <> '[]' then regexp_replace(regexp_replace(t1.spdf_list,',]',']'),'\\[,','[')
            else null end                       as spdf_list
        ,case when t1.shopeepay_user_id is not null and t1.szdf_list <> '[]' then regexp_replace(regexp_replace(t1.szdf_list,',]',']'),'\\[,','[')
            else null end                       as szdf_list
    from (
        select 
            shopeepay_user_id
            ,regexp_replace(array_distinct(collect_list(device_fingerprint)),'"','') as spdf_list
            ,regexp_replace(array_distinct(collect_list(szdf)),'"','')               as szdf_list
            ,grass_region                                                            as grass_region
            ,'${grass_date}'                                                         as grass_date
        from (
            select 
                a.shopeepay_user_id
                ,a.device_fingerprint
                ,a.szdf
                ,case when a.topic_name like '%_live_credit_risk_gateway_req_rsp_kredit' and risk_scene_id='10013' and a.is_spl_activated = '1' then 0
                    when a.topic_name like '%_live_credit_risk_gateway_req_rsp_spj' and risk_scene_id='10013' and a.is_cashloan_activated = '1' then 0
                    else 1 end as is_available
                ,a.grass_region
            from tmp_risk_strategy_final_result a 
            join tmp_workflow_tab b on a.workflow_flow_no= b.flow_no and a.grass_region = b.grass_region
            where to_date(a.req_time_local)>= date_sub('${grass_date}',181)
        ) a 
        where is_available=1
        group by shopeepay_user_id,grass_region
    ) t1
)

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_frequency_device_df partition (grass_date = '${grass_date}')
select 
    a.shopeepay_user_id as shopeepay_user_id
    ,tmp1.spdf_list
    ,tmp1.szdf_list
from (
    select cast(shopeepay_user_id as string) as shopeepay_user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where grass_date = '${grass_date}'
) as a
left join tmp1 on a.shopeepay_user_id = tmp1.shopeepay_user_id
;