-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: ads_risk_${table_product}_${table_region}_user_df
-- ** Create Author|创建人: hejia.an
-- ** Create time|创建日期: 2025-07-31
-- ** Modified log|修改日志:
-- **             修改日期: 2025-07-31  修改人:hejia.an  新建内容: https://docs.google.com/spreadsheets/d/1yYtlZE7Di3UiKZ70TUcVkhqp7J2pekSHdG_wmixsqmc/edit?gid=1674787113#gid=1674787113
-- **             修改日期: 2025-08-05  修改人:hejia.an  修改内容: 分产品子表，添加注释，下线mp相关字段
-- **             修改日期: 2025-08-10  修改人:hejia.an  修改内容: 去除不必要的去重逻辑，增加利用率字段
-- **             修改日期: 2025-08-11  修改人:hejia.an  修改内容: 冻结字段，拆分为用户粒度，和产品粒度
-- **             修改日期: 2025-08-13  修改人:hejia.an  修改内容: spl biz_type变为3，7，取splx。后续放到宽表里去打横
-- **             修改日期: 2025-08-15  修改人:hejia.an  修改内容: 修改根据数组位置计算利率的逻辑
-- **             修改日期: 2025-09-23  修改人:hejia.an  修改内容: account表切换aio，ddl放到代码前边
-- **             修改日期: 2025-09-26  修改人:hejia.an  修改内容: 补充历史额度利用率字段
-- **             修改日期: 2025-11-06  修改人:hejia.an  修改内容: 补充BR需求字段：https://docs.google.com/spreadsheets/d/1HvtmypV26djmILUlX_pnJq48hyH4pPV3eIzIQ_9jx2Y/edit?gid=1688131530#gid=1688131530
-- **             修改日期: 2025-11-28  修改人:hejia.an  修改内容: 源表切换为credit_uc.dws_uc_${table_region}_user_lock_status_df
-- **             修改日期: 2026-01-08  修改人:hejia.an  修改内容: 源表切换为account_mid_df
-- **             修改日期: 2026-03-11  修改人:siyuan.sun 修改内容: 新增BR地区需求字段: first_activation_application_time和last_activation_application_time字段，需求文档: https://docs.google.com/spreadsheets/d/10ECrH99eEe4T4u_DREPevibN58f0DmDAc5JLnPSBsoI/edit?gid=170680832#gid=170680832  
-- **             修改日期: 2026-03-11  修改人:siyuan.sun 修改内容: 新增BR地区需求字段: repaid_bills_cnt字段，不同产品有不同的逻辑，SPL需要排除refund订单和restructure订单进行计算，需求文档: https://docs.google.com/spreadsheets/d/10ECrH99eEe4T4u_DREPevibN58f0DmDAc5JLnPSBsoI/edit?gid=170680832#gid=170680832  
-- **             修改日期: 2026-03-11  修改人:siyuan.sun 修改内容: Backfill BR地区需求字段: 激活时额度和利率字段从risk_feature.dws_risk_br_spl_activate_interest_rate_di取数，按(credit_user_id,platform_user_id,biz_type)取最新grass_date一条，需求文档: https://docs.google.com/spreadsheets/d/10ECrH99eEe4T4u_DREPevibN58f0DmDAc5JLnPSBsoI/edit?gid=170680832#gid=170680832
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************

-- drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df;
create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df (
    credit_user_id                          string          comment 'credit user id'
    ,platform_user_id                       string          comment 'shopee user id'
    ,sp_user_id                             string          comment 'shopee user id'
    ,spp_user_id                            string          comment 'shopeepay user id'
    ,product_id                             string          comment 'product id'
    ,user_status                            string          comment 'user status'
    ,is_limit_expired                       int             comment 'Whether limit is expired'
    ,has_valid_activated                    int             comment 'Whether has valid activated'
    ,first_activation_time                  string          comment 'First activation time'
    ,new_activation_time                    string          comment 'New activation time'
    ,month_since_activation                 int             comment 'Month since activation'
    ,is_activated_l1d                       int             comment 'Whether activated in last 1 day'
    ,is_activated_l30d                      int             comment 'Whether activated in last 30 days'
    ,is_activated_l90d                      int             comment 'Whether activated in last 90 days'
    ,is_activated_l180d                     int             comment 'Whether activated in last 180 days'
    ,is_activated_l360d                     int             comment 'Whether activated in last 360 days'
    ,first_application_time                 string          comment 'First application time'
    ,last_application_time                  string          comment 'Last application time'
    ,first_activation_application_time      string          comment 'First Activation Application (apply_type=1) Time yyyy-MM-dd HH:mm:ss'
    ,last_activation_application_time       string          comment 'Last Activation Application (apply_type=1) Time yyyy-MM-dd HH:mm:ss'
    ,is_whitelist                           int             comment 'Whether user is in whitelist'
    ,whitelist_time                         string          comment 'Whitelist time'
    ,common_perm_credit_limit               decimal(30, 10) comment 'Common permanent credit limit'
    ,common_perm_frozen_credit_amount       decimal(30, 10) comment 'Common permanent frozen credit amount'
    ,common_perm_used_credit_amount         decimal(30, 10) comment 'Common permanent used credit amount'
    ,common_perm_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
    ,common_temp_credit_limit               decimal(30, 10) comment 'Common temporary credit limit'
    ,common_temp_frozen_credit_amount       decimal(30, 10) comment 'Common temporary frozen credit amount'
    ,common_temp_used_credit_amount         decimal(30, 10) comment 'Common temporary used credit amount'
    ,common_temp_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
    ,campaign_temp_credit_limit             decimal(30, 10) comment 'Campaign temporary credit limit'
    ,campaign_temp_frozen_credit_amount     decimal(30, 10) comment 'Campaign temporary frozen credit amount'
    ,campaign_temp_used_credit_amount       decimal(30, 10) comment 'Campaign temporary used credit amount'
    ,campaign_temp_available_credit_amount  decimal(30, 10) comment 'base - frozen - used'
    ,total_credit_limit                     decimal(30, 10) comment 'Total credit limit'
    ,total_used_credit_amount               decimal(30, 10) comment 'Total used credit amount'
    ,total_frozen_credit_amount             decimal(30, 10) comment 'Total frozen credit amount'
    ,common_perm_credit_limit_utilization   decimal(30, 10) comment 'Common permanent credit limit utilization rate'
    ,common_temp_credit_limit_utilization   decimal(30, 10) comment 'Common temporary credit limit utilization rate'
    ,campaign_temp_credit_limit_utilization decimal(30, 10) comment 'Campaign temporary credit limit utilization rate'
    ,total_credit_amount_utilization        decimal(30, 10) comment 'Total credit amount utilization rate'
    ,is_eligible_for_1m                     int             comment 'Whether eligible for 1 month tenure'
    ,is_eligible_for_2m                     int             comment 'Whether eligible for 2 month tenure'
    ,is_eligible_for_3m                     int             comment 'Whether eligible for 3 month tenure'
    ,is_eligible_for_6m                     int             comment 'Whether eligible for 6 month tenure'
    ,is_eligible_for_9m                     int             comment 'Whether eligible for 9 month tenure'
    ,is_eligible_for_12m                    int             comment 'Whether eligible for 12 month tenure'
    ,is_eligible_for_18m                    int             comment 'Whether eligible for 18 month tenure'
    ,is_eligible_for_24m                    int             comment 'Whether eligible for 24 month tenure'
    ,interest_rate_1m                       decimal(30, 10) comment 'eir for 1 month tenure'
    ,interest_rate_2m                       decimal(30, 10) comment 'eir for 2 month tenure'
    ,interest_rate_3m                       decimal(30, 10) comment 'eir for 3 month tenure'
    ,interest_rate_6m                       decimal(30, 10) comment 'eir for 6 month tenure'
    ,interest_rate_9m                       decimal(30, 10) comment 'eir for 9 month tenure'
    ,interest_rate_12m                      decimal(30, 10) comment 'eir for 12 month tenure'
    ,interest_rate_18m                      decimal(30, 10) comment 'eir for 18 month tenure'
    ,interest_rate_24m                      decimal(30, 10) comment 'eir for 24 month tenure'
    ,is_post_kyc_freeze                     int             comment 'Whether post kyc freeze'
    ,is_post_fraud_freeze                   int             comment 'Whether post fraud freeze'
    ,is_overdue_freeze                      int             comment 'Whether overdue freeze'
    ,is_restructure_freeze                  int             comment 'Whether restructure freeze'
    ,is_dpd_freeze                          int             comment 'Whether dpd freeze'
    ,is_underwriting_freeze                 int             comment 'Whether underwriting freeze'
    ,is_acc_closure_freeze                  int             comment 'Whether acc closure freeze'
    ,is_shopee_freeze                       int             comment 'Whether shopee freeze'
    ,is_limit_expired_freeze                int             comment 'Whether limit expired freeze'
    ,is_payment_reject_freeze               int             comment 'Whether payment reject freeze'
    ,max_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 30 days'
    ,max_common_temp_credit_limit_utilization_30d  decimal(30, 10) comment 'Max common temporary credit limit utilization in last 30 days'
    ,max_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 30 days'
    ,max_total_credit_amount_utilization_30d decimal(30, 10) comment 'Max total credit amount utilization in last 30 days'
    ,min_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 30 days'
    ,min_common_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 30 days'
    ,min_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 30 days'
    ,min_total_credit_amount_utilization_30d decimal(30, 10) comment 'Min total credit amount utilization in last 30 days'
    ,avg_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 30 days'
    ,avg_common_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 30 days'
    ,avg_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 30 days'
    ,avg_total_credit_amount_utilization_30d decimal(30, 10) comment 'Avg total credit amount utilization in last 30 days'
    ,med_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 30 days'
    ,med_common_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 30 days'
    ,med_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 30 days'
    ,med_total_credit_amount_utilization_30d decimal(30, 10) comment 'Median total credit amount utilization in last 30 days'
    ,max_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 90 days'
    ,max_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Max common temporary credit limit utilization in last 90 days'
    ,max_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 90 days'
    ,max_total_credit_amount_utilization_90d decimal(30, 10) comment 'Max total credit amount utilization in last 90 days'
    ,min_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 90 days'
    ,min_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 90 days'
    ,min_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 90 days'
    ,min_total_credit_amount_utilization_90d decimal(30, 10) comment 'Min total credit amount utilization in last 90 days'
    ,avg_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 90 days'
    ,avg_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 90 days'
    ,avg_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 90 days'
    ,avg_total_credit_amount_utilization_90d decimal(30, 10) comment 'Avg total credit amount utilization in last 90 days'
    ,med_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 90 days'
    ,med_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 90 days'
    ,med_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 90 days'
    ,med_total_credit_amount_utilization_90d decimal(30, 10) comment 'Median total credit amount utilization in last 90 days'
    ,max_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 180 days'
    ,max_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Max common temporary credit limit utilization in last 180 days'
    ,max_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 180 days'
    ,max_total_credit_amount_utilization_180d decimal(30, 10) comment 'Max total credit amount utilization in last 180 days'
    ,min_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 180 days'
    ,min_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 180 days'
    ,min_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 180 days'
    ,min_total_credit_amount_utilization_180d decimal(30, 10) comment 'Min total credit amount utilization in last 180 days'
    ,avg_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 180 days'
    ,avg_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 180 days'
    ,avg_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 180 days'
    ,avg_total_credit_amount_utilization_180d decimal(30, 10) comment 'Avg total credit amount utilization in last 180 days'
    ,med_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 180 days'
    ,med_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 180 days'
    ,med_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 180 days'
    ,med_total_credit_amount_utilization_180d decimal(30, 10) comment 'Median total credit amount utilization in last 180 days'
    ,max_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 360 days'
    ,max_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Max common temporary credit limit utilization in last 360 days'
    ,max_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 360 days'
    ,max_total_credit_amount_utilization_360d decimal(30, 10) comment 'Max total credit amount utilization in last 360 days'
    ,min_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 360 days'
    ,min_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 360 days'
    ,min_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 360 days'
    ,min_total_credit_amount_utilization_360d decimal(30, 10) comment 'Min total credit amount utilization in last 360 days'
    ,avg_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 360 days'
    ,avg_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 360 days'
    ,avg_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 360 days'
    ,avg_total_credit_amount_utilization_360d decimal(30, 10) comment 'Avg total credit amount utilization in last 360 days'
    ,med_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 360 days'
    ,med_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 360 days'
    ,med_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 360 days'
    ,med_total_credit_amount_utilization_360d decimal(30, 10) comment 'Median total credit amount utilization in last 360 days'
    -- amount/interest rate when latest activated
    ,activate_common_credit_limit decimal(30, 10) comment 'Common credit limit at latest activation'
    ,activate_campaign_credit_limit decimal(30, 10) comment 'Campaign credit limit at latest activation'
    ,activate_temp_credit_limit decimal(30, 10) comment 'Temporary credit limit at latest activation'
    ,activate_interest_rate_1m decimal(30, 10) comment 'Interest rate for 1 month tenure at latest activation'
    ,activate_interest_rate_2m decimal(30, 10) comment 'Interest rate for 2 month tenure at latest activation'
    ,activate_interest_rate_3m decimal(30, 10) comment 'Interest rate for 3 month tenure at latest activation'
    ,activate_interest_rate_6m decimal(30, 10) comment 'Interest rate for 6 month tenure at latest activation'
    ,activate_interest_rate_9m decimal(30, 10) comment 'Interest rate for 9 month tenure at latest activation'
    ,activate_interest_rate_12m decimal(30, 10) comment 'Interest rate for 12 month tenure at latest activation'
    ,activate_interest_rate_18m decimal(30, 10) comment 'Interest rate for 18 month tenure at latest activation'
    ,activate_interest_rate_24m decimal(30, 10) comment 'Interest rate for 24 month tenure at latest activation'
    ,spl_share_rate decimal(30, 10) comment 'SPL available limit share in BCL (null for SPL product)' 
    ,repaid_bills_cnt   int comment 'Count of Repaid Bills'
)
partitioned by (
    grass_date string 
) 
stored as orc 
comment 'risk user base summary table'
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${table_product}_${table_region}_user_df/grass_region=${region}'
;

