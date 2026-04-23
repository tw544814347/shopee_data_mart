

    alter table risk.ods__credit_risk_control_id_cf_db__ticket_field_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/ticket_field_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_cf_db__ticket_field_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_cf_db__ticket_field_tab;
create external table risk.ods__credit_risk_control_id_cf_db__ticket_field_tab
(
 id                                                                                                   bigint               comment ''
,flow_no                                                                                              string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,ticket_fields                                                                                        string               comment ''
,ticket_status                                                                                        bigint               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,original_platform_type                                                                               bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/ticket_field_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_cf_db__ticket_field_tab;
