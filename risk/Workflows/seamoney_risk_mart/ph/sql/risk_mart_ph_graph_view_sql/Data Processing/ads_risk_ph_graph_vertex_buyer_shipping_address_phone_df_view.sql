
drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_buyer_shipping_address_phone_df_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_buyer_shipping_address_phone_df_view as 
select 
vertex
,hash_vertex
,address_phone
,address
,town
,district
,city
,state
,zipcode
,phone
,event_count
,event_count_l3d
,event_count_l7d
,event_count_l30d
,event_count_l90d
,event_count_l180d
,event_count_l360d
,event_count_l720d
,grass_region
,vertex_name
,grass_date
from (
select 
vertex_value                                                                as vertex
,cast(hash_vertex_value as bigint)                                          as hash_vertex
,get_json_object(extend_info,'$.address_phone')                             as address_phone
,get_json_object(extend_info,'$.address')                                   as address
,get_json_object(extend_info,'$.town')                                      as town
,get_json_object(extend_info,'$.district')                                  as district
,get_json_object(extend_info,'$.city')                                      as city
,get_json_object(extend_info,'$.state')                                     as state
,get_json_object(extend_info,'$.zipcode')                                   as zipcode
,get_json_object(extend_info,'$.phone')                                     as phone
,cast(get_json_object(extend_info,'$.event_count') as int)                  as event_count
,cast(get_json_object(extend_info,'$.event_count_l3d') as int)              as event_count_l3d
,cast(get_json_object(extend_info,'$.event_count_l7d') as int)              as event_count_l7d
,cast(get_json_object(extend_info,'$.event_count_l30d') as int)             as event_count_l30d
,cast(get_json_object(extend_info,'$.event_count_l90d') as int)             as event_count_l90d
,cast(get_json_object(extend_info,'$.event_count_l180d') as int)            as event_count_l180d
,cast(get_json_object(extend_info,'$.event_count_l360d') as int)            as event_count_l360d
,cast(get_json_object(extend_info,'$.event_count_l720d')  as int)           as event_count_l720d
,'PH'                                                                       as grass_region
,vertex_name                                                                as vertex_name
,grass_date                                                                 as grass_date
,row_number() over(partition by vertex_value,hash_vertex_value order by create_date desc ) as rn 
from ${SCHEMA}.ads_risk_ph_graph_vertex_info_df
where grass_date='${grass_date}'
and vertex_name='address'
) a 
where rn =1 
;