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
    succ_device_list_6m string comment 'succ_device_list_6m' ,
    succ_szdf_list_6m string comment 'succ_szdf_list_6m' ,
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


drop table if exists tmp_risk_strategy_final_result_${region};
create table tmp_risk_strategy_final_result_${region} as
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
) b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=date_sub('${grass_date}',190)
    and grass_date<='${grass_date}'
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

drop table if exists tmp_workflow_tab_${region};
create table tmp_workflow_tab_${region} as
select 
    flow_no
    ,'${grass_region}' as grass_region
from  risk.dwd_risk_${region}_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%'
group by flow_no
;

with dws_risk_th_user_behavior_spp_frequency_device_df_tmp1_${region} as (
    select
        shopeepay_user_id
        ,cast(collect_set(device_fingerprint) as string) as succ_device_list_6m
        ,cast(
            collect_set(
                get_json_object(
                    extension
                    ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
                )
            ) as string
        ) as succ_szdf_list_6m
    from risk.dwd_risk_${region}_strategy_final_result_merge_di
    where
        (
            device_fingerprint is not null
            or get_json_object(
                extension
                ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
            ) is not null
        )
        and (
            device_fingerprint <> ''
            or get_json_object(
                extension
                ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
            ) <> ''
        )
        and (
            trim(device_fingerprint) <> ''
            or trim(
                get_json_object(
                    extension
                    ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
                )
            ) <> ''
        )
        and final_result = 1
        and topic_name in (
                'th_live_credit_risk_gateway_req_rsp_kredit'
                ,'th_live_credit_risk_gateway_req_rsp_spj'
                ,'th_live_credit_risk_gateway_req_rsp_spjup'
                ,'th_live_credit_risk_gateway_req_rsp_fes'
            )
            and (
                concat(topic_name, '_', risk_scene_id) in (
                    'th_live_credit_risk_gateway_req_rsp_kredit_10013'
                    ,'th_live_credit_risk_gateway_req_rsp_kredit_10001'
                    ,'th_live_credit_risk_gateway_req_rsp_spj_10013'
                    ,'th_live_credit_risk_gateway_req_rsp_spj_10001'
                    ,'th_live_credit_risk_gateway_req_rsp_spjup_10003'
                    ,'th_live_credit_risk_gateway_req_rsp_spjup_10001'
                    ,'th_live_credit_risk_gateway_req_rsp_fe_10013'
                )
                or (
                    grass_date >= add_months('${grass_date}', 12)
                    and concat(topic_name, '_', risk_scene_id) in (
                        'th_live_credit_risk_gateway_req_rsp_kredit_10024'
                        ,'th_live_credit_risk_gateway_req_rsp_kredit_10025'
                        ,'th_live_credit_risk_gateway_req_rsp_kredit_10035'
                        ,'th_live_credit_risk_gateway_req_rsp_kredit_10034'
                        ,'th_live_credit_risk_gateway_req_rsp_spj_10024'
                        ,'th_live_credit_risk_gateway_req_rsp_spj_10025'
                        ,'th_live_credit_risk_gateway_req_rsp_spj_10026'
                        ,'th_live_credit_risk_gateway_req_rsp_spjup_10004'
                        ,'th_live_credit_risk_gateway_req_rsp_spjup_10005'
                        ,'th_live_credit_risk_gateway_req_rsp_fes_10004'
                        ,'th_live_credit_risk_gateway_req_rsp_fes_10005'
                    )
                )
            )
    group by --platform_user_id,
        shopeepay_user_id 
),
dws_risk_th_user_behavior_spp_frequency_device_df_tmp2_${region} as (
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
            from tmp_risk_strategy_final_result_${region} a 
            join tmp_workflow_tab_${region} b on a.workflow_flow_no= b.flow_no and a.grass_region = b.grass_region
            where to_date(a.req_time_local)>= date_sub('${grass_date}',181)
        ) a 
        where is_available=1
        group by shopeepay_user_id,grass_region
    ) t1
)

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_frequency_device_df partition (grass_date = '${grass_date}')
select 
    a.shopeepay_user_id as shopeepay_user_id
    ,dws_risk_th_user_behavior_spp_frequency_device_df_tmp1_${region}.succ_device_list_6m
    ,dws_risk_th_user_behavior_spp_frequency_device_df_tmp1_${region}.succ_szdf_list_6m
    ,dws_risk_th_user_behavior_spp_frequency_device_df_tmp2_${region}.spdf_list
    ,dws_risk_th_user_behavior_spp_frequency_device_df_tmp2_${region}.szdf_list
from (
    select cast(shopeepay_user_id as string) as shopeepay_user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where grass_date = '${grass_date}'
) as a
left join dws_risk_th_user_behavior_spp_frequency_device_df_tmp1_${region} on a.shopeepay_user_id = dws_risk_th_user_behavior_spp_frequency_device_df_tmp1_${region}.shopeepay_user_id
left join dws_risk_th_user_behavior_spp_frequency_device_df_tmp2_${region} on a.shopeepay_user_id = dws_risk_th_user_behavior_spp_frequency_device_df_tmp2_${region}.shopeepay_user_id
;