drop table if exists ${SCHEMA}.dwd_risk_${region}_user_identity_log_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_user_identity_log_df
(
id                           bigint               comment ''
,flow_no                     string               comment ''
,id_no                       string               comment ''
,name                        string               comment ''
,birth_date                  string               comment ''
,birth_place                 string               comment ''
,identity_photo_url          string               comment ''
,selfie_photo_url            string               comment ''
,name_match                  bigint               comment ''
,birth_date_match            bigint               comment ''
,birth_place_match           bigint               comment ''
,rsp_address                 string               comment ''
,selfie_photo_match_score    bigint               comment ''
,rsp_code                    bigint               comment ''
,errors                      string               comment ''
,create_time                 string               comment ''
,update_time                 string               comment ''
,req_channel                 string               comment 'which channel that request the asliri'
,req_no                      string               comment 'channel request number'
,req_time                    string               comment 'channel request timestamp'
,req_status                  bigint               comment 'request status, 0: unknown, 1:success, 2:failed, 3: pending'
,asli_version                string               comment ''
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_user_identity_log_df/garss_region=${upper_region}';

msck repair table ${SCHEMA}.dwd_risk_${region}_user_identity_log_df;