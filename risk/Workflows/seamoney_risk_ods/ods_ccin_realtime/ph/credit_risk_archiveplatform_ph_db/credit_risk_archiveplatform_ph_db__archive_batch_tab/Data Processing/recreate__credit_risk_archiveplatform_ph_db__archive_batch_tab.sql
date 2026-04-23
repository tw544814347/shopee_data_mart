

    alter table risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_archiveplatform_xx_db/archive_batch_tab__df/grass_region=PH/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab__df;



    drop table if exists risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab;
create external table risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,archive_batch_no                                                                                     string               comment ''
,archive_status                                                                                       tinyint              comment ''
,archive_rule_no                                                                                      decimal(20,0)        comment ''
,archive_rule_version                                                                                 bigint               comment ''
,pre_delete_total_count                                                                               decimal(20,0)        comment ''
,actual_delete_total_count                                                                            decimal(20,0)        comment ''
,pre_delete_time                                                                                      string               comment ''
,confirm_delete_time                                                                                  string               comment ''
,actual_delete_time                                                                                   string               comment ''
,biz_date                                                                                             string               comment ''
,remark                                                                                               string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
,logic_db_name                                                                                        string               comment ''
,logic_table_name_list                                                                                string               comment ''
,upload_succ_time                                                                                     string               comment ''
,is_cross_db                                                                                          bigint               comment ''
,is_field_archive                                                                                     bigint               comment ''
,logic_db_and_tab_info_cross_db                                                                       string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_archiveplatform_xx_db/archive_batch_tab__df/grass_region=PH/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab;
