drop table if exists ${SCHEMA}.dwd_th_af_activation_aripay_info_df;
create external table if not exists ${SCHEMA}.dwd_th_af_activation_aripay_info_df
(
    flow_no                                 string comment 'flow no'
    ,app_id                                 string comment 'app id'
    ,scene_id                               bigint comment 'scene id'
    ,platform_user_id                       string comment 'shopee platform user id'
    ,create_time                            bigint comment 'create time'
    ,airpay_liveness_check_picture_url1     string comment 'Airpay liveness check picture1 url'
    ,airpay_liveness_check_picture_url2     string comment 'Airpay liveness check picture2 url'
    ,airpay_liveness_check_result           int    comment 'Airpay liveness check result, assigned after the liveness check'
    ,airpay_liveness_check_time             bigint comment 'Airpay liveness check time, assigned after the liveness check'
    ,airpay_anti_spoofing_result            int    comment 'Airpay anti-spoofing result, assigned after the anti-spoofing' 
    ,airpay_anti_spoofing_time              bigint comment 'Airpay anti-spoofing time, assigned after the anti-spoofing'
    ,airpay_anti_spoofing_score             string comment 'Airpay anti-spoofing score, assigned after the anti-spoofing'
    ,airpay_facial_matching_result          int    comment 'Airpay facial_matching result, assigned after the facial_matching' 
    ,airpay_facial_matching_time            bigint comment 'Airpay facial_matching time, assigned after the facial_matching'
    ,airpay_facial_macthing_score           string comment 'Airpay facial_matching score, assigned after the facial_matching'
)
partitioned by
(
    grass_date                              string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_af_activation_aripay_info_df/grass_region=TH';
msck repair table ${SCHEMA}.dwd_th_af_activation_aripay_info_df;

