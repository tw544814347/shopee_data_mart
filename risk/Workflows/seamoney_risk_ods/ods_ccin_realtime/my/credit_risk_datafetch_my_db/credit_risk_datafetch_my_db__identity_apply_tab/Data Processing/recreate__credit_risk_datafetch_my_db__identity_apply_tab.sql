

    alter table risk.ods__credit_risk_datafetch_my_db__identity_apply_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/identity_apply_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_datafetch_my_db__identity_apply_tab__df;



    drop table if exists risk.ods__credit_risk_datafetch_my_db__identity_apply_tab;
create external table risk.ods__credit_risk_datafetch_my_db__identity_apply_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,unique_key                                                                                           string               comment ''
,data_source_name                                                                                     string               comment ''
,req_header                                                                                           string               comment ''
,req                                                                                                  string               comment ''
,extra_info                                                                                           string               comment ''
,resp_code                                                                                            bigint               comment ''
,hit_cache                                                                                            bigint               comment ''
,trace_id                                                                                             string               comment ''
,app_key                                                                                              string               comment ''
,flow_no                                                                                              string               comment ''
,data_year_month                                                                                      string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
,req_encrypt                                                                                          string               comment ''
,archive_batch_no                                                                                     string               comment ''
 ,req_encrypt_data                                                                                     string               comment ''
,req_encrypt_md5                                                                                      string               comment ''
,req_encrypt_mask                                                                                     string               comment ''
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/identity_apply_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_datafetch_my_db__identity_apply_tab;
