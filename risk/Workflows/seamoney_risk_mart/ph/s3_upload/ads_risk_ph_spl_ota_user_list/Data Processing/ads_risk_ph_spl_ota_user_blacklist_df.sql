insert overwrite table ${SCHEMA}.ads_risk_ph_spl_ota_user_blacklist_df partition (grass_date = '${ds}')
select 
      user_id               as shopee_userid,
      blacklist_tag_ota_ph  as is_blacklist 
from smcdrisk_policy.fs_seamoney_underwriting_buyer_ph 
where blacklist_tag_ota_ph in(1,0)