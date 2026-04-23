

    alter table risk.ods__credit_score_id_db__user_limit_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/user_limit_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_score_id_db__user_limit_record_tab__df;



    drop table if exists risk.ods__credit_score_id_db__user_limit_record_tab;
create external table risk.ods__credit_score_id_db__user_limit_record_tab
(
 id                                                                                                   decimal(20,0)        comment '""'
,credit_user_id                                                                                       string               comment 'credit user id'
,platform_user_id                                                                                     string               comment 'platform user id'
,platform_type                                                                                        bigint               comment 'platform type'
,limit_type                                                                                           bigint               comment '1:2c temp limit,2:permanent limit'
,permanent_limit                                                                                      bigint               comment 'user current permanent credit limit'
,change_limit                                                                                         bigint               comment 'user change credit limit'
,apply_time                                                                                           bigint               comment 'limit apply time'
,start_time                                                                                           bigint               comment 'temp limit start time'
,end_time                                                                                             bigint               comment 'limit end time'
,result_code                                                                                          bigint               comment '1:success,6:Over limit,7:user frozen，9:system error'
,result_msg                                                                                           string               comment 'result message'
,expiry_time                                                                                          bigint               comment 'current expiry time'
,reserved1                                                                                            string               comment 'reserved field 1'
,create_time                                                                                          bigint               comment 'created time'
,update_time                                                                                          bigint               comment 'update time'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/user_limit_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_score_id_db__user_limit_record_tab;
