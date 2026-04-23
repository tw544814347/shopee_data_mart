--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-17
-- Theme Domain：        risk graph vertex
-- Description:         
-- Data Granularity:    
-- 变更历史：
--********************************************************************--
drop view if exists ${SCHEMA}.ads_risk_${region}_graph_vertex_info_version_df_view; 
create view IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_graph_vertex_info_version_df_view as 
select 
vertex
,hash_vertex
,userid
,device
,device_type
,full_address
,address
,town
,district
,city
,state
,zipcode
,full_account
,account_number
,account_name
,bank_name_id
,bank_name
,status
,is_seller_withdrawal_account
,email
,phone
,credit_card
,card_number
,expiry_date
,account_no
,category_id
,id_card_no
,address_phone
,'${grass_region}' as grass_region
,version_name
,vertex_name
,grass_date
from (
select 
vertex_value                                                                as vertex
,cast(hash_vertex_value as bigint)                                          as hash_vertex
---- login
,get_json_object(extend_info,'$.userid')                                    as userid
,get_json_object(extend_info,'$.device')                                    as device
,get_json_object(extend_info,'$.device_type')                               as device_type
---- address
,get_json_object(extend_info,'$.full_address')                              as full_address
,get_json_object(extend_info,'$.address')                                   as address
,get_json_object(extend_info,'$.town')                                      as town
,get_json_object(extend_info,'$.district')                                  as district
,get_json_object(extend_info,'$.city')                                      as city
,get_json_object(extend_info,'$.state')                                     as state
,get_json_object(extend_info,'$.zipcode')                                   as zipcode
-- bank_account
,get_json_object(extend_info,'$.full_account')                              as full_account
,get_json_object(extend_info,'$.account_number')                            as account_number
,get_json_object(extend_info,'$.account_name')                              as account_name
,cast(get_json_object(extend_info,'$.bank_name_id') as int)                 as bank_name_id
,get_json_object(extend_info,'$.bank_name')                                 as bank_name
,cast(get_json_object(extend_info,'$.status') as int)                       as status
,cast(get_json_object(extend_info,'$.is_seller_withdrawal_account') as int) as is_seller_withdrawal_account
-- email
,get_json_object(extend_info,'$.email')                                     as email
-- phone
,get_json_object(extend_info,'$.phone')                                     as phone
-- credit_card
,get_json_object(extend_info,'$.credit_card')                               as credit_card
,get_json_object(extend_info,'$.card_number')                               as card_number
,get_json_object(extend_info,'$.expiry_date')                               as expiry_date
-- dp_account_no
,get_json_object(extend_info,'$.account_no')                                as account_no
,cast(get_json_object(extend_info,'$.category_id') as int)                  as category_id
-- kyc 
,get_json_object(extend_info,'$.id_card_no')                                as id_card_no
-- buyer_shipping_address_phone
,get_json_object(extend_info,'$.address_phone')                             as address_phone
,version_name                                                               as version_name
,vertex_name                                                                as vertex_name
,grass_date                                                                 as grass_date
,row_number() over(partition by grass_date,vertex_value,hash_vertex_value order by create_date desc ) as rn 
from ${SCHEMA}.dws_risk_id_graph_vertex_info_version_df
) a 
where rn =1 
;

