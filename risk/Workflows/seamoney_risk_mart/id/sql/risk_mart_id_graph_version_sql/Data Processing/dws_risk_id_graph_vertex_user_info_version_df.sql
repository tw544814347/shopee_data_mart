DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_vertex_user_info_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_vertex_user_info_version_df
(
    vertex_value      string comment 'source vertex',
    hash_vertex_value string comment 'hash source vertex',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    version_name string comment 'version_name',
    grass_region string comment 'region',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_vertex_user_info_version_df';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_vertex_user_info_version_df;

insert overwrite table ${SCHEMA}.dws_risk_id_graph_vertex_user_info_version_df partition (version_name='v2', grass_region, grass_date)
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
                ,'user_id',coalesce(t2.spl_user_id, t3.bcl_user_id, t4.scl_user_id, '')
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
                ,'scl_activate_date',t4.scl_activate_date
                ,'is_scl',t4.is_scl
                ,'scl_fpd',t10.scl_fpd
                ,'scl_current_dpd',t7.scl_current_dpd
                ,'scl_history_max_dpd',t7.scl_history_max_dpd
                ,'scl_history_max_dpd_30d',t7.scl_history_max_dpd_30d
                ,'scl_history_max_dpd_90d',t7.scl_history_max_dpd_90d
                ,'scl_history_max_dpd_180d',t7.scl_history_max_dpd_180d
            )
        ) as extend_info
        ,'${grass_region}' as grass_region
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
    where   grass_region = '${grass_region}'
      and   grass_date = '${grass_date}'
) t1
--spl profile--
left join (
    select  cast(t1.platform_user_id as string) as userid
            ,cast(t1.credit_user_id as string) as spl_user_id
            ,to_date(t2.first_activation_time) as spl_activate_date
            ,1 as is_spl
    from    credit_mart.wide_spl_${region}_behavior_user_df t1 
    left join ( 
        select platform_user_id ,first_activation_time,grass_date
        from credit_uc.dws_all_prod_${grass_region}_uc_user_df 
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
    from    credit_mart.wide_bcl_${person_table_region}_behavior_user_df t1 
   left join ( 
        select platform_user_id ,first_activation_time ,grass_date
        from credit_uc.dws_all_prod_${region}_uc_user_df 
        where grass_date = '${grass_date}'
        and product_id = 1 
        ) t2 on t1.platform_user_id = t2.platform_user_id and t1.grass_date = t2.grass_date
    where   t1.grass_date = '${grass_date}'
    -- sg 没有这张表
    and '${person_table_region}' = '${region}'
) t3
on t1.userid = t3.userid
--scl profile--
left join (
    select  cast(t1.platform_user_id as string) as userid
            ,cast(t1.credit_user_id as string) as scl_user_id
            ,to_date(t2.first_activation_time) as scl_activate_date
            ,1 as is_scl
    from    credit_mart.wide_scl_${person_table_region}_behavior_user_df t1
        left join ( 
        select platform_user_id ,first_activation_time ,grass_date
        from credit_uc.dws_all_prod_${region}_uc_user_df 
        where grass_date = '${grass_date}'
        and product_id = 2 
        ) t2 on t1.platform_user_id = t2.platform_user_id and t1.grass_date = t2.grass_date
    where   t1.grass_date = '${grass_date}'
    -- sg 没有这张表
    and '${person_table_region}' = '${region}'
) t4
on t1.userid = t4.userid
--spl dpd--
left join (
    select  cast(platform_user_id as string) as userid
            ,current_max_dpd as spl_current_dpd
            ,historical_max_dpd as spl_history_max_dpd
            ,ever_max_dpd_30d as spl_history_max_dpd_30d
            ,ever_max_dpd_90d as spl_history_max_dpd_90d
            ,ever_max_dpd_180d as spl_history_max_dpd_180d
    from    credit_mart.dws_spl_${region}_user_df
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
    from    credit_mart.dws_bcl_${person_table_region}_user_df
    where   grass_date = '${grass_date}'
    -- sg 没有这张表
    and '${person_table_region}' = '${region}'
) t6
on t1.userid = t6.userid
--scl dpd--
left join (
    select  cast(platform_user_id as string) as userid
            ,current_max_dpd as scl_current_dpd
            ,historical_max_dpd as scl_history_max_dpd
            ,ever_max_dpd_30d as scl_history_max_dpd_30d
            ,ever_max_dpd_90d as scl_history_max_dpd_90d
            ,ever_max_dpd_180d as scl_history_max_dpd_180d
    from    credit_mart.dws_scl_${person_table_region}_user_df
    where   grass_date = '${grass_date}'
    -- sg 没有这张表
    and '${person_table_region}' = '${region}'
) t7
on t1.userid = t7.userid
--spl fpd--
left join (
    select  userid
            ,max(max_dpd) as spl_fpd
    from    (
        select  cast(platform_user_id as string) as userid
                ,max_dpd
                ,row_number() over (partition by platform_user_id order by month_due_time) as rank
        from    credit_mart.dws_spl_${region}_instalment_repayment_df
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
        from    credit_mart.dws_bcl_${person_table_region}_instalment_repayment_df
        where   grass_date = '${grass_date}'
          and   total_amount_repayable > 0
          -- sg 没有这张表
        and '${person_table_region}' = '${region}'
    )
    where   rank = 1
    group by userid
) t9
on t1.userid = t9.userid
--scl fpd--
left join (
    select  userid
            ,max(max_dpd) as scl_fpd
    from    (
        select  cast(platform_user_id as string) as userid
                ,max_dpd
                ,row_number() over (partition by platform_user_id order by month_due_time) as rank
        from    credit_mart.dws_scl_${person_table_region}_instalment_repayment_df
        where   grass_date = '${grass_date}'
          and   total_amount_repayable > 0
          -- sg 没有这张表
          and '${person_table_region}' = '${region}'
    )
    where   rank = 1
    group by userid
) t10
on t1.userid = t10.userid
--shop profile--
left join (
    select  user_id as userid
            ,shop_name
    from    mp_user.dim_shop__reg_s0_live
    where   grass_region = '${grass_region}'
      and   grass_date = '${grass_date}'
) t11
on t1.userid = t11.userid
;