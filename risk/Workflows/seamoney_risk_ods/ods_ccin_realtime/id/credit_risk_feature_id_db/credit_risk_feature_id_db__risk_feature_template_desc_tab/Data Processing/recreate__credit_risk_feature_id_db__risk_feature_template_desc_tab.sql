

    alter table risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_desc_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab__df;



    drop table if exists risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab;
create external table risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,template_name                                                                                        string               comment ''
,placeholder_params                                                                                   string               comment ''
,datasource                                                                                           string               comment ''
,datasource_placeholder_params                                                                        string               comment ''
,result                                                                                               string               comment ''
,remark                                                                                               string               comment ''
,dependency                                                                                           string               comment ''
,desc_version                                                                                         string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,template_desc                                                                                        string               comment ''
,region                                                                                               string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_desc_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab;
