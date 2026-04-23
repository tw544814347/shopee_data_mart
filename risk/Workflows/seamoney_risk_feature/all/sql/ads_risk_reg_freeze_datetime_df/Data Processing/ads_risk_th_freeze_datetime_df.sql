--      update by chenyingying  2026-03-19 DFS迁移重构


-- drop table if exists risk.ads_risk_${region}_freeze_datetime_df
-- ;

create table if not exists risk.ads_risk_${region}_freeze_datetime_df (
    user_id string
    
    ,dpd_freeze_date string 
    ,dpd_freeze_datetime_ts bigint 

    ,spl_uw_freeze_date string 
    ,spl_uw_freeze_datetime_ts bigint 

    ,bcl_uw_freeze_date string 
    ,bcl_uw_freeze_datetime_ts bigint 

    ,chp_uw_freeze_date string 
    ,chp_uw_freeze_datetime_ts bigint 

    -- ,tl_uw_freeze_date string 
    -- ,tl_uw_freeze_datetime_ts bigint 
)
partitioned by
    (grass_date string) stored as orc 
tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${region}_freeze_datetime_df'
;

-- msck repair table risk.ads_risk_${region}_freeze_datetime_df
-- ;




INSERT OVERWRITE TABLE risk.ads_risk_${region}_freeze_datetime_df PARTITION (grass_date = '${ds}')
select  t1.credit_user_id
        ,t2.dpd_freeze_date          
        ,t2.dpd_freeze_datetime_ts   
        ,t2.spl_uw_freeze_date       
        ,t2.spl_uw_freeze_datetime_ts
        ,t2.bcl_uw_freeze_date       
        ,t2.bcl_uw_freeze_datetime_ts
        ,t2.chp_uw_freeze_date       
        ,t2.chp_uw_freeze_datetime_ts
from    (
    select credit_user_id
    from    credit_uc.dws_all_prod_th_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    and     credit_user_id <> ''
    group by credit_user_id 
) t1
left join (
    select  credit_user_id
            ,dpd_freeze_date          
            ,dpd_freeze_datetime_ts   
            ,spl_uw_freeze_date       
            ,spl_uw_freeze_datetime_ts
            ,bcl_uw_freeze_date       
            ,bcl_uw_freeze_datetime_ts
            ,chp_uw_freeze_date       
            ,chp_uw_freeze_datetime_ts
    from    risk_feature.dws_risk_th_user_info_credit_feature_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id