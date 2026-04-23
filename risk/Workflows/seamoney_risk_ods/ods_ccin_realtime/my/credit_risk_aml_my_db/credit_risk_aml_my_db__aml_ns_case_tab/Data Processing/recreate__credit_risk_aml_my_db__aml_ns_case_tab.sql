

    alter table risk.ods__credit_risk_aml_my_db__aml_ns_case_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_aml_xx_db/aml_ns_case_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_aml_my_db__aml_ns_case_tab__df;



    drop table if exists risk.ods__credit_risk_aml_my_db__aml_ns_case_tab;
create external table risk.ods__credit_risk_aml_my_db__aml_ns_case_tab
(
 id                                                                                                   bigint               comment ''
,case_uuid                                                                                            string               comment ''
,req_no                                                                                               string               comment ''
,category                                                                                             bigint               comment ''
,scene                                                                                                string               comment ''
,customer_name                                                                                        string               comment ''
,user_id                                                                                              string               comment ''
,kyc_info                                                                                             string               comment ''
,name_screening_info                                                                                  string               comment ''
,risk_rating                                                                                          bigint               comment ''
,last_risk_rating                                                                                     bigint               comment ''
,status                                                                                               bigint               comment ''
,result                                                                                               bigint               comment ''
,maker                                                                                                string               comment ''
,maker_notes                                                                                          string               comment ''
,checker                                                                                              string               comment ''
,checker_notes                                                                                        string               comment ''
,case_owner                                                                                           string               comment ''
,updater                                                                                              string               comment ''
,document                                                                                             string               comment ''
,reviews                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''
,ext_info                                                                                             string               comment ''
,product_type                                                                                         string               comment ''
,compliance_notes                                                                                     string               comment ''
,compliance                                                                                           string               comment ''
,name_list                                                                                            string               comment ''
,kyc_info_encrypt                                                                                     string               comment ''
,final_conclusions                                                                                    string               comment ''
,risk_rating_score_info                                                                               string               comment ''
,hit_reasons                                                                                          string               comment ''
,edd_result_info_encrypt                                                                              string               comment ''
,edd_status                                                                                           bigint               comment ''
,edd_result_info                                                                                      string               comment ''
,order_field                                                                                          string               comment ''
,priority                                                                                             bigint               comment ''
,version                                                                                              bigint               comment ''
,archive_batch_no                                                                                     string               comment ''
,original_platform_type                                                                               bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_aml_xx_db/aml_ns_case_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_aml_my_db__aml_ns_case_tab;
