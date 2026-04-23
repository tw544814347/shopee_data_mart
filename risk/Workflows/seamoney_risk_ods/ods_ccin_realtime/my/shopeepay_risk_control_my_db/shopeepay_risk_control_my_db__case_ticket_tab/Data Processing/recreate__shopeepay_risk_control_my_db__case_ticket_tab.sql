

    alter table risk.ods__shopeepay_risk_control_my_db__case_ticket_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/case_ticket_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_my_db__case_ticket_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_my_db__case_ticket_tab;
create external table risk.ods__shopeepay_risk_control_my_db__case_ticket_tab
(
 id                                                                                                   bigint               comment ''
,ticket_id                                                                                            string               comment ''
,user_ids                                                                                             string               comment ''
,customer_issue                                                                                       string               comment ''
,channel                                                                                              string               comment ''
,status                                                                                               bigint               comment ''
,case_type                                                                                            bigint               comment ''
,channel_case_id                                                                                      string               comment ''
,investigate_record                                                                                   string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,creator                                                                                              string               comment ''
,result                                                                                               bigint               comment ''
,assignee                                                                                             string               comment ''
,category                                                                                             bigint               comment ''
,notes                                                                                                string               comment ''
,record_status                                                                                        bigint               comment ''
,treatment                                                                                            string               comment ''
,order_field                                                                                          string               comment ''
,priority                                                                                             bigint               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/case_ticket_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_my_db__case_ticket_tab;
