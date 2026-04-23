--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-11-01T14:00:00
-- Theme Domain：       反欺诈-授信
-- Description:         DWS bcl/scl/fes 反欺诈宽表，整合工作流、kyc、voi、final result等结果
-- Data Granularity:    apply_no
-- 变更历史：
--      update by zongyi.lu@shopee.com, af_kyc_workflow_flow_no取10001,af_af_workflow_flow_no取10011
--      update by zongyi.lu@shopee.com, kredit_result_info 改成10001
--      update by zongyi.lu@shopee.com 2024-09-03 uw result 去掉 and flow in(1,6)

--********************************************************************--

create or replace temporary view apply_base_info as
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
    ,CASE WHEN t2.credit_user_id IS NOT NULL THEN '1' ELSE null END AS uc_screen_update_info_result
    ,t1.rejected_reason      as rejected_reason
    ,t1.reject_code          as reject_code
from credit_uc.dwd_aio_id_uc_apply_df t1
left join(
    select
        credit_user_id
    from (
    select
       platform_user_id,
       credit_user_id,
       apply_no,
       row_number() over( partition by platform_user_id order by create_time asc ) as rank_id
    from   credit_uc.dwd_aio_id_uc_apply_df
    where  grass_date = '${bizdate}' 
    and  apply_type = 3 -- update_info
    and  apply_status = 4
    and  product_id = 7
    ) as t1
    where     rank_id = 1 -- 去重只取用户最早pass的update_info
) AS t2 ON t1.credit_user_id = t2.credit_user_id
where t1.grass_date = '${bizdate}' 
and (t1.create_time >= date_sub('${bizdate}',190) or t1.activate_submit_time >= date_sub('${bizdate}',190))
AND t1.apply_type in(1,6)
and t1.product_id = 7
;

-- af - kyc/voi 10001&10012
create or replace temporary view kyc_result_info as 
select 
t1.apply_no
,t1.app_id
,t1.scene_id
,t1.final_result
,t1.screen_result
,t1.workflow_flow_no as af_kyc_workflow_flow_no
,t1.task_run_step as af_kyc_workflow_task_run_step
from (
    select 
        split(reqno,"\\|")[0]                                                                                                 as apply_no
        ,tt1.app_id                                                                                                           as app_id
        ,tt1.scene_id                                                                                                         as scene_id  
        ,tt1.final_result                                                                                                     as final_result
        ,coalesce(tt2.result,0)                                                                                               as screen_result 
        ,tt1.workflow_flow_no
                ,task_run_step
        ,row_number() over(partition by split(tt1.reqno,"\\|")[0] ,tt1.app_id,tt1.scene_id order by tt1.req_time desc, tt1.handle_end_time desc ) as rn
    from risk.dwd_risk_id_strategy_final_result_merge_di_v2 tt1 
    left join (
        select 
            workflow_flow_no as ticket_id
            ,af_screen_result  as result
        from risk.dwd_credit_id_risk_ticket_df 
        where grass_date='${bizdate}'
    ) tt2 on tt1.workflow_flow_no = tt2.ticket_id
    where tt1.grass_date >= date_sub('${bizdate}',190)
    and tt1.topic_name in('id_live_credit_risk_gateway_req_rsp_voi','id_live_credit_risk_gateway_req_rsp_kyc')
    and tt1.scene_id in('10001','10012')
    and tt1.app_id in( 'kyc','voi')
    and get_json_object(tt1.extension,'$.product_code')='kredit'
) t1 
where t1.rn=1
;

-- af - kredit final_result
create or replace temporary view kredit_result_info as 
select 
    t1.apply_no
    ,t1.scene_id
    ,t1.final_result
    ,t1.workflow_flow_no as af_af_workflow_flow_no
        ,t1.task_run_step as af_af_workflow_task_run_step
from (
    select 
        split(tt1.reqno,"\\|")[0]                                                                                              as apply_no
        ,tt1.scene_id                                                                                                          as scene_id  
        ,tt1.final_result                                                                                                      as final_result
        ,tt1.workflow_flow_no
                ,tt1.task_run_step
        ,row_number() over(partition by split(tt1.reqno,"\\|")[0] ,tt1.app_id,tt1.scene_id order by tt1.req_time desc, tt1.handle_end_time desc )  as rn
    from risk.dwd_risk_id_strategy_final_result_merge_di_v2 tt1 
    where tt1.topic_name='id_live_credit_risk_gateway_req_rsp_chp'
    and tt1.grass_date >= date_sub('${bizdate}',190)
    and tt1.scene_id in('10001','10013')
    and tt1.app_id = 'chp'
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
    ,case when upper(result) = 'APPROVE' then 1 
        when upper(result) = 'REJECT' then 2 
        when upper(result) in ('P','PENDING') then 3 
        else -1 end uw_result
    ,row_number() over(partition by request_id order by request_time desc) rn 
    from risk.dws_risk_id_hpl_uw_process_by_request_id_df 
    where grass_date ='${bizdate}'
    and req_date>= date_sub('${bizdate}',190)
    and policy_status IN (1, 2) -- 1, 2: live 3: shadow
    and request_id IS NOT NULL
    -- and flow in(1,6) -- 1,6: "loan origination"
) t1 
where rn =1 
;

