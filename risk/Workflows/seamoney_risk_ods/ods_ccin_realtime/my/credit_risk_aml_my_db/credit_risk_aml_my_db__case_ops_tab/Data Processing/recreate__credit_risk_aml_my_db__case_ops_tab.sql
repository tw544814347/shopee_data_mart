

    alter table risk.ods__credit_risk_aml_my_db__case_ops_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_aml_xx_db/case_ops_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_aml_my_db__case_ops_tab__df;



    drop table if exists risk.ods__credit_risk_aml_my_db__case_ops_tab;
create external table risk.ods__credit_risk_aml_my_db__case_ops_tab
(
 id                                                                                                   bigint               comment ''
,case_uuid                                                                                            string               comment ''
,operator                                                                                             string               comment ''
,content                                                                                              string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''
,operation_type                                                                                       bigint               comment ''
,role                                                                                                 string               comment ''
,start_time                                                                                           bigint               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_aml_xx_db/case_ops_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_aml_my_db__case_ops_tab;
