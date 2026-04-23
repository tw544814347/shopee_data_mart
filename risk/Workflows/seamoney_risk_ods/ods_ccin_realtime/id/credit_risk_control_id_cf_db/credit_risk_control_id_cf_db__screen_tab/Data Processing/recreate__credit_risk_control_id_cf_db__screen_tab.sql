

    alter table risk.ods__credit_risk_control_id_cf_db__screen_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/screen_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_cf_db__screen_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_cf_db__screen_tab;
create external table risk.ods__credit_risk_control_id_cf_db__screen_tab
(
 id                                                                                                   bigint               comment ''
,screen_id                                                                                            string               comment ''
,req_no                                                                                               string               comment ''
,product_code                                                                                         string               comment ''
,screen_type                                                                                          string               comment ''
,screen_source                                                                                        string               comment ''
,apply_type                                                                                           string               comment ''
,category                                                                                             bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,credit_user_id                                                                                       bigint               comment ''
,credit_corp_id                                                                                       bigint               comment ''
,user_name                                                                                            string               comment ''
,id_card_no                                                                                           string               comment ''
,id_card_type                                                                                         bigint               comment ''
,first_order_time                                                                                     bigint               comment ''
,screen_status                                                                                        bigint               comment ''
,task_result                                                                                          bigint               comment ''
,screen_result                                                                                        bigint               comment ''
,reject_code                                                                                          string               comment ''
,maker_result                                                                                         bigint               comment ''
,maker_submit_time                                                                                    bigint               comment ''
,maker                                                                                                string               comment ''
,maker_map_no                                                                                         string               comment ''
,checker_result                                                                                       bigint               comment ''
,checker_submit_time                                                                                  bigint               comment ''
,checker                                                                                              string               comment ''
,checker_map_no                                                                                       string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,screen_info                                                                                          string               comment ''
,screen_tpl_uuid                                                                                      string               comment ''
,is_skip                                                                                              bigint               comment ''
,maker_checker_attr                                                                                   bigint               comment ''
,skip_reason                                                                                          string               comment ''
,skip_operator                                                                                        string               comment ''
,skip_operator_map_no                                                                                 string               comment ''
,skip_time                                                                                            bigint               comment ''
,shop_id                                                                                              string               comment ''
,maker_start_time                                                                                     bigint               comment ''
,checker_start_time                                                                                   bigint               comment ''
,assignee                                                                                             string               comment ''
,notes                                                                                                string               comment ''
,risk_result_type                                                                                     bigint               comment ''
,from_source                                                                                          string               comment ''
,user_name_encrypt                                                                                    string               comment ''
,id_card_no_encrypt                                                                                   string               comment ''
,screen_info_encrypt                                                                                  string               comment ''
,order_field                                                                                          string               comment ''
,archive_batch_no                                                                                     string               comment ''
,priority                                                                                             bigint               comment ''
,original_platform_type                                                                               bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/screen_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_cf_db__screen_tab;
