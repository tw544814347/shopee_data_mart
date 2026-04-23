-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-20
-- Theme Domain:        User Txn Credit Feature汇总主题表
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chengguo.liu - 初始化
-- =============================================================================


drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df
(
    credit_user_id                                      string         comment 'shopee user id'
    ,average_limit_utilization_in_30d_spl               decimal(30,10) comment 'average_spl_limit_utilization_in_30d_spl'
    ,average_limit_utilization_in_90d_spl               decimal(30,10) comment 'average_spl_limit_utilization_in_90d_spl'
    ,average_limit_utilization_in_180d_spl              decimal(30,10) comment 'average_spl_limit_utilization_in_180d_spl'
    ,max_limit_utilization_in_30d_spl                   decimal(30,10) comment 'max_spl_limit_utilization_in_30d_spl'
    ,max_limit_utilization_in_90d_spl                   decimal(30,10) comment 'max_spl_limit_utilization_in_90d_spl'
    ,max_limit_utilization_in_180d_spl                  decimal(30,10) comment 'max_spl_limit_utilization_in_180d_spl'
    ,average_limit_utilization_in_30d_bcl               decimal(30,10) comment 'average_bcl_limit_utilization_in_30d_bcl'
    ,average_limit_utilization_in_90d_bcl               decimal(30,10) comment 'average_bcl_limit_utilization_in_90d_bcl'
    ,average_limit_utilization_in_180d_bcl              decimal(30,10) comment 'average_bcl_limit_utilization_in_180d_bcl'
    ,max_limit_utilization_in_30d_bcl                   decimal(30,10) comment 'max_bcl_limit_utilization_in_30d_bcl'
    ,max_limit_utilization_in_90d_bcl                   decimal(30,10) comment 'max_bcl_limit_utilization_in_90d_bcl'
    ,max_limit_utilization_in_180d_bcl                  decimal(30,10) comment 'max_bcl_limit_utilization_in_180d_bcl'
    ,average_limit_utilization_in_30d_chp               decimal(30,10) comment 'average_spl_extra_limit_utilization_in_30d_chp'
    ,average_limit_utilization_in_90d_chp               decimal(30,10) comment 'average_spl_extra_limit_utilization_in_90d_chp'
    ,average_limit_utilization_in_180d_chp              decimal(30,10) comment 'average_spl_extra_limit_utilization_in_180d_chp'
    ,max_limit_utilization_in_30d_chp                   decimal(30,10) comment 'max_spl_extra_limit_utilization_in_30d_chp'
    ,max_limit_utilization_in_90d_chp                   decimal(30,10) comment 'max_spl_extra_limit_utilization_in_90d_chp'
    ,max_limit_utilization_in_180d_chp                  decimal(30,10) comment 'max_spl_extra_limit_utilization_in_180d_chp'
    ,average_limit_utilization_in_30d_tl                decimal(30,10) comment 'average_limit_utilization_in_30d_tl'
    ,average_limit_utilization_in_90d_tl                decimal(30,10) comment 'average_limit_utilization_in_90d_tl'
    ,average_limit_utilization_in_180d_tl               decimal(30,10) comment 'average_limit_utilization_in_180d_tl'
    ,average_limit_utilization_in_360d_tl               decimal(30,10) comment 'average_limit_utilization_in_360d_tl'
    ,max_limit_utilization_in_30d_tl                    decimal(30,10) comment 'max_limit_utilization_in_30d_tl'
    ,max_limit_utilization_in_90d_tl                    decimal(30,10) comment 'max_limit_utilization_in_90d_tl'
    ,max_limit_utilization_in_180d_tl                   decimal(30,10) comment 'max_limit_utilization_in_180d_tl'
    ,max_limit_utilization_in_360d_tl                   decimal(30,10) comment 'max_limit_utilization_in_360d_tl'
    ,is_spl_disbursed                                   bigint         comment 'is_spl_disbursed'
    ,is_bcl_disbursed                                   bigint         comment 'is_bcl_disbursed'
    ,repaid_bills_num_spl                               bigint         comment 'repaid_bills_num_spl'
    ,repaid_bills_num_bcl                               bigint         comment 'repaid_bills_num_bcl'
    ,first_spl_disburse_time                            string         comment 'first_spl_disburse_time'
    ,preloan_reject_cnt_chp                             bigint         comment 'preloan_reject_cnt_chp'
    ,preloan_reject_cnt_90d_chp                         bigint         comment 'preloan_reject_cnt_90d_chp'
    ,preloan_reject_cnt_180d_chp                        bigint         comment 'preloan_reject_cnt_180d_chp'
    ,first_postloan_reject_date_chp                     string         comment 'first_postloan_reject_date_chp'
    ,dpd_freeze_date                                    string         comment 'dpd_freeze_date'
    ,dpd_freeze_datetime_ts                             bigint         comment 'dpd_freeze_datetime_ts'
    ,spl_uw_freeze_date                                 string         comment 'spl_uw_freeze_date'
    ,spl_uw_freeze_datetime_ts                          bigint         comment 'spl_uw_freeze_datetime_ts'
    ,bcl_uw_freeze_date                                 string         comment 'bcl_uw_freeze_date'
    ,bcl_uw_freeze_datetime_ts                          bigint         comment 'bcl_uw_freeze_datetime_ts'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_feature_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.average_limit_utilization_in_30d_spl
    ,t2.average_limit_utilization_in_90d_spl
    ,t2.average_limit_utilization_in_180d_spl
    ,t2.max_limit_utilization_in_30d_spl
    ,t2.max_limit_utilization_in_90d_spl
    ,t2.max_limit_utilization_in_180d_spl
    ,t2.average_limit_utilization_in_30d_bcl
    ,t2.average_limit_utilization_in_90d_bcl
    ,t2.average_limit_utilization_in_180d_bcl
    ,t2.max_limit_utilization_in_30d_bcl
    ,t2.max_limit_utilization_in_90d_bcl
    ,t2.max_limit_utilization_in_180d_bcl
    ,t2.average_limit_utilization_in_30d_chp
    ,t2.average_limit_utilization_in_90d_chp
    ,t2.average_limit_utilization_in_180d_chp
    ,t2.max_limit_utilization_in_30d_chp
    ,t2.max_limit_utilization_in_90d_chp
    ,t2.max_limit_utilization_in_180d_chp
    ,t2.average_limit_utilization_in_30d_tl
    ,t2.average_limit_utilization_in_90d_tl
    ,t2.average_limit_utilization_in_180d_tl
    ,t2.average_limit_utilization_in_360d_tl
    ,t2.max_limit_utilization_in_30d_tl
    ,t2.max_limit_utilization_in_90d_tl
    ,t2.max_limit_utilization_in_180d_tl
    ,t2.max_limit_utilization_in_360d_tl
    ,t3.is_spl_disbursed
    ,t3.is_bcl_disbursed
    ,t3.repaid_bills_num_spl
    ,t3.repaid_bills_num_bcl
    ,t3.first_spl_disburse_time
    ,t4.preloan_reject_cnt_chp
    ,t4.preloan_reject_cnt_90d_chp
    ,t4.preloan_reject_cnt_180d_chp
    ,t4.first_postloan_reject_date_chp
    ,t5.dpd_freeze_date
    ,t5.dpd_freeze_datetime_ts
    ,t5.spl_uw_freeze_date
    ,t5.spl_uw_freeze_datetime_ts
    ,t5.bcl_uw_freeze_date
    ,t5.bcl_uw_freeze_datetime_ts
from 
(
    select
        credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${grass_date}'
        and credit_user_id <> ''
    group by credit_user_id
) t1
left join
(
    select
        credit_user_id
        ,average_limit_utilization_in_30d_spl
        ,average_limit_utilization_in_90d_spl
        ,average_limit_utilization_in_180d_spl
        ,max_limit_utilization_in_30d_spl
        ,max_limit_utilization_in_90d_spl
        ,max_limit_utilization_in_180d_spl
        ,average_limit_utilization_in_30d_bcl
        ,average_limit_utilization_in_90d_bcl
        ,average_limit_utilization_in_180d_bcl
        ,max_limit_utilization_in_30d_bcl
        ,max_limit_utilization_in_90d_bcl
        ,max_limit_utilization_in_180d_bcl
        ,average_limit_utilization_in_30d_chp
        ,average_limit_utilization_in_90d_chp
        ,average_limit_utilization_in_180d_chp
        ,max_limit_utilization_in_30d_chp
        ,max_limit_utilization_in_90d_chp
        ,max_limit_utilization_in_180d_chp
        ,average_limit_utilization_in_30d_tl
        ,average_limit_utilization_in_90d_tl
        ,average_limit_utilization_in_180d_tl
        ,average_limit_utilization_in_360d_tl
        ,max_limit_utilization_in_30d_tl
        ,max_limit_utilization_in_90d_tl
        ,max_limit_utilization_in_180d_tl
        ,max_limit_utilization_in_360d_tl
    from ${SCHEMA}.dws_risk_${region}_user_txn_credit_limit_df
    where
        grass_date = '${grass_date}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join
(
    select
        credit_user_id
        ,is_spl_disbursed
        ,is_bcl_disbursed
        ,repaid_bills_num_spl
        ,repaid_bills_num_bcl
        ,first_spl_disburse_time
    from ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df
    where
        grass_date = '${grass_date}'
) t3
on t1.credit_user_id = t3.credit_user_id
left join
(
    select
        credit_user_id
        ,preloan_reject_cnt_chp
        ,preloan_reject_cnt_90d_chp
        ,preloan_reject_cnt_180d_chp
        ,first_postloan_reject_date_chp
    from ${SCHEMA}.dws_risk_${region}user_txn_credit_loan_repayment_df
    where
        grass_date = '${grass_date}'
) t4
on t1.credit_user_id = t4.credit_user_id
left join
(
    select
        credit_user_id
        ,dpd_freeze_date
        ,dpd_freeze_datetime_ts
        ,spl_uw_freeze_date
        ,spl_uw_freeze_datetime_ts
        ,bcl_uw_freeze_date
        ,bcl_uw_freeze_datetime_ts
    from ${SCHEMA}.dws_risk_${region}_user_txn_credit_freeze_df
    where
        grass_date = '${grass_date}'
) t5
on t1.credit_user_id = t5.credit_user_id
;