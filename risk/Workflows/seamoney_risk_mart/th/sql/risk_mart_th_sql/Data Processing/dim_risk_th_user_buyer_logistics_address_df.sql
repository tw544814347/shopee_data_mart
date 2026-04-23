--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2024-01-19T14:00:00
-- Description:         DIM Layer | User Domain | Marketplace Buyer物流订单地址表 DML
-- PRD                  https://docs.google.com/document/d/1JN0u5KCp-4f6SxsORzm53R2-T0GmFRebkpTMDYBSkBM/edit
-- Jira                 https://jira.shopee.io/browse/SPFDT-30368
--********************************************************************--

insert overwrite ${SCHEMA}.dim_risk_${region}_user_buyer_logistics_address_df PARTITION (grass_date='${grass_date}')
select  buyer_id
        ,trim(REPLACE(REPLACE(buyer_shipping_address, CHAR(160), ''), CHAR(9), ''))                               as buyer_shipping_address
        ,trim(REPLACE(REPLACE(buyer_shipping_address_state, CHAR(160), ''), CHAR(9), ''))                         as buyer_shipping_address_state
        ,trim(REPLACE(REPLACE(buyer_shipping_address_city, CHAR(160), ''), CHAR(9), ''))                          as buyer_shipping_address_city
        ,trim(REPLACE(REPLACE(buyer_shipping_address_town, CHAR(160), ''), CHAR(9), ''))                          as buyer_shipping_address_town
        ,trim(REPLACE(REPLACE(buyer_shipping_address_district, CHAR(160), ''), CHAR(9), ''))                      as buyer_shipping_address_district
        ,trim(REPLACE(REPLACE(buyer_shipping_address_zip_code, CHAR(160), ''), CHAR(9), ''))                      as buyer_shipping_address_zip_code
from (
  select  buyer_id
          ,buyer_shipping_address
          ,buyer_shipping_address_state
          ,buyer_shipping_address_city
          ,buyer_shipping_address_town
          ,buyer_shipping_address_district
          ,buyer_shipping_address_zip_code
  from mp_order.dwd_ofo_all_ent_df__reg_live
  where grass_region = '${REGION}'
--     and grass_date >= date('${grass_date}')
)
group by 1,2,3,4,5,6,7
;