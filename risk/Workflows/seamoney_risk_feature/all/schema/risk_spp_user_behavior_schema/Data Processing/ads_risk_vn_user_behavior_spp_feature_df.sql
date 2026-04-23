--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2024-09-04T14:00:00
-- Description:         ADS shopeepay_user_id指标表(id/th/vn) 用户是否登陆过shopeepay独立app
--                      数据源 mart_dwd_us_user_login_dz__${region}  
--                      数据源文档: https://confluence.shopee.io/pages/viewpage.action?pageId=1704767948
-- Data Granularity:    shopeepay_user_id
-- PRD                  https://confluence.shopee.io/pages/viewpage.action?pageId=2306389254
-- Jira                 https://jira.shopee.io/browse/SPFDT-43626
-- source table         mart_dwd_us_user_login_dz__${region}
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${region}_user_behavior_spp_feature_df ;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_user_behavior_spp_feature_df
(
    shopeepay_user_id   string  comment 'shopeepay user id'
    ,last_login_date    string  comment 'shopeepay user latest login date, in local time'
    ,source_name        string  comment 'Description of shopeepay user last login source'
    ,is_ever_login_spp  int     comment 'is shopeepay user ever login spp standalone app'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc
tblproperties
(
    "orc.compress" = "ZSTD"
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_feature/ads/ads_risk_reg_user_behavior_spp_feature_df/grass_region=${REGION}';
;

MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${region}_user_behavior_spp_feature_df;