-- msck repair table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df;

with spl_repaid_bills_cnt as (
with excluded_bill as (
    -- Bills whose instalments were cleared by restructure
    select bill_id
    from (
        select bill_id
        from credit_mart.dws_spl_br_instalment_repayment_df
        where grass_date = '${ds}' 
        and restructure_clear_flag = 1 
    ) t  
    union 
    -- Bills whose loans were cleared by restructure
    select i.bill_id 
    from (
        select  bill_id,
                loan_id 
        from credit_mart.dws_spl_br_instalment_repayment_df 
        where grass_date = '${ds}' 
        ) i 
    inner join 
        (select loan_id 
        from credit_mart.dws_spl_br_loan_repayment_df 
        where grass_date = '${ds}' and loan_from_restructure is not null
        ) l 
        on i.loan_id = l.loan_id 
)

select
    cast(t10.credit_user_id as string) as credit_user_id,
    cast(t10.platform_user_id as string) as platform_user_id,
    count(distinct t10.bill_id) as repaid_bills_cnt,
    cast(t10.biz_type as string) as biz_type,
    '${ds}' as grass_date  
from (
    select  credit_user_id,
            platform_user_id,
            bill_id,
            biz_type
    from credit_mart.dws_spl_br_bill_repayment_df 
    where grass_date = '${ds}'
      and biz_type in (3,7)
      and restructure_clear_flag = 0
      and total_amount_repayable - total_amount_refund - total_amount_deduct > 0
      and principal_repayable > 0
) t10
left join excluded_bill t11
    on t10.bill_id = t11.bill_id
-- Remove restructure related bills
where t11.bill_id is null 
group by
    t10.credit_user_id,
    t10.platform_user_id,
    t10.biz_type
)

