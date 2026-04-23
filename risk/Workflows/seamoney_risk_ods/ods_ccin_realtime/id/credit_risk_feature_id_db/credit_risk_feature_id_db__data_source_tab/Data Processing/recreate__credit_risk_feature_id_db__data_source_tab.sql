

    alter table risk.ods__credit_risk_feature_id_db__data_source_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/data_source_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_feature_id_db__data_source_tab__df;



    drop table if exists risk.ods__credit_risk_feature_id_db__data_source_tab;
create external table risk.ods__credit_risk_feature_id_db__data_source_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,data_source_name                                                                                     string               comment ''
,data_source_desc                                                                                     string               comment ''
,row_key_format                                                                                       string               comment ''
,column_key_format                                                                                    string               comment ''
,person_in_charge                                                                                     string               comment ''
,storage_location                                                                                     string               comment ''
,related_original_data                                                                                string               comment ''
,data_source_type                                                                                     bigint               comment ''
,expiration_time                                                                                      bigint               comment ''
,store_time                                                                                           bigint               comment ''
,offline_data_refresh_time                                                                            bigint               comment ''
,outer_person_in_charge                                                                               string               comment ''
,outer_interface                                                                                      string               comment ''
,outer_interface_protocol                                                                             string               comment ''
,data_structure                                                                                       bigint               comment ''
,create_time                                                                                          decimal(20,0)        comment ''
,update_time                                                                                          decimal(20,0)        comment ''
,usage_scene                                                                                          bigint               comment ''
,data_source_link                                                                                     string               comment ''
,region                                                                                               string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/data_source_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_feature_id_db__data_source_tab;
