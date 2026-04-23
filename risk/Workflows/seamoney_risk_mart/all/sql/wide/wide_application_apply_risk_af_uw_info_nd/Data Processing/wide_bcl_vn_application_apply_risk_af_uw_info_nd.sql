--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-11-01T14:00:00
-- Theme Domain：反欺诈
-- Description:         DWS bcl/scl/fes 反欺诈宽表，整合工作流、kyc、voi、final result 等结果
-- Data Granularity:    apply_no
-- 变更历史：
--      update by xiaobin.qiu@shopee.com，增加注释，切换 risk.dwd_br_af_risk_screen_df Mart 表
--      update by zongyi.lu@shopee.com，新增字段 af_kyc_workflow_flow_no,af_af_workflow_flow_no(就是两个 af) https://jira.shopee.io/browse/SPFDT-41062
--      update by zongyi.lu@shopee.com, af_kyc_workflow_flow_no 取 10001,af_af_workflow_flow_no 取 10001
--      update by zhicheng, 2025 年 1 月 15 日 add otp_status, bank_status

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
    ,null                    as uc_screen_update_info_result
    ,t1.rejected_reason      as rejected_reason
    ,t1.reject_code          as reject_code
    ,t1.otp_status
    ,t1.bank_status
from credit_uc.dwd_aio_vn_uc_apply_df t1
where t1.grass_date = '${bizdate}'
and (t1.create_time >= date_sub('${bizdate}',190) or t1.activate_submit_time >= date_sub('${bizdate}',190))
and t1.apply_type in(1,6)
and product_id=1
;

-- af - kyc/voi 10001&10012
create or replace temporary view kyc_result_info as
select
    t1.apply_no,
    t1.app_id,
    t1.scene_id,
    t1.final_result,
    t1.screen_result,
    t1.workflow_flow_no as af_kyc_workflow_flow_no,
    t1.task_run_step as af_kyc_workflow_task_run_step
from (
    select
        tt1.apply_no,
        tt1.app_id,
        tt1.scene_id,
        tt1.final_result,
        coalesce(tt2.result, 0) as screen_result,
        tt1.workflow_flow_no,
                task_run_step,
        row_number() over(partition by tt1.apply_no, tt1.temp_app_id, tt1.scene_id order by tt1.req_time desc, tt1.handle_end_time desc) as rn
    from (
        select
            split(reqno, "\\|")[0] as apply_no,
            app_id,
            scene_id,
            final_result,
            workflow_flow_no,
            req_time,
            handle_end_time,
            task_run_step,
            case when app_id in ('kyc', 'voi') then 'kyc' else 'af' end as temp_app_id
        from risk.dwd_risk_vn_strategy_final_result_merge_di_v2
        where grass_date >= date_sub('${bizdate}', 190)
            and app_id in ('kyc', 'voi', 'spj')
    ) tt1
    left join (
        select
            workflow_flow_no as ticket_id,
            af_screen_result as result
        from risk.dwd_credit_vn_risk_ticket_df
        where grass_date = '${bizdate}'
    ) tt2 on tt1.workflow_flow_no = tt2.ticket_id
) t1
where t1.rn = 1
;

-- af - kredit final_result
create or replace temporary view kredit_result_info as
select
    t1.apply_no,
    t1.scene_id,
    t1.final_result,
    t1.flow_no as af_af_workflow_flow_no
        ,t1.task_run_step as af_af_workflow_task_run_step
from (
    select
        split(tt1.reqno, "\\|")[0] as apply_no,
        tt1.scene_id,
        tt1.final_result,
        tt1.flow_no,
        tt1.task_run_step,
        row_number() over(partition by split(tt1.reqno, "\\|")[0], tt1.app_id, tt1.scene_id order by tt1.req_time desc, tt1.handle_end_time desc) as rn
    from risk.dwd_risk_vn_strategy_final_result_merge_di_v2 tt1
    where tt1.grass_date >= date_sub('${bizdate}', 190)
    and tt1.app_id = 'spj'
) t1
where t1.rn = 1
;

-- uw result
create or replace temporary view uw_result_info as
select
    request_id,
    uw_result
