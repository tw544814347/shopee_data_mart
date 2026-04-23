insert overwrite table ${SCHEMA}.ads_sync_risk_blacklist_df partition (grass_region, grass_date, table_name)
-- select  
-- data
--         ,datatype
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'br_blacklist_overdue' as table_name
-- from    smcdrisk_antifraud.br_blacklist_overdue
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,datatype
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'br_blacklist_uc_screening' as table_name
-- from    smcdrisk_antifraud.br_blacklist_uc_screening
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,datatype
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'br_shopee_fraud_tag_spl' as table_name
-- from    smcdrisk_antifraud.br_shopee_fraud_tag_spl
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,datatype
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'device_clustering_br' as table_name
-- from smcdrisk_antifraud.device_clustering_br
-- group by data
--         ,datatype
-- union all 
-- select data
--         ,datatype
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'user_clustering_br' as table_name
-- from smcdrisk_antifraud.user_clustering_br
-- group by data
--         ,datatype
-- union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_spdf_ph' as table_name
from    smcdrisk_antifraud.blacklist_spdf_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_tddf_ph' as table_name
from    smcdrisk_antifraud.blacklist_tddf_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'ec_overdue_ph' as table_name
from    smcdrisk_antifraud.ec_overdue_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_fraud_tag_ph' as table_name
from    smcdrisk_antifraud.blacklist_fraud_tag_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_user_graph_ph' as table_name
from    smcdrisk_antifraud.blacklist_user_graph_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_overdue_users_ph' as table_name
from    smcdrisk_antifraud.blacklist_overdue_users_ph
group by data
        ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'PH' grass_region
--         ,'${ds}' grass_date
--         ,'shop_whitelist_ph' as table_name
-- from    smcdrisk_antifraud.shop_whitelist_ph
-- group by data
--         ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_screening_ph' as table_name
from    smcdrisk_antifraud.blacklist_screening_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'mp_auto_seller_whitelist_ph' as table_name
from    smcdrisk_antifraud.mp_auto_seller_whitelist_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_ph' as table_name
from    smcdrisk_antifraud.blacklist_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'blacklist_cashout_shops_ph' as table_name
from    smcdrisk_antifraud.blacklist_cashout_shops_ph
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'ph_blacklist_overdue_users_shopee' as table_name
from    smcdrisk_antifraud.ph_blacklist_overdue_users_shopee
group by data
        ,datatype

union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'ph_overdue_users_dpd30' as table_name
from    smcdrisk_antifraud.ph_overdue_users_dpd30
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'ph_blacklist_uw_freeze_users' as table_name
from    smcdrisk_antifraud.ph_blacklist_uw_freeze_users
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'ph_mp_highrisky_device_ba_phone_linked_shop' as table_name
from    smcdrisk_antifraud.ph_mp_highrisky_device_ba_phone_linked_shop
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'ph_blacklist_spp_account_selling' as table_name
from    smcdrisk_antifraud.ph_blacklist_spp_account_selling
group by data
        ,datatype
union all 
select  data
        ,dataType
        ,'PH' grass_region
        ,'${ds}' grass_date
        ,'cashout_pattern_shop_blacklist_ph' as table_name
from    smcdrisk_antifraud.cashout_pattern_shop_blacklist_ph
group by data
        ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'br_blacklist_req_by_bcb' as table_name
-- from    smcdrisk_antifraud.br_blacklist_req_by_bcb
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'BR' grass_region
--         ,'${ds}' grass_date
--         ,'br_blacklist_overdue_users_shopee' as table_name
-- from    smcdrisk_antifraud.br_blacklist_overdue_users_shopee
-- group by data
--         ,datatype

-- ID black list 
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'blacklist_ato_id' as table_name
-- from    smcdrisk_antifraud.blacklist_ato_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'blacklist_cashout_id' as table_name
-- from    smcdrisk_antifraud.blacklist_cashout_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'blacklist_overdue_id' as table_name
-- from    smcdrisk_antifraud.blacklist_overdue_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'blacklist_shopee_device_consentration_id' as table_name
-- from    smcdrisk_antifraud.blacklist_shopee_device_consentration_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'blacklist_shopee_fraud_tag_id' as table_name
-- from    smcdrisk_antifraud.blacklist_shopee_fraud_tag_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'greylist_cashout_id' as table_name
-- from    smcdrisk_antifraud.greylist_cashout_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'greylist_overdue_shipping_info_id' as table_name
-- from    smcdrisk_antifraud.greylist_overdue_shipping_info_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'greylist_shopee_device_consentration_id' as table_name
-- from    smcdrisk_antifraud.greylist_shopee_device_consentration_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'mp_shop_auto_blacklist_table_id' as table_name
-- from    smcdrisk_antifraud.mp_shop_auto_blacklist_table_id
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'risky_itemid_table_id' as table_name
-- from    smcdrisk_antifraud.risky_itemid_table_id
-- group by data
--         ,datatype

-- TH blacklist
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_Shopee_fraud_tag' as table_name
-- from    smcdrisk_antifraud.th_blacklist_Shopee_fraud_tag
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_ec_overdue' as table_name
-- from    smcdrisk_antifraud.th_ec_overdue
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_overdue_users' as table_name
-- from    smcdrisk_antifraud.th_blacklist_overdue_users
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_clustering_spdf' as table_name
-- from    smcdrisk_antifraud.th_blacklist_clustering_spdf
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_clustering_tddf' as table_name
-- from    smcdrisk_antifraud.th_blacklist_clustering_tddf
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_cashout_shops' as table_name
-- from    smcdrisk_antifraud.th_blacklist_cashout_shops
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_overdue_users_shopee' as table_name
-- from    smcdrisk_antifraud.th_blacklist_overdue_users_shopee
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'TH' grass_region
--         ,'${ds}' grass_date
--         ,'th_blacklist_fake_id_spp_users' as table_name
-- from    smcdrisk_antifraud.th_blacklist_fake_id_spp_users
-- group by data
--         ,datatype

-- MY blacklist
-- union all 
-- select  data
--         ,dataType
--         ,'MY' grass_region
--         ,'${ds}' grass_date
--         ,'blacklist_overdue_my' as table_name
-- from    smcdrisk_antifraud.blacklist_overdue_my
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'MY' grass_region
--         ,'${ds}' grass_date
--         ,'risky_itemid_table_my' as table_name
-- from    smcdrisk_antifraud.risky_itemid_table_my
-- group by data
--         ,datatype
-- union all 
-- select  data
--         ,dataType
--         ,'ID' grass_region
--         ,'${ds}' grass_date
--         ,'auto_tok_bad_shop_list_id' as table_name
-- from    smcdrisk_antifraud.auto_tok_bad_shop_list_id
-- group by data
--         ,datatype
;
   