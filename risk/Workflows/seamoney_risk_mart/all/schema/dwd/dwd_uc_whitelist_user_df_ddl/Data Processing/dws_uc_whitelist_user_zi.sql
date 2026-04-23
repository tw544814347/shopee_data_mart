drop table if exists ${SCHEMA}.dws_uc_whitelist_user_zi;
create external table if not exists ${SCHEMA}.dws_uc_whitelist_user_zi
(
    platform_user_id          string  comment 'platform_user_id'
    ,prod                     string  comment 'e.g: spl/bcl/scl/fes'
    ,status                   int     comment '-1:invalid 1:effective'
    ,start_date               string  comment 'status start_date'
    ,end_date                 string  comment 'status end_date'
)
comment 'uc_whitelist_zi'
partitioned by
(
    grass_region    string         comment         'partition key'
    ,app_id         int            comment         '1-spl,2-bcl,3-scl,4-fes,5-partnerLoan,6-spl_lite,7-mcl,8-cpl,9-chp'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_uc_whitelist_user_zi';
msck repair table ${SCHEMA}.dws_uc_whitelist_user_zi;

-- init 
insert overwrite table ${SCHEMA}.dws_uc_whitelist_user_zi partition (grass_region,app_id)
select 
platform_user_id
,prod
,status
,'2023-07-01' as start_date 
,'9999-12-31' as end_date 
,grass_region
,app_id 
from risk.dwd_uc_whitelist_user_df 
where grass_date ='2023-07-01'
;

