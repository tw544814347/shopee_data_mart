
--变更历史：
    -- 20250618 wei.tao DWD/DWS新增 SPP 数据源，但是此表保持不变，新增过滤条件，jira：https://jira.shopee.io/browse/SPFDT-52751

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
   ,is_spp_update
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
        ,is_spp_update
        ,shopeepay_user_id
    from ${SCHEMA}.dwd_risk_login_di
    where grass_date = date('${bizdate}')
        and grass_region = upper('${region}')
        and shopee_df is not null
    group by user_id, shopee_df, tongdun_device_id, hash_shopee_df, sz_dfp_device_id, grass_region, is_spp_update, shopeepay_user_id
));

create or replace view ${SCHEMA}.dws_risk_${region}_user_device_login_di as
select
    *
from ${SCHEMA}.dws_risk_user_device_login_di
where
    grass_region = upper('${region}')
;