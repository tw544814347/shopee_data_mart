--drop table if exists ${SCHEMA}.ads_risk_ph_spl_od_credit_feature_df;
create table if not exists ${SCHEMA}.ads_risk_ph_spl_od_credit_feature_df (
    credit_user_id string comment 'platform_user_id'
    ,is_spl_disbursed bigint
    ,is_chp_disbursed bigint
    ,is_spl_billed bigint
    ,first_spl_disburse_time string
    ,is_bcl_disbursed bigint
    ,repaid_bills_num_spl bigint
    ,repaid_bills_num_bcl_floating bigint
    ,repaid_bills_num_chp bigint
    ,ever_max_dpd_chp bigint
    ,latest_dpd_eod_chp bigint
    ,ever_max_dpd_spl bigint
    ,current_dpd_spl bigint
    ,latest_dpd_eod_spl bigint
    ,ever_max_dpd_bcl bigint
    ,latest_dpd_eod_bcl bigint
    ,current_dpd_eod_bcl bigint
    ,current_dpd_eod_chp bigint
    ,ever_max_dpd_180d_user bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_credit_feature_df/grass_region=PH'
;
--msck repair table ${SCHEMA}.ads_risk_ph_spl_od_credit_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_ph_spl_od_credit_feature_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
    ,t2.is_chp_disbursed
    ,t2.is_spl_billed
    ,t2.first_spl_disburse_time
    ,t2.is_bcl_disbursed
    ,t2.repaid_bills_num_spl
    ,t2.repaid_bills_num_bcl_floating
    ,t2.repaid_bills_num_chp
    ,t3.ever_max_dpd_chp
    ,t3.latest_dpd_eod_chp
    ,t3.ever_max_dpd_spl
    ,t3.current_dpd_spl
    ,t3.latest_dpd_eod_spl
    ,t3.ever_max_dpd_bcl
    ,t3.latest_dpd_eod_bcl
    ,t3.current_dpd_eod_bcl
    ,t3.current_dpd_eod_chp
    ,t3.ever_max_dpd_180d_user
from
(
    select
        credit_user_id
    from credit_uc.dws_aio_ph_uc_user_df
    where grass_date = '${grass_date}'
    and credit_user_id is not null
    group by credit_user_id
) t1
left join
(
    select
        credit_user_id
        ,is_spl_disbursed
        ,is_chp_disbursed
        ,is_spl_billed
        ,first_spl_disburse_time
        ,is_bcl_disbursed
        ,repaid_bills_num_spl
        ,repaid_bills_num_bcl_floating
        ,repaid_bills_num_chp
    from ${SCHEMA}.dws_risk_ph_user_behavior_credit_info_df
    where grass_date = '${grass_date}'
) t2 on t1.credit_user_id = t2.credit_user_id
left join
(
    select distinct 
        user_id as credit_user_id
        ,ever_max_dpd_chp
        ,latest_dpd_eod_chp
        ,ever_max_dpd_spl_core as ever_max_dpd_spl
        ,current_dpd_spl
        ,latest_dpd_eod_spl
        ,ever_max_dpd_cashloan_core as ever_max_dpd_bcl
        ,latest_dpd_eod_bcl
        ,current_dpd_eod_bcl
        ,current_dpd_eod_chp
        ,ever_max_dpd_180d_user
    from risk.dws_risk_ph_user_dpd_df
    where grass_date = '${grass_date}'
) t3 on t1.credit_user_id = t3.credit_user_id
;