insert overwrite table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df partition (grass_date = '${ds}')
select 
    t1.credit_user_id
    ,t1.platform_user_id
    ,t1.sp_user_id
    ,t1.spp_user_id
    ,t1.product_id
    ,t1.user_status
    ,t1.is_limit_expired
    ,t1.has_valid_activated
    ,t1.first_activation_time
    ,t1.new_activation_time
    ,t1.month_since_activation
    ,t1.is_activated_l1d
    ,t1.is_activated_l30d
    ,t1.is_activated_l90d
    ,t1.is_activated_l180d
    ,t1.is_activated_l360d
    ,t1.first_application_time
    ,t1.last_application_time
    ,t1.first_activation_application_time
    ,t1.last_activation_application_time  
    ,t1.is_whitelist
    ,t1.whitelist_time
    ,t1.common_perm_credit_limit
    ,t1.common_perm_frozen_credit_amount
    ,t1.common_perm_used_credit_amount
    ,t1.common_perm_available_credit_amount
    ,t1.common_temp_credit_limit
    ,t1.common_temp_frozen_credit_amount
    ,t1.common_temp_used_credit_amount
    ,t1.common_temp_available_credit_amount
    ,t1.campaign_temp_credit_limit
    ,t1.campaign_temp_frozen_credit_amount
    ,t1.campaign_temp_used_credit_amount
    ,t1.campaign_temp_available_credit_amount
    ,t1.total_credit_limit
    ,t1.total_used_credit_amount
    ,t1.total_frozen_credit_amount
    ,t1.common_perm_credit_limit_utilization
    ,t1.common_temp_credit_limit_utilization
    ,t1.campaign_temp_credit_limit_utilization
    ,t1.total_credit_amount_utilization
    ,t1.is_eligible_for_1m
    ,t1.is_eligible_for_2m
    ,t1.is_eligible_for_3m
    ,t1.is_eligible_for_6m
    ,t1.is_eligible_for_9m
    ,t1.is_eligible_for_12m
    ,t1.is_eligible_for_18m
    ,t1.is_eligible_for_24m
    ,t1.interest_rate_1m
    ,t1.interest_rate_2m
    ,t1.interest_rate_3m
    ,t1.interest_rate_6m
    ,t1.interest_rate_9m
    ,t1.interest_rate_12m
    ,t1.interest_rate_18m
    ,t1.interest_rate_24m
    ,t1.is_post_kyc_freeze
    ,t1.is_post_fraud_freeze
    ,t1.is_overdue_freeze
    ,t1.is_restructure_freeze
    ,t1.is_dpd_freeze
    ,t1.is_underwriting_freeze
    ,t1.is_acc_closure_freeze
    ,t1.is_shopee_freeze
    ,t1.is_limit_expired_freeze
    ,t1.is_payment_reject_freeze
    -- 30d
    ,t3.max_common_perm_credit_limit_utilization_30d
    ,t3.max_common_temp_credit_limit_utilization_30d
    ,t3.max_campaign_temp_credit_limit_utilization_30d
    ,t3.max_total_credit_amount_utilization_30d
    ,t3.min_common_perm_credit_limit_utilization_30d
    ,t3.min_common_temp_credit_limit_utilization_30d
    ,t3.min_campaign_temp_credit_limit_utilization_30d
    ,t3.min_total_credit_amount_utilization_30d
    ,t3.avg_common_perm_credit_limit_utilization_30d
    ,t3.avg_common_temp_credit_limit_utilization_30d
    ,t3.avg_campaign_temp_credit_limit_utilization_30d
    ,t3.avg_total_credit_amount_utilization_30d
    ,t3.med_common_perm_credit_limit_utilization_30d
    ,t3.med_common_temp_credit_limit_utilization_30d
    ,t3.med_campaign_temp_credit_limit_utilization_30d
    ,t3.med_total_credit_amount_utilization_30d
    -- 90d
    ,t3.max_common_perm_credit_limit_utilization_90d
    ,t3.max_common_temp_credit_limit_utilization_90d
    ,t3.max_campaign_temp_credit_limit_utilization_90d
    ,t3.max_total_credit_amount_utilization_90d
    ,t3.min_common_perm_credit_limit_utilization_90d
    ,t3.min_common_temp_credit_limit_utilization_90d
    ,t3.min_campaign_temp_credit_limit_utilization_90d
    ,t3.min_total_credit_amount_utilization_90d
    ,t3.avg_common_perm_credit_limit_utilization_90d
    ,t3.avg_common_temp_credit_limit_utilization_90d
    ,t3.avg_campaign_temp_credit_limit_utilization_90d
    ,t3.avg_total_credit_amount_utilization_90d
    ,t3.med_common_perm_credit_limit_utilization_90d
    ,t3.med_common_temp_credit_limit_utilization_90d
    ,t3.med_campaign_temp_credit_limit_utilization_90d
    ,t3.med_total_credit_amount_utilization_90d
    -- 180d
    ,t3.max_common_perm_credit_limit_utilization_180d
    ,t3.max_common_temp_credit_limit_utilization_180d
    ,t3.max_campaign_temp_credit_limit_utilization_180d
    ,t3.max_total_credit_amount_utilization_180d
    ,t3.min_common_perm_credit_limit_utilization_180d
    ,t3.min_common_temp_credit_limit_utilization_180d
    ,t3.min_campaign_temp_credit_limit_utilization_180d
    ,t3.min_total_credit_amount_utilization_180d
    ,t3.avg_common_perm_credit_limit_utilization_180d
    ,t3.avg_common_temp_credit_limit_utilization_180d
    ,t3.avg_campaign_temp_credit_limit_utilization_180d
    ,t3.avg_total_credit_amount_utilization_180d
    ,t3.med_common_perm_credit_limit_utilization_180d
    ,t3.med_common_temp_credit_limit_utilization_180d
    ,t3.med_campaign_temp_credit_limit_utilization_180d
    ,t3.med_total_credit_amount_utilization_180d
    -- 360d
    ,t3.max_common_perm_credit_limit_utilization_360d
    ,t3.max_common_temp_credit_limit_utilization_360d
    ,t3.max_campaign_temp_credit_limit_utilization_360d
    ,t3.max_total_credit_amount_utilization_360d
    ,t3.min_common_perm_credit_limit_utilization_360d
    ,t3.min_common_temp_credit_limit_utilization_360d
    ,t3.min_campaign_temp_credit_limit_utilization_360d
    ,t3.min_total_credit_amount_utilization_360d
    ,t3.avg_common_perm_credit_limit_utilization_360d
    ,t3.avg_common_temp_credit_limit_utilization_360d
    ,t3.avg_campaign_temp_credit_limit_utilization_360d
    ,t3.avg_total_credit_amount_utilization_360d
    ,t3.med_common_perm_credit_limit_utilization_360d
    ,t3.med_common_temp_credit_limit_utilization_360d
    ,t3.med_campaign_temp_credit_limit_utilization_360d
    ,t3.med_total_credit_amount_utilization_360d
    -- amount/interest rate when latest activated
    ,t2.activate_common_credit_limit
    ,t2.activate_campaign_credit_limit
    ,t2.activate_temp_credit_limit
    ,t2.activate_interest_rate_1m
    ,t2.activate_interest_rate_2m
    ,t2.activate_interest_rate_3m
    ,t2.activate_interest_rate_6m
    ,t2.activate_interest_rate_9m
    ,t2.activate_interest_rate_12m
    ,t2.activate_interest_rate_18m
    ,t2.activate_interest_rate_24m
    ,t1.spl_share_rate
    ,coalesce(t1.repaid_bills_cnt, 0) as repaid_bills_cnt
