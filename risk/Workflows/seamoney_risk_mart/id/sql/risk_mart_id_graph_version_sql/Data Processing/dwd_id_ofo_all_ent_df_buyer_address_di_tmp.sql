------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-19
-- Description:         Risk Graph需求，ofo物流买家、买家数据解析，落di表
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-54938
-- version:
--          2025.9.18  mp_user.dwd_account_audit_changelog_di__reg_s1_live表数据量很小，ID地区全量数据20G，不需要做增量逻辑
------------------------------------------------------------------------


--DROP TABLE IF EXISTS ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp
(
    buyer_userid string comment 'buyer_userid',
    seller_userid string comment 'seller_userid',
    buyer_shipping_address_id bigint comment 'buyer_shipping_address_id',
    buyer_address string comment 'buyer_address',
    seller_address string comment 'seller_address',
    buyer_town string comment 'buyer_town',
    seller_town string comment 'seller_town',
    buyer_district string comment 'buyer_district',
    seller_district string comment 'seller_district',
    buyer_city string comment 'buyer_city',
    seller_city string comment 'seller_city',
    buyer_state string comment 'buyer_state',
    seller_state string comment 'seller_state',
    buyer_zipcode string comment 'buyer_zipcode',
    seller_zipcode string comment 'seller_zipcode',
    buyer_phone string comment 'buyer_phone',
    seller_phone string comment 'seller_phone',
    is_dropshipping_info_enabled int comment 'is_dropshipping_info_enabled',
    is_cb_seller int comment 'is_cb_seller'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dwd_ofo_all_ent_df_buyer_address_di_tmp/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp;

create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';


insert overwrite table ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp partition(grass_date)
select  buyer_id as buyer_userid
    ,GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.userid') as seller_userid
    ,buyer_shipping_address_id
    ,trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.address'),''), '[^a-zA-Z0-9]+', ' '))) as buyer_address
    ,trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.address'),''), '[^a-zA-Z0-9]+', ' '))) as seller_address
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.town'),'')               as buyer_town
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.town') ,'')             as seller_town
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.district') ,'')          as buyer_district
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.district')  ,'')        as seller_district
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.city') ,'')              as buyer_city
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.city')  ,'')            as seller_city
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.state') ,'')             as buyer_state
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.state') ,'')            as seller_state
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.zipcode') ,'')           as buyer_zipcode
    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.zipcode') ,'')          as seller_zipcode
    ,phone_number_parse(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.phone'), ''), '${grass_region}')  as buyer_phone
    ,phone_number_parse(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.phone'), ''), '${grass_region}') as seller_phone
    ,cast (GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int) as is_dropshipping_info_enabled
    ,is_cb_seller
    ,date_format(create_datetime, 'yyyy-MM-dd') as grass_date
from    mp_order.dwd_ofo_all_ent_df__reg_live
where   grass_region = '${grass_region}'
and     date_format(create_datetime, 'yyyy-MM-dd') = '${grass_date}'
;