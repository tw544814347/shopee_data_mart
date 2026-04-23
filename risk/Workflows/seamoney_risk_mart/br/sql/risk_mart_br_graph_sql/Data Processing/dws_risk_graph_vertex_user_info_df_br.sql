-- update by zongyi.lu@shopee.com 2024-12-04 补充bcl相关信息
-- https://git.garena.com/shopee-ds/shopee-kredit/ds-graph-db/-/blob/4378c924cbff2bf9a6a6bb780a24e91461e2dac7/dws_risk_graph_vertex_user_info_df_br.sql
insert overwrite table ${SCHEMA}.dws_risk_graph_vertex_user_info_df partition (grass_region, grass_date)
select  concat('userid/', t1.userid) as vertex
        ,xxhash64(concat('userid/', t1.userid)) as hash_vertex
        ,to_json(
            named_struct(
                'userid',t1.userid
                ,'user_name',t1.user_name
                ,'shop_id',t1.shop_id
                ,'is_seller',t1.is_seller
                ,'shop_name',t11.shop_name
                ,'status',t1.status
                ,'registration_date',t1.registration_date
                ,'registration_timestamp',t1.registration_timestamp
                ,'user_id',coalesce(t2.spl_user_id, t3.bcl_user_id, '')
                ,'spl_activate_date',t2.spl_activate_date
                ,'is_spl',t2.is_spl
                ,'spl_fpd',t8.spl_fpd
                ,'spl_current_dpd',t5.spl_current_dpd
                ,'spl_history_max_dpd',t5.spl_history_max_dpd
                ,'spl_history_max_dpd_30d',t5.spl_history_max_dpd_30d
                ,'spl_history_max_dpd_90d',t5.spl_history_max_dpd_90d
                ,'spl_history_max_dpd_180d',t5.spl_history_max_dpd_180d
                ,'bcl_activate_date',t3.bcl_activate_date
                ,'is_bcl',t3.is_bcl
                ,'bcl_fpd',t9.bcl_fpd
                ,'bcl_current_dpd',t6.bcl_current_dpd
                ,'bcl_history_max_dpd',t6.bcl_history_max_dpd
                ,'bcl_history_max_dpd_30d',t6.bcl_history_max_dpd_30d
                ,'bcl_history_max_dpd_90d',t6.bcl_history_max_dpd_90d
                ,'bcl_history_max_dpd_180d',t6.bcl_history_max_dpd_180d

            )
        ) as extend_info
        ,'BR' as grass_region
        ,'${grass_date}' as grass_date
--user profile--
from    (
    select  user_id as userid
            ,shop_id as shop_id
            ,is_seller as is_seller
            ,status as status
            ,to_date(registration_datetime) as registration_date
            ,registration_timestamp
            ,user_name
    from    mp_user.dim_user__reg_s0_live
    where   grass_region = 'BR'
      and   grass_date = '${grass_date}'
) t1
--spl profile--
left join (
    select  cast(t1.platform_user_id as string) as userid
            ,cast(t1.credit_user_id as string) as spl_user_id
            ,to_date(t2.first_activation_time) as spl_activate_date
            ,1 as is_spl
    from    credit_mart.wide_spl_br_behavior_user_df t1 
    left join ( 
        select platform_user_id ,first_activation_time,grass_date
        from credit_uc.dws_all_prod_br_uc_user_df 
        where grass_date = '${grass_date}'
        and product_id = 3 
        ) t2 on t1.platform_user_id = t2.platform_user_id and t1.grass_date = t2.grass_date
    where   t1.grass_date = '${grass_date}'
) t2
on t1.userid = t2.userid
--bcl profile--
left join (
    select  cast(t1.platform_user_id as string) as userid
            ,cast(t1.credit_user_id as string) as bcl_user_id
            ,to_date(t2.first_activation_time) as bcl_activate_date
            ,1 as is_bcl
    from    credit_mart.wide_bcl_br_behavior_user_df t1 
   left join ( 
        select platform_user_id ,first_activation_time ,grass_date
        from credit_uc.dws_all_prod_br_uc_user_df 
        where grass_date = '${grass_date}'
        and product_id = 1 
        ) t2 on t1.platform_user_id = t2.platform_user_id and t1.grass_date = t2.grass_date
    where   t1.grass_date = '${grass_date}'
) t3
on t1.userid = t3.userid

--spl dpd--
left join (
    select  cast(platform_user_id as string) as userid
            ,current_max_dpd as spl_current_dpd
            ,historical_max_dpd as spl_history_max_dpd
            ,ever_max_dpd_30d as spl_history_max_dpd_30d
            ,ever_max_dpd_90d as spl_history_max_dpd_90d
            ,ever_max_dpd_180d as spl_history_max_dpd_180d
    from    credit_mart.dws_spl_br_user_df
    where   grass_date = '${grass_date}'
) t5
on t1.userid = t5.userid
--bcl dpd--
left join (
    select  cast(platform_user_id as string) as userid
            ,current_max_dpd as bcl_current_dpd
            ,historical_max_dpd as bcl_history_max_dpd
            ,ever_max_dpd_30d as bcl_history_max_dpd_30d
            ,ever_max_dpd_90d as bcl_history_max_dpd_90d
            ,ever_max_dpd_180d as bcl_history_max_dpd_180d
    from    credit_mart.dws_bcl_br_user_df
    where   grass_date = '${grass_date}'
) t6
on t1.userid = t6.userid

--spl fpd--
left join (
    select  userid
            ,max(max_dpd) as spl_fpd
    from    (
        select  cast(platform_user_id as string) as userid
                ,max_dpd
                ,row_number() over (partition by platform_user_id order by month_due_time) as rank
        from    credit_mart.dws_spl_br_instalment_repayment_df
        where   grass_date = '${grass_date}'
          and   total_amount_repayable > 0
    )
    where   rank = 1
    group by userid
) t8
on t1.userid = t8.userid
--bcl fpd--
left join (
    select  userid
            ,max(max_dpd) as bcl_fpd
    from    (
        select  cast(platform_user_id as string) as userid
                ,max_dpd
                ,row_number() over (partition by platform_user_id order by month_due_time) as rank
        from    credit_mart.dws_bcl_br_instalment_repayment_df
        where   grass_date = '${grass_date}'
          and   total_amount_repayable > 0
    )
    where   rank = 1
    group by userid
) t9
on t1.userid = t9.userid

--shop profile--
left join (
    select  user_id as userid
            ,shop_name
    from    mp_user.dim_shop__reg_s0_live
    where   grass_region = 'BR'
      and   grass_date = '${grass_date}'
) t11
on t1.userid = t11.userid
;
