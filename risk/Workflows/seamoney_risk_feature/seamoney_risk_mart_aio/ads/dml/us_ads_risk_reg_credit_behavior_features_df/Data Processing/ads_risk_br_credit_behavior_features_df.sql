-- Risk(ADS) SQL
--**************************************************************************
-- ** 所属主题: 信贷
-- ** 功能描述: 贷中分析时，所使用的所有维度属性
-- ** 创建者 : huangwei@shopee.com
-- ** 创建日期: 20231113 
-- ** 修改日志:
-- ** 修改日期 
-- yyyymmdd name comment 
-- 20231113 初始化 初始化
--**************************************************************************
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table ${SCHEMA}.ads_risk_${region_lower}_credit_behavior_features_df partition (grass_date = '${ds}')
select  
        t1.credit_user_id
        ,t1.platform_user_id
        --risk相关
        ,t2.is_whitelisted_scl
        ,t2.is_whitelisted_bcl
        ,t2.is_whitelisted_spl
        ,cast(t8.bscore as DECIMAL(30,10)) as bscore
        ,t8.bscore_grass_date
        ,t8.bscore_overdue_tag
        ,null as antifraud_tag
        --apply
        ,datediff('${ds}', date(bcl_activation_time)) as activated_from_now_bcl
        ,t1.is_activated_bcl
        ,t1.is_activated_spl
        --quota-bcl
        ,if(t3.total_credit_limit = 0, -9998, (t3.total_used_credit_amount+t3.total_frozen_credit_amount)/t3.total_credit_limit) as total_limit_utilization_bcl
        ,t3.total_credit_limit as total_limit_bcl
        ,t3.common_temp_credit_limit as temperory_limit_bcl
        ,t3.total_used_credit_amount as used_limit_bcl
        ,if(t3.common_perm_credit_limit = 0, -9998, t3.common_perm_used_credit_amount/t3.common_perm_credit_limit)  as permanent_total_limit_utilization_excluding_frozen_bcl
        --quota-spl
        ,if(t4.common_credit_limit = 0, -9998, (t4.common_used_credit_amount+t4.common_frozen_credit_amount)/t4.common_credit_limit) as permanent_general_limit_utilization_spl
        ,if(t4.installment_credit_limit = 0, -9998, (t4.installment_used_credit_amount+t4.installment_frozen_credit_amount)/t4.installment_credit_limit) as permanent_installment_limit_utilization_spl
        ,if(t4.total_credit_limit = 0, -9998, (t4.total_used_credit_amount+t4.total_frozen_credit_amount)/t4.total_credit_limit) as total_limit_utilization_spl
        ,if(t4.common_perm_credit_limit = 0, -9998, t4.common_perm_used_credit_amount/t4.common_perm_credit_limit) as permanent_total_limit_utilization_excluding_frozen_spl
        ,t4.total_used_credit_amount as used_limit_spl
        --disburse
        ,t3.disbursed_cnt as disbursed_cnt_bcl
        ,t4.disbursed_cnt as disbursed_cnt_spl
        ,t4.is_disbursed=1 as is_disbursed_spl
        ,t3.is_disbursed=1 as is_disbursed_bcl
        --bill
        ,if(t5.bill_cnt_90d_bcl = 0, 0, t5.bill_amt_90d_bcl/t5.bill_cnt_90d_bcl) as average_bill_amt_90d_bcl
        ,if(t6.bill_cnt_90d_spl = 0, 0, t6.bill_amt_90d_spl/t6.bill_cnt_90d_spl) as average_bill_amt_90d_spl
        ,if(coalesce(t6.bill_cnt_90d_spl, 0)+coalesce(t5.bill_cnt_90d_bcl, 0) = 0, 0, (coalesce(t6.bill_amt_90d_spl, 0)+coalesce(t5.bill_amt_90d_bcl, 0))/(coalesce(t6.bill_cnt_90d_spl, 0)+coalesce(t5.bill_cnt_90d_bcl, 0))) as average_bill_amt_90d_user
        ,datediff('${ds}', if(t5.first_bill_date_bcl > t6.first_bill_date_spl, t6.first_bill_date_spl, coalesce(t5.first_bill_date_bcl, t6.first_bill_date_spl))) as first_billed_from_now
        ,datediff('${ds}', t5.first_bill_date_bcl) as first_billed_from_now_bcl
        ,datediff('${ds}', t6.first_bill_date_spl) as first_billed_from_now_spl
        ,t3.is_billed=1 as is_billed_bcl
        ,t4.is_billed=1 as is_billed_spl
        ,t3.last_bill_amt as latest_bill_amt_bcl
        ,t4.last_bill_amt as latest_bill_amt_spl
        ,t3.last_bill_amt+t4.last_bill_amt as latest_bill_amt_user
        ,t3.repaid_bill_num as repaid_bills_num_bcl
        ,t4.repaid_bill_num as repaid_bills_num_spl
        ,t3.repaid_bill_num+t4.repaid_bill_num as repaid_bills_num_user
        --repay
        ,datediff('${ds}', if(t3.last_repay_time < t4.last_repay_time, t4.last_repay_time, coalesce(t3.last_repay_time, t4.last_repay_time))) as last_repay_from_now
        --overdue
        ,t3.current_dpd_eod as current_dpd_bcl
        ,null as current_dpd_scl
        ,t4.current_dpd_eod as current_dpd_spl
        ,t3.ever_max_dpd_180d as ever_max_dpd_180d_bcl
        ,t4.ever_max_dpd_180d as ever_max_dpd_180d_spl
        ,t3.ever_max_dpd_360d as ever_max_dpd_360d_bcl
        ,t4.ever_max_dpd_360d as ever_max_dpd_360d_spl
        ,t3.historical_max_dpd_eod as ever_max_dpd_bcl
        ,null as ever_max_dpd_scl
        ,t4.historical_max_dpd_eod as ever_max_dpd_spl
        ,t9.latest_dpd_bcl as latest_dpd_bcl
        ,t9.latest_dpd_spl as latest_dpd_spl
        --credit userinfo
        ,t1.user_status as credit_user_status
        ,t1.account_label as user_tag_spl
        --shopee userinfo
        ,t10.status as shopee_account_status
        ,datediff('${ds}', t10.shopee_registration_datetime) as shopee_age
        ,t11.buyer_nmv_usd_in_180d as confirmed_gmv_usd_in_180d_user
        ,t11.buyer_spl_exclude_nmv_usd_in_180d as confirmed_gmv_usd_in_180d_spl
