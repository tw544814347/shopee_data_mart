insert overwrite table ${SCHEMA}.ads_risk_id_seller_withdrawal_amt_df partition(grass_date)
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), created_timestamp,withdrawal_id) as rowkey
       ,cast(withdrawal_amt * 100000  as string) as qf
       ,grass_date
from mp_order.dwd_seller_wallet_withdrawal_all_ent_df__reg_live
where grass_region = 'ID'
     and bank_account_id = 0
     and withdrawal_status_id = 4
     and withdrawal_amt is not null
     and grass_date >= date_sub('${grass_date}', 120)
;






