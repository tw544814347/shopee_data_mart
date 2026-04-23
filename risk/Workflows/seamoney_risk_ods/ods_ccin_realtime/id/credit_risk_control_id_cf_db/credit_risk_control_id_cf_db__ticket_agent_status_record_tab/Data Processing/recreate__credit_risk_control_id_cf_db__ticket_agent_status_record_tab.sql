

    alter table risk.ods__credit_risk_control_id_cf_db__ticket_agent_status_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/ticket_agent_status_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_cf_db__ticket_agent_status_record_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_cf_db__ticket_agent_status_record_tab;
create external table risk.ods__credit_risk_control_id_cf_db__ticket_agent_status_record_tab
(
 id                                                                                                   bigint               comment ''
,agent                                                                                                string               comment ''
,notes                                                                                                string               comment ''
,queue                                                                                                bigint               comment ''
,status                                                                                               bigint               comment ''
,end_time                                                                                             bigint               comment ''
,assigned_ticket_id                                                                                   string               comment ''
,last_assigned_time                                                                                   bigint               comment ''
,assessed_ticket_count                                                                                string               comment ''
,update_time                                                                                          bigint               comment ''
,create_time                                                                                          bigint               comment ''
,ticket_count                                                                                         bigint               comment ''
,source                                                                                               bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/ticket_agent_status_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_cf_db__ticket_agent_status_record_tab;
