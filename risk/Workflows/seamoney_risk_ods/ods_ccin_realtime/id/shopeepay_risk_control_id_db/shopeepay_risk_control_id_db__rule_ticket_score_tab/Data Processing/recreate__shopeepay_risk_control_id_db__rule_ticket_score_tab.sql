

    alter table risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/rule_ticket_score_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab;
create external table risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab
(
 id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,ticket_id                                                                                            string               comment ''
,product_code                                                                                         string               comment ''
,result                                                                                               bigint               comment ''
,request_time                                                                                         bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,credit_user_id                                                                                       bigint               comment ''
,ticket_category                                                                                      bigint               comment ''
,status                                                                                               bigint               comment ''
,scorer                                                                                               string               comment ''
,scorer_notes                                                                                         string               comment ''
,start_time                                                                                           bigint               comment ''
,end_time                                                                                             bigint               comment ''
,score_info                                                                                           string               comment ''
,decision                                                                                             bigint               comment ''
,remarks                                                                                              string               comment ''
,score                                                                                                bigint               comment ''
,score_config                                                                                         string               comment ''
,screen_type                                                                                          string               comment ''
,reject_code                                                                                          string               comment ''
,qa_ticket_id                                                                                         string               comment ''
,ticket_info                                                                                          string               comment ''
,ticket_info_encrypt                                                                                  string               comment ''
,category                                                                                             bigint               comment ''
,priority                                                                                             bigint               comment ''
,expiry_time                                                                                          bigint               comment ''
,create_date                                                                                          bigint               comment ''
,creator                                                                                              string               comment ''
,topic                                                                                                string               comment ''
,sub_topic                                                                                            string               comment ''
,modified_by                                                                                          string               comment ''
,modified_by_notes                                                                                    string               comment ''
,ticket_subtype                                                                                       bigint               comment ''
,case_id                                                                                              string               comment ''
,application_id                                                                                       string               comment ''
,shopeepay_user_id                                                                                    string               comment ''
,ic_type                                                                                              bigint               comment ''
,kyc_tag_list                                                                                         string               comment ''
,application_source                                                                                   bigint               comment ''
,archive_batch_no                                                                                     string               comment ''
,original_platform_type                                                                               bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/rule_ticket_score_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab;
