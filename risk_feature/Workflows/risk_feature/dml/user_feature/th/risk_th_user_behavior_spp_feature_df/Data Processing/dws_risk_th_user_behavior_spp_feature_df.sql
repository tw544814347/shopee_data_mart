-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-04
-- Theme Domain:        User Behavior SPP Feature汇总主题表
-- Data Granularity:    shopeepay_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-04 - chengguo.liu - 初始化
-- =============================================================================


drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df
(
    shopeepay_user_id   string  comment 'shopeepay user id',
    succ_device_list_6m string comment 'succ_device_list_6m' ,
    succ_szdf_list_6m string comment 'succ_szdf_list_6m' ,
    spdf_list string comment 'spdf_list' ,
    szdf_list string comment 'szdf_list',
    szdf_ever_login_1y string comment 'szdf_ever_login_1y',
    frequency_sz_dfp_device_id_list_seller_1y_v2 string comment 'frequency_sz_dfp_device_id_list_seller_1y_v2' , 
    frequency_sz_dfp_device_id_list_1y_v3 string comment 'frequency_sz_dfp_device_id_list_1y_v3' ,
    frequency_sz_dfp_device_id_list_seller_1y_v3 string comment 'frequency_sz_dfp_device_id_list_seller_1y_v3' ,
    frequency_city_name_list_6m_v3 string comment 'frequency_city_name_list_6m_v3',
    silence_day_cnt_td_v3 string comment 'silence_day_cnt_td_v3'               
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_behavior_spp_feature_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df partition (grass_date = '${grass_date}')
select
    t1.shopeepay_user_id
    ,t2.succ_device_list_6m
    ,t2.succ_szdf_list_6m
    ,t2.spdf_list
    ,t2.szdf_list
    ,t3.szdf_ever_login_1y
    ,t4.frequency_sz_dfp_device_id_list_seller_1y_v2
    ,t4.frequency_sz_dfp_device_id_list_1y_v3
    ,t4.frequency_sz_dfp_device_id_list_seller_1y_v3
    ,t4.frequency_city_name_list_6m_v3
    ,t4.silence_day_cnt_td_v3
from 
(
    select
        shopeepay_user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__th
    where
        grass_date = '${grass_date}'
) t1
left join (
    select  shopeepay_user_id
            ,succ_device_list_6m
            ,succ_szdf_list_6m
            ,spdf_list
            ,szdf_list    
    from    risk_feature.dws_risk_th_user_behavior_spp_frequency_device_df
    where   grass_date = '${grass_date}'                     
) t2
on t1.shopeepay_user_id = t2.shopeepay_user_id
left join (
    select
        shopeepay_user_id
        ,szdf_ever_login_1y
    from risk_feature.dws_risk_th_user_behavior_spp_login_ever_login_info_df
    where
        grass_date = '${grass_date}'
) t3
on t1.shopeepay_user_id = t3.shopeepay_user_id
left join
(
    select
        shopeepay_user_id
        ,frequency_sz_dfp_device_id_list_seller_1y_v2
        ,frequency_sz_dfp_device_id_list_1y_v3
        ,frequency_sz_dfp_device_id_list_seller_1y_v3
        ,frequency_city_name_list_6m_v3
        ,silence_day_cnt_td_v3
    from risk_feature.dws_risk_th_user_behavior_spp_login_info_df
    where   grass_date = '${grass_date}'
) t4
on t1.shopeepay_user_id = t4.shopeepay_user_id
;