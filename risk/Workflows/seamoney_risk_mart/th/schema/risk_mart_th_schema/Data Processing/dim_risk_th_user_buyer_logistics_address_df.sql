--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2024-01-19T14:00:00
-- Description:         DIM Layer | User Domain | Marketplace Buyer物流订单地址表 DDL
-- PRD                  https://docs.google.com/document/d/1JN0u5KCp-4f6SxsORzm53R2-T0GmFRebkpTMDYBSkBM/edit
-- Jira                 https://jira.shopee.io/browse/SPFDT-30368
--********************************************************************--

drop table if exists ${SCHEMA}.dim_risk_${region}_user_buyer_logistics_address_df;
create external table if not exists ${SCHEMA}.dim_risk_${region}_user_buyer_logistics_address_df
(
    buyer_id	        bigint  comment 'buyer id, same as platform user id.'
    ,address            string  comment 'buyer shipping address.'
    ,state              string  comment 'buyer shipping address state.'
    ,city               string  comment 'buyer shipping address city.'
    ,town               string  comment 'buyer shipping address town.'
    ,district           string  comment 'buyer shipping address district.'
    ,zipcode            string  comment 'buyer shipping address zipcode.'
)   
comment 'the address user configured'
partitioned by
(
    grass_date     string          comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_user_buyer_logistics_address_df/grass_reion=${REGION}';
msck repair table ${SCHEMA}.dim_risk_${region}_user_buyer_logistics_address_df;
