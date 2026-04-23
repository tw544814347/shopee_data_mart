

    alter table risk.ods__credit_risk_archiveplatform_id_db__archive_sub_batch_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_archiveplatform_xx_db/archive_sub_batch_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_archiveplatform_id_db__archive_sub_batch_tab__df;



    drop table if exists risk.ods__credit_risk_archiveplatform_id_db__archive_sub_batch_tab;
create external table risk.ods__credit_risk_archiveplatform_id_db__archive_sub_batch_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,archive_rule_no                                                                                      decimal(20,0)        comment ''
,archive_batch_no                                                                                     string               comment ''
,archive_sub_batch_no                                                                                 decimal(20,0)        comment ''
,table_batch_index                                                                                    decimal(20,0)        comment ''
,db_host                                                                                              string               comment ''
,db_port                                                                                              bigint               comment ''
,real_db_name                                                                                         string               comment ''
,real_table_name                                                                                      string               comment ''
,pre_delete_id_list                                                                                   string               comment ''
,pre_delete_count                                                                                     decimal(20,0)        comment ''
,actual_delete_count                                                                                  decimal(20,0)        comment ''
,pre_delete_time                                                                                      string               comment ''
,actual_delete_time                                                                                   string               comment ''
,archive_status                                                                                       tinyint              comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
,is_primary                                                                                           bigint               comment ''
,primary_sub_batch_no                                                                                 decimal(20,0)        comment ''
,is_archive                                                                                           bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_archiveplatform_xx_db/archive_sub_batch_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_archiveplatform_id_db__archive_sub_batch_tab;
