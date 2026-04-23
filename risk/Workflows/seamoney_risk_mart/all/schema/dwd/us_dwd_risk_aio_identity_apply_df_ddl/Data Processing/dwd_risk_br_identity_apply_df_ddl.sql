drop  table if exists risk.dwd_risk_${region}_identity_apply_df;
create external table if not exists risk.dwd_risk_${region}_identity_apply_df
(
id                                                                                                    bigint     comment ''
,request_key                                                                                          string     comment ''          
,unique_key                                                                                           string     comment ''
,data_source_name                                                                                     string     comment ''
,req_header                                                                                           string     comment ''
,req                                                                                                  string     comment ''
,extra_info                                                                                           string     comment ''
,resp_code                                                                                            bigint     comment ''
,hit_cache                                                                                            bigint     comment ''
,trace_id                                                                                             string     comment ''
,app_key                                                                                              string     comment ''
,flow_no                                                                                              string     comment ''
,data_year_month                                                                                      string     comment ''
,create_time                                                                                          string     comment 'local time'
,update_time                                                                                          string     comment 'local time'
)
partitioned by (
    grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_identity_apply_df/grass_region=${upper_region}';

msck repair table risk.dwd_risk_${region}_identity_apply_df;