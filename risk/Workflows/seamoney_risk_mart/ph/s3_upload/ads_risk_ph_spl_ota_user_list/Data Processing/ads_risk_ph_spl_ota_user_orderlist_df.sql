insert overwrite table ${SCHEMA}.ads_risk_ph_spl_ota_user_orderlist_df partition (grass_date = '${ds}')
select 
    coalesce(t1.user_id,t2.buyer_id)       as shopee_userid
    ,coalesce(t1.blacklist_tag_ota_ph,0)   as is_blacklist
    ,coalesce(t2.completed_order_cnt_td,0) as completed_order_cnt_td
from    (
    select  user_id
            ,blacklist_tag_ota_ph
    from    smcdrisk_policy.fs_seamoney_underwriting_buyer_ph 
    where   blacklist_tag_ota_ph = 1
) t1
full join (
    select  buyer_id
            ,completed_order_cnt_td
    from    mp_order.dws_buyer_gmv_td__ph_s0_live
    where  
      grass_date = '${begin_ds}'
      and   completed_order_cnt_td > 0
) t2
on     t1.user_id = t2.buyer_id
;
