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


-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df
(
    shopeepay_user_id   string  comment 'shopeepay user id',
    spdf_list string comment 'spdf_list' ,
    szdf_list string comment 'szdf_list'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_behavior_spp_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_feature_df partition (grass_date = '${grass_date}')
select
    t1.shopeepay_user_id
    ,t2.spdf_list
    ,t2.szdf_list
from 
(
    select
        shopeepay_user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where
        grass_date = '${grass_date}'
) t1
left join (
    select  shopeepay_user_id
            ,spdf_list
            ,szdf_list    
    from    risk_feature.dws_risk_${region}_user_behavior_spp_frequency_device_df
    where   grass_date = '${grass_date}'                     
) t2
on t1.shopeepay_user_id = t2.shopeepay_user_id
;