drop view if exists ${SCHEMA}.ads_risk_ph_graph_vertex_info_df_view;
create view IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_info_df_view as 
select 
vertex_value
,hash_vertex_value
,get_json_object(extend_info,'$.userid')              as userid
,get_json_object(extend_info,'$.device')              as device
,get_json_object(extend_info,'$.create_date')         as create_date
,get_json_object(extend_info,'$.rank')                as rank
,get_json_object(extend_info,'$.daily_event_cnt')     as daily_event_cnt
,get_json_object(extend_info,'$.device_type')         as device_type
,get_json_object(extend_info,'$.ctime')               as ctime
,get_json_object(extend_info,'$.full_account')        as full_account
,get_json_object(extend_info,'$.account_number')      as account_number
,get_json_object(extend_info,'$.account_name')        as account_name
,get_json_object(extend_info,'$.bank_name_id')        as bank_name_id
,get_json_object(extend_info,'$.bank_name')           as bank_name
,get_json_object(extend_info,'$.status')              as status
,get_json_object(extend_info,'$.email')               as email
,get_json_object(extend_info,'$.phone')               as phone
,get_json_object(extend_info,'$.relation')            as relation
,get_json_object(extend_info,'$.credit_card')         as credit_card
,get_json_object(extend_info,'$.card_number')         as card_number
,get_json_object(extend_info,'$.expiry_date')         as expiry_date
,get_json_object(extend_info,'$.full_address')        as full_address
,get_json_object(extend_info,'$.address')             as address
,get_json_object(extend_info,'$.town')                as town
,get_json_object(extend_info,'$.district')            as district
,get_json_object(extend_info,'$.city')                as city
,get_json_object(extend_info,'$.state')               as state
,get_json_object(extend_info,'$.zipcode')             as zipcode
,get_json_object(extend_info,'$.address_phone')       as address_phone
,get_json_object(extend_info,'$.category_id')       as category_id
,'PH' as grass_region    
,vertex_name
,grass_date
from ${SCHEMA}.ads_risk_ph_graph_vertex_info_df
;