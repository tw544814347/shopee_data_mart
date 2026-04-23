ADD JAR  hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
create or replace temporary view dwd_aio_id_application_apply_df__sensitive as
select 
     t3.apply_no                                        as apply_no 
    ,t3.platform_user_id                                as platform_user_id
    ,t3.credit_user_id                                  as credit_user_id 
    ,t3.apply_create_time                               as apply_create_time    
    ,t3.activate_submit_time                            as activate_submit_time 
    ,t3.apply_type                                      as apply_type   
    ,t3.apply_status                                    as apply_status        
    ,t3.rejected_reason_type                            as rejected_reason_type 
    ,t3.screen_status                                   as screen_status        
    ,t3.risk_resp_flow_no                               as risk_resp_flow_no    
    ,t3.user_label                                      as user_label 
    ,t3.is_af_inner_platform_user_id                    as is_af_inner_platform_user_id
    ,t3.is_uw_inner_platform_user_id                    as is_uw_inner_platform_user_id
    ,t3.rejected_reason                                 as rejected_reason
    ,t3.reject_code                                     as reject_code
from (
    select 
         t2.apply_no                                        as apply_no 
        ,t2.platform_user_id                                as platform_user_id
        ,t2.credit_user_id                                  as credit_user_id 
        ,t2.apply_create_time                               as apply_create_time    
        ,t2.activate_submit_time                            as activate_submit_time 
        ,t2.apply_type                                      as apply_type   
        ,t2.apply_status                                    as apply_status        
        ,t2.rejected_reason_type                            as rejected_reason_type 
        ,t2.screen_status                                   as screen_status        
        ,t2.risk_resp_flow_no                               as risk_resp_flow_no    
        ,t2.user_label                                      as user_label 
        ,t2.is_af_inner_platform_user_id                    as is_af_inner_platform_user_id
        ,t2.is_uw_inner_platform_user_id                    as is_uw_inner_platform_user_id
        ,t2.rejected_reason                                 as rejected_reason
        ,t2.reject_code                                     as reject_code
        ,row_number() over(partition by t2.apply_no order by apply_create_time desc )  as rn 
    from (
        select 
            t1.apply_no              as apply_no 
            ,t1.platform_user_id     as platform_user_id
            ,t1.credit_user_id       as credit_user_id 
            ,t1.create_time          as apply_create_time    
            ,t1.activate_submit_time as activate_submit_time 
            ,t1.apply_type           as apply_type   
            ,t1.apply_status         as apply_status        
            ,t1.rejected_reason_type as rejected_reason_type 
            ,t1.screen_status        as screen_status        
            ,t1.risk_resp_flow_no    as risk_resp_flow_no    
            ,t1.user_label           as user_label 
            ,null                    as is_af_inner_platform_user_id
            ,null                    as is_uw_inner_platform_user_id
            ,t1.rejected_reason      as rejected_reason
            ,t1.reject_code          as reject_code
        from credit_mart.dwd_aio_id_application_apply_df__sensitive t1
        where t1.grass_date = '${bizdate}' 
        and (t1.create_time >= date_sub('${bizdate}',60) or t1.activate_submit_time >= date_sub('${bizdate}',60))
        AND t1.apply_type = 1
        and t1.product_id= 1
        union all 
        select 
            get_json_object(t1.data,'$.apply_no')                                 as apply_no 
            ,get_json_object(t1.data,'$.platform_user_id')                        as platform_user_id
            ,get_json_object(t1.data,'$.user_id')                                 as credit_user_id 
            ,format_time(get_json_object(t1.data,'$.create_time'),'ID')           as apply_create_time    
            ,format_time(get_json_object(t1.data,'$.activate_submit_time'),'ID')  as activate_submit_time 
            ,get_json_object(t1.data,'$.apply_type')                              as apply_type   
            ,get_json_object(t1.data,'$.apply_status')                            as apply_status        
            ,get_json_object(t1.data,'$.rejected_reason_type')                    as rejected_reason_type 
            ,get_json_object(t1.data,'$.screen_status')                           as screen_status        
            ,get_json_object(t1.data,'$.risk_resp_flow_no')                       as risk_resp_flow_no    
            ,get_json_object(t1.data,'$.user_label')                              as user_label 
            ,null                                                                 as is_af_inner_platform_user_id
            ,null                                                                 as is_uw_inner_platform_user_id
            ,get_json_object(t1.data,'$.rejected_reason')                         as rejected_reason
            ,get_json_object(t1.data,'$.reject_code')                             as reject_code
        from credit.ccin_realtime_binlog_for_all t1
        where t1.dt =date_add('${bizdate}',1)
        and t1.base_database='credit_usercenter_apply_id_db'
        and t1.base_table='apply_activation_order_tab'
        and (format_time(get_json_object(t1.data,'$.create_time'),'ID') >= date_sub('${bizdate}',60) or format_time(get_json_object(t1.data,'$.activate_submit_time'),'ID') >= date_sub('${bizdate}',60))
        and get_json_object(t1.data,'$.apply_type') = 1
        and get_json_object(t1.data,'$.biz_type') = 1
    ) t2 
) t3 
where t3.rn = 1 

