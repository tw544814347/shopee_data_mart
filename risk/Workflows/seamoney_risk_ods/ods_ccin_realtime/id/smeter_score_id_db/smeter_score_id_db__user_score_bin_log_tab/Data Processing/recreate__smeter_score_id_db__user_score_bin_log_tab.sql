

    alter table risk.ods__smeter_score_id_db__user_score_bin_log_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_score_bin_log_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__smeter_score_id_db__user_score_bin_log_tab__df;



    drop table if exists risk.ods__smeter_score_id_db__user_score_bin_log_tab;
create external table risk.ods__smeter_score_id_db__user_score_bin_log_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,bin_log_id                                                                                           string               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,bin_time                                                                                             bigint               comment ''
,current_score                                                                                        bigint               comment ''
,change_score                                                                                         bigint               comment ''
,result_score                                                                                         bigint               comment ''
,cause_type                                                                                           bigint               comment ''
,cause                                                                                                bigint               comment ''
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,reserved1                                                                                            string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,has_seen                                                                                             bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_score_bin_log_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__smeter_score_id_db__user_score_bin_log_tab;
