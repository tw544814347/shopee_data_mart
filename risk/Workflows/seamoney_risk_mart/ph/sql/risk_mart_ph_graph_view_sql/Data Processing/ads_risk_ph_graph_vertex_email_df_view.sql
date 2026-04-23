
drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_email_df_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_email_df_view as 
select 
vertex
,hash_vertex
,email
,grass_region
,vertex_name
,grass_date
from (
select 
vertex_value                                                                as vertex
,cast(hash_vertex_value as bigint)                                          as hash_vertex
,get_json_object(extend_info,'$.email')                                     as email
,'PH'                                                                       as grass_region
,vertex_name                                                                as vertex_name
,grass_date                                                                 as grass_date
,row_number() over(partition by vertex_value,hash_vertex_value order by create_date desc ) as rn 
from ${SCHEMA}.ads_risk_ph_graph_vertex_info_df
where grass_date='${grass_date}'
and vertex_name='email'
) a 
where rn =1 
;