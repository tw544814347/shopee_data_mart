--drop table if exists ${SCHEMA}.ads_risk_id_spl_od_credit_feature_df;
create table if not exists ${SCHEMA}.ads_risk_id_spl_od_credit_feature_df (
    credit_user_id  string
    ,last_chp_disburse_time  string
    ,first_spl_disburse_time string
    ,is_bcl_disbursed    bigint
    ,repaid_bills_num_bcl    bigint
    ,repaid_bills_num_chp    bigint
    ,repaid_bills_num_spl    bigint
    ,is_spl_disbursed    bigint
    ,is_chp_disbursed    bigint
    ,latest_dpd_eod_spl  bigint
    ,latest_dpd_eod_cashloan bigint
    ,latest_dpd_eod_chp  bigint
    ,ever_max_dpd_180d_cashloan  bigint
    ,ever_max_dpd_180d_spl   bigint
    ,ever_max_dpd_30d_cashloan   bigint
    ,ever_max_dpd_30d_spl    bigint
    ,ever_max_dpd_30d_chp    bigint
    ,ever_max_dpd_180d_chp   bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_credit_feature_df/grass_region=ID'
;
--msck repair table ${SCHEMA}.ads_risk_id_spl_od_credit_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_id_spl_od_credit_feature_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.last_chp_disburse_time
    ,t2.first_spl_disburse_time
    ,coalesce(t2.is_bcl_disbursed, -9999) as is_bcl_disbursed
    ,coalesce(t2.repaid_bills_num_bcl, -9999) as repaid_bills_num_bcl
    ,coalesce(t2.repaid_bills_num_chp, -9999) as repaid_bills_num_chp
    ,coalesce(t2.repaid_bills_num_spl, -9999) as repaid_bills_num_spl
    ,coalesce(t2.is_spl_disbursed, -9999) as is_spl_disbursed
    ,coalesce(t2.is_chp_disbursed, -9999) as is_chp_disbursed
    ,coalesce(t3.latest_dpd_eod_spl, -9999) as latest_dpd_eod_spl
    ,coalesce(t3.latest_dpd_eod_cashloan, -9999) as latest_dpd_eod_cashloan
    ,coalesce(t3.latest_dpd_eod_chp, -9999) as latest_dpd_eod_chp
    ,coalesce(t3.ever_max_dpd_180d_cashloan, -9999) as ever_max_dpd_180d_cashloan
    ,coalesce(t3.ever_max_dpd_180d_spl, -9999) as ever_max_dpd_180d_spl
    ,coalesce(t3.ever_max_dpd_30d_cashloan, -9999) as ever_max_dpd_30d_cashloan
    ,coalesce(t3.ever_max_dpd_30d_spl, -9999) as ever_max_dpd_30d_spl
    ,coalesce(t3.ever_max_dpd_30d_chp, -9999) as ever_max_dpd_30d_chp
    ,coalesce(t3.ever_max_dpd_180d_chp, -9999) as ever_max_dpd_180d_chp
from
    (
        select
            credit_user_id
        from credit_uc.dwd_aio_id_uc_user_df
        where grass_date = '${grass_date}'
        and credit_user_id <> '0'
        group by credit_user_id
    ) t1
    left join (
        select
            credit_user_id
            ,last_chp_disburse_time
            ,first_spl_disburse_time
            ,is_bcl_disbursed
            ,repaid_bills_num_bcl
            ,repaid_bills_num_chp
            ,repaid_bills_num_spl
            ,is_spl_disbursed
            ,is_chp_disbursed
        from ${SCHEMA}.ads_behavior_underwrting_feature_df
        where grass_date = '${grass_date}'
    ) t2 on t1.credit_user_id = t2.credit_user_id
    left join (
        select
            user_id as credit_user_id
            ,latest_dpd_eod_spl
            ,latest_dpd_eod_cashloan
            ,latest_dpd_eod_chp
            ,ever_max_dpd_180d_cashloan
            ,ever_max_dpd_180d_spl
            ,ever_max_dpd_30d_cashloan
            ,ever_max_dpd_30d_spl
            ,ever_max_dpd_30d_chp
            ,ever_max_dpd_180d_chp
        from risk.dws_risk_id_user_dpd_df
        where grass_date = '${grass_date}'
    ) t3 on t1.credit_user_id = t3.credit_user_id
;
