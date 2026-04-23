

    alter table risk.ods__shopeepay_risk_aml_my_db__aml_case_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_aml_xx_db/aml_case_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_aml_my_db__aml_case_tab__df;



    drop table if exists risk.ods__shopeepay_risk_aml_my_db__aml_case_tab;
create external table risk.ods__shopeepay_risk_aml_my_db__aml_case_tab
(
 id                                                                                                   bigint               comment ''
,case_uuid                                                                                            string               comment ''
,category                                                                                             bigint               comment ''
,customer_name                                                                                        string               comment ''
,user_id                                                                                              string               comment ''
,nums_of_alerts                                                                                       bigint               comment ''
,kyc_info                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,is_rework                                                                                            bigint               comment ''
,maker                                                                                                string               comment ''
,maker_notes                                                                                          string               comment ''
,checker                                                                                              string               comment ''
,checker_notes                                                                                        string               comment ''
,compliance                                                                                           string               comment ''
,compliance_notes                                                                                     string               comment ''
,case_owner                                                                                           string               comment ''
,updater                                                                                              string               comment ''
,document                                                                                             string               comment ''
,reviews                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''
,ext_info                                                                                             string               comment ''
,result                                                                                               bigint               comment ''
,last_risk_rating                                                                                     bigint               comment ''
,platform_type                                                                                        bigint               comment ''
,rule_hit                                                                                             string               comment ''
,version                                                                                              bigint               comment ''
,kyc_info_encrypt                                                                                     string               comment ''
,order_field                                                                                          string               comment ''
,priority                                                                                             bigint               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_aml_xx_db/aml_case_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_aml_my_db__aml_case_tab;
