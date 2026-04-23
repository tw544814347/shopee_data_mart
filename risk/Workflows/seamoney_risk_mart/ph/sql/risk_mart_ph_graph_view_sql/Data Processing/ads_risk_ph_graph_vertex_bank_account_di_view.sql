
drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_bank_account_di_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_bank_account_di_view as 
select 
vertex
,hash_vertex
,full_account
,account_number
,account_name
,bank_name_id
,bank_name
,status
,is_seller_withdrawal_account
,grass_region
,vertex_name
,grass_date
from (
select 
vertex_value                                                                as vertex
,cast(hash_vertex_value as bigint)                                          as hash_vertex
,get_json_object(extend_info,'$.full_account')                              as full_account
,get_json_object(extend_info,'$.account_number')                            as account_number
,get_json_object(extend_info,'$.account_name')                              as account_name
,cast(get_json_object(extend_info,'$.bank_name_id') as int)                 as bank_name_id
,get_json_object(extend_info,'$.bank_name')                                 as bank_name
,get_json_object(extend_info,'$.status')                                 as status
,get_json_object(extend_info,'$.is_seller_withdrawal_account')                                 as is_seller_withdrawal_account
,'PH'                                                                       as grass_region
,vertex_name                                                                as vertex_name
,grass_date                                                                 as grass_date
,row_number() over(partition by vertex_value,hash_vertex_value order by create_date desc ) as rn 
from ${SCHEMA}.ads_risk_ph_graph_vertex_info_di
where grass_date='${grass_date}'
and vertex_name='bank_account'
) a 
where rn =1 
;