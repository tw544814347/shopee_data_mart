--drop table if exists ${SCHEMA}.ads_risk_my_spl_od_credit_feature_df;
create table if not exists ${SCHEMA}.ads_risk_my_spl_od_credit_feature_df (
    credit_user_id string comment 'credit_user_id'
    ,is_spl_disbursed bigint
    ,repaid_bills_num_spl bigint
    ,first_spl_disburse_time string
    ,is_bcl_disbursed bigint
    ,repaid_bills_num_bcl_floating bigint
    ,latest_dpd_eod_spl bigint
    ,ever_max_dpd_30d_spl bigint
    ,ever_max_dpd_180d_spl bigint
    ,latest_dpd_eod_bcl bigint
    ,ever_max_dpd_30d_bcl bigint
    ,ever_max_dpd_180d_bcl bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_credit_feature_df/grass_region=MY'
;
--msck repair table ${SCHEMA}.ads_risk_my_spl_od_credit_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_my_spl_od_credit_feature_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
    ,t2.repaid_bills_num_spl
    ,t2.first_spl_disburse_time
    ,t2.is_bcl_disbursed
    ,t2.repaid_bills_num_bcl_floating
    ,t3.latest_dpd_eod_spl
    ,t3.ever_max_dpd_30d_spl
    ,t3.ever_max_dpd_180d_spl
    ,t3.latest_dpd_eod_bcl
    ,t3.ever_max_dpd_30d_bcl
    ,t3.ever_max_dpd_180d_bcl
from
(
    select
        credit_user_id
    from credit_uc.dws_aio_my_uc_user_df
    where grass_date = '${grass_date}'
    and credit_user_id is not null
    group by credit_user_id
    ) t1
    left join (
        select
            credit_user_id
            ,is_spl_disbursed
            ,repaid_bills_num_spl
            ,first_spl_disburse_time
            ,is_bcl_disbursed
            ,repaid_bills_num_bcl_floating
        from ${SCHEMA}.dws_risk_my_user_behavior_credit_info_df
        where grass_date = '${grass_date}'
    ) t2 on t1.credit_user_id = t2.credit_user_id
    left join (
        select
            credit_user_id
            ,latest_dpd_eod_spl
            ,latest_dpd_eod_bcl
            ,ever_max_dpd_180d_bcl
            ,ever_max_dpd_180d_spl
            ,ever_max_dpd_30d_cashloan as ever_max_dpd_30d_bcl
            ,ever_max_dpd_30d_spl
        from ${SCHEMA}.dws_risk_my_user_dpd_df
        where grass_date = '${grass_date}'  
    ) t3 on t1.credit_user_id = t3.credit_user_id
;