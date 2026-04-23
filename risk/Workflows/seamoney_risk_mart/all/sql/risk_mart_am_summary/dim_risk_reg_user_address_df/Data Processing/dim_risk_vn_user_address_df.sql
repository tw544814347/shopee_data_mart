-- created by wei.tao  统一到模板部署，SG/US 都使用这个 模板

insert overwrite table ${SCHEMA}.dim_risk_user_address_df partition (tz_type='local', grass_region, grass_date )
select
    userid as user_id
    ,address as config_address
    ,cast(mtime as bigint) as modified_time
    ,status
    ,case
        when status in (1, 2) then 'Y'
        else 'N'
        end as is_valid
    ,country as grass_region
    ,cast('${bizdate}' as date) as grass_date
from
(
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_id_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_my_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_ph_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_th_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_vn_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_sg_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_tw_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_br_db__buyer_address_tab__reg_continuous_s0_live
    union all
    select
        userid
        ,address
        ,mtime
        ,status
        ,country
    from marketplace.shopee_account_address_mx_db__buyer_address_tab__reg_continuous_s0_live
) t
where t.country = '${grass_region}'
;