from 
(
    select 
        t4.credit_user_id
        ,t4.platform_user_id
        ,t4.sp_user_id
        ,t4.spp_user_id
        ,t4.product_id -- 1: bcl 3: spl 7: splx
        ,t4.user_status
        ,t4.is_limit_expired
        ,t4.has_valid_activated
        ,t4.first_activation_time
        ,t4.new_activation_time
        ,t4.month_since_activation
        ,t4.is_activated_l1d
        ,t4.is_activated_l30d
        ,t4.is_activated_l90d
        ,t4.is_activated_l180d
        ,t4.is_activated_l360d
        ,t4.first_application_time
        ,t4.last_application_time
        ,t4.first_activation_application_time
        ,t4.last_activation_application_time 
        
        ,case when t4.product_id = 3 then t5.is_whitelist_spl
            when t4.product_id = 7 then t5.is_whitelist_splx
            when t4.product_id = 1 then t5.is_whitelist_bcl 
            else null end as is_whitelist
        ,case when t4.product_id = 3 then t5.whitelist_time_spl
            when t4.product_id = 7 then t5.whitelist_time_splx
            when t4.product_id = 1 then t5.whitelist_time_bcl 
            else null end as whitelist_time
        
        ,t6.common_perm_credit_limit
        ,t6.common_perm_frozen_credit_amount
        ,t6.common_perm_used_credit_amount
        ,t6.common_perm_available_credit_amount
        ,t6.common_temp_credit_limit
        ,t6.common_temp_frozen_credit_amount
        ,t6.common_temp_used_credit_amount
        ,t6.common_temp_available_credit_amount
        ,t6.campaign_temp_credit_limit
        ,t6.campaign_temp_frozen_credit_amount
        ,t6.campaign_temp_used_credit_amount
        ,t6.campaign_temp_available_credit_amount
        ,t6.total_credit_limit
        ,t6.total_used_credit_amount
        ,t6.total_frozen_credit_amount
        ,t6.common_perm_credit_limit_utilization
        ,t6.common_temp_credit_limit_utilization
        ,t6.campaign_temp_credit_limit_utilization 
        ,t6.total_credit_amount_utilization
        ,t6.is_eligible_for_1m
        ,t6.is_eligible_for_2m
        ,t6.is_eligible_for_3m
        ,t6.is_eligible_for_6m
        ,t6.is_eligible_for_9m
        ,t6.is_eligible_for_12m
        ,t6.is_eligible_for_18m
        ,t6.is_eligible_for_24m
        ,t6.interest_rate_1m
        ,t6.interest_rate_2m
        ,t6.interest_rate_3m
        ,t6.interest_rate_6m
        ,t6.interest_rate_9m
        ,t6.interest_rate_12m
        ,t6.interest_rate_18m
        ,t6.interest_rate_24m 

        ,t7.is_post_kyc_freeze
        ,t7.is_post_fraud_freeze
        ,t7.is_overdue_freeze
        ,t7.is_restructure_freeze
        ,t7.is_dpd_freeze

        ,t8.is_underwriting_freeze
        ,t8.is_acc_closure_freeze
        ,t8.is_shopee_freeze
        ,t8.is_limit_expired_freeze
        ,t8.is_payment_reject_freeze

        ,null as max_common_perm_credit_limit_utilization_30d
        ,null as max_common_temp_credit_limit_utilization_30d
        ,null as max_campaign_temp_credit_limit_utilization_30d
        ,null as max_total_credit_amount_utilization_30d
        ,null as min_common_perm_credit_limit_utilization_30d
        ,null as min_common_temp_credit_limit_utilization_30d
        ,null as min_campaign_temp_credit_limit_utilization_30d
        ,null as min_total_credit_amount_utilization_30d
        ,null as avg_common_perm_credit_limit_utilization_30d
        ,null as avg_common_temp_credit_limit_utilization_30d
        ,null as avg_campaign_temp_credit_limit_utilization_30d
        ,null as avg_total_credit_amount_utilization_30d
        ,null as med_common_perm_credit_limit_utilization_30d
        ,null as med_common_temp_credit_limit_utilization_30d
        ,null as med_campaign_temp_credit_limit_utilization_30d
        ,null as med_total_credit_amount_utilization_30d
        ,null as max_common_perm_credit_limit_utilization_90d
        ,null as max_common_temp_credit_limit_utilization_90d
        ,null as max_campaign_temp_credit_limit_utilization_90d
        ,null as max_total_credit_amount_utilization_90d
        ,null as min_common_perm_credit_limit_utilization_90d
        ,null as min_common_temp_credit_limit_utilization_90d
        ,null as min_campaign_temp_credit_limit_utilization_90d
        ,null as min_total_credit_amount_utilization_90d
        ,null as avg_common_perm_credit_limit_utilization_90d
        ,null as avg_common_temp_credit_limit_utilization_90d
        ,null as avg_campaign_temp_credit_limit_utilization_90d
        ,null as avg_total_credit_amount_utilization_90d
        ,null as med_common_perm_credit_limit_utilization_90d
        ,null as med_common_temp_credit_limit_utilization_90d
        ,null as med_campaign_temp_credit_limit_utilization_90d
        ,null as med_total_credit_amount_utilization_90d
        ,null as max_common_perm_credit_limit_utilization_180d
        ,null as max_common_temp_credit_limit_utilization_180d
        ,null as max_campaign_temp_credit_limit_utilization_180d
        ,null as max_total_credit_amount_utilization_180d
        ,null as min_common_perm_credit_limit_utilization_180d
        ,null as min_common_temp_credit_limit_utilization_180d
        ,null as min_campaign_temp_credit_limit_utilization_180d
        ,null as min_total_credit_amount_utilization_180d
        ,null as avg_common_perm_credit_limit_utilization_180d
        ,null as avg_common_temp_credit_limit_utilization_180d
        ,null as avg_campaign_temp_credit_limit_utilization_180d
        ,null as avg_total_credit_amount_utilization_180d
        ,null as med_common_perm_credit_limit_utilization_180d
        ,null as med_common_temp_credit_limit_utilization_180d
        ,null as med_campaign_temp_credit_limit_utilization_180d
        ,null as med_total_credit_amount_utilization_180d
        ,null as max_common_perm_credit_limit_utilization_360d
        ,null as max_common_temp_credit_limit_utilization_360d
        ,null as max_campaign_temp_credit_limit_utilization_360d
        ,null as max_total_credit_amount_utilization_360d
        ,null as min_common_perm_credit_limit_utilization_360d
        ,null as min_common_temp_credit_limit_utilization_360d
        ,null as min_campaign_temp_credit_limit_utilization_360d
        ,null as min_total_credit_amount_utilization_360d
        ,null as avg_common_perm_credit_limit_utilization_360d
        ,null as avg_common_temp_credit_limit_utilization_360d
        ,null as avg_campaign_temp_credit_limit_utilization_360d
        ,null as avg_total_credit_amount_utilization_360d
        ,null as med_common_perm_credit_limit_utilization_360d
        ,null as med_common_temp_credit_limit_utilization_360d
        ,null as med_campaign_temp_credit_limit_utilization_360d
        ,null as med_total_credit_amount_utilization_360d
        -- amount/interest rate when latest activated
        ,cast(null as decimal(30, 10)) as spl_share_rate
        ,coalesce(t9.repaid_bills_cnt, 0) as repaid_bills_cnt   
    FROM
    (
        select 
            distinct credit_user_id
            ,platform_user_id 
            ,sp_user_id  -- shopee_user_ud
            ,spp_user_id  -- shopeepay_user_id
            ,product_id 
            ,user_status -- 1 → new 2 → normal 3 → lock
            ,is_limit_expired
            ,has_valid_activated
            ,first_activation_time
            ,new_activation_time
            ,floor(months_between('${ds}', date(first_activation_time))) as month_since_activation
            ,if(datediff('${ds}', date(new_activation_time)) <= 1, 1, 0) as is_activated_l1d
            ,if(datediff('${ds}', date(new_activation_time)) <= 30, 1, 0) as is_activated_l30d
            ,if(datediff('${ds}', date(new_activation_time)) <= 90, 1, 0) as is_activated_l90d
            ,if(datediff('${ds}', date(new_activation_time)) <= 180, 1, 0) as is_activated_l180d
            ,if(datediff('${ds}', date(new_activation_time)) <= 360, 1, 0) as is_activated_l360d
            ,first_application_time
            ,last_application_time
            ,first_activation_application_time
            ,last_activation_application_time  
        from credit_uc.dws_all_prod_${table_region}_uc_user_df
        WHERE grass_date = '${ds}'
        AND platform_user_id IS NOT NULL 
        and product_id in (${product_id})
        -- and platform_type = 1 -- 等panjin加上，限制shopee platform_user_id。验证过目前ph都是1
    ) t4     
    left join 
    (
        select 
            credit_user_id
            ,platform_user_id
            ,is_whitelist_spl 
            ,to_date(first_whitelist_local_time_spl) as whitelist_time_spl
            ,is_whitelist_bcl 
            ,to_date(first_whitelist_local_time_bcl) as whitelist_time_bcl
            ,is_whitelist_chp as is_whitelist_splx
            ,to_date(first_whitelist_local_time_chp) as whitelist_time_splx
        from credit_uc.ads_${table_region}_uc_user_list_wide_df -- 产品横表，splx在这张表里记为chp
        where grass_date = '${ds}' 
    ) t5
    on t4.platform_user_id = t5.platform_user_id 
    left join  
    (
        select 
            credit_user_id
            ,platform_user_id
            ,common_perm_credit_limit 
            ,common_perm_frozen_credit_amount
            ,common_perm_used_credit_amount
            ,common_perm_available_credit_amount
            ,common_temp_credit_limit
            ,common_temp_frozen_credit_amount
            ,common_temp_used_credit_amount
            ,common_temp_available_credit_amount
            ,campaign_temp_credit_limit
            ,campaign_temp_frozen_credit_amount
            ,campaign_temp_used_credit_amount
            ,campaign_temp_available_credit_amount
            ,risk_total_credit_limit as total_credit_limit -- risk定制逻辑，不同产品取不同limit相加
            ,risk_total_used_credit_amount as total_used_credit_amount -- risk定制逻辑，不同产品取不同limit相加
            ,risk_total_frozen_credit_amount as total_frozen_credit_amount -- risk定制逻辑，不同产品取不同limit相加
            ,common_perm_credit_limit_utilization
            ,common_temp_credit_limit_utilization
            ,campaign_temp_credit_limit_utilization 
            ,risk_total_credit_amount_utilization as total_credit_amount_utilization -- risk定制逻辑
            ,is_eligible_for_1m
            ,is_eligible_for_2m
            ,is_eligible_for_3m
            ,is_eligible_for_6m
            ,is_eligible_for_9m
            ,is_eligible_for_12m
            ,is_eligible_for_18m
            ,is_eligible_for_24m
            ,interest_rate_1m
            ,interest_rate_2m
            ,interest_rate_3m
            ,interest_rate_6m
            ,interest_rate_9m
            ,interest_rate_12m
            ,interest_rate_18m
            ,interest_rate_24m
            ,biz_type
        from credit_mart.dws_${table_product}_aio_${table_region}_account_mid_df
        where grass_date = '${ds}' 
        and biz_type in (${product_id})
    ) t6
    on t4.credit_user_id = t6.credit_user_id
    and t4.platform_user_id = t6.platform_user_id
    and t4.product_id = t6.biz_type
    left join 
    (
        select 
            platform_user_id
            ,credit_user_id
            ,max(is_post_kyc_freeze) as is_post_kyc_freeze -- kyc冻结
            ,max(is_post_fraud_freeze) as is_post_fraud_freeze -- 反欺诈冻结
            ,max(is_overdue_freeze) as is_overdue_freeze -- overdue冻结
            ,max(is_restructure_freeze) as is_restructure_freeze -- User is under restructure program
            ,max(is_dpd_freeze) as is_dpd_freeze -- ALL DPD 60 Freeze
        from credit_uc.dws_uc_${table_region}_user_lock_status_df 
        where grass_date = '${ds}' 
        group by platform_user_id, credit_user_id -- user粒度冻结   
    ) t7 
    on t4.credit_user_id = t7.credit_user_id
    and t4.platform_user_id = t7.platform_user_id
    left join 
    (
        select 
            platform_user_id
            ,is_underwriting_freeze -- 授信冻结
            ,is_acc_closure_freeze -- 账户关闭冻结
            ,is_shopee_freeze -- shopee状态冻结
            ,is_limit_expired_freeze -- 非SPL Xtra的额度过期冻结和SPL Xtra的支付拒绝冻结
            ,is_payment_reject_freeze -- 支付拒绝冻结
            ,product_id
        from credit_uc.dws_uc_${table_region}_user_lock_status_df  -- user + 产品粒度冻结
        where grass_date = '${ds}' 
        and product_id in (${product_id})
    ) t8
    on t4.platform_user_id = t8.platform_user_id
    and t4.product_id = t8.product_id
    left join
    (
        select
            credit_user_id,
            platform_user_id,
            repaid_bills_cnt, 
            biz_type 
        from ${table_product}_repaid_bills_cnt
        where grass_date = '${ds}'
    ) t9
    on t4.credit_user_id = t9.credit_user_id
    and t4.product_id = t9.biz_type
    and t4.platform_user_id = t9.platform_user_id
) t1
left join 
(
    select
        credit_user_id,
        platform_user_id,
        biz_type,
        activate_interest_rate_1m,
        activate_interest_rate_2m,
        activate_interest_rate_3m,
        activate_interest_rate_6m,
        activate_interest_rate_9m,
        activate_interest_rate_12m,
        activate_interest_rate_18m,
        activate_interest_rate_24m,
        activate_common_credit_limit,
        activate_campaign_credit_limit,
        activate_temp_credit_limit
    from (
        select
            credit_user_id,
            platform_user_id,
            biz_type,
            activate_interest_rate_1m,
            activate_interest_rate_2m,
            activate_interest_rate_3m,
            activate_interest_rate_6m,
            activate_interest_rate_9m,
            activate_interest_rate_12m,
            activate_interest_rate_18m,
            activate_interest_rate_24m,
            activate_common_credit_limit,
            activate_campaign_credit_limit,
            activate_temp_credit_limit,
            product_id,
            grass_date,
            row_number() over (
                partition by credit_user_id, platform_user_id, biz_type
                order by grass_date desc
            ) as rn
        from risk_feature.dws_risk_br_spl_activate_interest_rate_di
        where biz_type in (${product_id})
    ) t
    where rn = 1
) t2
on t1.credit_user_id = t2.credit_user_id
and t1.platform_user_id = t2.platform_user_id
and t1.product_id = t2.biz_type 
left join  
(
    select 
        credit_user_id
        ,platform_user_id
        -- 30d
        ,max(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as max_common_perm_credit_limit_utilization_30d
        ,max(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as max_common_temp_credit_limit_utilization_30d
        ,max(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as max_campaign_temp_credit_limit_utilization_30d
        ,max(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as max_total_credit_amount_utilization_30d
        ,min(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as min_common_perm_credit_limit_utilization_30d
        ,min(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as min_common_temp_credit_limit_utilization_30d
        ,min(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as min_campaign_temp_credit_limit_utilization_30d
        ,min(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as min_total_credit_amount_utilization_30d
        ,avg(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as avg_common_perm_credit_limit_utilization_30d
        ,avg(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as avg_common_temp_credit_limit_utilization_30d
        ,avg(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as avg_campaign_temp_credit_limit_utilization_30d
        ,avg(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as avg_total_credit_amount_utilization_30d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end, 0.5) as med_common_perm_credit_limit_utilization_30d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end, 0.5) as med_common_temp_credit_limit_utilization_30d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end, 0.5) as med_campaign_temp_credit_limit_utilization_30d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 30) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end, 0.5) as med_total_credit_amount_utilization_30d
        -- 90d
        ,max(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as max_common_perm_credit_limit_utilization_90d
        ,max(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as max_common_temp_credit_limit_utilization_90d
        ,max(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as max_campaign_temp_credit_limit_utilization_90d
        ,max(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as max_total_credit_amount_utilization_90d
        ,min(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as min_common_perm_credit_limit_utilization_90d
        ,min(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as min_common_temp_credit_limit_utilization_90d
        ,min(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as min_campaign_temp_credit_limit_utilization_90d
        ,min(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as min_total_credit_amount_utilization_90d
        ,avg(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as avg_common_perm_credit_limit_utilization_90d
        ,avg(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as avg_common_temp_credit_limit_utilization_90d
        ,avg(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as avg_campaign_temp_credit_limit_utilization_90d
        ,avg(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as avg_total_credit_amount_utilization_90d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end, 0.5) as med_common_perm_credit_limit_utilization_90d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end, 0.5) as med_common_temp_credit_limit_utilization_90d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end, 0.5) as med_campaign_temp_credit_limit_utilization_90d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 90) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end, 0.5) as med_total_credit_amount_utilization_90d
        -- 180d
        ,max(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as max_common_perm_credit_limit_utilization_180d
        ,max(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as max_common_temp_credit_limit_utilization_180d
        ,max(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as max_campaign_temp_credit_limit_utilization_180d
        ,max(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as max_total_credit_amount_utilization_180d
        ,min(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as min_common_perm_credit_limit_utilization_180d
        ,min(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as min_common_temp_credit_limit_utilization_180d
        ,min(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as min_campaign_temp_credit_limit_utilization_180d
        ,min(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as min_total_credit_amount_utilization_180d
        ,avg(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as avg_common_perm_credit_limit_utilization_180d
        ,avg(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as avg_common_temp_credit_limit_utilization_180d
        ,avg(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as avg_campaign_temp_credit_limit_utilization_180d
        ,avg(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as avg_total_credit_amount_utilization_180d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end, 0.5) as med_common_perm_credit_limit_utilization_180d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end, 0.5) as med_common_temp_credit_limit_utilization_180d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end, 0.5) as med_campaign_temp_credit_limit_utilization_180d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 180) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end, 0.5) as med_total_credit_amount_utilization_180d
        -- 360d
        ,max(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as max_common_perm_credit_limit_utilization_360d
        ,max(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as max_common_temp_credit_limit_utilization_360d
        ,max(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as max_campaign_temp_credit_limit_utilization_360d
        ,max(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as max_total_credit_amount_utilization_360d
        ,min(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as min_common_perm_credit_limit_utilization_360d
        ,min(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as min_common_temp_credit_limit_utilization_360d
        ,min(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as min_campaign_temp_credit_limit_utilization_360d
        ,min(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as min_total_credit_amount_utilization_360d
        ,avg(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end) as avg_common_perm_credit_limit_utilization_360d
        ,avg(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end) as avg_common_temp_credit_limit_utilization_360d
        ,avg(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end) as avg_campaign_temp_credit_limit_utilization_360d
        ,avg(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end) as avg_total_credit_amount_utilization_360d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_perm_credit_limit_utilization end, 0.5) as med_common_perm_credit_limit_utilization_360d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then common_temp_credit_limit_utilization end, 0.5) as med_common_temp_credit_limit_utilization_360d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then campaign_temp_credit_limit_utilization end, 0.5) as med_campaign_temp_credit_limit_utilization_360d
        ,percentile_approx(case when grass_date >= date_sub('${ds}', 360) and grass_date <= '${ds}' then risk_total_credit_amount_utilization end, 0.5) as med_total_credit_amount_utilization_360d
        ,biz_type
    from credit_mart.dws_${table_product}_aio_${table_region}_account_mid_df
    where grass_date >= date_sub('${ds}', 360)
    and grass_date <= '${ds}'
    and biz_type in (${product_id})
    group by credit_user_id, platform_user_id, biz_type
) t3
on t1.credit_user_id = t3.credit_user_id
and t1.platform_user_id = t3.platform_user_id
and t1.product_id = t3.biz_type
;

create or replace view ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_feature_df 
comment 'credit uc summary table'
as 
select 
    credit_user_id
    ,platform_user_id
    ,sp_user_id
    ,spp_user_id
    ,product_id
    ,user_status
    ,is_limit_expired
    ,has_valid_activated
    ,first_activation_time
    ,new_activation_time
    ,month_since_activation
    ,is_activated_l1d
    ,is_activated_l30d
    ,is_activated_l90d
    ,is_activated_l180d
    ,is_activated_l360d
    ,first_application_time
    ,last_application_time
    ,first_activation_application_time
    ,last_activation_application_time
    -- ,is_whitelist
    -- ,whitelist_time
    ,common_perm_credit_limit
    ,common_perm_frozen_credit_amount
    ,common_perm_used_credit_amount
    ,common_perm_available_credit_amount
    ,common_temp_credit_limit
    ,common_temp_frozen_credit_amount
    ,common_temp_used_credit_amount
    ,common_temp_available_credit_amount
    ,campaign_temp_credit_limit
    ,campaign_temp_frozen_credit_amount
    ,campaign_temp_used_credit_amount
    ,campaign_temp_available_credit_amount
    ,total_credit_limit
    ,total_used_credit_amount
    ,total_frozen_credit_amount
    ,common_perm_credit_limit_utilization
    ,common_temp_credit_limit_utilization
    ,campaign_temp_credit_limit_utilization
    ,total_credit_amount_utilization
    ,is_eligible_for_1m
    ,is_eligible_for_2m
    ,is_eligible_for_3m
    ,is_eligible_for_6m
    ,is_eligible_for_9m
    ,is_eligible_for_12m
    ,is_eligible_for_18m
    ,is_eligible_for_24m
    ,interest_rate_1m
    ,interest_rate_2m
    ,interest_rate_3m
    ,interest_rate_6m
    ,interest_rate_9m
    ,interest_rate_12m
    ,interest_rate_18m
    ,interest_rate_24m
    -- ,is_post_kyc_freeze
    -- ,is_post_fraud_freeze
    -- ,is_overdue_freeze 
    -- ,is_restructure_freeze
    -- ,is_dpd_freeze
    ,is_underwriting_freeze
    ,is_acc_closure_freeze
    ,is_shopee_freeze
    ,is_limit_expired_freeze
    ,is_payment_reject_freeze
    ,max_common_perm_credit_limit_utilization_30d
    ,max_common_temp_credit_limit_utilization_30d
    ,max_campaign_temp_credit_limit_utilization_30d
    ,max_total_credit_amount_utilization_30d
    ,min_common_perm_credit_limit_utilization_30d
    ,min_common_temp_credit_limit_utilization_30d
    ,min_campaign_temp_credit_limit_utilization_30d
    ,min_total_credit_amount_utilization_30d
    ,avg_common_perm_credit_limit_utilization_30d
    ,avg_common_temp_credit_limit_utilization_30d
    ,avg_campaign_temp_credit_limit_utilization_30d
    ,avg_total_credit_amount_utilization_30d
    ,med_common_perm_credit_limit_utilization_30d
    ,med_common_temp_credit_limit_utilization_30d
    ,med_campaign_temp_credit_limit_utilization_30d
    ,med_total_credit_amount_utilization_30d
    ,max_common_perm_credit_limit_utilization_90d
    ,max_common_temp_credit_limit_utilization_90d
    ,max_campaign_temp_credit_limit_utilization_90d
    ,max_total_credit_amount_utilization_90d
    ,min_common_perm_credit_limit_utilization_90d
    ,min_common_temp_credit_limit_utilization_90d
    ,min_campaign_temp_credit_limit_utilization_90d
    ,min_total_credit_amount_utilization_90d
    ,avg_common_perm_credit_limit_utilization_90d
    ,avg_common_temp_credit_limit_utilization_90d
    ,avg_campaign_temp_credit_limit_utilization_90d
    ,avg_total_credit_amount_utilization_90d
    ,med_common_perm_credit_limit_utilization_90d
    ,med_common_temp_credit_limit_utilization_90d
    ,med_campaign_temp_credit_limit_utilization_90d
    ,med_total_credit_amount_utilization_90d
    ,max_common_perm_credit_limit_utilization_180d
    ,max_common_temp_credit_limit_utilization_180d
    ,max_campaign_temp_credit_limit_utilization_180d
    ,max_total_credit_amount_utilization_180d
    ,min_common_perm_credit_limit_utilization_180d
    ,min_common_temp_credit_limit_utilization_180d
    ,min_campaign_temp_credit_limit_utilization_180d
    ,min_total_credit_amount_utilization_180d
    ,avg_common_perm_credit_limit_utilization_180d
    ,avg_common_temp_credit_limit_utilization_180d
    ,avg_campaign_temp_credit_limit_utilization_180d
    ,avg_total_credit_amount_utilization_180d
    ,med_common_perm_credit_limit_utilization_180d
    ,med_common_temp_credit_limit_utilization_180d
    ,med_campaign_temp_credit_limit_utilization_180d
    ,med_total_credit_amount_utilization_180d
    ,max_common_perm_credit_limit_utilization_360d
    ,max_common_temp_credit_limit_utilization_360d
    ,max_campaign_temp_credit_limit_utilization_360d
    ,max_total_credit_amount_utilization_360d
    ,min_common_perm_credit_limit_utilization_360d
    ,min_common_temp_credit_limit_utilization_360d
    ,min_campaign_temp_credit_limit_utilization_360d
    ,min_total_credit_amount_utilization_360d
    ,avg_common_perm_credit_limit_utilization_360d
    ,avg_common_temp_credit_limit_utilization_360d
    ,avg_campaign_temp_credit_limit_utilization_360d
    ,avg_total_credit_amount_utilization_360d
    ,med_common_perm_credit_limit_utilization_360d
    ,med_common_temp_credit_limit_utilization_360d
    ,med_campaign_temp_credit_limit_utilization_360d
    ,med_total_credit_amount_utilization_360d
    ,activate_common_credit_limit
    ,activate_campaign_credit_limit
    ,activate_temp_credit_limit
    ,activate_interest_rate_1m
    ,activate_interest_rate_2m
    ,activate_interest_rate_3m
    ,activate_interest_rate_6m
    ,activate_interest_rate_9m
    ,activate_interest_rate_12m
    ,activate_interest_rate_18m
    ,activate_interest_rate_24m
    ,spl_share_rate
    ,repaid_bills_cnt
    ,grass_date
from ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df
;