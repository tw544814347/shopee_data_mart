-- Order ID order_id
-- Level 1 Category category_level1
-- Seller Type seller_type
-- User ID  platform_user_id/credit_user_id
-- Mission ID
-- User Mission ID
-- Order GMV
-- Instalment (e.g. BNPL, 3x, 6x, ...)
-- Order Creation Time
-- Order Complete Time 

drop table if exists risk.dwd_risk_id_spl_mission_order_info_df;
create external table if not exists risk.dwd_risk_id_spl_mission_order_info_df
(
mission_id                         string comment 'mission_id'
,mission_name                      string comment 'mission_name'
,mission_type                      string comment 'mission_type'
,biz_type                          string comment '1-bcl,2-scl,3-spl'
,complete_duration                 bigint comment 'complete_duration'
,reward_duration                   bigint comment 'reward_duration'
,user_mission_id                   string comment 'user_mission_id'
,platform_user_id                  string comment 'platform_user_id'
,credit_user_id                    string comment 'credit_user_id'
,user_mission_start_time           string comment 'user mission start_time(local time)'
,user_mission_expiry_time          string comment 'user mission complete_time(local time)'
,order_id                          string comment 'order_id'
,seller_type                       string comment 'Seller Type'
,disburse_amount                   decimal(30,10) comment 'order gmv'
,total_term_num                    int            comment 'instalment'
,order_create_time                 string         comment 'order_create_time(local)'
,order_complete_time               string         comment 'order_complete_time(locla)'
,is_mission_type_2                 string         comment 'is_mission_type_2'
,is_mission_type_3                 string         comment 'is_mission_type_3'     
,category_id_list                  string         comment 'category_id_list'     
,is_threshold_value                int            comment '是否属于阈值范围内的order'
)
partitioned by (
grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_mission_order_info_df/grass_region=ID/biz_name=spl';
;

msck repair table risk.dwd_risk_id_spl_mission_order_info_df;