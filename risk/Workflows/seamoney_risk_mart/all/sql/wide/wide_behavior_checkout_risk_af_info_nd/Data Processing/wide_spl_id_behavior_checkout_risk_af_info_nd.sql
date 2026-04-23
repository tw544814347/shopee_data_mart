--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-09
-- Theme Domain：       spl 贷中宽表
-- Description:         spl 贷中宽表
-- Data Granularity:    checkout_id
-- 变更历史：
--      update by 2024-05-08 zongyi.lu@shopee.com 1.uw_result 所有region都给值, 2.改成模版+新增注释
--      update by zongyi.lu@shopee.com 1.将授信表改成risk.dws_risk_${region}_${biz_name}_uw_process_by_request_id_df https://docs.google.com/spreadsheets/d/15_k8buzAcFh4YlYbsuXi3JvoPH70Xx791oEiRvUYWJs/edit?gid=1298125605#gid=1298125605
--      update by zongyi.lu@shopee.com 2024-07-22 1.将checkout id的逻辑优化成优先去req_no[2],再用原来的逻辑取值 https://jira.shopee.io/browse/SPFDT-42535 
--      update by zongyi.lu@shopee.com 2024-07-24 risk_uw_result 需要限制为and policy_status IN (1, 2) -- 1, 2: live 3: shadow https://jira.shopee.io/browse/SPFDT-42595
--      update by wei.tao@shopee.com 20250730 新增字段: https://jira.shopee.io/browse/SPFDT-54084
--      update by dongbo.yu at 2025-11-21 经用户反馈现有wide_spl表的关于workflow的字段信息不准确,临时用dws final result表来merge数据,长期使用ads表来出具
--********************************************************************--


ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
drop temporary function if exists json_to_array; 
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

use risk;
create or replace temporary view risk_af_tag_option_list_en_name as
select flow_no, get_json_object(tbl.tag_option_list,'$.en_name') as af_tag_online
from(
select  flow_no
        ,get_json_object(tag_list,'$.en_name') as en_name
        ,get_json_object(tag_list,'$.tag_option_list') as tag_option_list
from (
    select flow_no
        ,mis_merchant
    from risk.dwd_${region}_af_flow_no_tag_di t1
    where grass_date>=date_sub('${grass_date}',190)
    and grass_date<='${grass_date}'
    -- and app_id='kredit'
    and app_id ${app_id}
    -- and scene_id in('10044', '10045')
    and scene_id ${af_tag_scene_id}
 ) a
 lateral view explode(json_to_array(get_json_object(a.mis_merchant,'$.merchant_info.tag_list'))) tbl as tag_list
) a
lateral view explode(json_to_array(tag_option_list)) tbl as tag_option_list
where en_name = 'Merchant Type'
group by flow_no, get_json_object(tbl.tag_option_list,'$.en_name')
;	

create or replace temporary view risk_af_is_first_disbursement as
select flow_no, is_first_disbursement
from risk.dwd_${region}_af_flow_no_tag_di
where grass_date>=date_sub('${grass_date}',190)
 and grass_date<='${grass_date}'
 -- and app_id='kredit'
 and app_id ${app_id}
--  and scene_id in('10025', '10035', '10045', '10055', '10075')
and scene_id ${first_disbursement_scene_id}
group by flow_no, is_first_disbursement
;	


create or replace temporary view risk_af_result as
select 
    t1.scene_id
    ,t1.flow_no
    ,t1.checkout_id
    ,t1.af_tag_isonus
    ,t1.final_result
    ,t1.req_time
    ,t1.handle_end_time
    ,t1.is_workflow
    ,t1.key
    ,t1.task_run_step
