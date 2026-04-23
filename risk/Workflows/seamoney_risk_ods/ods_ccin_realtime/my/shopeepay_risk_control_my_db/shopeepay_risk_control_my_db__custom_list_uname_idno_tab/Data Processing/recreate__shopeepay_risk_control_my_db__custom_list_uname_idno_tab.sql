

    alter table risk.ods__shopeepay_risk_control_my_db__custom_list_uname_idno_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_uname_idno_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_my_db__custom_list_uname_idno_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_my_db__custom_list_uname_idno_tab;
create external table risk.ods__shopeepay_risk_control_my_db__custom_list_uname_idno_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,uname_idno                                                                                           string               comment ''
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
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_uname_idno_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_my_db__custom_list_uname_idno_tab;
