

drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_user_df_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_user_df_view as 
select 
    vertex
    ,hash_vertex
    ,userid
    ,user_name
    ,shop_id
    ,is_seller
    ,shop_name
    ,status
    ,registration_date
    ,registration_timestamp
    ,user_id
    ,spl_activate_date
    ,is_spl
    ,spl_fpd
    ,spl_current_dpd
    ,spl_history_max_dpd
    ,spl_history_max_dpd_30d
    ,spl_history_max_dpd_90d
    ,spl_history_max_dpd_180d
    ,bcl_activate_date
    ,is_bcl
    ,bcl_fpd
    ,bcl_current_dpd
    ,bcl_history_max_dpd
    ,bcl_history_max_dpd_30d
    ,bcl_history_max_dpd_90d
    ,bcl_history_max_dpd_180d
    ,scl_activate_date
    ,is_scl
    ,scl_fpd
    ,scl_current_dpd
    ,scl_history_max_dpd
    ,scl_history_max_dpd_30d
    ,scl_history_max_dpd_90d
    ,scl_history_max_dpd_180d
    ,grass_region
    ,grass_date
from (
    select 
    vertex_value                                                                                as vertex
    ,cast(hash_vertex_value as bigint)                                                          as hash_vertex
    ,get_json_object(extend_info,'$.userid')                                                    as userid
    ,get_json_object(extend_info,'$.user_name')                                                 as user_name
    ,get_json_object(extend_info,'$.shop_id')                                                   as shop_id
    ,cast(get_json_object(extend_info,'$.is_seller') as int)                                    as is_seller
    ,cast(get_json_object(extend_info,'$.shop_name') as string)                                    as shop_name
    ,cast(get_json_object(extend_info,'$.status') as int)                                       as status
    ,to_date(get_json_object(extend_info,'$.registration_date'),'yyyy-MM-dd')                   as registration_date
    ,unix_timestamp(from_unixtime(get_json_object(extend_info,'$.registration_timestamp')))     as registration_timestamp
    ,get_json_object(extend_info,'$.user_id')                                                   as user_id
    ,to_date(get_json_object(extend_info,'$.spl_activate_date'),'yyyy-MM-dd')                   as spl_activate_date
    ,cast(get_json_object(extend_info,'$.is_spl') as int)                                       as is_spl
    ,cast(get_json_object(extend_info,'$.spl_fpd') as int)                                      as spl_fpd
    ,cast(get_json_object(extend_info,'$.spl_current_dpd') as int)                              as spl_current_dpd
    ,cast(get_json_object(extend_info,'$.spl_history_max_dpd') as int)                          as spl_history_max_dpd
    ,cast(get_json_object(extend_info,'$.spl_history_max_dpd_30d') as int)                      as spl_history_max_dpd_30d
    ,cast(get_json_object(extend_info,'$.spl_history_max_dpd_90d') as int)                      as spl_history_max_dpd_90d
    ,cast(get_json_object(extend_info,'$.spl_history_max_dpd_180d')as int)                      as spl_history_max_dpd_180d
    ,to_date(get_json_object(extend_info,'$.bcl_activate_date'),'yyyy-MM-dd')                   as bcl_activate_date
    ,cast(get_json_object(extend_info,'$.is_bcl') as int)                                       as is_bcl
    ,cast(get_json_object(extend_info,'$.bcl_fpd') as int)                                      as bcl_fpd
    ,cast(get_json_object(extend_info,'$.bcl_current_dpd') as int)                              as bcl_current_dpd
    ,cast(get_json_object(extend_info,'$.bcl_history_max_dpd') as int)                          as bcl_history_max_dpd
    ,cast(get_json_object(extend_info,'$.bcl_history_max_dpd_30d') as int)                      as bcl_history_max_dpd_30d
    ,cast(get_json_object(extend_info,'$.bcl_history_max_dpd_90d') as int)                      as bcl_history_max_dpd_90d
    ,cast(get_json_object(extend_info,'$.bcl_history_max_dpd_180d') as int)                     as bcl_history_max_dpd_180d
    ,to_date(get_json_object(extend_info,'$.scl_activate_date'),'yyyy-MM-dd')                   as scl_activate_date
    ,cast(get_json_object(extend_info,'$.is_scl') as int)                                       as is_scl
    ,cast(get_json_object(extend_info,'$.scl_fpd') as int)                                      as scl_fpd
    ,cast(get_json_object(extend_info,'$.scl_current_dpd') as int)                              as scl_current_dpd
    ,cast(get_json_object(extend_info,'$.scl_history_max_dpd') as int)                          as scl_history_max_dpd
    ,cast(get_json_object(extend_info,'$.scl_history_max_dpd_30d') as int)                      as scl_history_max_dpd_30d
    ,cast(get_json_object(extend_info,'$.scl_history_max_dpd_90d') as int)                      as scl_history_max_dpd_90d
    ,cast(get_json_object(extend_info,'$.scl_history_max_dpd_180d') as int)                     as scl_history_max_dpd_180d
    ,'${region}'                                                                                as grass_region
    ,grass_date                                                                                 as grass_date
    ,row_number() over(partition by vertex_value,hash_vertex_value order by get_json_object(extend_info,'$.create_date') desc ) as rn 
    from ${SCHEMA}.ads_risk_ph_graph_vertex_user_df
    where grass_date='${grass_date}'
) a 
where rn =1 
;