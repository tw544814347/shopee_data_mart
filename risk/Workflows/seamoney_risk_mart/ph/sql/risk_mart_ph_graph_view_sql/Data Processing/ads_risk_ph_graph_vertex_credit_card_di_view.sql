
drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_credit_card_di_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_credit_card_di_view as 
select 
vertex
,hash_vertex
,credit_card
,card_number
,expiry_date
,status
,grass_region
,vertex_name
,grass_date
from (
select 
vertex_value                                                                as vertex
,cast(hash_vertex_value as bigint)                                          as hash_vertex
,get_json_object(extend_info,'$.credit_card')                               as credit_card
,get_json_object(extend_info,'$.card_number')                               as card_number
,get_json_object(extend_info,'$.expiry_date')                               as expiry_date
,get_json_object(extend_info,'$.status')                               as status
,'PH'                                                                       as grass_region
,vertex_name                                                                as vertex_name
,grass_date                                                                 as grass_date
,row_number() over(partition by vertex_value,hash_vertex_value order by create_date desc ) as rn 
from ${SCHEMA}.ads_risk_ph_graph_vertex_info_di
where grass_date='${grass_date}'
and vertex_name='credit_card'
) a 
where rn =1 
;