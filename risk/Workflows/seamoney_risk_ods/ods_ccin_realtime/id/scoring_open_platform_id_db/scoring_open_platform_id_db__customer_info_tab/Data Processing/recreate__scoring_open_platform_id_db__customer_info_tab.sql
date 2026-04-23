

    alter table risk.ods__scoring_open_platform_id_db__customer_info_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/scoring_open_platform_xx_db/customer_info_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__scoring_open_platform_id_db__customer_info_tab__df;



    drop table if exists risk.ods__scoring_open_platform_id_db__customer_info_tab;
create external table risk.ods__scoring_open_platform_id_db__customer_info_tab
(
 id                                                                                                   bigint               comment ''
,customer_id                                                                                          string               comment ''
,company_name                                                                                         string               comment ''
,tax_no                                                                                               string               comment ''
,business_email                                                                                       string               comment ''
,basic_info                                                                                           string               comment ''
,legal_person                                                                                         string               comment ''
,picture_info                                                                                         string               comment ''
,address                                                                                              string               comment ''
,ip_whitelist                                                                                         string               comment ''
,customer_status                                                                                      bigint               comment ''
,create_by                                                                                            string               comment ''
,create_time                                                                                          bigint               comment ''
,update_by                                                                                            string               comment ''
,update_time                                                                                          bigint               comment ''
,company_mobile_no                                                                                    string               comment ''
,category                                                                                             bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/scoring_open_platform_xx_db/customer_info_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__scoring_open_platform_id_db__customer_info_tab;
