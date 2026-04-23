--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-04
-- Theme Domain：       platform_user_id
-- Description:         id spl ota 黑名单
-- Data Granularity:    platform_user_id
-- 变更历史：          
-- 2024-05-08 zongyi.lu 将live 用户改成 0; 1500w一个文件上传s3
--********************************************************************--

-- create or replace temporary view ods_risk_ph_spl_ota_be_blacklist as
-- select 
-- platform_user_id as shopee_userid
-- from credit.ods__credit_usercenter_tag_ph_db__user_platform_tag_info_tab__df
-- where grass_date ='${ds}'
-- and tag_type = 101 AND tag_status IN (1, 10) AND biz_type = 3
-- group by platform_user_id
-- ;
-- insert overwrite table ${SCHEMA}.ads_risk_ph_spl_ota_user_blacklist_di partition (grass_date = '${ds}')
-- -- DE表tag =1(表示增加黑名单的数据),去掉“和UC交集的用户”数据记录,保留剩下的 tag =1的数据
-- select
--     t1.shopee_userid
--     ,t1.is_blacklist
-- from risk.ads_risk_ph_spl_ota_user_blacklist_df t1 
-- left join ods_risk_ph_spl_ota_be_blacklist t2 on t1.shopee_userid = t2.shopee_userid
-- where t1.grass_date = '${ds}'
-- and t1.is_blacklist=1 
-- and t2.shopee_userid is null 
-- union all 
-- -- DE表tag =0(表示去掉黑名单的数据),保留“和UC交集的用户”数据记录
-- select
--     t1.shopee_userid
--    ,t1.is_blacklist
-- from risk.ads_risk_ph_spl_ota_user_blacklist_df t1 
-- join ods_risk_ph_spl_ota_be_blacklist t2 on t1.shopee_userid = t2.shopee_userid
-- where t1.grass_date = '${ds}'
-- and t1.is_blacklist=0 
-- ;

insert overwrite table ${SCHEMA}.ads_risk_ph_spl_ota_user_blacklist_di partition (grass_date = '${ds}')
select 
platform_user_id as shopee_userid
,0  as is_blacklist
from credit.ods__credit_usercenter_tag_ph_db__user_platform_tag_info_tab__df
where grass_date ='${ds}'
and tag_type = 101 AND tag_status IN (1, 10) AND biz_type = 3
;