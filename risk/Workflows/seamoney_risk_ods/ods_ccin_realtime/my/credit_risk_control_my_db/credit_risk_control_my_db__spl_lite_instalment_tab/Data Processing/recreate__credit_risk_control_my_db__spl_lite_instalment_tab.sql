
    
    alter table risk.ods__credit_risk_control_my_db__spl_lite_instalment_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/spl_lite_instalment_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__spl_lite_instalment_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_my_db__spl_lite_instalment_tab;

    create external table risk.ods__credit_risk_control_my_db__spl_lite_instalment_tab
    (
     id                                                                                                   bigint               comment ''
,platform_type                                                                                        bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,term                                                                                                 bigint               comment ''
,interest_rate                                                                                        bigint               comment ''
,checkout_cap                                                                                         bigint               comment ''
,status                                                                                               bigint               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
,notes                                                                                                string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/spl_lite_instalment_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_my_db__spl_lite_instalment_tab;

    