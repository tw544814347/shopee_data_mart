insert overwrite table ${SCHEMA}.dws_risk_user_device_login_di partition (tz_type='local', grass_region, grass_date) (
select
   user_id
   ,shopee_df
   ,tongdun_device_id
   ,fst_login_timestamp
   ,lst_login_timestamp
   ,login_cnt_1d
   ,hash_shopee_df
   ,sz_dfp_device_id
   ,shopeepay_user_id
   ,grass_region
   ,date('${bizdate}') as grass_date
from (
    select
        user_id
        ,shopee_df
        ,tongdun_device_id
        ,grass_region
        ,min(login_timestamp) as fst_login_timestamp
        ,max(login_timestamp) as lst_login_timestamp
        ,count(*) as login_cnt_1d
        ,hash_shopee_df
        ,sz_dfp_device_id
        ,shopeepay_user_id
    from ${SCHEMA}.dwd_risk_login_di
    where grass_date = date('${bizdate}')
        and grass_region = upper('${region}')
        and shopee_df is not null
    group by user_id, shopee_df, tongdun_device_id, hash_shopee_df, sz_dfp_device_id, grass_region, shopeepay_user_id
));

create or replace view ${SCHEMA}.dws_risk_${region}_user_device_login_di as
select
    *
from ${SCHEMA}.dws_risk_user_device_login_di
where
    grass_region = upper('${region}')
;