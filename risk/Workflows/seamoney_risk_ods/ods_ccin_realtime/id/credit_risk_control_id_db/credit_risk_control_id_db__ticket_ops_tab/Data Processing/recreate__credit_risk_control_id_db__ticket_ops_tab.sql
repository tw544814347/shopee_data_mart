

    alter table risk.ods__credit_risk_control_id_db__ticket_ops_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/ticket_ops_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__ticket_ops_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__ticket_ops_tab;
create external table risk.ods__credit_risk_control_id_db__ticket_ops_tab
(
 id                                                                                                   bigint               comment ''
,ticket_id                                                                                            string               comment ''
,operator                                                                                             string               comment ''
,content                                                                                              string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''
,content_notes                                                                                        string               comment ''
,operation_type                                                                                       bigint               comment ''
,start_time                                                                                           bigint               comment ''
,role                                                                                                 string               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/ticket_ops_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__ticket_ops_tab;
