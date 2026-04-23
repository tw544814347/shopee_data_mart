
drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_device_szdf_di_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_device_szdf_di_view as 
select 
vertex
,hash_vertex
,device
,event_day_count
,event_day_count_l3d
,event_day_count_l7d
,event_day_count_l30d
,event_day_count_l90d
,event_day_count_l180d
,event_day_count_l360d
,event_day_count_l720d
,device_type
,grass_region
,vertex_name
,grass_date
from (
select 
vertex_value                                                                as vertex
,cast(hash_vertex_value as bigint)                                          as hash_vertex
,get_json_object(extend_info,'$.device')                                    as device
,get_json_object(extend_info,'$.event_day_count')                                    as event_day_count
,get_json_object(extend_info,'$.event_day_count_l3d')                                    as event_day_count_l3d
,get_json_object(extend_info,'$.event_day_count_l7d')                                    as event_day_count_l7d
,get_json_object(extend_info,'$.event_day_count_l30d')                                    as event_day_count_l30d
,get_json_object(extend_info,'$.event_day_count_l90d')                                    as event_day_count_l90d
,get_json_object(extend_info,'$.event_day_count_l180d')                                    as event_day_count_l180d
,get_json_object(extend_info,'$.event_day_count_l360d')                                    as event_day_count_l360d
,get_json_object(extend_info,'$.event_day_count_l720d')                                    as event_day_count_l720d
,get_json_object(extend_info,'$.device_type')                                    as device_type
,'PH'                                                                       as grass_region
,vertex_name                                                                as vertex_name
,grass_date                                                                 as grass_date
,row_number() over(partition by vertex_value,hash_vertex_value order by create_date desc ) as rn 
from ${SCHEMA}.ads_risk_ph_graph_vertex_info_di
where grass_date='${grass_date}'
and vertex_name='device_szdf'
) a 
where rn =1 
;