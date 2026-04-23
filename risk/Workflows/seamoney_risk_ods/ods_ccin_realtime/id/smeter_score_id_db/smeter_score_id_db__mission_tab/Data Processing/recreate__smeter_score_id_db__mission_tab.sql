

    alter table risk.ods__smeter_score_id_db__mission_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/mission_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__smeter_score_id_db__mission_tab__df;



    drop table if exists risk.ods__smeter_score_id_db__mission_tab;
create external table risk.ods__smeter_score_id_db__mission_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,mission_id                                                                                           decimal(20,0)        comment ''
,template_id                                                                                          decimal(20,0)        comment ''
,mission_name                                                                                         string               comment ''
,mission_code                                                                                         string               comment ''
,mission_type                                                                                         bigint               comment ''
,mission_status                                                                                       bigint               comment ''
,uniqueness                                                                                           bigint               comment ''
,will_get_score                                                                                       bigint               comment ''
,visible_condition                                                                                    string               comment ''
,complete_condition                                                                                   string               comment ''
,ops                                                                                                  string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,display_rule_id                                                                                      bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/mission_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__smeter_score_id_db__mission_tab;