from(
    select 
        t1.scene_id
        ,t1.flow_no
        ,t1.checkout_id
        ,t1.af_tag_isonus
        ,t1.final_result
        ,t1.req_time
        ,t1.handle_end_time
        ,t2.is_workflow
        ,t1.key
        ,t1.task_run_step
        ,row_number() over( partition by t1.checkout_id,t1.scene_id order by t1.req_time desc,t1.handle_end_time desc ) as rn 
    from (
    select 
            t1.scene_id
            ,t1.flow_no
            -- ,case when t1.scene_id in (10045,10044,10055,10054)  then get_json_object(extension, '$.TransactionSN')
            --       when t1.scene_id in (10075,10074) then get_json_object(extension, '$.PayId') 
            --     else get_json_object(extension, '$.CheckOutId') end as checkout_id
            ,case when '${table_product}'='spl' and t1.scene_id ${transaction_scene_id} then nvl(split(substring_index(t1.${reqno},'_',3),'_')[2],get_json_object(extension, '$.TransactionSN'))
                  when '${table_product}'='hpl' and t1.scene_id ${transaction_scene_id} then nvl(split(substring_index(t1.${reqno},'_',3),'_')[2],get_json_object(extension, '$.CheckOutId'))
                  when t1.scene_id ${pay_scene_id} then nvl(split(substring_index(t1.${reqno},'_',3),'_')[2],get_json_object(extension, '$.PayId')) 
                else nvl(split(substring_index(t1.${reqno},'_',3),'_')[2],get_json_object(extension, '$.CheckOutId')) end as checkout_id
            ,get_json_object(extension,'$.IsOnUs') as  af_tag_isonus
            ,t1.final_result
            ,format_time(t1.req_time,upper('${region}')) as req_time
            ,t1.handle_end_time
            ,substring_index(t1.${reqno},'_',3) as  key
            ,t1.app_id
            ,task_run_step
        from risk.dwd_risk_${region}_strategy_final_result_merge_di_v2 t1 
        where t1.grass_date>=date_sub('${grass_date}',190)
        and t1.grass_date<='${grass_date}'
        -- and t1.topic_name='${region}_live_credit_risk_gateway_req_rsp_kredit'
        and t1.topic_name ${topic_name}
        -- and t1.risk_scene_id in ('10025','10024','10035','10034','10045','10044','10055','10054','10075','10074')
        and t1.risk_scene_id ${risk_af_scene_id}
    ) t1 
    join risk.dim_risk_behavior_scene_info t2 on t1.scene_id = t2.scene_id and t2.app_id=t1.app_id
    and t2.region=upper('${region}') and t2.biz_name='${dim_biz_name}'
) t1 
where t1.rn =1 
;
create or replace temporary view risk_uw_result as
SELECT
        workflow_flow_no
        ,uw_result
FROM      (
SELECT
          request_id  as workflow_flow_no,
          result      as uw_result,
          ROW_NUMBER() OVER( PARTITION BY request_id ORDER BY request_time DESC ) AS rank_id
from risk.dws_risk_${region}_${biz_name}_uw_process_by_request_id_df
    where grass_date= '${grass_date}'
    and req_date >= date_sub('${grass_date}',190)
    and req_date<='${grass_date}' 
    and policy_status IN (1, 2) -- 1, 2: live 3: shadow
  AND     request_id IS NOT NULL
  AND     policy_scene_id ='20001'
) AS t1
WHERE     rank_id = 1
;

create or replace temporary view risk_af_screen as
SELECT    workflow_flow_no          as workflow_flow_no,
          af_screen_result          as af_screen_result,
          af_screen_sla_second      as af_screen_sla
FROM      risk.dwd_credit_${region}_risk_ticket_df
WHERE     grass_date = '${grass_date}'
;

create or replace temporary view spl_id_check as
-- insert overwrite table risk.wide_behavior_checkout_risk_af_info_nd partition(grass_region,biz_name,grass_date)
select 
t1.checkout_id                                                                                  as checkout_id
,t1.platform_user_id                                                                            as platform_user_id
,t1.credit_user_id                                                                              as credit_user_id 
,t1.create_time                                                                                 as create_time
,t1.channel_id                                                                                  as channel_id
,t1.check_type                                                                                  as risk_check_type
,t1.check_result                                                                                as risk_check_result
,t1.payment_result                                                                              as payment_result
,case when t2.key is not null and t2.is_workflow='1' then t2.final_result else null end         as workflow_af_result     
,case when t3.key is not null and t3.is_workflow='0' then t3.final_result else null end         as workflow_step_af_result
,case when t2.key is not null and t2.is_workflow='1' then t2.req_time else null end             as workflow_req_time      
,case when t3.key is not null and t3.is_workflow='0' then t3.req_time else null end             as workflow_step_req_time 
,case when t4.workflow_flow_no is not null then t4.uw_result else null end                      as uw_result 
,case when (t2.key is not null or t3.key is not null) then nvl(t2.af_tag_isonus,t3.af_tag_isonus) else '9-no_af_log_tag' end    as af_tag_isonus
,case when t5.flow_no is not null then t5.af_tag_online else null end                                                           as af_tag_online
,case when t2.key is not null then t6.is_first_disbursement else null end                                                       as is_first_disbursement
,case when t2.key is not null and t2.is_workflow='1' then t2.flow_no else null end                                              as workflow_flow_no    
,case when t3.key is not null and t3.is_workflow='0' then t3.flow_no else null end                                              as workflow_step_flow_no
,case when t7.workflow_flow_no is not null then t7.af_screen_result else null end                                               as af_screen_result     
,case when t7.workflow_flow_no is not null then t7.af_screen_sla else null end                                                  as af_screen_sla

,case when t2.key is not null and t2.is_workflow='1' then t2.task_run_step else null end                                              as workflow_task_run_step    
,case when t3.key is not null and t3.is_workflow='0' then t3.task_run_step else null end                                              as workflow_step_task_run_step