;
create or replace temporary view ods__credit_risk_control_id_db__ticket_tab__df as 
select 
    ticket_id
    ,result 
from (
    select 
        ticket_id
        ,result
        ,row_number() over(partition by ticket_id order by create_time desc ) rn 
    from (
    select 
        ticket_id
        ,result 
        ,create_time
    from risk.ods__credit_risk_control_id_db__ticket_tab__df 
    where grass_date='${bizdate}'
    union all 
    select 
        get_json_object(data,'$.ticket_id') as ticket_id
        ,get_json_object(data,'$.result') as result
        ,get_json_object(data,'$.create_time') as create_time
    from risk.ccin_realtime_binlog_for_all
    where dt=date_add('${bizdate}',1)
        and base_database='credit_risk_control_id_db'
        and base_table='ticket_tab'
    ) t1 
) t2 
where rn = 1 
;


create or replace temporary view  dwd_risk_id_strategy_final_result_merge_di as 
select 
    app_id                 as app_id
    ,scene_id              as scene_id
    ,flow_no               as flow_no
    ,req_time              as req_time
    ,reqno                 as reqno
    ,platform_user_id      as platform_user_id
    ,handle_begin_time     as handle_begin_time
    ,handle_end_time       as handle_end_time
    ,final_result          as final_result
    ,create_time           as create_time
    ,topic_name            as topic_name
    ,risk_scene_id         as risk_scene_id
    ,grass_date            as grass_date
    ,process_date          as process_date
    ,extension             as extension     
    ,workflow_flow_no      as workflow_flow_no

from risk.dwd_risk_id_strategy_final_result_merge_di 
where  grass_date >= date_sub('${bizdate}',60)
and   ((topic_name = 'id_live_credit_risk_gateway_req_rsp_kyc' and scene_id in('10001','10012'))
        or (topic_name = 'id_live_credit_risk_gateway_req_rsp_spj' and scene_id in('10001','10013'))
        or (topic_name = 'id_live_credit_risk_gateway_req_rsp_voi' and scene_id in('10001','10012'))
        )
union all 
select  
     get_json_object(value, '$.Req.RiskReqHeader.AppID')                                     as app_id
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.SceneID') as bigint)                   as scene_id
    ,get_json_object(value, '$.Req.RiskReqHeader.FlowNo')                                    as flow_no
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint)                   as req_time
    ,get_json_object(value, '$.Req.RiskReqHeader.ReqNo')                                     as reqno
    ,get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id')                     as platform_user_id
    ,cast(get_json_object(value, '$.Rsp.RiskInsight.HandleBeginTime') as bigint)             as handle_begin_time
    ,cast(get_json_object(value, '$.Rsp.RiskInsight.HandleEndTime') as bigint)               as handle_end_time
    ,cast(get_json_object(value, '$.Rsp.RiskInsight.CheckResult') as bigint)                 as final_result
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint)                   as create_time
    ,t1.tn                                                                                   as topic_name
    ,t1.scene_id                                                                             as risk_scene_id
    ,to_date(from_unixtime(get_json_object(value, '$.Req.RiskReqHeader.ReqTime')-3600))      as grass_date
    ,dt                                                                                      as process_date
    ,get_json_object(value, '$.ReqParams')                                                   as extension
    ,get_json_object(value, '$.Req.RiskReqHeader.WorkflowFlowNo')                            as workflow_flow_no
