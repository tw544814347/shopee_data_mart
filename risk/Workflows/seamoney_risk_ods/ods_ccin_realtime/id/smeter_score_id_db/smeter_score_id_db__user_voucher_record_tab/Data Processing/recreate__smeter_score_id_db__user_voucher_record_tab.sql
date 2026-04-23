

    alter table risk.ods__smeter_score_id_db__user_voucher_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_voucher_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__smeter_score_id_db__user_voucher_record_tab__df;



    drop table if exists risk.ods__smeter_score_id_db__user_voucher_record_tab;
create external table risk.ods__smeter_score_id_db__user_voucher_record_tab
(
 id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,voucher_id                                                                                           bigint               comment ''
,promotion_id                                                                                         string               comment ''
,claim_start_time                                                                                     bigint               comment ''
,claim_success_time                                                                                   bigint               comment ''
,claim_failed_time                                                                                    bigint               comment ''
,claim_failed_reason                                                                                  string               comment ''
,claim_status                                                                                         bigint               comment ''
,dispatch_status                                                                                      bigint               comment ''
,ops                                                                                                  string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/smeter_score_xx_db/user_voucher_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__smeter_score_id_db__user_voucher_record_tab;
