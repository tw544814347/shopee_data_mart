

    alter table risk.ods__credit_risk_control_id_ldn_db__ticket_score__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/ticket_score__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_ldn_db__ticket_score__df;



    drop table if exists risk.ods__credit_risk_control_id_ldn_db__ticket_score;
create external table risk.ods__credit_risk_control_id_ldn_db__ticket_score
(
 id                                                                                                   bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,ticket_id                                                                                            string               comment ''
,product_code                                                                                         string               comment ''
,result                                                                                               bigint               comment ''
,ticket_completed_time                                                                                bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,credit_user_id                                                                                       bigint               comment ''
,maker_checker_attr                                                                                   bigint               comment ''
,category                                                                                             bigint               comment ''
,status                                                                                               bigint               comment ''
,maker                                                                                                string               comment ''
,id_card_type                                                                                         bigint               comment ''
,maker_notes                                                                                          string               comment ''
,checker                                                                                              string               comment ''
,checker_notes                                                                                        string               comment ''
,scorer                                                                                               string               comment ''
,scorer_notes                                                                                         string               comment ''
,start_time                                                                                           bigint               comment ''
,end_time                                                                                             bigint               comment ''
,score_info                                                                                           string               comment ''
,score_config                                                                                         string               comment ''
,screen_type                                                                                          string               comment ''
,risk_result_type                                                                                     bigint               comment ''
,reject_reason                                                                                        string               comment ''
,source                                                                                               bigint               comment ''
,create_date                                                                                          bigint               comment ''
,creator                                                                                              string               comment ''
,ticket_category                                                                                      bigint               comment ''
,qa_ticket_id                                                                                         string               comment ''
,priority                                                                                             bigint               comment ''
,expiry_time                                                                                          bigint               comment ''
,sub_topic                                                                                            string               comment ''
,spp_info                                                                                             string               comment ''
,topic                                                                                                string               comment ''
,modified_by_notes                                                                                    string               comment ''
,modified_by                                                                                          string               comment ''
,order_field                                                                                          string               comment ''
,archive_batch_no                                                                                     string               comment ''
,original_platform_type                                                                               bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/ticket_score__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_ldn_db__ticket_score;
