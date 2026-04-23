--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-04
-- Theme Domain：       platform_user_id
-- Description:         id spl ota 黑名单
-- Data Granularity:    platform_user_id
-- 变更历史：          
-- 2024-03-04 zongyi.lu 将live 21000000改成 0; 100w一个文件上传s3
--********************************************************************--

-- insert overwrite table risk.ads_risk_id_spl_ota_user_blacklist_di partition(grass_date ='${grass_date}')
-- select 
--     t1.user_id  as user_id
--     ,1          as status 
-- from risk.ads_risk_id_spl_ota_user_blacklist_df t1
-- left join (
--     select 
--     user_id 
--     from risk.ads_risk_id_spl_ota_user_blacklist_df t2 
--     where grass_date =date_sub('${grass_date}',1)
--     group by user_id
-- ) t2 on t1.user_id = t2.user_id
-- where grass_date ='${grass_date}' and  t2.user_id is null 

-- union all 
-- select 
--     t1.user_id  as user_id
--     ,0       as status 
-- from risk.ads_risk_id_spl_ota_user_blacklist_df t1
-- left join (
--     select 
--     user_id 
--     from risk.ads_risk_id_spl_ota_user_blacklist_df t2 
--     where grass_date ='${grass_date}'
--     group by user_id
-- ) t2 on t1.user_id = t2.user_id
-- where grass_date =date_sub('${grass_date}',1)
-- and t2.user_id is null 
-- ;

insert overwrite table risk.ads_risk_id_spl_ota_user_blacklist_di partition(grass_date ='${grass_date}')
select 
user_id  as user_id 
,1      as status
from risk.ads_risk_id_spl_ota_user_blacklist_df_manual
where status='1'