,upper('${region}')                                                                                                             as grass_region
,'${table_product}'                                                                                                                  as biz_name
,grass_date                                                                                                                     as grass_date         
from credit_mart.dwd_spl_${region}_checkout_df t1 
left join risk_af_result t2 on concat(t1.credit_user_id,'_',t1.channel_id,'_',t1.checkout_id) = t2.key and t2.is_workflow='1'
left join risk_af_result t3 on concat(t1.credit_user_id,'_',t1.channel_id,'_',t1.checkout_id) = t3.key and t3.is_workflow='0'
left join risk_uw_result t4 on t2.flow_no = t4.workflow_flow_no
left join risk_af_tag_option_list_en_name t5 on t3.flow_no = t5.flow_no and t3.is_workflow='0'
left join risk_af_is_first_disbursement t6 on t2.flow_no = t6.flow_no
left join risk_af_screen t7 on t2.flow_no = t7.workflow_flow_no
where grass_date ='${grass_date}'
and to_date(t1.create_time)>=date_sub('${grass_date}',190)
and to_date(t1.create_time)<='${grass_date}'
and t1.channel_id ${channel_id}
;

WITH dws_risk_reg_af_biz_workflow_di AS (
      SELECT
                app_id,
                scene_id,
                req_no,
                channel_id,
                checkout_id,
                flow_no AS workflow_flow_no,
                platform_user_id,
                run_step,
                workflow_create_time,
                workflow_update_time,
                rank_id_for_checkout_id_channel_id
      FROM      risk.dws_risk_reg_af_biz_workflow_di
      WHERE     grass_date >= date_sub('${grass_date}',190)
        AND     grass_date <= '${grass_date}'
        AND     grass_region = upper('${region}')
        AND     biz_name = 'credit'
        AND     rank_id_for_checkout_id_channel_id = 1
        AND     scene_id <> 30019 -- 决策是否能提额使用SPL,不影响支付流程 from xiaonian
  ),
  dws_workflow_flow_no_from_final_result AS (
      SELECT
                workflow_flow_no,
                -- t3：flow_no = workflow_flow_no（is_workflow='1'）
                MAX(CASE WHEN flow_no = workflow_flow_no  THEN final_result  END) AS workflow_af_result,
                MAX(CASE WHEN flow_no = workflow_flow_no  THEN req_time      END) AS workflow_req_time,
                MAX(CASE WHEN flow_no = workflow_flow_no  THEN task_run_step END) AS workflow_task_run_step,
                -- t4：flow_no <> workflow_flow_no（is_workflow='0'）
                MAX(CASE WHEN flow_no <> workflow_flow_no THEN flow_no       END) AS workflow_step_flow_no,
                MAX(CASE WHEN flow_no <> workflow_flow_no THEN final_result  END) AS workflow_step_af_result,
                MAX(CASE WHEN flow_no <> workflow_flow_no THEN req_time      END) AS workflow_step_req_time,
                MAX(CASE WHEN flow_no <> workflow_flow_no THEN task_run_step END) AS workflow_step_task_run_step
      FROM      risk.dws_risk_id_strategy_credit_final_result_di
      WHERE    
      WHERE     grass_date >= date_sub('${grass_date}',190)
        AND     grass_date <= '${grass_date}'
        AND     rank_id_for_checkout_id_channel_id = 1
      GROUP BY  workflow_flow_no
  )

insert overwrite table risk.wide_behavior_checkout_risk_af_info_nd partition(grass_region,biz_name,grass_date)
SELECT
    t1.checkout_id
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.create_time
    ,t1.channel_id
    ,t1.risk_check_type
    ,t1.risk_check_result
    ,t1.payment_result
    ,t3.workflow_af_result
    ,t3.workflow_step_af_result
    ,t3.workflow_req_time
    ,t3.workflow_step_req_time
    -- ,t1.uw_result
    ,CASE
              WHEN t2.run_step LIKE '%invoke_policy/return_pass/END'   THEN 'Approve'
              WHEN t2.run_step LIKE '%invoke_policy/return_reject/END' THEN 'Reject'
              ELSE ''
          END AS uw_result
    ,t1.af_tag_isonus
    ,t1.af_tag_online
    ,t1.is_first_disbursement
    ,t2.workflow_flow_no
    ,t3.workflow_step_flow_no
    ,t1.af_screen_result
    ,t1.af_screen_sla
    ,t3.workflow_task_run_step
    ,t3.workflow_step_task_run_step
    ,t1.grass_region
    ,t1.biz_name
    ,t1.grass_date
FROM      
-- dwd_spl_id_checkout_df                      AS t1
spl_id_check                                          AS t1
-- wf表的意义 --> 1.都用反欺诈的日志就好, 不用涉及复杂逻辑 + 2. 取交互字段 workflow_flow_no
LEFT JOIN dws_risk_reg_af_biz_workflow_di             AS t2 ON t1.checkout_id = t2.checkout_id AND t1.channel_id = t2.channel_id
LEFT JOIN dws_workflow_flow_no_from_final_result      AS t3 ON t2.workflow_flow_no = t3.workflow_flow_no
;



msck repair table risk.wide_behavior_checkout_risk_af_info_nd;
msck repair table risk.wide_${table_product}_${region}_behavior_checkout_risk_af_info_nd;