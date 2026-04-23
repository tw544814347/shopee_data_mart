insert overwrite table risk.ads_th_spl_card_physical_card_whitelist_index partition(grass_date = '${ds}')
select status,
    count(distinct user_id) as cnt 
from risk.ads_th_spl_card_physical_card_whitelist_di
where grass_date = '${ds}'
group by status
;