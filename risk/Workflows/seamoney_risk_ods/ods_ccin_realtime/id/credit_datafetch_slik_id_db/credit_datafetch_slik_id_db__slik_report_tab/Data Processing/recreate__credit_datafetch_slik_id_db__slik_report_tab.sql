

    alter table risk.ods__credit_datafetch_slik_id_db__slik_report_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_datafetch_slik_xx_db/slik_report_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_datafetch_slik_id_db__slik_report_tab__df;



    drop table if exists risk.ods__credit_datafetch_slik_id_db__slik_report_tab;
create external table risk.ods__credit_datafetch_slik_id_db__slik_report_tab
(
 report_id                                                                                            bigint               comment ''
,ktp                                                                                                  string               comment ''
,user_reference_code                                                                                  string               comment ''
,file_exist                                                                                           integer              comment ''
,file                                                                                                 string               comment ''
,result                                                                                               string               comment ''
,file_path                                                                                            string               comment ''
,decode_file_path                                                                                     string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
,flow_no                                                                                              string               comment ''
,app_key                                                                                              string               comment ''
,crawl_account                                                                                        string               comment ''
,approve_account                                                                                      string               comment ''
,crawl_time                                                                                           string               comment ''
,approve_time                                                                                         string               comment ''
,file_reference_code                                                                                  string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_datafetch_slik_xx_db/slik_report_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_datafetch_slik_id_db__slik_report_tab;