from    risk.kafka__live_credit_risk_gateway_req_rsp_di t1
where   t1.dt = date_add('${bizdate}',1)
  and   ((t1.tn = 'id_live_credit_risk_gateway_req_rsp_kyc' and scene_id in('10001','10012'))
        or (t1.tn = 'id_live_credit_risk_gateway_req_rsp_spj' and scene_id in('10001','10013'))
        or (t1.tn = 'id_live_credit_risk_gateway_req_rsp_voi' and scene_id in('10001','10012'))
        )
  and   get_json_object(t1.value, '$.Req.RiskReqHeader.AppID') is not null
  and   length(trim(get_json_object(t1.value, '$.ReqParams.CommonHeader.platform_user_id'))) between 1 and 14
;

create or replace temporary view ads_risk_id_uw_bcl_process_di as 
    select 
        request_id
        ,case when upper(result) = 'APPROVE' then 1 
              when upper(result) = 'REJECT' then 2 
              when upper(result) in ('P','PENDING') then 3 
              else -1 end  as uw_result
        ,request_time
    from risk.ads_risk_id_uw_bcl_process_di 
    where grass_date >= date_sub('${bizdate}',60)
    and policy_status IN (1, 2) -- 1, 2: live 3: shadow
    and request_id IS NOT NULL
    and policy_type_id in(1,6) -- 1,6: "loan origination"
    union all 
    select 
        get_json_object(value,'$.requestId') as request_id
        ,case when upper(get_json_object(value,'$.result')) = 'APPROVE' then 1 
              when upper(get_json_object(value,'$.result')) = 'REJECT' then 2 
              when upper(get_json_object(value,'$.result')) in ('P','PENDING') then 3 
              else -1 end  as uw_result
        ,cast(get_json_object(value,'$.requestTime') as bigint)  as request_time
    from risk.ods__risk_id_uw_crc_sis_request_log
    where dt =date_add('${bizdate}',1)
    and (get_json_object(value,'$.appId') = 'spj' or CAST(get_json_object(get_json_object(value,'$.rsp'),'$.DAJSONDocument.OCONTROL.ALIAS.value') AS String) LIKE 'IB%')
    and cast(get_json_object(value,'$.policyStatus') as bigint) IN (1, 2) -- 1, 2: live 3: shadow
    and get_json_object(value,'$.requestId') IS NOT NULL
    and cast(get_json_object(value,'$.flow') as bigint) in(1,6) -- 1,6: "loan origination" 
;


create or replace temporary view apply_base_info as
select 
    t1.apply_no              as apply_no 
    ,t1.platform_user_id     as platform_user_id
    ,t1.credit_user_id       as credit_user_id 
    ,t1.apply_create_time    as apply_create_time    
    ,t1.activate_submit_time as activate_submit_time 
    ,t1.apply_type           as apply_type   
    ,t1.apply_status         as apply_status        
    ,t1.rejected_reason_type as rejected_reason_type 
    ,t1.screen_status        as screen_status        
    ,t1.risk_resp_flow_no    as risk_resp_flow_no    
    ,t1.user_label           as user_label 
    ,null                    as is_af_inner_platform_user_id
    ,null                    as is_uw_inner_platform_user_id
    ,null                    as uc_screen_update_info_result
    ,t1.rejected_reason      as rejected_reason
    ,t1.reject_code          as reject_code
from dwd_aio_id_application_apply_df__sensitive t1
-- where t1.grass_date = '${bizdate}' 
-- and (t1.create_time >= date_sub('${bizdate}',60) or t1.activate_submit_time >= date_sub('${bizdate}',60))
-- AND t1.apply_type = 1
-- and t1.product_id= 1
;

-- af - kyc/voi 10001&10012
create or replace temporary view kyc_result_info as 
select 
t1.apply_no
,t1.app_id
,t1.scene_id
,t1.final_result
,t1.screen_result
from (
    select 
        split(reqno,"\\|")[0]                                                                                                 as apply_no
        ,tt1.app_id                                                                                                           as app_id
        ,tt1.scene_id                                                                                                         as scene_id  
        ,tt1.final_result                                                                                                     as final_result
        ,coalesce(tt2.result,0)                                                                                               as screen_result 
        ,row_number() over(partition by split(tt1.reqno,"\\|")[0] ,tt1.app_id,tt1.scene_id order by tt1.req_time desc, tt1.handle_end_time desc ) as rn
    from dwd_risk_id_strategy_final_result_merge_di tt1 
    left join (
        select 
            ticket_id
            ,result 
        from ods__credit_risk_control_id_db__ticket_tab__df 
        -- where grass_date='${bizdate}'
    ) tt2 on tt1.workflow_flow_no = tt2.ticket_id
    where tt1.grass_date >= date_sub('${bizdate}',60)
    and tt1.app_id in( 'kyc','voi')
    and get_json_object(tt1.extension,'$.product_code')='spj'
) t1 
where t1.rn=1
;

