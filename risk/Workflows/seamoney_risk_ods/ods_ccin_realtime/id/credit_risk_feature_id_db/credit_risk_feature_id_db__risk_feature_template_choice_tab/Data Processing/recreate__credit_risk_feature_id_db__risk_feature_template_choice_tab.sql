

    alter table risk.ods__credit_risk_feature_id_db__risk_feature_template_choice_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_choice_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_feature_id_db__risk_feature_template_choice_tab__df;



    drop table if exists risk.ods__credit_risk_feature_id_db__risk_feature_template_choice_tab;
create external table risk.ods__credit_risk_feature_id_db__risk_feature_template_choice_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,template_id                                                                                          decimal(20,0)        comment ''
,placeholder                                                                                          string               comment ''
,placeholder_choice_name                                                                              string               comment ''
,placeholder_choice                                                                                   string               comment ''
,placeholder_choice_type                                                                              bigint               comment ''
,category                                                                                             bigint               comment ''
,chosen_condition                                                                                     string               comment ''
,exclusive                                                                                            bigint               comment ''
,creator                                                                                              string               comment ''
,updater                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,placeholder_type                                                                                     bigint               comment ''
,choice_status                                                                                        bigint               comment ''
,choice_desc                                                                                          string               comment ''
,fit_scope                                                                                            string               comment ''
,region                                                                                               string               comment ''
,render_prop                                                                                          string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_choice_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_feature_id_db__risk_feature_template_choice_tab;
