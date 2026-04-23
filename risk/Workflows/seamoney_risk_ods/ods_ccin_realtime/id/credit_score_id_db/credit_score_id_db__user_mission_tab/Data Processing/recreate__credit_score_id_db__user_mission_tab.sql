

    alter table risk.ods__credit_score_id_db__user_mission_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/user_mission_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_score_id_db__user_mission_tab__df;



    drop table if exists risk.ods__credit_score_id_db__user_mission_tab;
create external table risk.ods__credit_score_id_db__user_mission_tab
(
 id                                                                                                   decimal(20,0)        comment '""'
,platform_user_id                                                                                     string               comment '""'
,platform_type                                                                                        bigint               comment '1 shopee'
,mission_start_score                                                                                  bigint               comment 'user score when start mission'
,get_score                                                                                            bigint               comment 'credit score earned upon completion'
,mission_id                                                                                           decimal(20,0)        comment 'mission id'
,mission_code                                                                                         string               comment 'mission code'
,mission_type                                                                                         bigint               comment 'mission type'
,complete_condition                                                                                   string               comment 'conditions for completing this mission'
,mission_total_count                                                                                  bigint               comment 'number of todo for this mission'
,completed_count                                                                                      bigint               comment 'number of completed for this mission'
,complete_status                                                                                      bigint               comment 'user do mission status 1:started 2:doing 3:done'
,start_time                                                                                           bigint               comment 'user mission start time（millisecond）'
,complete_time                                                                                        bigint               comment 'user mission complete time （millisecond）'
,create_time                                                                                          bigint               comment 'created time ms'
,update_time                                                                                          bigint               comment 'update time ms'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/user_mission_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_score_id_db__user_mission_tab;
