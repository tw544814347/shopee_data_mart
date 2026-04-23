insert overwrite directory 'hdfs://R2/projects/risk/hdfs/prod/export_data/2cscore/2cscore_user_dpd/ID/${dt}' using CSV
options
(
    header "true"
)
select  /*+ REPARTITION(20) */ shopee_userid
        ,product_type
        ,dpd
from    risk.ads_2cscore_id_user_dpd_df
where   grass_date = '${ds}'
  and   dpd > 0
;