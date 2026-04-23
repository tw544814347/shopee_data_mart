insert overwrite table risk.ads_th_spl_card_physical_card_whitelist partition(grass_date = '${ds}')
select data as platform_user_id, 1 as status
from risk.dwd_risk_th_credit_custom_list_df
where data_type_name='shopeeAccount'
    and status='1'
    -- and custom_list_id=178 --virtual list
    and custom_list_id=181 --physical list
    and grass_date = '${ds}'
;