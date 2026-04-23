
drop view if exists ${SCHEMA}.ads_risk_ph_graph_edge_shopeepay_transfer_df_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_edge_shopeepay_transfer_df_view as 
select 
platform_user_id                                                            as src_vertex   
,cast(hash_platform_user_id as bigint)                                      as hash_src_vertex
,destination_node                                                           as dst_vertex
,cast(hash_destination_node as bigint)                                      as hash_dst_vertex
,cast(create_date as date)                                                  as create_date
,cast(last_date as date)                                                    as last_date
,get_json_object(extend_info,'$.sender_userid')                             as sender_userid
,get_json_object(extend_info,'$.receiver_userid')                           as receiver_userid
,cast(get_json_object(extend_info,'$.event_item_count') as int)             as event_item_count
,cast(get_json_object(extend_info,'$.event_amount')as double)               as event_amount
,'PH'                                                                       as grass_region
,edge_name                                                                  as edge_name
,grass_date                                                                 as grass_date
from ${SCHEMA}.ads_risk_ph_graph_edge_user_info_df
where grass_date='${grass_date}'
and edge_name='shopeepay_transfer'
;