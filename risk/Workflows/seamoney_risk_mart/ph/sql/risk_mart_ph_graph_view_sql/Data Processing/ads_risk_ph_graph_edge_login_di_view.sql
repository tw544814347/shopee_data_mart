drop view if exists ${SCHEMA}.ads_risk_ph_graph_edge_login_di_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_edge_login_di_view as 
select 
platform_user_id                                                            as src_vertex   
,cast(hash_platform_user_id as bigint)                                      as hash_src_vertex
,destination_node                                                           as dst_vertex
,cast(hash_destination_node as bigint)                                      as hash_dst_vertex
,cast(create_date as date)                                                  as create_date
,cast(last_date as date)                                                    as last_date
,get_json_object(extend_info,'$.userid')                                    as userid
,get_json_object(extend_info,'$.device')                                    as device
,cast(get_json_object(extend_info,'$.event_day_count') as int )             as event_day_count
,cast(get_json_object(extend_info,'$.event_day_count_l3d') as int )             as event_day_count_l3d
,cast(get_json_object(extend_info,'$.event_day_count_l7d') as int )             as event_day_count_l7d
,cast(get_json_object(extend_info,'$.event_day_count_l30d') as int )             as event_day_count_l30d
,cast(get_json_object(extend_info,'$.event_day_count_l90d') as int )             as event_day_count_l90d
,cast(get_json_object(extend_info,'$.event_day_count_l180d') as int )             as event_day_count_l180d
,cast(get_json_object(extend_info,'$.event_day_count_l360d') as int )             as event_day_count_l360d
,cast(get_json_object(extend_info,'$.event_day_count_l720d') as int )             as event_day_count_l720d
,cast(get_json_object(extend_info,'$.device_type') as int)                  as device_type
,'PH'                                                                       as grass_region
,edge_name                                                                  as edge_name
,grass_date                                                                 as grass_date
from ${SCHEMA}.ads_risk_ph_graph_edge_user_info_di
where grass_date='${grass_date}'
and edge_name='login'
;