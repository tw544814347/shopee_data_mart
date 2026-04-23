
    
    alter table risk.ods__credit_risk_control_id_db__custom_list_apaccount_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/custom_list_apaccount_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__custom_list_apaccount_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_id_db__custom_list_apaccount_tab;

    create external table risk.ods__credit_risk_control_id_db__custom_list_apaccount_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,ap_account                                                                                           string               comment ''
,custom_list_id                                                                                       decimal(20,0)        comment ''
,data_source                                                                                          string               comment ''
,action_detail                                                                                        string               comment ''
,action_fail_detail                                                                                   string               comment ''
,action_status                                                                                        bigint               comment ''
,remark                                                                                               string               comment ''
,status                                                                                               bigint               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,expire_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/custom_list_apaccount_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_id_db__custom_list_apaccount_tab;

    