--drop table if exists ${SCHEMA}.dws_risk_id_user_app_installation_df;
create external table if not exists ${SCHEMA}.dws_risk_id_user_app_installation_df
(
    platform_user_id string comment 'shopee platform user id'
    ,is_bpjs_installed tinyint comment 'whether install ID social security apps'
)
partitioned by
(
    grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_app_installation_df/grass_region=ID';
--msck repair table ${SCHEMA}.dws_risk_id_user_app_installation_df;

insert overwrite table ${SCHEMA}.dws_risk_id_user_app_installation_df partition (grass_date)
select  user_id as platform_user_id
        ,max(if(app_id = 'com.bpjstku', 1, 0)) as is_bpjs_installed
        ,'${grass_date}' as grass_date
from    ${SCHEMA}.dwd_datapoint_applist_zi
where   grass_region = '${region}'
  and   end_date = '9999-12-31'
group by user_id
;

