

    alter table risk.ods__credit_risk_control_my_db__ticket_tpl_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/ticket_tpl_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__ticket_tpl_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__ticket_tpl_tab;
create external table risk.ods__credit_risk_control_my_db__ticket_tpl_tab
(
 id                                                                                                   bigint               comment ''
,ticket_category                                                                                      bigint               comment ''
,ticket_subtype                                                                                       bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,region                                                                                               string               comment ''
,version                                                                                              bigint               comment ''
,ticket_info_tpl                                                                                      string               comment ''
,ticket_info_render                                                                                   string               comment ''
,ticket_other_info_tpl                                                                                string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,name                                                                                                 string               comment ''
,adapter_uuid                                                                                         string               comment ''
,complete_fields                                                                                      string               comment ''
,description                                                                                          string               comment ''
,ticket_other_info_tpl_new                                                                            string               comment ''
,ticket_info_tpl_new                                                                                  string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/ticket_tpl_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__ticket_tpl_tab;
