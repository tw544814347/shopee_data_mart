
    
    alter table risk.ods__credit_risk_control_my_db__policy_user_group_member_history_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_user_group_member_history_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__policy_user_group_member_history_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_my_db__policy_user_group_member_history_tab;

    create external table risk.ods__credit_risk_control_my_db__policy_user_group_member_history_tab
    (
     hid                                                                                                  bigint               comment ''
,id                                                                                                   bigint               comment ''
,group_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,description                                                                                          string               comment ''
,status                                                                                               bigint               comment '-1 invalid, 1 valid'
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_user_group_member_history_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_my_db__policy_user_group_member_history_tab;

    