

    alter table risk.ods__credit_score_id_db__mission_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/mission_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_score_id_db__mission_tab__df;



    drop table if exists risk.ods__credit_score_id_db__mission_tab;
create external table risk.ods__credit_score_id_db__mission_tab
(
 id                                                                                                   decimal(20,0)        comment '""'
,mission_id                                                                                           decimal(20,0)        comment 'mission id'
,template_id                                                                                          decimal(20,0)        comment 'mission template id'
,mission_name                                                                                         string               comment 'mission name'
,mission_code                                                                                         string               comment 'mission code'
,mission_type                                                                                         bigint               comment 'mission type'
,mission_status                                                                                       bigint               comment 'mission status -1:invalid,1:valid,2:locked'
,uniqueness                                                                                           bigint               comment '1:yes,-1 no'
,will_get_score                                                                                       bigint               comment 'credit score that will be earned after completion'
,visible_condition                                                                                    string               comment 'conditions for seeing this mission'
,complete_condition                                                                                   string               comment 'conditions for completing this mission'
,ops                                                                                                  string               comment 'operator email'
,create_time                                                                                          bigint               comment 'created time ms'
,update_time                                                                                          bigint               comment 'update time ms'
,display_rule_id                                                                                      bigint               comment 'rules of the mission'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/mission_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_score_id_db__mission_tab;
