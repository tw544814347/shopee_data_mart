----临时任务，配合业务LiveTesting，已下线
insert overwrite directory 'hdfs://R2/projects/risk/hdfs/prod/export_data/2cscore/2cscore_user_test_score_list/ID/${today_ds}' using CSV
options
(
    header "true"
)
select  /*+ REPARTITION(20) */ shopee_userid
        ,id_card_number
        ,score_list
from    risk.ads_2cscore_id_user_test_score_list_df
where   grass_date = '2024-11-18'
;