-- af - kredit final_result
create or replace temporary view kredit_result_info as 
select 
    t1.apply_no
    ,t1.scene_id
    ,t1.final_result
from (
    select 
        split(tt1.reqno,"\\|")[0]                                                                                              as apply_no
        ,tt1.scene_id                                                                                                          as scene_id  
        ,tt1.final_result                                                                                                      as final_result
        ,row_number() over(partition by split(tt1.reqno,"\\|")[0] ,tt1.app_id,tt1.scene_id order by tt1.req_time desc, tt1.handle_end_time desc )  as rn
    from dwd_risk_id_strategy_final_result_merge_di tt1 
    where tt1.grass_date >= date_sub('${bizdate}',60)
        and tt1.app_id = 'spj'
) t1 
where t1.rn=1
;

-- uw result 
create or replace temporary view uw_result_info as 
select 
request_id
,uw_result
from (
    select 
    request_id
    ,uw_result
    ,row_number() over(partition by request_id order by request_time desc) rn 
    from ads_risk_id_uw_bcl_process_di 
    -- where grass_date >= date_sub('${bizdate}',60)
    -- and policy_status IN (1, 2) -- 1, 2: live 3: shadow
    -- and request_id IS NOT NULL
    -- and policy_type_id in(1,6) -- 1,6: "loan origination"
) t1 
where rn =1 
;

insert overwrite table risk.wide_application_apply_info_realtime_nd partition(grass_region,biz_name,grass_date)
select 
     t.apply_no                             as apply_no 
    ,t.platform_user_id                     as platform_user_id
    ,t.credit_user_id                       as credit_user_id
    ,t.apply_create_time                    as apply_create_time    
    ,t.activate_submit_time                 as activate_submit_time 
    ,t.apply_type                           as apply_type  
    ,t.apply_status                         as apply_status        
    ,t.rejected_reason_type                 as rejected_reason_type 
    ,t.screen_status                        as screen_status        
    ,t.risk_resp_flow_no                    as risk_resp_flow_no 
    ,t.af_share_kyc_type                    as af_share_kyc_type
    ,case when t.af_result_share_kyc_10001 = -1 then null else t.af_result_share_kyc_10001 end                             as af_result_share_kyc_10001
    ,case when t.af_result_share_kyc_10001_10012 = -1 then null else t.af_result_share_kyc_10001_10012 end                 as af_result_share_kyc_10001_10012
    ,case when t.af_result_share_kyc_10001_10012_screen = -1 then null else t.af_result_share_kyc_10001_10012_screen end   as af_result_share_kyc_10001_10012_screen
    ,case when t.af_result_10011 = -1 then null else t.af_result_10011 end                                                 as af_result_10011      
    ,case when t.af_result_10011_10012 = -1 then null else t.af_result_10011_10012 end                                     as af_result_10011_10012
    ,case when t.af_result_10011_10013 = -1 then null else t.af_result_10011_10013 end                                     as af_result_10011_10013
    ,case when t.af_result_10011_10014 = -1 then null else t.af_result_10011_10014 end                                     as af_result_10011_10014
    ,t.uw_result                            as uw_result
    ,t.user_label                           as user_label 
    ,t.is_af_inner_platform_user_id         as is_af_inner_platform_user_id 
    ,t.is_uw_inner_platform_user_id         as is_uw_inner_platform_user_id 
    ,case when t.af_result_spr_10001=-1 then null else t.af_result_spr_10001 end                                           as af_result_spr_10001          
    ,case when t.uc_screen_update_info_result=-1 then null else t.uc_screen_update_info_result end                         as uc_screen_update_info_result 
    ,case when t.af_result_10001=-1 then null else t.af_result_10001 end                                                   as af_result_10001      
    ,case when t.af_result_10001_10012=-1 then null else t.af_result_10001_10012 end                                       as af_result_10001_10012
    ,case when t.af_result_10001_10013=-1 then null else t.af_result_10001_10013 end                                       as af_result_10001_10013
    ,t.rejected_reason                                                                                                     as rejected_reason
    ,t.reject_code                                                                                                         as reject_code
    ,case when t.af_result_10001_10003=-1 then null else t.af_result_10001_10003 end                                       as af_result_10001_10003
    ,case when t.af_result_10011_10012_screen=-1 then null else t.af_result_10011_10012_screen end                         as af_result_10011_10012_screen
    ,case when t.af_result_10001_10012_screen=-1 then null else t.af_result_10001_10012_screen end                         as af_result_10001_10012_screen
    ,case when t.af_result_10001_10003_screen=-1 then null else t.af_result_10001_10003_screen end                         as af_result_10001_10003_screen
    ,null                                    as is_skip_idwall
    ,null                                    as otp_status
    ,null                                    as bank_status
    ,'ID'                                    as grass_region 
    ,'bcl'                                   as biz_name
    ,date_add('${bizdate}',1)                as grass_date
