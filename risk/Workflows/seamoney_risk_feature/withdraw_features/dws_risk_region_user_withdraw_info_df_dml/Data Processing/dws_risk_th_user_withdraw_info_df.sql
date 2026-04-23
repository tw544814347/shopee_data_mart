--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2023-11-01
-- Theme Domain：       risk-feature
-- Description:         spl/bcl/scl user_withdraw_feature
-- Data Granularity:    user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com，2023-12-14 增加注释，新增字段rejected_num_90d_bcl, jira https://jira.shopee.io/browse/SPFDT-25987
--      update by wei.tao 新增 tl 和 chp 字段 https://jira.shopee.io/browse/SPFDT-59597
--********************************************************************--

ADD JAR hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

        insert overwrite risk.dws_risk_${region_lower}_user_withdraw_info_df
        select
            substring(md5(cast(t1.user_id as string)), 0, 2) || '_' || t1.user_id as row_key,
            t1.user_id as credit_user_id,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t2.is_90d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_90d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t2.is_90d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_90d_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t2.is_90d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_90d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t2.is_90d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_90d_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t2.is_180d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_180d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t2.is_180d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_180d_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t2.is_180d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_180d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t2.is_180d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_180d_spl,
            count(
                distinct if(
                    t2.is_90d 
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null ) 
            )as rejected_num_90d_bcl,
            -- ========== 新增 tl 指标（从 t3 新表取数）==========
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t3.is_tl_policy,
                    t3.flow_no,
                    null
                )
            ) as postloan_reject_cnt_tl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t3.is_tl_policy,
                    t3.flow_no,
                    null
                )
            ) as preloan_reject_cnt_tl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t3.is_90d
                    and t3.is_tl_policy,
                    t3.flow_no,
                    null
                )
            ) as postloan_reject_cnt_90d_tl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t3.is_90d
                    and t3.is_tl_policy,
                    t3.flow_no,
                    null
                )
            ) as preloan_reject_cnt_90d_tl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t3.is_180d
                    and t3.is_tl_policy,
                    t3.flow_no,
                    null
                )
            ) as postloan_reject_cnt_180d_tl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t3.is_180d
                    and t3.is_tl_policy,
                    t3.flow_no,
                    null
                )
            ) as preloan_reject_cnt_180d_tl,
            -- ========== 新增 chp 指标（从 t3 新表取数）==========
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t3.is_chp_policy,
                    t3.flow_no,
                    null
                )
            ) as postloan_reject_cnt_chp,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t3.is_chp_policy,
                    t3.flow_no,
                    null
                )
            ) as preloan_reject_cnt_chp,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t3.is_90d
                    and t3.is_chp_policy,
                    t3.flow_no,
                    null
                )
            ) as postloan_reject_cnt_90d_chp,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t3.is_90d
                    and t3.is_chp_policy,
                    t3.flow_no,
                    null
                )
            ) as preloan_reject_cnt_90d_chp,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t3.is_180d
                    and t3.is_chp_policy,
                    t3.flow_no,
                    null
                )
            ) as postloan_reject_cnt_180d_chp,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t3.is_180d
                    and t3.is_chp_policy,
                    t3.flow_no,
                    null
                )
            ) as preloan_reject_cnt_180d_chp,
            '${begin_ds}' as grass_date
        from
            (
                select
                    *
                    ${userid_alias}
                from
                    risk.dws_risk_${region_lower}_user_dpd_df
                where
                    grass_date = '${begin_ds}'
            ) t1
            left join (
                select
                    credit_user_id,
                    flow_no,
                    topic_name,
                    risk_scene_id,
                    date_sub('${begin_ds}', 90) <= grass_date as is_90d,
                    date_sub('${begin_ds}', 180) <= grass_date as is_180d,
                    topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_kredit'
                    and risk_scene_id in ('10025', '10035', '10045', '10055', '10075') as is_spl_policy,
                    topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_spj'
                    and risk_scene_id = '10025' as is_bcl_policy
                from
                    risk.dwd_risk_${region_lower}_strategy_task_result_merge_di
                where
                    task_name = 'invoke_policy'
                    and task_result = 2
                    and (
                        -- 原有 spl 条件
                        (
                            topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_kredit'
                            and risk_scene_id in('10025', '10035', '10045', '10055', '10075')
                        )
                        -- 原有 bcl 条件
                        or (
                            topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_spj'
                            and risk_scene_id ='10025'
                        )
                    )
            ) t2 on t1.user_id = t2.credit_user_id
            -- ========== 新增 t3：从新表 dwd_risk_th_live_kafka_gateway_aio_log_di 获取 chp 和 tl 数据 ==========
            left join (
                select
                    credit_user_id,
                    flow_no,
                    topic_name,
                    risk_scene_id,
                    biz_type,
                    date_sub('${begin_ds}', 90) <= grass_date as is_90d,
                    date_sub('${begin_ds}', 180) <= grass_date as is_180d,
                    -- chp 策略标识
                    topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_kredit'
                    and risk_scene_id in ('10025', '10035', '10045', '10084') 
                    and biz_type = 7 as is_chp_policy,
                    -- tl 策略标识
                    topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_tl'
                    and risk_scene_id in ('10025') as is_tl_policy
                from 
                (
                    select 
                        credit_user_id,
                        flow_no,
                        topic_name,
                        risk_scene_id,
                        biz_type,
                        get_json_object(all_task_result, '$.Name')         as task_name,
                        get_json_object(all_task_result, '$.Status')       as task_status,
                        get_json_object(all_task_result, '$.Result')       as task_result,
                        grass_date
                    from
                    (
                        select 
                            get_json_object(value, '$.ReqParams.CommonHeader.credit_user_id') as credit_user_id,
                            get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as flow_no,
                            t1.tn as topic_name,
                            t1.scene_id as risk_scene_id,
                            get_json_object(value, '$.ReqParams.biz_type') as biz_type,	
                            get_json_object(value, '$.Rsp.RiskInsight.TaskResults') as task_result_array,
                            grass_date
                        from risk.ods_risk_live_kafka_gateway_req_rsp_di_v3 t1
                        inner join risk.dim_risk_reg_strategy_task_result_merge_di t2
                        on t1.tn = cast(concat('${region_lower}_live_credit_risk_gateway_req_rsp_',t2.app_id) as string) 
                            and t1.scene_id = t2.scene_id
                        where   t1.grass_date >= '2025-01-01' -- splx 和 bclx 上线时间不足一年
                            and   t1.grass_region = upper('${region_lower}')
                            and   get_json_object(t1.value, '$.Req.RiskReqHeader.AppID') is not null
                    )
                    lateral view explode(json_to_array(task_result_array))tbl as all_task_result
                ) t3_sub
                where
                    task_name = 'invoke_policy'
                    and task_result = 2
                    and (
                        -- chp 条件
                        (
                            topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_kredit'
                            and risk_scene_id in ('10025', '10035', '10045', '10084')
                            and biz_type = 7
                        )
                        -- tl 条件
                        or (
                            topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_tl'
                            and risk_scene_id in ('10025')
                        )
                    )
            ) t3 on t1.user_id = t3.credit_user_id
        group by
            t1.user_id
