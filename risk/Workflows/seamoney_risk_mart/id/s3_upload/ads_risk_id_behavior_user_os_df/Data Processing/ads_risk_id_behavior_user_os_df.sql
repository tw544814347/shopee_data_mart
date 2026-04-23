--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2024-11-04
-- Theme Domain：      
-- Description:         [SPFDT-44654] 
-- Data Granularity:    
-- 变更历史： https://casement.scredit.io/project/78703/version?versionTab=task&versionId=7013&jiraKey=SPFDT-44654
--********************************************************************--

insert overwrite table risk.ads_risk_id_behavior_user_os_df partition(grass_date='${grass_date}')
select 
    platform_user_id
    ,spl_os
    ,spl_plus_offline_os
    ,spl_plus_online_os
    ,bcl_os
    ,tl_os
    ,total_internal_os
    ,spl_os_dued_within_30d
    ,spl_plus_offline_os_dued_within_30d
    ,spl_plus_online_os_dued_within_30d
    ,bcl_os_dued_within_30d
    ,tl_os_dued_within_30d
    ,total_internal_os_dued_within_30d

    -- ,grass_date
from credit_mart.ads_id_behavior_user_os_df
where grass_date = '${grass_date}'
;