from (
select 
     t1.apply_no                    as apply_no 
    ,t1.platform_user_id            as platform_user_id
    ,t1.credit_user_id              as credit_user_id
    ,t1.apply_create_time           as apply_create_time    
    ,t1.activate_submit_time        as activate_submit_time 
    ,t1.apply_type                  as apply_type   
    ,t1.apply_status                as apply_status        
    ,t1.rejected_reason_type        as rejected_reason_type 
    ,t1.screen_status               as screen_status        
    ,t1.risk_resp_flow_no           as risk_resp_flow_no    
    ,coalesce(t2.app_id,null)       as af_share_kyc_type
    ,max(case when t2.apply_no is not null and t2.scene_id = '10001' then t2.final_result else -1 end)  as af_result_share_kyc_10001
    ,max(case when t2.apply_no is not null and t2.scene_id = '10012' then t2.final_result else -1 end)  as af_result_share_kyc_10001_10012
    ,max(case when t2.apply_no is not null and t2.scene_id = '10012' then t2.screen_result else -1 end) as af_result_share_kyc_10001_10012_screen
    ,null                                                                                               as af_result_10011      
    ,null                                                                                               as af_result_10011_10012
    ,null                                                                                               as af_result_10011_10013
    ,null                                                                                               as af_result_10011_10014
    ,coalesce(t4.uw_result,null)                                                                        as uw_result
    ,t1.user_label                                                                                      as user_label 
    ,null                                                                                               as is_af_inner_platform_user_id
    ,null                                                                                               as is_uw_inner_platform_user_id
    ,null                                                                                               as af_result_spr_10001
    ,t1.uc_screen_update_info_result                                                                    as uc_screen_update_info_result
    ,max(case when t3.apply_no is not null and t3.scene_id = '10001' then t3.final_result else -1 end)  as af_result_10001      
    ,null                                                                                               as af_result_10001_10012
    ,max(case when t3.apply_no is not null and t3.scene_id = '10013' then t3.final_result else -1 end)  as af_result_10001_10013
    ,t1.rejected_reason                                                                                 as rejected_reason
    ,t1.reject_code                                                                                     as reject_code
    ,null                                                                                               as af_result_10001_10003
    ,null                                                                                               as af_result_10011_10012_screen
    ,null                                                                                               as af_result_10001_10012_screen
    ,null                                                                                               as af_result_10001_10003_screen
from apply_base_info t1 
left join kyc_result_info t2 on t1.apply_no = t2.apply_no 
left join kredit_result_info t3 on t1.apply_no = t3.apply_no
left join uw_result_info t4 on t1.risk_resp_flow_no = t4.request_id
group by t1.apply_no             
,t1.platform_user_id     
,t1.credit_user_id       
,t1.apply_create_time    
,t1.activate_submit_time 
,t1.apply_type   
,t1.apply_status        
,t1.rejected_reason_type 
,t1.screen_status        
,t1.risk_resp_flow_no 
,coalesce(t2.app_id,null) 
,coalesce(t4.uw_result,null)   
,t1.user_label
,t1.uc_screen_update_info_result
,t1.rejected_reason
,t1.reject_code
) t 
;

msck repair table risk.wide_application_apply_info_realtime_nd;
msck repair table risk.wide_bcl_id_application_apply_risk_af_uw_info_realtime_nd;