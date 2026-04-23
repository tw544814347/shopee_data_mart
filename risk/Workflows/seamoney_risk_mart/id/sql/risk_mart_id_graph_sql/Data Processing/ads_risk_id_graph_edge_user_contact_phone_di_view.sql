drop view if exists ${SCHEMA}.ads_risk_${region}_graph_edge_user_contact_phone_di_view; 
create view IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_graph_edge_user_contact_phone_di_view as 
select 
platform_user_id                                                            as src_vertex   
,cast(hash_platform_user_id as bigint)                                      as hash_src_vertex
,destination_node                                                           as dst_vertex
,cast(hash_destination_node as bigint)                                      as hash_dst_vertex
,create_date                                                                as create_date
,last_date                                                                  as last_date
-- contact_phone
,get_json_object(extend_info,'$.userid')                                    as userid
,get_json_object(extend_info,'$.phone')                                     as phone
,get_json_object(extend_info,'$.name')                                      as name
,'${grass_region}'                                                          as grass_region
,edge_name                                                                  as edge_name
,grass_date                                                                 as grass_date
from ${SCHEMA}.dws_risk_graph_edge_user_contact_phone_di
where grass_region = '${grass_region}'
and grass_date='${grass_date}'
;

