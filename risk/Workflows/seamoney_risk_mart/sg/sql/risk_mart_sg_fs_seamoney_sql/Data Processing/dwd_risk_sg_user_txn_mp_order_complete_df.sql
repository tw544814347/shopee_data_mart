--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-11
-- Theme Domain：       mp order 
-- Description:         risk mp order, https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit#gid=400549880
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee 2024-10-30 新增字段 payment_method_id,has_return_item,is_net_order,payment_channel
--********************************************************************--
-- drop table if exists ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df
(
platform_user_id                   string               comment 'platform_user_id'   
,order_id                          bigint               comment 'order_id'
,gmv                               bigint               comment 'gmv'
,gmv_usd                           bigint               comment 'gmv_usd'
,shop_id                           bigint               comment 'shop_id'
,checkout_id                       bigint               comment 'checkout_id'
,payment_be_channel                string               comment 'payment_be_channel'  
,order_be_status_id                bigint               comment 'order_be_status_id "4 → completed, 11 → escrow paid, 12 → escrow created, 13 → escrow pending, 14 → escrow verified, 15 → escrow payout"'  
,buyer_shipping_address_district   string               comment 'property@buyer shipping district'  
,shipping_confirm_timestamp        bigint               comment 'property@shipping confirm timestamp. For cash on delivery (COD) order: time when the order is placed. For non-COD order: time when the order is paid' 
,shipping_confirm_time_local       string               comment 'property@shipping confirm timestamp. For cash on delivery (COD) order: time when the order is placed. For non-COD order: time when the order is paid'  
,is_bi_excluded                    bigint               comment 'tag@is_bi excluded'  
,payment_method_id                 bigint               comment 'property@payment method id, this is roughly detail of backend payment channel; refer: dim_payment_method for enum value'
,has_return_item                   tinyint              comment 'tag@whether has any item been returned'
,is_net_order                      tinyint              comment 'tag@Whether the order is a net order, this is calculated based on the order, refer to user guide for more details(https://docs.google.com/document/d/1NkpDYLikLCRliJubXTbK3GXpLxa-0-G03Ud5OaX0rWI/edit#heading=h.b8cth4bt3s42), starts from 2020-01-01'
,payment_channel                   string               comment 'property@payment channel name, this is same thing with backend payment channel. But it is alias'
,payment_be_channel_id             bigint               comment 'property@backend payment channel id, it has 1-1 mapping with spm_channel_id and options. For example, shopee pay later will have 3,6 and 9 months installment. Each installment has same spm_channel_id, but has different backend payment channel id. refer:dim_payment_channel__reg_live for enum value'
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_user_txn_mp_order_complete_df/garss_region=${upper_region}';
--msck repair table ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df;

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df partition(grass_date)
select 
t1.buyer_id                                                    as platform_user_id
,t1.order_id                                                   as order_id
,t1.gmv                                                        as gmv
,t1.gmv_usd                                                    as gmv_usd
,t1.shop_id                                                    as shop_id
,t1.checkout_id                                                as checkout_id
,t1.payment_be_channel                                         as payment_be_channel
,t1.order_be_status_id                                         as order_be_status_id
,t1.buyer_shipping_address_district                            as buyer_shipping_address_district
,t1.shipping_confirm_timestamp                                 as shipping_confirm_timestamp
,format_time(t1.shipping_confirm_timestamp,upper('${region}')) as shipping_confirm_time_local
,t1.is_bi_excluded                                             as is_bi_excluded
,t1.payment_method_id                                          as payment_method_id 
,t1.has_return_item                                            as has_return_item     
,t1.is_net_order                                               as is_net_order  
,t1.payment_channel                                            as payment_channel  
,t1.payment_be_channel_id                                      as payment_be_channel_id  
,'${grass_date}'                                               as grass_date 
from mp_order.dwd_order_all_ent_df__${region}_s0_live t1 
where tz_type = 'local'   
and grass_date >= date_sub('${grass_date}', 365) 
and order_be_status_id in (4, 11, 12, 13, 14, 15)
;
