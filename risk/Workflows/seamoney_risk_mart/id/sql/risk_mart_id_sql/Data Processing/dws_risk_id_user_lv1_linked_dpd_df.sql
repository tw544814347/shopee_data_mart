drop table if exists ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_by_tddf_tmp;
create table ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_by_tddf_tmp stored as orc as
select
    t1.platform_user_id
    ,t1.fst_lvl_network_user_id_list_td
    ,t2.ever_max_dpd_spl_core
from
(
    select
        user_id as platform_user_id
        ,fst_lvl_network_user_id_list_td
    from ${SCHEMA}.ads_risk_profile_user_df
    where tz_type = 'local'
        and grass_region = '${region}'
        and grass_date = '${ds}'
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
on t1.platform_user_id = t2.platform_user_id
;

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_df PARTITION (grass_date)
select
    t1.platform_user_id
    ,count(distinct t1.linked_l1_user) as total_users
    ,null as blacklist_users
    ,count(distinct if(t1.ever_max_dpd_spl_core>15,t1.linked_l1_user,null)) as dpd15p_users
    ,count(distinct if(t1.ever_max_dpd_spl_core>30,t1.linked_l1_user,null)) as dpd30p_users
    ,'${ds}' as grass_date
from
(
    select
        platform_user_id
        ,ever_max_dpd_spl_core
        ,trim(linked_l1_user) as linked_l1_user
    from
    (
        select
            platform_user_id
            ,ever_max_dpd_spl_core
            ,split(fst_lvl_network_user_id_list_td,',') as userid_l1_list_by_tddf
        from ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_by_tddf_tmp
    ) lateral view explode(userid_l1_list_by_tddf) temp as linked_l1_user
) t1
group by t1.platform_user_id
;