from (
    select
        request_id,
        case
            when upper(result) = 'APPROVE' then 1
            when upper(result) = 'REJECT' then 2
            when upper(result) in ('P', 'PENDING') then 3
            else -1
        end as uw_result,
        row_number() over(partition by request_id order by request_time desc) as rn
    from risk.dws_risk_vn_bcl_uw_process_by_request_id_df
    where grass_date = '${bizdate}'
    and req_date >= date_sub('${bizdate}', 190)
    and policy_status IN (1, 2) -- 1, 2: live 3: shadow
    and request_id IS NOT NULL
    and flow in (1, 6) -- 1,6: "loan origination"
) t1
where rn = 1
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
    ,case when t.af_result_10001=-1 then null else t.af_result_10001 end                                                   as af_result_10001
    ,case when t.af_result_10001_10012=-1 then null else t.af_result_10001_10012 end                                       as af_result_10001_10012
    ,case when t.af_result_10001_10013=-1 then null else t.af_result_10001_10013 end                                       as af_result_10001_10013
    ,t.rejected_reason                                                                                                     as rejected_reason
    ,t.reject_code                                                                                                         as reject_code
    ,case when t.af_result_10001_10003=-1 then null else t.af_result_10001_10003 end                                       as af_result_10001_10003
    ,case when t.af_result_10011_10012_screen=-1 then null else t.af_result_10011_10012_screen end                         as af_result_10011_10012_screen
    ,case when t.af_result_10001_10012_screen=-1 then null else t.af_result_10001_10012_screen end                         as af_result_10001_10012_screen
    ,case when t.af_result_10001_10003_screen=-1 then null else t.af_result_10001_10003_screen end                         as af_result_10001_10003_screen
    ,null                                   as is_skip_idwall
    ,t.otp_status                           as otp_status
    ,t.bank_status                          as bank_status
    ,0                                       as af_kyc_risk_screen_sla
    ,t.af_kyc_workflow_flow_no              as af_kyc_workflow_flow_no
    ,t.af_af_workflow_flow_no               as af_af_workflow_flow_no
    ,t.af_kyc_workflow_task_run_step
    ,t.af_af_workflow_task_run_step
    ,'VN'                                                                                                                  as grass_region
    ,'bcl'                                                                                                                 as biz_name
    ,'${bizdate}'                                                                                                          as grass_date
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
        ,t1.otp_status                  as otp_status
        ,t1.bank_status                 as bank_status
        ,t1.risk_resp_flow_no           as risk_resp_flow_no
        ,coalesce(t2.app_id,null)       as af_share_kyc_type
        ,max(case when t2.scene_id = '10001' then t2.final_result else -1 end)  as af_result_share_kyc_10001
        ,max(case when t2.scene_id = '10012' then t2.final_result else -1 end)  as af_result_share_kyc_10001_10012
        ,max(case when t2.scene_id = '10012' then t2.screen_result else -1 end) as af_result_share_kyc_10001_10012_screen
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
        ,max(case when t3.scene_id = '10001' then t3.final_result else -1 end)  as af_result_10001
        ,max(case when t3.scene_id = '10012' then t3.final_result else -1 end)  as af_result_10001_10012
        ,max(case when t3.scene_id = '10013' then t3.final_result else -1 end)  as af_result_10001_10013
        ,t1.rejected_reason                                                                                 as rejected_reason
        ,t1.reject_code                                                                                     as reject_code
        ,null                                                                                               as af_result_10001_10003
        ,null                                                                                               as af_result_10011_10012_screen
        ,max(case when t5.scene_id = '10012' then t5.screen_result else -1 end) as af_result_10001_10012_screen
        ,null                                                                                               as af_result_10001_10003_screen
        ,max(case when t2.scene_id = '10001' then t2.af_kyc_workflow_flow_no else null end)  as af_kyc_workflow_flow_no
        ,max(case when t3.scene_id = '10001' then t3.af_af_workflow_flow_no else null end)  as af_af_workflow_flow_no

        ,max(case when t2.apply_no is not null and t2.scene_id = '10001' then t2.af_kyc_workflow_task_run_step else null end)  as af_kyc_workflow_task_run_step 
        ,max(case when t3.apply_no is not null and t3.scene_id = '10001' then t3.af_af_workflow_task_run_step else null end)  as af_af_workflow_task_run_step
    FROM      apply_base_info          AS t1
    LEFT JOIN kyc_result_info          AS t2 ON t1.apply_no = t2.apply_no
                                            AND t2.app_id IN ('kyc', 'voi')
    LEFT JOIN kredit_result_info       AS t3 ON t1.apply_no = t3.apply_no
    LEFT JOIN uw_result_info           AS t4 ON coalesce(t1.risk_resp_flow_no, t3.af_af_workflow_flow_no) = t4.request_id
    LEFT JOIN kyc_result_info          AS t5 ON t1.apply_no = t5.apply_no
                                            AND t5.app_id IN ('spj')
    group by
         t1.apply_no
        ,t1.platform_user_id
        ,t1.credit_user_id
        ,t1.apply_create_time
        ,t1.activate_submit_time
        ,t1.apply_type
        ,t1.apply_status
        ,t1.rejected_reason_type
        ,t1.screen_status
        ,t1.otp_status
        ,t1.bank_status
        ,t1.risk_resp_flow_no
        ,coalesce(t2.app_id,null)
        ,coalesce(t4.uw_result,null)
        ,t1.user_label
        ,t1.uc_screen_update_info_result
        ,t1.rejected_reason
        ,t1.reject_code
) AS t
;

msck repair table risk.wide_application_apply_info_nd;
msck repair table risk.wide_bcl_vn_application_apply_risk_af_uw_info_nd;