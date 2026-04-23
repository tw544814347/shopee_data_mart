--      update by chenyingying  2026-03-19 DFS迁移重构

--drop table if exists ${SCHEMA}.ads_risk_br_spl_od_credit_feature_df;
create external table if not exists ${SCHEMA}.ads_risk_br_spl_od_credit_feature_df (
    credit_user_id string
    ,is_bcl_disbursed bigint
    ,is_spl_disbursed bigint
    ,ever_max_dpd_90d_bcl bigint
    ,ever_max_dpd_180d_bcl bigint
    ,current_dpd_eod_bcl bigint
    ,latest_dpd_eod_bcl bigint
    ,repaid_bills_num_spl bigint
    ,latest_dpd_spl bigint
    ,current_dpd_spl bigint
    ,ever_max_dpd_90d_spl bigint
    ,ever_max_dpd_180d_spl bigint
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_credit_feature_df/grass_region=BR'
;

--msck repair table ${SCHEMA}.ads_risk_br_spl_od_credit_feature_df;
insert overwrite table ${SCHEMA}.ads_risk_br_spl_od_credit_feature_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.is_bcl_disbursed
    ,t2.is_spl_disbursed
    ,t2.ever_max_dpd_90d_bcl
    ,t2.ever_max_dpd_180d_bcl
    ,t2.current_dpd_eod_bcl
    ,t2.latest_dpd_eod_bcl
    ,t2.repaid_bills_num_spl
    ,t2.latest_dpd_spl
    ,t2.current_dpd_spl
    ,t2.ever_max_dpd_90d_spl
    ,t2.ever_max_dpd_180d_spl
from    (
    select  credit_user_id
    from credit_uc.dws_aio_br_uc_user_df
    where grass_date = '${grass_date}'
    and coalesce(credit_user_id,'') <> ''
    and credit_user_id <> '0'
    group by credit_user_id
) t1
left join (
    select  credit_user_id
            ,is_bcl_disbursed
            ,is_spl_disbursed
            ,ever_max_dpd_90d_cashloan  as ever_max_dpd_90d_bcl
            ,ever_max_dpd_180d_cashloan  as ever_max_dpd_180d_bcl
            ,current_dpd_eod_bcl
            ,current_dpd_spl
            ,ever_max_dpd_90d_spl
            ,ever_max_dpd_180d_spl
            ,repaid_bills_num_spl
            ,latest_dpd_eod_cashloan as latest_dpd_eod_bcl
            ,latest_dpd_spl
    from    risk_feature.dws_risk_br_user_txn_credit_feature_df
    where   grass_date = '${ds}'
) t2 
on t1.credit_user_id = t2.credit_user_id
;