DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_${region_lower}_credit_custom_list_rare_type_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_${region_lower}_credit_custom_list_rare_type_df
(
     id                                                                                                   decimal(20,0)        comment ''
,data                                                                                                 string               comment ''
,data_type                                                                                            bigint               comment ''
,custom_list_id                                                                                       decimal(20,0)        comment ''
,data_source                                                                                          string               comment ''
,action_detail                                                                                        string               comment ''
,action_fail_detail                                                                                   string               comment ''
,action_status                                                                                        bigint               comment ''
,remark                                                                                               string               comment ''
,status                                                                                               bigint               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string
,expire_time                                                                                          string
)
PARTITIONED BY
(
  grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_reg_credit_custom_list_rare_type_df/grass_region=${region_upper}';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_${region_lower}_credit_custom_list_rare_type_df;