

    alter table risk.ods__credit_risk_control_id_db__strategy_function_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_function_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__strategy_function_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__strategy_function_tab;
create external table risk.ods__credit_risk_control_id_db__strategy_function_tab
(
 id                                                                                                   bigint               comment ''
,ori_id                                                                                               bigint               comment ''
,function_name                                                                                        string               comment ''
,params                                                                                               string               comment ''
,function_script                                                                                      string               comment ''
,template                                                                                             string               comment ''
,interface                                                                                            string               comment ''
,function_type                                                                                        bigint               comment ''
,return_type                                                                                          bigint               comment ''
,extention                                                                                            string               comment ''
,version                                                                                              bigint               comment ''
,description                                                                                          string               comment ''
,status                                                                                               bigint               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,version_status                                                                                       bigint               comment ''
,data_src                                                                                             bigint               comment ''
,func_real_name                                                                                       string               comment ''
,func_template                                                                                        string               comment ''
,func_ext_template                                                                                    string               comment ''
,func_real_params                                                                                     string               comment ''
,fit_scope                                                                                            string               comment ''
,fit_scope_version                                                                                    string               comment ''
,rendering_template                                                                                   string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_function_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__strategy_function_tab;
