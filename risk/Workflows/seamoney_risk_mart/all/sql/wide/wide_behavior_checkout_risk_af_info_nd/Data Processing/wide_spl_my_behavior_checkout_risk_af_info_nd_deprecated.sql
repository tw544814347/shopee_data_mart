create or replace temporary view risk_af_result as
select 
    t1.scene_id
    ,t1.flow_no
    ,t1.checkout_id
    ,t1.final_result
    ,t1.req_time
    ,t1.handle_end_time
    ,t1.is_workflow
    ,t1.key
from(
    select 
        t1.scene_id
        ,t1.flow_no
        ,t1.checkout_id
        ,t1.final_result
        ,t1.req_time
        ,t1.handle_end_time
        ,t2.is_workflow
        ,t1.key
        ,row_number() over( partition by t1.checkout_id,t1.scene_id order by t1.req_time desc,t1.handle_end_time desc ) as rn 
    from (
    select 
            t1.scene_id
            ,t1.flow_no
            ,case when t1.scene_id in (10045,10044,10055,10054)  then get_json_object(extension, '$.TransactionSN')
                else get_json_object(extension, '$.CheckOutId') end as checkout_id
            ,t1.final_result
            ,from_unixtime(t1.req_time-0*3600) as req_time
            ,t1.handle_end_time
            ,substring_index(t1.reqno,'_',3) as  key
        from risk.dwd_risk_my_strategy_final_result_merge_di t1 
        where t1.grass_date>=date_sub('${grass_date}',190)
        and t1.grass_date<='${grass_date}'
        and t1.topic_name='my_live_credit_risk_gateway_req_rsp_kredit'
        and t1.risk_scene_id in ('10035','10034','10024','10025','10045','10044','10055','10054')
    ) t1 
    join risk.dim_risk_behavior_scene_info t2 on t1.scene_id = t2.scene_id and t2.app_id='kredit'
    and t2.region='MY' and t2.biz_name='spl'
) t1 
where t1.rn =1 
;

create or replace temporary view risk_af_screen as
SELECT    workflow_flow_no          as workflow_flow_no,
          af_screen_result          as af_screen_result,
          af_screen_sla_second      as af_screen_sla
FROM      risk.dwd_my_af_risk_screen_df
WHERE     grass_date = '${grass_date}'
;


insert overwrite table risk.wide_behavior_checkout_risk_af_info_nd partition(grass_region,biz_name,grass_date)
select 
t1.checkout_id                                                                                  as checkout_id
,t1.platform_user_id                                                                            as platform_user_id
,t1.user_id                                                                                     as credit_user_id 
,from_unixtime(unix_timestamp(t1.create_time)+ 8*3600)                                          as create_time
,t1.channel_id                                                                                  as channel_id
,t1.check_type                                                                                  as risk_check_type
,t1.check_result                                                                                as risk_check_result
,t1.payment_result                                                                              as payment_result
,case when t2.key is not null and t2.is_workflow='1' then t2.final_result else null end         as  workflow_af_result     
,case when t3.key is not null and t3.is_workflow='0' then t3.final_result else null end         as  workflow_step_af_result
,case when t2.key is not null and t2.is_workflow='1' then t2.req_time else null end             as  workflow_req_time      
,case when t3.key is not null and t3.is_workflow='0' then t3.req_time else null end             as  workflow_step_req_time 
,null                                                                                           as uw_result
,null                                                                                           as af_tag_isonus
,null                                                                                           as af_tag_online
,null                                                                                           as is_first_disbursement
,case when t2.key is not null and t2.is_workflow='1' then t2.flow_no else null end              as workflow_flow_no 
,case when t3.key is not null and t3.is_workflow='0' then t3.flow_no else null end              as workflow_step_flow_no 
,case when t4.workflow_flow_no is not null then t4.af_screen_result else null end               as af_screen_result  
,case when t4.workflow_flow_no is not null then t4.af_screen_sla else null end                  as af_screen_sla  
,'MY'                                                                                           as grass_region
,'spl'                                                                                          as biz_name
,grass_date                                                                                     as grass_date         
from credit.ods__credit_spl_transaction_my_db__checkout_info_tab__df t1 
left join risk_af_result t2 on concat(t1.user_id,'_',t1.channel_id,'_',t1.checkout_id) = t2.key and t2.is_workflow='1'
left join risk_af_result t3 on concat(t1.user_id,'_',t1.channel_id,'_',t1.checkout_id) = t3.key and t3.is_workflow='0'
left join risk_af_screen t4 on t2.flow_no = t4.workflow_flow_no and t2.is_workflow='1'
where grass_date ='${grass_date}'
and to_date(from_unixtime(unix_timestamp(t1.create_time)+ 8*3600))>=date_sub('${grass_date}',190)
and to_date(from_unixtime(unix_timestamp(t1.create_time)+ 8*3600))<='${grass_date}'
;

msck repair table risk.wide_behavior_checkout_risk_af_info_nd;
msck repair table risk.wide_spl_my_behavior_checkout_risk_af_info_nd;

