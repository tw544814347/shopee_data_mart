-- https://docs.google.com/spreadsheets/d/1wMnKvl1JL5q_fCe-JFXOW5FO63H8VmMsqgOisKlZZK0/edit#gid=0
-- 需要在配置表中新增对应产品的贷中sceneid 

-- update by zongyi.lu@shopee.com 1.新系统新增id_bcl id_scl 2.将vn_scl 改成新系统 https://jira.shopee.io/browse/SPFDT-38713 
-- update by zongyi.lu@shopee.com 不再维护SG BR的相关表，只在us 维护 
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

create or replace temporary view risk_af_result as
select 
    t1.scene_id
    ,t1.flow_no
    ,t1.loan_id
    ,t1.final_result
    ,t1.req_time
    ,t1.handle_end_time
    ,t1.is_workflow
    ,t1.workflow_flow_no
from(
    select 
        t1.scene_id
        ,t1.flow_no
        ,t1.loan_id
        ,t1.final_result
        ,t1.req_time
        ,t1.handle_end_time
        ,t2.is_workflow
        ,t1.workflow_flow_no
        ,row_number() over( partition by t1.loan_id,t1.scene_id order by t1.req_time desc,t1.handle_end_time desc ) as rn 
    from (
    select 
            t1.scene_id
            ,t1.flow_no
            ,get_json_object(extension, '$.PayId') as loan_id
            ,t1.final_result
            ,format_time(t1.req_time,upper('${region}')) as req_time
            ,t1.handle_end_time
            ,t1.workflow_flow_no
        from risk.dwd_risk_${region}_strategy_final_result_merge_di t1 
        where t1.grass_date>=date_sub('${grass_date}',190)
        and t1.grass_date<='${grass_date}'
        and t1.topic_name='${region}_live_credit_risk_gateway_req_rsp_${old_app_name}'
        and t1.scene_id in ${scene_id}
    ) t1 
    join risk.dim_risk_behavior_scene_info t2 on t1.scene_id = t2.scene_id and t2.app_id='${old_app_name}'
    and t2.region=upper('${region}') and t2.biz_name='${biz_name}'
) t1 
where t1.rn =1 
;
create or replace temporary view risk_uw_result as
select 
    workflow_flow_no
    ,uw_result 
    ,grass_date 
from (
    select 
        request_id   as workflow_flow_no
        ,result      as uw_result 
        ,grass_date  as grass_date 
        ,row_number() over(partition by request_id order by request_time desc) as rn 
    from risk.ads_risk_${region}_uw_${biz_name}_process_di 
    where grass_date>=date_sub('${grass_date}',190)
    and grass_date<='${grass_date}' 
    and policy_status in(1,2)
    and request_id is not null 
    and policy_scene_id ='20001'
)  a  
where rn = 1 
;


create or replace temporary view risk_af_screen as
SELECT    workflow_flow_no          as workflow_flow_no,
          af_screen_result          as af_screen_result,
          af_screen_sla_second      as af_screen_sla
FROM      risk.dwd_${region}_af_risk_screen_df
WHERE     grass_date = '${grass_date}'
;



insert overwrite table risk.wide_${biz_name}_${region}_behavior_withdraw_risk_af_info_nd partition(grass_date)
select 
    t1.loan_id                                 
   ,t1.credit_user_id                          
   ,t1.create_time                             
   ,t1.loan_status                        
   ,case when t2.loan_id is not null and t2.is_workflow='1' then t2.final_result else null end  as workflow_af_result                      
   ,case when t3.loan_id is not null and t3.is_workflow='0' then t3.final_result else null end  as workflow_step_af_result                 
   ,case when t2.loan_id is not null and t2.is_workflow='1' then t2.req_time else null end      as workflow_req_time                       
   ,case when t3.loan_id is not null and t3.is_workflow='0' then t3.req_time else null end      as workflow_step_req_time                  
   ,case when t4.workflow_flow_no is not null then t4.uw_result else null end                   as uw_reuslt  
   ,t1.create_time                                                                              as do_submit_time 
   ,t1.disburse_actual_done_time                                                                as verify_done_time 
   ,t1.disburse_fail_time                                                                       as verify_fail_time 
   ,case when t2.loan_id is not null and t2.is_workflow='1' then t2.flow_no else null end       as workflow_flow_no 
   ,case when t3.loan_id is not null and t3.is_workflow='0' then t3.flow_no else null end       as workflow_step_flow_no
   ,case when t5.workflow_flow_no is not null then t5.af_screen_result else null end            as af_screen_result  
   ,case when t5.workflow_flow_no is not null then t5.af_screen_sla else null end               as af_screen_sla  
   ,t1.grass_date                                                                               as grass_date                               
from credit_mart.dwd_${biz_name}_${region}${has_txn}order_df t1
left join risk_af_result t2 on t1.loan_id = t2.loan_id and t2.is_workflow='1'
left join risk_af_result t3 on t1.loan_id = t3.loan_id and t3.is_workflow='0'
left join risk_uw_result t4 on t2.workflow_flow_no = t4.workflow_flow_no and t2.is_workflow='1'
left join risk_af_screen t5 on t2.workflow_flow_no = t5.workflow_flow_no and t2.is_workflow='1'
where t1.grass_date = '${grass_date}'
;

msck repair table risk.wide_cl_behavior_withdraw_risk_af_info_nd;
msck repair table risk.wide_${biz_name}_${region}_behavior_withdraw_risk_af_info_nd;
