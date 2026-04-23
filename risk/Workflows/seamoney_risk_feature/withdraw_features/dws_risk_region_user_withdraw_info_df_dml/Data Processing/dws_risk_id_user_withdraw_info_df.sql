--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2023-11-01
-- Theme Domain：       risk-feature
-- Description:         spl/bcl/scl user_withdraw_feature
-- Data Granularity:    user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com，2023-12-14 增加注释，新增字段rejected_num_90d_bcl, jira https://jira.shopee.io/browse/SPFDT-25987
--********************************************************************--



insert overwrite risk.dws_risk_${region_lower}_user_withdraw_info_df
select
    substring(md5(cast(t1.user_id as string)), 0, 2) || '_' || t1.user_id as row_key,
    t1.user_id as credit_user_id,
    count(
        distinct if(
            days_after_first_due_date_cashloan >= 1
            and is_bcl_policy,
            flow_no,
            null
        )
    ) as postloan_reject_cnt_bcl,
    count(
        distinct if(
            days_after_first_due_date_spl >= 1
            and is_spl_policy,
            flow_no,
            null
        )
    ) as postloan_reject_cnt_spl,
    count(
        distinct if(
            days_after_first_due_date_cashloan < 1
            and is_bcl_policy,
            flow_no,
            null
        )
    ) as preloan_reject_cnt_bcl,
    count(
        distinct if(
            days_after_first_due_date_spl < 1
            and is_spl_policy,
            flow_no,
            null
        )
    ) as preloan_reject_cnt_spl,
    count(
        distinct if(
            days_after_first_due_date_cashloan >= 1
            and is_90d
            and is_bcl_policy,
            flow_no,
            null
        )
    ) as postloan_reject_cnt_90d_bcl,
    count(
        distinct if(
            days_after_first_due_date_spl >= 1
            and is_90d
            and is_spl_policy,
            flow_no,
            null
        )
    ) as postloan_reject_cnt_90d_spl,
    count(
        distinct if(
            days_after_first_due_date_cashloan < 1
            and is_90d
            and is_bcl_policy,
            flow_no,
            null
        )
    ) as preloan_reject_cnt_90d_bcl,
    count(
        distinct if(
            days_after_first_due_date_spl < 1
            and is_90d
            and is_spl_policy,
            flow_no,
            null
        )
    ) as preloan_reject_cnt_90d_spl,
    count(
        distinct if(
            days_after_first_due_date_cashloan >= 1
            and is_180d
            and is_bcl_policy,
            flow_no,
            null
        )
    ) as postloan_reject_cnt_180d_bcl,
    count(
        distinct if(
            days_after_first_due_date_spl >= 1
            and is_180d
            and is_spl_policy,
            flow_no,
            null
        )
    ) as postloan_reject_cnt_180d_spl,
    count(
        distinct if(
            days_after_first_due_date_cashloan < 1
            and is_180d
            and is_bcl_policy,
            flow_no,
            null
        )
    ) as preloan_reject_cnt_180d_bcl,
    count(
        distinct if(
            days_after_first_due_date_spl < 1
            and is_180d
            and is_spl_policy,
            flow_no,
            null
        )
    ) as preloan_reject_cnt_180d_spl,
    count(
        distinct if(
            is_90d 
            and is_bcl_policy,
            flow_no,
            null ) 
    )as rejected_num_90d_bcl,
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
                (
                    topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_kredit'
                    and risk_scene_id in('10025', '10035', '10045', '10055', '10075')
                )
                or (
                    topic_name = '${region_lower}_live_credit_risk_gateway_req_rsp_spj'
                    and risk_scene_id ='10025'
                )
            )
    ) t2 on t1.user_id = t2.credit_user_id
group by
    t1.user_id
