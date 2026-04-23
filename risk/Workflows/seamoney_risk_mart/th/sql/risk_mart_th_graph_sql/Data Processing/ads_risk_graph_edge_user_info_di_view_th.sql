--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-08-26
-- Theme Domain：        risk graph vertex
-- Description:         
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-08-26 1. 修改类型 2. 新增注释
--********************************************************************--

drop view if exists ${SCHEMA}.ads_risk_${region}_graph_edge_user_info_di_view; 
create view IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_graph_edge_user_info_di_view as 
select 
platform_user_id                                                            as src_vertex   
,cast(hash_platform_user_id as bigint)                                      as hash_src_vertex
,destination_node                                                           as dst_vertex
,cast(hash_destination_node as bigint)                                      as hash_dst_vertex
,cast(create_date as date)                                                  as create_date
,cast(last_date as date)                                                    as last_date
-- login
,get_json_object(extend_info,'$.userid')                                    as userid
,get_json_object(extend_info,'$.device')                                    as device
,cast(get_json_object(extend_info,'$.event_day_count') as int )             as event_day_count
,cast(get_json_object(extend_info,'$.event_day_count_l3d') as int )         as event_day_count_l3d
,cast(get_json_object(extend_info,'$.event_day_count_l7d') as int )         as event_day_count_l7d
,cast(get_json_object(extend_info,'$.event_day_count_l30d') as int )        as event_day_count_l30d
,cast(get_json_object(extend_info,'$.event_day_count_l90d') as int )        as event_day_count_l90d
,cast(get_json_object(extend_info,'$.event_day_count_l180d') as int )       as event_day_count_l180d
,cast(get_json_object(extend_info,'$.event_day_count_l360d') as int )       as event_day_count_l360d
,cast(get_json_object(extend_info,'$.event_day_count_l720d') as int )       as event_day_count_l720d
,cast(get_json_object(extend_info,'$.device_type') as int)                  as device_type
-- bank_account
,get_json_object(extend_info,'$.full_account')                              as full_account
,get_json_object(extend_info,'$.account_number')                            as account_number
,get_json_object(extend_info,'$.account_name')                              as account_name
,cast(get_json_object(extend_info,'$.bank_name_id') as int)                 as bank_name_id
,get_json_object(extend_info,'$.bank_name')                                 as bank_name
,cast(get_json_object(extend_info,'$.status') as int)                       as status
,cast(get_json_object(extend_info,'$.is_seller_withdrawal_account') as int) as is_seller_withdrawal_account
-- register_email
,get_json_object(extend_info,'$.email')                                     as email
-- register_phone
,get_json_object(extend_info,'$.phone')                                     as phone
-- ec_phone
,cast(get_json_object(extend_info,'$.relation') as int)                     as relation
,get_json_object(extend_info,'$.name')                                      as name
-- buyer_shipping_phone
,cast(get_json_object(extend_info,'$.event_count')       as int)            as event_count
,cast(get_json_object(extend_info,'$.event_count_l3d')   as int)            as event_count_l3d
,cast(get_json_object(extend_info,'$.event_count_l7d')   as int)            as event_count_l7d
,cast(get_json_object(extend_info,'$.event_count_l30d')  as int)            as event_count_l30d
,cast(get_json_object(extend_info,'$.event_count_l90d')  as int)            as event_count_l90d
,cast(get_json_object(extend_info,'$.event_count_l180d') as int)            as event_count_l180d
,cast(get_json_object(extend_info,'$.event_count_l360d') as int)            as event_count_l360d
,cast(get_json_object(extend_info,'$.event_count_l720d') as int)            as event_count_l720d
-- seller_shipping_phone
-- buyer_topup_phone
-- buyer_postpaid_phone
-- credit_card
,get_json_object(extend_info,'$.credit_card')                               as credit_card
,get_json_object(extend_info,'$.card_number')                               as card_number
,get_json_object(extend_info,'$.expiry_date')                               as expiry_date
-- buyer_shipping_address
,get_json_object(extend_info,'$.full_address')                              as full_address
,get_json_object(extend_info,'$.address')                                   as address
,get_json_object(extend_info,'$.town')                                      as town
,get_json_object(extend_info,'$.district')                                  as district
,get_json_object(extend_info,'$.city')                                      as city
,get_json_object(extend_info,'$.state')                                     as state
,get_json_object(extend_info,'$.zipcode')                                   as zipcode
-- seller_shipping_address
-- shopeepay_transfer
,get_json_object(extend_info,'$.sender_userid')                             as sender_userid
,get_json_object(extend_info,'$.receiver_userid')                           as receiver_userid
,cast(get_json_object(extend_info,'$.event_amount') as double)              as event_amount
-- shopee_transfer
,get_json_object(extend_info,'$.buyer_userid')                              as buyer_userid
,get_json_object(extend_info,'$.seller_userid')                             as seller_userid
,cast(get_json_object(extend_info,'$.event_item_count')as int)              as event_item_count


-- dp_acccount_no
,cast(get_json_object(extend_info,'$.category_id')as int)                   as category_id
,get_json_object(extend_info,'$.account_no')                                as account_no
-- kyc
,get_json_object(extend_info,'$.id_card_no')                                as kcy_id_card_no
-- buyer_shipping_address_phone
,get_json_object(extend_info,'$.address_phone')                             as address_phone

,'${grass_region}'                                                          as grass_region
,edge_name                                                                  as edge_name
,grass_date                                                                 as grass_date
from ${SCHEMA}.dws_risk_graph_edge_user_info_di
where grass_region = '${grass_region}'
and grass_date='${grass_date}'
;