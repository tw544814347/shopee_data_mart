-- jira:https://jira.shopee.io/browse/SPFDT-49107
-- author:wei.tao@shopee.com
-- create_time:20250319
-- note:
/*
    1.20260326 https://jira.shopee.io/browse/SPFDT-60046 从业务底表换到 holmes 回传的 DB 数据
*/


insert overwrite table risk.ads_${reg}_spl_card_virtual_card_whitelist partition(grass_date = '${ds}')
select data as platform_user_id, 1 as status
from risk.dwd_risk_th_credit_custom_list_df
where data_type_name='shopeeAccount'
    and status='1'
    and custom_list_id=178 --virtual list
    -- and custom_list_id=181 --physical list
    and grass_date = '${ds}'
;