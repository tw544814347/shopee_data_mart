DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${region}_user_login_phone_recycle_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_user_login_phone_recycle_df
(
    user_id                   string comment 'user_id'
    ,login_1y                 int    comment '最近一年是否有登陆Shopee, 1-y; 0-other'
    ,gross_order              int    comment '是否买过Shopee订单, 1-y; 0-other'
    ,credit_user              int    comment '是否是credit_user, 1-y; 0-other'
    ,cutoff_silence_days      int    comment '60 for ID;180 for PH;180 for MY'
    ,flag_silence_user        int    comment '是否有连续超过cutoff_silence_days登陆, 1-y; 0-other'
    ,silence_start_timestamp  bigint comment '冷静期开始时间(最近的一次)'
    ,silence_end_timestamp    bigint comment '冷静期结束时间(最近的一次)'
    ,phone_added_bef_silence  int    comment '用户是否在Silence_start_timestamp之前add phone,1-y; 0-other; -1-Flag_silence_user=0'
    ,gross_order_bef_silence  int    comment '用户是否在Silence_start_timestamp之前是否有下单,1-y; 0-other; -1-Flag_silence_user=0' 
    ,new_device_reactive      int    comment '用户是否在冷静期结束end_timestamp时使用新设备登陆,1-y; 0-other; -1-Flag_silence_user=0'
    ,old_device_appear        int    comment '用户是否在冷静期结束end_timestamp时使用旧设备登陆,1-y; 0-other; -1-Flag_silence_user=0'
    ,consistent_mp_address    int    comment '用户沉默期前后下单的地址是否一致,1-y; 0-other; -1-Flag_silence_user=0'
    ,old_added_mp_address     int    comment '用户是否沉默期前就设置了地址(并且沉默期后下了单),1-y; 0-other; -1-Flag_silence_user=0'
    ,edge_data_issue          int    comment '用户是否在沉默期期间修改手机号码, 1-是; 0-否'
    ,gps_city_list            string comment 'Gps_city_list #用户net订单的地址'
    ,gps_city_list_slice      string comment 'Gps_city_list #用户net订单的地址切片'
    ,gps_province_list        string comment 'Gps_city_list #用户net订单的地址省份'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_aio_user_login_phone_recycle_df/grass_region=${upper_region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${region}_user_login_phone_recycle_df;
