insert overwrite directory 'hdfs://R2/projects/risk/hdfs/prod/export_data/2cscore/2cscore_user_mission_result/ID/${dt}' using CSV
options
(
    header "true"
)
select  /*+ REPARTITION(20) */ shopee_userid
        ,mission_id
        ,mission_type
        ,start_time
        ,mission_result
from    risk.ads_2cscore_id_user_mission_result_df
where   grass_date = '${ds}'
  and   mission_result > 0
;

