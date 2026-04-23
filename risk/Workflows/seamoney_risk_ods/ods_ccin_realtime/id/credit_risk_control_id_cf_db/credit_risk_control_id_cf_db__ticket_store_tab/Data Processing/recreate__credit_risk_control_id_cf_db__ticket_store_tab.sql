

    alter table risk.ods__credit_risk_control_id_cf_db__ticket_store_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/ticket_store_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_cf_db__ticket_store_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_cf_db__ticket_store_tab;
create external table risk.ods__credit_risk_control_id_cf_db__ticket_store_tab
(
 id                                                                                                   bigint               comment ''
,ticket_id                                                                                            string               comment ''
,ticket_category                                                                                      bigint               comment ''
,ticket_subtype                                                                                       bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,store_id                                                                                             string               comment ''
,partner_id                                                                                           string               comment ''
,merchant_name                                                                                        string               comment ''
,store_name                                                                                           string               comment ''
,source_type                                                                                          string               comment ''
,merchant_type                                                                                        string               comment ''
,ops                                                                                                  string               comment ''
,assignee                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,result                                                                                               bigint               comment ''
,reject_reason                                                                                        string               comment ''
,ticket_info                                                                                          string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,return_codes                                                                                         string               comment ''
,adapter_id                                                                                           bigint               comment ''
,code_return_nums                                                                                     bigint               comment ''
,product_code                                                                                         string               comment ''
,notes                                                                                                string               comment ''
,priority                                                                                             bigint               comment ''
,assign_time                                                                                          bigint               comment ''
,ticket_info_encrypt                                                                                  string               comment ''
,order_field                                                                                          string               comment ''
,skip_operator_notes                                                                                  string               comment ''
,skip_time                                                                                            bigint               comment ''
,skip_reason                                                                                          string               comment ''
,skip_operator                                                                                        string               comment ''
,remark                                                                                               string               comment ''
,approve_reason                                                                                       string               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/ticket_store_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_cf_db__ticket_store_tab;
