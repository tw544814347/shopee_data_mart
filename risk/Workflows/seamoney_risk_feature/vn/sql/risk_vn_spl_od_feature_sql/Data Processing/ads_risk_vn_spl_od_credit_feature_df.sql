-- drop table if exists ${SCHEMA}.ads_risk_vn_spl_od_credit_feature_df;
create table if not exists ${SCHEMA}.ads_risk_vn_spl_od_credit_feature_df (
    credit_user_id string comment 'credit user_id'
    ,repaid_bills_num_spl bigint
    ,latest_dpd_eod_spl bigint
    ,latest_dpd_eod_bcl bigint
    ,ever_max_dpd_180d_bcl bigint
    ,ever_max_dpd_180d_spl bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_credit_feature_df/grass_region=VN'
;
-- msck repair table ${SCHEMA}.ads_risk_vn_spl_od_credit_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_vn_spl_od_credit_feature_df partition (grass_date = '${bizdate}')
select  t1.credit_user_id,
        t1.repaid_bills_num_spl,
        t1.latest_dpd_eod_spl,
        t1.latest_dpd_eod_bcl,
        t1.ever_max_dpd_180d_bcl,
        t1.ever_max_dpd_180d_spl
from
(
    select credit_user_id
            ,repaid_bills_num_spl
            ,latest_dpd_eod_spl
            ,latest_dpd_eod_cashloan as latest_dpd_eod_bcl
            ,ever_max_dpd_180d_cashloan as ever_max_dpd_180d_bcl
            ,ever_max_dpd_180d_spl
    from    risk_feature.dws_risk_vn_user_txn_credit_feature_df
    where   grass_date = '${ds}'
) t1
