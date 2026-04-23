--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-24
-- Theme Domain：       platform_user_id matching bill and delivery address
-- Description:         jira: https://jira.shopee.io/browse/SPFDT-42138
-- Data Granularity:    platform_user_id
-- 变更历史：
--********************************************************************--
-- ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
-- drop temporary function if exists json_to_array;
-- create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

-- -- Biller’s Zip code passed by DP
-- create or replace temporary view biller_final_result as
-- select
-- flow_no
-- ,app_id
-- ,scene_id
-- ,platform_user_id
-- ,get_json_object(extension, '$.ItemInfoList[0].CategoryId') cat_id
-- ,cast(get_json_object(extension,'$.ItemInfoList[0].Details') as string) details
-- ,final_result
-- from risk.dwd_risk_th_strategy_final_result_merge_di
-- where topic_name in ('th_live_credit_risk_gateway_req_rsp_kredit')
--     and risk_scene_id in ('10024')
--     and length(platform_user_id)<15
--     and platform_user_id is not null
--     and platform_user_id != ''
-- and grass_date >= '2024-07-01'
-- ;

-- create or replace temporary view biller_bill_zipcode  as
-- select 
-- t1.flow_no
-- ,t1.platform_user_id
-- ,substr(replace(get_json_object(tbl.details_json,'$.address'),' ',''),-5) as bill_zipcode
-- from biller_final_result t1
-- lateral view explode(json_to_array(t1.details)) tbl as details_json 
-- where cat_id = '20103'
-- ;

-- Zip codes from payer’s completed orders’ receive addresses
create or replace temporary view buyer_shipping_address_zipcode_tab  as
select 
buyer_id                         as platform_user_id
,buyer_shipping_address_zipcode
from mp_order.dwd_order_all_ent_df__reg_s1_live
where grass_region='TH'
and tz_type='local'
-- and date(grass_date) >= date'2024-06-01'
and payment_method_id != 24 -- spl
and order_be_status = 'ESCROW_PAID'
group by 1,2
;
insert overwrite table risk.ads_risk_th_buyer_shipping_address_zipcode_df partition(grass_date='${grass_date}')
select 
platform_user_id
,replace(buyer_shipping_address_zipcode,' ','') as buyer_shipping_address_zipcode
from(
select 
t1.platform_user_id 
,cast(collect_set(t1.buyer_shipping_address_zipcode) as string) as buyer_shipping_address_zipcode
from buyer_shipping_address_zipcode_tab t1
where nvl(t1.buyer_shipping_address_zipcode,'') !=''
group by t1.platform_user_id 
) t1 
;