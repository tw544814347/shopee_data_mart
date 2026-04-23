

    alter table risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_datafetch_slik_xx_db/slik_report_apply_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab__df;



    drop table if exists risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab;
create external table risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab
(
 apply_id                                                                                             bigint               comment ''
,ktp                                                                                                  string               comment ''
,shopee_id                                                                                            bigint               comment ''
,credit_user_id                                                                                       bigint               comment ''
,product_code                                                                                         string               comment ''
,apply_status                                                                                         bigint               comment ''
,is_use_cache                                                                                         bigint               comment ''
,apply_time                                                                                           string               comment ''
,apply_finish_time                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_datafetch_slik_xx_db/slik_report_apply_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab;
