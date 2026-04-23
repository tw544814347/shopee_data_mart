

    alter table risk.ods__credit_score_id_db__user_score_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/user_score_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_score_id_db__user_score_tab__df;



    drop table if exists risk.ods__credit_score_id_db__user_score_tab;
create external table risk.ods__credit_score_id_db__user_score_tab
(
 id                                                                                                   decimal(20,0)        comment '""'
,platform_user_id                                                                                     string               comment 'platform user id'
,platform_type                                                                                        bigint               comment 'platform type'
,score                                                                                                bigint               comment 'user current score'
,initial_score                                                                                        bigint               comment 'user initial score'
,bin_log_id                                                                                           string               comment 'user current score bin log'
,reserved1                                                                                            string               comment 'reserved field 1'
,create_time                                                                                          bigint               comment 'created time'
,update_time                                                                                          bigint               comment 'update time'
,version                                                                                              decimal(20,0)        comment 'data version'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/user_score_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_score_id_db__user_score_tab;
