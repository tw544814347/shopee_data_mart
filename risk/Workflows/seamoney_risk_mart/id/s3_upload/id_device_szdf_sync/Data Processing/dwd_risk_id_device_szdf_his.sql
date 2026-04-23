with hist_id_activation_device as 
(
    select  
        platform_user_id
        ,credit_user_id
        ,device_fingerprint
        ,substr(req_memo, 12, length(req_memo)) flow_no_memo
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.tongdun_deviec_info.tongdun_df') tongdun_df
        ,req_time
        ,final_result
        ,app_id
        ,scene_id
        ,get_json_object(extension, '$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id') szdf
        ,row_number() over(partition by substr(req_memo, 12, length(req_memo)) order by req_time desc ) rn 
from    risk.dwd_risk_id_strategy_final_result_merge_di_history
    where   (
                app_id in ('kredit', 'spj')
                and scene_id in (10013)
            )
      or    (
                app_id in ('spjup')
                and scene_id in (10003)
            )
    union   
    select  platform_user_id
            ,credit_user_id
            ,device_fingerprint
            ,substr(req_memo, 12, length(req_memo)) flow_no_memo
            ,get_json_object(extension, '$.CommonHeader.extension_process_data.tongdun_deviec_info.tongdun_df') tongdun_df
            ,req_time
            ,final_result
            ,app_id
            ,scene_id
            ,get_json_object(extension, '$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id') szdf
            ,row_number() over(partition by substr(req_memo, 12, length(req_memo)) order by req_time desc ) rn 
    from    risk.dwd_risk_id_strategy_final_result_merge_di
    where   (
                topic_name in ('id_live_credit_risk_gateway_req_rsp_kredit', 'id_live_credit_risk_gateway_req_rsp_spj')
                and risk_scene_id in ('10013')
            )
      or    (
                topic_name in ('id_live_credit_risk_gateway_req_rsp_spjup')
                and risk_scene_id in ('10003')
            )
      and   grass_date < '2022-08-01'
)
,hist_id_activation_workflow as (
    select  
        flow_no
        ,id
        ,platform_user_id
        ,coalesce(get_json_object(output, '$.CheckResult'), get_json_object(output, '$.checkResult')) CheckResult
        ,app_id
        ,run_step
        ,scene_id
        ,get_json_object(output, '$.product_code') product_code
        ,from_unixtime(create_time) create_time
    from    risk.credit_risk_control_id_db__workflow_tab_reg_daily_s0_live
    where   grass_date < '2022-08-01'
      and   from_unixtime(create_time) < '2022-08-01'
      and   run_step !=''
      and   app_id in ('spjup', 'kredit', 'spj')
      and   scene_id in (10001, 10011)
)
-- 即静态激活设备表
,hist_id_act_pass_device as (
    select  
        b.platform_user_id
        ,b.credit_user_id
        ,b.device_fingerprint
        ,b.flow_no_memo
        ,b.tongdun_df
        ,b.req_time
        ,b.final_result
        ,b.szdf
        ,b.app_id
        ,b.scene_id
        ,a.flow_no
        ,a.CheckResult
        ,'ID' as region
    from    hist_id_activation_workflow a
    inner join hist_id_activation_device b
    on      a.flow_no = b.flow_no_memo
    where   a.CheckResult = '1'
    and b.rn=1
)
insert overwrite table risk.dwd_risk_id_device_szdf_his
select  
    row_key
    ,tongdun_df 
    ,device_fingerprint 
    ,coalesce(a.szdf, c.sz_dfp_device_id, d.sz_dfp_device_id) as df
from    (
    select  
        flow_no
        ,cast(platform_user_id as string)  as platform_user_id
        ,concat(platform_user_id , '_' , app_id) as row_key
        ,app_id
        ,req_time
        ,device_fingerprint
        ,tongdun_df
        ,szdf
        ,row_number() over(partition by platform_user_id,app_id order by req_time desc ) rn 
    from    hist_id_act_pass_device
) a
left join (
    select  
        t1.device_id
        ,t1.sz_dfp_device_id
    from  credit.risk_mart_dim_sz_dfp_device_mapping t1 
    join ( 
        select 
            device_id
            ,count(sz_dfp_device_id) sz_dfp_device_cnt
        from credit.risk_mart_dim_sz_dfp_device_mapping
        where   grass_date = '2022-08-23'
        and   grass_region = 'ID'
        and   device_type = 'tddf'
        group by  device_id
    ) t2 on t1.device_id = t2.device_id  
    where   t1.grass_date = '2022-08-23'
      and   t1.grass_region = 'ID'
      and   t1.device_type = 'tddf'
        --    *只取unique的tddf_szdf*
      and t2.sz_dfp_device_cnt=1
) c
on      a.tongdun_df = c.device_id
left join (
    select  
        t1.device_id
        ,t1.sz_dfp_device_id
    from  credit.risk_mart_dim_sz_dfp_device_mapping t1 
    join ( 
        select 
            device_id
            ,count(sz_dfp_device_id) sz_dfp_device_cnt
        from credit.risk_mart_dim_sz_dfp_device_mapping
        where   grass_date = '2022-08-23'
        and   grass_region = 'ID'
        and   device_type = 'spdf'
        group by  device_id
    ) t2 on t1.device_id = t2.device_id  
    where   t1.grass_date = '2022-08-23'
      and   t1.grass_region = 'ID'
      and   t1.device_type = 'spdf'
        --    *只取unique的tddf_szdf*
      and t2.sz_dfp_device_cnt=1
) d
on      a.device_fingerprint = d.device_id
where a.rn = 1
group by 
row_key
,tongdun_df
,device_fingerprint
,coalesce(a.szdf, c.sz_dfp_device_id, d.sz_dfp_device_id)
;