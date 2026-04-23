drop table if exists ${SCHEMA}.tmp_dws_risk_id_device_dpd;
create table ${SCHEMA}.tmp_dws_risk_id_device_dpd stored as orc as
select
    t1.user_id
    ,t1.shopee_hashed_df_list
    ,t1.tongdun_df_list
    ,t1.sz_df_list
    ,t2.ever_max_dpd_spl_core
    ,t1.grass_date
from
(
    select
        user_id
        ,frequency_hex_hash_shopee_df_list_1y as shopee_hashed_df_list
        ,frequency_tongdun_device_id_list_1y as tongdun_df_list
        ,frequency_sz_dfp_device_id_list_1y as sz_df_list
        ,grass_date
    from ${SCHEMA}.ads_risk_profile_user_df
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = '${ds}'
        and frequency_hex_hash_shopee_df_list_1y is not null
) t1
left join
(
    select
        m1.platform_user_id
        ,m2.ever_max_dpd_spl_core
    from
        (
            select
                platform_user_id
                ,user_id as credit_user_id
            from credit.ods__credit_usercenter_member_id_db__user_activate_product_tab__df
            where grass_date = '${ds}'
                and platform_type = 1
                and biz_type = 3
            group by platform_user_id, user_id
        ) m1
        left join
        (
            select
                user_id as credit_user_id
                ,ever_max_dpd_spl_core
            from ${SCHEMA}.dws_risk_id_user_dpd_df
            where grass_date = '${ds}'
        ) m2
        on m1.credit_user_id = m2.credit_user_id
) t2
on t1.user_id = t2.platform_user_id
;

drop table if exists ${SCHEMA}.dws_risk_id_spdf_dpd_tmp;
create table ${SCHEMA}.dws_risk_id_spdf_dpd_tmp stored as orc as
select
    t1.shopee_hashed_df
    ,count(distinct if(t1.ever_max_dpd_spl_core>30,t1.user_id,null)) as dpd30p_users
from
(
    select
        trim(shopee_hashed_df) as shopee_hashed_df
        ,user_id
        ,ever_max_dpd_spl_core
    from
    (
        select
            user_id
            ,split(shopee_hashed_df_list,',') as shopee_hashed_df_list
            ,ever_max_dpd_spl_core
        from ${SCHEMA}.tmp_dws_risk_id_device_dpd
    ) lateral view explode(shopee_hashed_df_list) dfs as shopee_hashed_df
) t1
group by t1.shopee_hashed_df
;

drop table if exists ${SCHEMA}.tmp_dws_risk_id_tddf_dpd;
create table ${SCHEMA}.tmp_dws_risk_id_tddf_dpd stored as orc as
select
    t1.tongdun_df
    ,count(distinct if(t1.ever_max_dpd_spl_core>30,t1.user_id,null)) as dpd30p_users
from
(
    select
        trim(tongdun_df) as tongdun_df
        ,user_id
        ,ever_max_dpd_spl_core
    from
    (
        select
            user_id
            ,split(tongdun_df_list,',') as tongdun_df_list
            ,ever_max_dpd_spl_core
        from ${SCHEMA}.tmp_dws_risk_id_device_dpd
    ) lateral view explode(tongdun_df_list) dfs as tongdun_df
) t1
group by t1.tongdun_df
;

drop table if exists ${SCHEMA}.dws_risk_id_szdf_dpd_tmp;
create table ${SCHEMA}.dws_risk_id_szdf_dpd_tmp stored as orc as
select
    t1.sz_dfp_device_id
    ,count(distinct if(t1.ever_max_dpd_spl_core>30,t1.user_id,null)) as dpd30p_users
from
(
    select
        trim(sz_dfp_device_id) as sz_dfp_device_id
        ,user_id
        ,ever_max_dpd_spl_core
    from
    (
        select
            user_id
            ,split(sz_df_list,',') as sz_df_list
            ,ever_max_dpd_spl_core
        from ${SCHEMA}.tmp_dws_risk_id_device_dpd
    ) lateral view explode(sz_df_list) dfs as sz_dfp_device_id
) t1
group by t1.sz_dfp_device_id
;

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_id_device_dpd_df PARTITION (grass_date)
select
    device_id
    ,dpd30p_users
    ,device_type
    ,'${ds}' as grass_date
from
(
    select
        shopee_hashed_df as device_id
        ,dpd30p_users
        ,'spdf' as device_type
    from ${SCHEMA}.dws_risk_id_spdf_dpd_tmp
    union all
    select
        tongdun_df as device_id
        ,dpd30p_users
        ,'tddf' as device_type
    from ${SCHEMA}.tmp_dws_risk_id_tddf_dpd
    union all
    select
        sz_dfp_device_id as device_id
        ,dpd30p_users
        ,'szdf' as device_type
    from ${SCHEMA}.dws_risk_id_szdf_dpd_tmp
) t
;

msck repair table risk.dws_risk_id_device_dpd_df;