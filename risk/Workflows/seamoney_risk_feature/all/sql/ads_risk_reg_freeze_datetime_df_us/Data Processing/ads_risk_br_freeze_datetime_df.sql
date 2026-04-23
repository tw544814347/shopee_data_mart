drop table if exists risk.ads_risk_${region}_freeze_datetime_df
;

create table risk.ads_risk_${region}_freeze_datetime_df (
    user_id string
    
    ,dpd_freeze_date string 
    ,dpd_freeze_datetime_ts bigint 

    ,spl_uw_freeze_date string 
    ,spl_uw_freeze_datetime_ts bigint 

    ,bcl_uw_freeze_date string 
    ,bcl_uw_freeze_datetime_ts bigint 
)
partitioned by
    (grass_date string) stored as orc 
tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${region}_freeze_datetime_df'
;

msck repair table risk.ads_risk_${region}_freeze_datetime_df
;



INSERT OVERWRITE TABLE risk.ads_risk_${region}_freeze_datetime_df PARTITION (grass_date = '${ds}')
select  credit_user_id
        ,dpd_freeze_date
        ,dpd_freeze_datetime_ts
        ,spl_uw_freeze_date
        ,spl_uw_freeze_datetime_ts
        ,bcl_uw_freeze_date
        ,bcl_uw_freeze_datetime_ts
from    risk_feature.dws_risk_br_user_info_credit_feature_df
where   grass_date = '${ds}'
