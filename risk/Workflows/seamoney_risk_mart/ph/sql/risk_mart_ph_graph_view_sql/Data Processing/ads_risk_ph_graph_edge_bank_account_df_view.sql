
drop view if exists ${SCHEMA}.ads_risk_ph_graph_edge_bank_account_df_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_edge_bank_account_df_view as 
select 
platform_user_id                                                            as src_vertex   
,cast(hash_platform_user_id as bigint)                                      as hash_src_vertex
,destination_node                                                           as dst_vertex
,cast(hash_destination_node as bigint)                                      as hash_dst_vertex
,cast(create_date as date)                                                  as create_date
,cast(last_date as date)                                                    as last_date
,get_json_object(extend_info,'$.userid')                                    as userid
,get_json_object(extend_info,'$.full_account')                              as full_account
,get_json_object(extend_info,'$.account_number')                            as account_number
,get_json_object(extend_info,'$.account_name')                              as account_name
,cast(get_json_object(extend_info,'$.bank_name_id') as int)                 as bank_name_id
,get_json_object(extend_info,'$.bank_name')                                 as bank_name
,cast(get_json_object(extend_info,'$.status') as int)                       as status
,cast(get_json_object(extend_info,'$.is_seller_withdrawal_account') as int) as is_seller_withdrawal_account
,'PH'                                                                       as grass_region
,edge_name                                                                  as edge_name
,grass_date                                                                 as grass_date
from ${SCHEMA}.ads_risk_ph_graph_edge_user_info_df
where grass_date='${grass_date}'
and edge_name='bank_account'
;