insert overwrite table ${SCHEMA}.dwd_risk_th_af_seller_kyc_info_df partition (grass_date)
select
    userid as platform_user_id
    ,id_card_no
    ,'${grass_date}' as grass_date
from
    (
        select
            userid
            ,regexp_replace(accountid, '[^0-9]', '') as id_card_no
            ,row_number() over (
                partition by userid
                order by mtime desc
            ) rn
        from
            marketplace.shopee_user_backend_th_db__external_account_verification_tab__th_daily_s0_live
        where
            verification_type in (1, 2, 3)
            and status = 3
    )
where rn = 1
;