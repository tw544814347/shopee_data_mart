--      update by chenyingying  2026-03-19 DFS迁移重构


--drop table if exists ${SCHEMA}.ads_risk_th_spl_od_credit_feature_df;
create table if not exists ${SCHEMA}.ads_risk_th_spl_od_credit_feature_df (
    credit_user_id string comment 'platform_user_id'
    ,is_spl_disbursed bigint
    ,is_bcl_disbursed bigint
    ,repaid_bills_num_spl bigint
    ,repaid_bills_num_bcl bigint
    ,first_spl_disburse_time string
    ,days_after_first_due_date_spl_floating bigint
    ,latest_dpd_eod_spl bigint
    ,latest_dpd_eod_bcl bigint
    ,ever_max_dpd_180d_bcl bigint
    ,ever_max_dpd_180d_spl bigint
    ,ever_max_dpd_30d_bcl bigint
    ,ever_max_dpd_30d_spl bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_credit_feature_df/grass_region=TH'
;
--msck repair table ${SCHEMA}.ads_risk_th_spl_od_credit_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_th_spl_od_credit_feature_df partition (grass_date = '${grass_date}')
select  t1.credit_user_id
        ,t2.is_spl_disbursed                      
        ,t2.is_bcl_disbursed                      
        ,t2.repaid_bills_num_spl                  
        ,t2.repaid_bills_num_bcl                  
        ,t2.first_spl_disburse_time               
        ,t2.days_after_first_due_date_spl_floating
        ,t2.latest_dpd_eod_spl                    
        ,t2.latest_dpd_eod_bcl                    
        ,t2.ever_max_dpd_180d_bcl                 
        ,t2.ever_max_dpd_180d_spl                 
        ,t2.ever_max_dpd_30d_bcl                  
        ,t2.ever_max_dpd_30d_spl                  
from    (
    select  credit_user_id
    from    credit_uc.dws_all_prod_${region}_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    group by 1
) t1
left join (
    select  credit_user_id
            ,is_spl_disbursed                      
            ,is_bcl_disbursed                      
            ,repaid_bills_num_spl                  
            ,repaid_bills_num_bcl                  
            ,first_spl_disburse_time               
            ,days_after_first_due_date_spl_floating
            ,latest_dpd_eod_spl                    
            ,latest_dpd_eod_cashloan as latest_dpd_eod_bcl                    
            ,ever_max_dpd_180d_cashloan as ever_max_dpd_180d_bcl                 
            ,ever_max_dpd_180d_spl                 
            ,ever_max_dpd_30d_cashloan as ever_max_dpd_30d_bcl                  
            ,ever_max_dpd_30d_spl                  
    from    risk_feature.dws_risk_${region}_user_txn_credit_feature_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id