insert overwrite ${SCHEMA}.ads_risk_th_shop_site_user_map_df partition (grass_date = '${ds}')
select shop_id                                                                  as shop_id, 
       concat_ws(',', collect_set(cast(sbc_customer_site_use_id as string)))    as sbc_customer_site_use_id
from smcdrisk_policy.ads_risk_th_profile_shop
group by shop_id
;