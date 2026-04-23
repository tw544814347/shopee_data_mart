

    alter table risk.ods__smeter_score_id_db__user_limit_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_limit_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__smeter_score_id_db__user_limit_record_tab__df;



    drop table if exists risk.ods__smeter_score_id_db__user_limit_record_tab;
create external table risk.ods__smeter_score_id_db__user_limit_record_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,credit_user_id                                                                                       string               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,limit_type                                                                                           bigint               comment ''
,permanent_limit                                                                                      bigint               comment ''
,change_limit                                                                                         bigint               comment ''
,apply_time                                                                                           bigint               comment ''
,start_time                                                                                           bigint               comment ''
,end_time                                                                                             bigint               comment ''
,result_code                                                                                          bigint               comment ''
,result_msg                                                                                           string               comment ''
,expiry_time                                                                                          bigint               comment ''
,reserved1                                                                                            string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_limit_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__smeter_score_id_db__user_limit_record_tab;