from    (
    select  platform_user_id
            ,credit_user_id
            ,max(if(product_id = 1, new_activation_time, null)) as bcl_activation_time
            ,max(product_id = 1 and has_valid_activated = 1) as is_activated_bcl
            ,max(product_id = 3 and has_valid_activated = 1) as is_activated_spl
            ,max(if(product_id = 3, account_label, null)) as account_label
            ,max(if(product_id = 3, user_status, null)) as user_status
    from    credit_uc.dws_aio_${region_lower}_uc_user_df
    where   grass_date = '${ds}'
    group by platform_user_id, credit_user_id
) t1
left join (
    select  platform_user_id
            ,max(product_id = 2 and status = 1) as is_whitelisted_scl
            ,max(product_id = 1 and status = 1) as is_whitelisted_bcl
            ,max(product_id = 3 and status = 1) as is_whitelisted_spl
    from    credit_uc.dwd_uc_whitelist_user_df
    where   grass_region = '${region_upper}'
    group by platform_user_id
) t2
on      t1.platform_user_id = t2.platform_user_id
left join (
    select  credit_user_id
            ,total_credit_limit
            ,total_used_credit_amount
            ,total_frozen_credit_amount
            ,disbursed_cnt
            ,is_disbursed
            ,is_billed
            ,last_bill_amt
            ,repaid_bill_num
            ,last_repay_time
            ,current_dpd_eod
            ,common_perm_credit_limit
            ,common_perm_used_credit_amount
            ,common_temp_credit_limit
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
            ,historical_max_dpd_eod
    from    credit_mart.dws_bcl_${user_bcl_region}_user_df
    where   grass_date = '${ds}'
    and '${region_lower}' = '${user_bcl_region}'
) t3
on      t1.credit_user_id = t3.credit_user_id
left join (
    select  credit_user_id
            ,total_credit_limit
            ,total_used_credit_amount
            ,total_frozen_credit_amount
            ,total_available_credit_amount
            ,common_credit_limit
            ,common_used_credit_amount
            ,common_frozen_credit_amount
            ,common_available_credit_amount
            ,installment_credit_limit
            ,installment_used_credit_amount
            ,installment_frozen_credit_amount
            ,installment_available_credit_amount
            ,disbursed_cnt
            ,is_disbursed
            ,is_billed
            ,last_bill_amt
            ,repaid_bill_num
            ,last_repay_time
            ,current_dpd_eod
            ,common_perm_credit_limit
            ,common_perm_used_credit_amount
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
            ,historical_max_dpd_eod
    from    credit_mart.dws_spl_${region_lower}_user_df
    where   grass_date = '${ds}'
) t4
on      t1.credit_user_id = t4.credit_user_id
left join (
    select  credit_user_id
            ,count(if(month_bill_time >= date_sub('${ds}', 90), bill_id, null)) as bill_cnt_90d_bcl
            ,sum(if(month_bill_time >= date_sub('${ds}', 90), total_amount_repayable, 0)) as bill_amt_90d_bcl
            ,min(if(month_bill_time > '2000-01-01', date(month_bill_time), null)) as first_bill_date_bcl	--排除无效时间
    from    credit_mart.dws_bcl_${bcl_region}_bill_repayment_df
    where   grass_date = '${ds}'
      and   total_amount_repayable > 0
      and   '${region_lower}' = '${bcl_region}'
      and   1 = 0
    group by credit_user_id
) t5
on      t1.credit_user_id = t5.credit_user_id
left join (
    select  credit_user_id
            ,count(if(month_bill_time >= date_sub('${ds}', 90), bill_id, null)) as bill_cnt_90d_spl
            ,sum(if(month_bill_time >= date_sub('${ds}', 90), total_amount_repayable, 0)) as bill_amt_90d_spl
            ,min(if(month_bill_time > '2000-01-01', date(month_bill_time), null)) as first_bill_date_spl	--排除无效时间
    from    credit_mart.dws_spl_${region_lower}_bill_repayment_df
    where   grass_date = '${ds}'
      and   total_amount_repayable > 0
    group by credit_user_id
) t6
on      t1.credit_user_id = t6.credit_user_id
--left join (
--    select  credit_user_id
--            ,current_dpd_eod
--            ,ever_max_dpd_180d
--            ,ever_max_dpd_360d
--            ,historical_max_dpd_eod
--    from    credit_mart.dws_scl_${user_scl_region}_user_df
--    where   grass_date = '${ds}'
--    and   '${region_lower}' = '${user_scl_region}'
--) t7
--on      t1.credit_user_id = t7.credit_user_id
left join (
        select 
        * 
        from (
                select
                        platform_user_id
                        ,GET_JSON_OBJECT(score, '$.score')  as bscore
                        ,GET_JSON_OBJECT(score, '$.score_date')  as bscore_grass_date
                        ,GET_JSON_OBJECT(score, '$.overdue_tag')  as bscore_overdue_tag
                        ,ROW_NUMBER() over (partition by platform_user_id order by model_version desc) as rn
                from risk.dws_risk_user_score_df
                where grass_date='${ds}'
                and grass_region='${region_upper}'
                and source_table='rescbds_credit.${region_lower}_user_bcard_credit_score_feature_pool'
                and biz_type='user_bcard_credit_score'
        ) where rn=1
) t8
on      t1.platform_user_id = t8.platform_user_id
left join (
    select  credit_user_id
            ,latest_dpd_spl
            ,latest_dpd_bcl
    from    risk.dws_aio_${region_lower}_user_dpd_df
    where   grass_date = '${ds}'
) t9
on      t1.credit_user_id = t9.credit_user_id
left join (
    select  user_id as platform_user_id
            ,status
            ,registration_datetime as shopee_registration_datetime
            ,grass_region
    from    mp_user.dim_user__reg_s0_live
    where   tz_type = 'local'
      and   grass_region = '${region_upper}'
      and   grass_date = '${ds}'
) t10
on      t1.platform_user_id = t10.platform_user_id
left join (
    select  buyer_id as platform_user_id
            ,buyer_nmv_usd_in_180d
            ,buyer_spl_exclude_nmv_usd_in_180d
    from    risk.dws_risk_buyer_txn_df
    where   grass_date = '${ds}'
      and   grass_region = '${region_upper}'
) t11
on      t1.platform_user_id = t11.platform_user_id

