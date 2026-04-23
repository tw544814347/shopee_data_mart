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


insert overwrite table ${SCHEMA}.ads_risk_${region}_user_behavior_spp_feature_df partition (grass_date = '${ds}')
select  t1.shopeepay_user_id
        ,t1.last_login_date
        ,t1.source_name
        ,t2.is_ever_login_spp
from (
        select  shopeepay_user_id
                ,last_login_date
                ,source_name
        from shopeepay.mart_dwd_us_user_login_dz__${region}
        where grass_date = '${ds}'
) t1 inner join (
        select  shopeepay_user_id
                ,1 as is_ever_login_spp
        from shopeepay.mart_dwd_us_user_login_dz__${region}
        where grass_date = '${ds}'
          and source_name = 'SPP (ShopeePay App)'
        group by shopeepay_user_id
) t2 on t1.shopeepay_user_id = t2.shopeepay_user_id
;