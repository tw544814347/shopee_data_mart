insert overwrite table ${SCHEMA}.dws_risk_user_login_device_df partition (tz_type='local', grass_region, grass_date)
select
    user_id 
    ,max(case when asc_dev_rn = 1 then shopee_df end) as fst_login_shopee_df_td
    ,max(case when asc_dev_rn = 1 then shopee_device_id end) as fst_login_shopee_device_id_td
    ,max(case when asc_dev_rn = 1 then hash_shopee_df end) as fst_login_hash_shopee_df_td
    ,max(case when asc_dev_rn = 1 then tongdun_device_id end) as fst_login_tongdun_device_id_td
    ,max(case when asc_dev_rn = 1 then login_timestamp end) as fst_login_timestamp_td
    ,max(case when desc_dev_rn = 1 then shopee_df end) as lst_login_shopee_df_td
    ,max(case when desc_dev_rn = 1 then shopee_device_id end) as lst_login_shopee_device_id_td
    ,max(case when desc_dev_rn = 1 then hash_shopee_df end) as lst_login_hash_shopee_df_td
    ,max(case when desc_dev_rn = 1 then tongdun_device_id end) as lst_login_tongdun_device_id_td
    ,max(case when desc_dev_rn = 1 then login_timestamp end) as lst_login_timestamp_td
    ,max(case when asc_dev_rn = 1 then sz_dfp_device_id end) as fst_login_sz_dfp_device_id_td
    ,max(case when desc_dev_rn = 1 then sz_dfp_device_id end) as lst_login_sz_dfp_device_id_td
    ,grass_region
    ,cast('${bizdate}' as date) as grass_date
from (
    select
        *
        ,create_timestamp as login_timestamp
        ,row_number() over(partition by user_id, grass_region order by create_timestamp asc) as asc_dev_rn
        ,row_number() over(partition by user_id, grass_region order by create_timestamp desc) as desc_dev_rn
    from ${SCHEMA}.dim_risk_user_device_df
    where grass_date = date('${bizdate}')
      and tz_type = 'local'
      and grass_region = upper('${region}')
) a1
where (asc_dev_rn = 1 or desc_dev_rn = 1)
group by
    user_id
    ,grass_region;


create or replace view ${SCHEMA}.dws_risk_${region}_user_login_device_df as
select
    *
from ${SCHEMA}.dws_risk_user_login_device_df
where
    grass_region = upper('${region}')
;