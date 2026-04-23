-- jira:https://jira.shopee.io/browse/SPFDT-49107
-- author:wei.tao@shopee.com
-- create_time:20250319

insert overwrite table risk.ads_${reg}_spl_card_virtual_card_whitelist_index partition(grass_date = '${ds}')
select status,
    count(distinct user_id) as cnt 
from risk.ads_${reg}_spl_card_virtual_card_whitelist_di
where grass_date = '${ds}'
group by status
;