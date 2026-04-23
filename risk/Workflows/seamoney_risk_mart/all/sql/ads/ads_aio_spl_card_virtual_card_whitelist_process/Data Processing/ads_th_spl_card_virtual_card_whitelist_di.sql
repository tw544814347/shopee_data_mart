-- jira:https://jira.shopee.io/browse/SPFDT-49107
-- author:wei.tao@shopee.com
-- create_time:20250319
 
insert overwrite table risk.ads_${reg}_spl_card_virtual_card_whitelist_di partition(grass_date = '${ds}')
select distinct user_id as platform_user_id, 1 as status
from risk.ads_${reg}_spl_card_virtual_card_whitelist
where grass_date = '${ds}' and user_id not in 
(
    select distinct platform_user_id
    from credit.ods__credit_usercenter_tag_${reg}_db__user_platform_tag_info_tab__df
    where grass_date = '${ds}'
        and tag_type in (320)
        and tag_status =1
)
union 
select distinct platform_user_id as platform_user_id, -1 as status
from credit.ods__credit_usercenter_tag_${reg}_db__user_platform_tag_info_tab__df
where grass_date = '${ds}' and tag_type in (320) and tag_status =1 and platform_user_id not in 
(
    select distinct user_id as platform_user_id
    from risk.ads_${reg}_spl_card_virtual_card_whitelist
    where grass_date = '${ds}'
)
; 