insert overwrite table risk.wide_application_apply_info_nd partition(grass_region,biz_name,grass_date)
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
    ,coalesce(t.risk_resp_flow_no,t.af_af_workflow_flow_no) as risk_resp_flow_no
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
    ,af_result_10001                        as af_result_10001      
    ,null                                   as af_result_10001_10012
    ,af_result_10001_10013                  as af_result_10001_10013
    ,t.rejected_reason                      as rejected_reason
    ,t.reject_code                          as reject_code
    ,case when t.af_result_10001_10003=-1 then null else t.af_result_10001_10003 end                                       as af_result_10001_10003
    ,case when t.af_result_10011_10012_screen=-1 then null else t.af_result_10011_10012_screen end                         as af_result_10011_10012_screen
    ,case when t.af_result_10001_10012_screen=-1 then null else t.af_result_10001_10012_screen end                         as af_result_10001_10012_screen
    ,case when t.af_result_10001_10003_screen=-1 then null else t.af_result_10001_10003_screen end                         as af_result_10001_10003_screen
    ,null                                   as is_skip_idwall
    ,null                                   as otp_status
    ,null                                   as bank_status
    ,0                                       as af_kyc_risk_screen_sla
    ,t.af_kyc_workflow_flow_no              as af_kyc_workflow_flow_no 
    ,t.af_af_workflow_flow_no               as af_af_workflow_flow_no
    ,t.af_kyc_workflow_task_run_step
    ,t.af_af_workflow_task_run_step
    ,'ID'                                   as grass_region
    ,'hpl'                                  as biz_name
    ,'${bizdate}'                           as grass_date
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
    ,max(case when t3.apply_no is not null and t3.scene_id = '10011' then t3.final_result else -1 end)  as af_result_10011   
    ,max(case when t3.apply_no is not null and t3.scene_id = '10001' then t3.final_result else -1 end)  as af_result_10001    
    ,null                                                                                               as af_result_10011_10012
    ,max(case when t3.apply_no is not null and t3.scene_id = '10013' then t3.final_result else -1 end)  as af_result_10011_10013
    ,max(case when t3.apply_no is not null and t3.scene_id = '10013' then t3.final_result else -1 end)  as af_result_10001_10013
    ,max(case when t3.apply_no is not null and t3.scene_id = '10014' then t3.final_result else -1 end)  as af_result_10011_10014
    ,coalesce(t4.uw_result,null)                                                                        as uw_result
    ,t1.user_label                                                                                      as user_label 
    ,null                                                                                               as is_af_inner_platform_user_id
    ,null                                                                                               as is_uw_inner_platform_user_id
    ,null                                                                                               as af_result_spr_10001
    ,t1.uc_screen_update_info_result                                                                    as uc_screen_update_info_result
    ,t1.rejected_reason                                                                                 as rejected_reason
    ,t1.reject_code                                                                                     as reject_code
    ,null                                                                                               as af_result_10001_10003
    ,null                                                                                               as af_result_10011_10012_screen
    ,null                                                                                               as af_result_10001_10012_screen
    ,null                                                                                               as af_result_10001_10003_screen
    ,max(case when t2.apply_no is not null and t2.scene_id = '10001' then t2.af_kyc_workflow_flow_no else null end)  as af_kyc_workflow_flow_no 
    ,max(case when t3.apply_no is not null and t3.scene_id = '10011' then t3.af_af_workflow_flow_no else null end)  as af_af_workflow_flow_no

    ,max(case when t2.apply_no is not null and t2.scene_id = '10001' then t2.af_kyc_workflow_task_run_step else null end)  as af_kyc_workflow_task_run_step 
    ,max(case when t3.apply_no is not null and t3.scene_id = '10001' then t3.af_af_workflow_task_run_step else null end)  as af_af_workflow_task_run_step
from apply_base_info t1 
left join kyc_result_info t2 on t1.apply_no = t2.apply_no 
left join kredit_result_info t3 on t1.apply_no = t3.apply_no
left join uw_result_info t4 on coalesce(t1.risk_resp_flow_no,t3.af_af_workflow_flow_no) = t4.request_id
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
-- ,t2.af_kyc_workflow_flow_no
-- ,t3.af_af_workflow_flow_no 
) t 
;

msck repair table risk.wide_application_apply_info_nd;
msck repair table risk.wide_hpl_id_application_apply_risk_af_uw_info_nd;
msck repair table risk.wide_chp_id_application_apply_risk_af_uw_info_nd;