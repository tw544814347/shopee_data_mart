

    alter table risk.ods__shopeepay_risk_control_id_db__return_code_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/return_code_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__return_code_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_id_db__return_code_tab;
create external table risk.ods__shopeepay_risk_control_id_db__return_code_tab
(
 id                                                                                                   bigint               comment ''
,code_type                                                                                            bigint               comment ''
,code_category                                                                                        bigint               comment ''
,code_sub_category                                                                                    string               comment ''
,code_name                                                                                            string               comment ''
,description                                                                                          string               comment ''
,code_status                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/return_code_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_id_db__return_code_tab;
