

    alter table risk.ods__data_smd_genos_my_db__file_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/data_smd_genos_xx_db/file_record_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__data_smd_genos_my_db__file_record_tab__df;



    drop table if exists risk.ods__data_smd_genos_my_db__file_record_tab;
create external table risk.ods__data_smd_genos_my_db__file_record_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,ex_id                                                                                                string               comment ''
,request_id                                                                                           string               comment ''
,app_id                                                                                               string               comment ''
,file_type                                                                                            bigint               comment ''
,path                                                                                                 string               comment ''
,upload_path                                                                                          string               comment ''
,raw_output                                                                                           string               comment ''
,status                                                                                               bigint               comment ''
,msg                                                                                                  string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/data_smd_genos_xx_db/file_record_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__data_smd_genos_my_db__file_record_tab;
