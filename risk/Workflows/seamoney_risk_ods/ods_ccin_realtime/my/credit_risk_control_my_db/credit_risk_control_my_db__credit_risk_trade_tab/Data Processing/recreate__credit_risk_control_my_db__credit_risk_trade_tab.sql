

    alter table risk.ods__credit_risk_control_my_db__credit_risk_trade_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/credit_risk_trade_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__credit_risk_trade_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__credit_risk_trade_tab;
create external table risk.ods__credit_risk_control_my_db__credit_risk_trade_tab
(
 id                                                                                                   bigint               comment ''
,trade_id                                                                                             string               comment ''
,flow_no                                                                                              string               comment ''
,flow_type                                                                                            string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,req_ip                                                                                               string               comment ''
,server_ip                                                                                            string               comment ''
,code                                                                                                 bigint               comment ''
,msg                                                                                                  string               comment ''
,req                                                                                                  string               comment 'call http request json'
,rsp                                                                                                  string               comment 'call http response json'
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,version                                                                                              string               comment 'model version'
,score                                                                                                decimal(30,10)       comment 'model score'
,name                                                                                                 string               comment 'model name'
,speed                                                                                                bigint               comment 'Time consuming'
,local_ip                                                                                             string               comment 'local ip'
,relevance_id                                                                                         string               comment 'relevance id (SlikApplyId)'
,request_params                                                                                       string               comment 'client request param'
,process_step                                                                                         bigint               comment 'process step'
,exec_time                                                                                            string               comment 'execution time'
,node_id                                                                                              string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/credit_risk_trade_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__credit_risk_trade_tab;
