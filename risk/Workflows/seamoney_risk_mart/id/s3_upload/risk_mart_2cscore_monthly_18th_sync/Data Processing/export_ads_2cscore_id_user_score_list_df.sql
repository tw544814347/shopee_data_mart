insert overwrite directory 'hdfs://R2/projects/risk/hdfs/prod/export_data/2cscore/2cscore_user_score_list/ID/${month_ds}' using CSV
options
(
    header "true"
)
select  /*+ REPARTITION(20) */ shopee_userid
        ,id_card_number
        ,score_list
from    risk.ads_2cscore_id_user_score_list_df
where   grass_date = '${yesterday_ds}'
;
