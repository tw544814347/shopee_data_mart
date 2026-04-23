

    alter table risk.ods__smeter_score_id_db__user_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__smeter_score_id_db__user_tab__df;



    drop table if exists risk.ods__smeter_score_id_db__user_tab;
create external table risk.ods__smeter_score_id_db__user_tab
(
 id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,credit_user_id                                                                                       string               comment ''
,status                                                                                               bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,active_time                                                                                          bigint               comment ''
,merge_batch                                                                                          string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__smeter_score_id_db__user_tab;
