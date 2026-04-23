--drop table if exists ${SCHEMA}.dwd_dfp_request_ph_one_app_di;
create table if not exists ${SCHEMA}.dwd_dfp_request_ph_one_app_di (
    szdf string
    ,app_id string
    ,install_timestamp string
    ,app_list string
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/dwd_dfp_request_ph_one_app_di'
;
--msck repair table ${SCHEMA}.dwd_dfp_request_ph_one_app_di;

insert overwrite table ${SCHEMA}.dwd_dfp_request_ph_one_app_di partition (grass_date = '${grass_date}')
select
    szdf
    ,app_id
    ,install_timestamp
    ,app_list
from
(
select
    deviceid as szdf
    ,app_id
    ,install_timestamp
    ,app_list
    ,row_number() over (partition by deviceid order by install_timestamp desc) rn
from antifraud_dw.temp_dwd_dfp_request_ph_one_app_spark_view_rt
where
    grass_region = 'PH'
    and grass_date = '${grass_date}'
)
where rn = 1
;