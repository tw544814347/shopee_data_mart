

    alter table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/spp_ticket_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab__df;



    alter table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab__df add if not exists partition(grass_date='${ods_date_t0}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/spp_ticket_tab__df/grass_region=ID/grass_date=${ods_date_t0}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab;
create external table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab
(
 id                                                                                                   bigint               comment ''
,ticket_id                                                                                            string               comment ''
,ticket_category                                                                                      bigint               comment ''
,ticket_subtype                                                                                       bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,shopeepay_user_id                                                                                    string               comment ''
,case_id                                                                                              string               comment ''
,application_source                                                                                   bigint               comment ''
,assignee                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,result                                                                                               bigint               comment ''
,reject_reason                                                                                        string               comment ''
,ticket_info                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,kyc_tag_list                                                                                         string               comment ''
,ic_type                                                                                              bigint               comment ''
,id_card_no                                                                                           string               comment ''
,user_name                                                                                            string               comment ''
,notes                                                                                                string               comment ''
,application_id                                                                                       string               comment ''
,kyc_level                                                                                            bigint               comment ''
,user_name_encrypt                                                                                    string               comment ''
,ticket_info_encrypt                                                                                  string               comment ''
,id_card_no_encrypt                                                                                   string               comment ''
,skip_operator_notes                                                                                  string               comment ''
,skip_time                                                                                            bigint               comment ''
,skip_reason                                                                                          string               comment ''
,skip_operator                                                                                        string               comment ''
,archive_batch_no                                                                                     string               comment ''
,order_field                                                                                          string               comment ''
,priority                                                                                             bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/spp_ticket_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab;
