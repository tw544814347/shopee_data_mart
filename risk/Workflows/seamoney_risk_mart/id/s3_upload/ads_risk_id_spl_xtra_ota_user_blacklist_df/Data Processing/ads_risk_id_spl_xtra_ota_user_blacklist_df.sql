--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2024-11-01
-- Theme Domain：      
-- Description:         [SPFDT-45651] 
-- Data Granularity:    
-- 变更历史：
--    
--********************************************************************--

insert overwrite table risk.ads_risk_id_spl_xtra_ota_user_blacklist_df partition(grass_date='${grass_date}')
select 

    user_id --   string
    ,status --   string
    ,add_date -- string   
from smcdrisk_policy.id_spl_xtra_ota_user_blacklist
where status = '1' --  [SPFDT-45651]  需求过滤条件

-- -- 新增测试用
-- -- union all 
-- select '1408623393' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
-- union all       
-- select '1408623196' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
--         union all 
-- select '1408623012' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
--         union all 
-- select '1408622793' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
--         union all 
-- select '1387240827' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
--         union all 
-- select '1387240715' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
--         union all
-- select '1392137162' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date
--         union all
-- select '1234107726' as user_id
--         , '1' as status
--         , '2024-11-29' as add_date

-- -- 
;