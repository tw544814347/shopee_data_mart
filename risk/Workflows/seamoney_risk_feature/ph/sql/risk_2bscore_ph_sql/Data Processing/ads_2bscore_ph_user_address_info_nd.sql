-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-12-15
-- Theme Domain:        User Address Info
-- Data Granularity:    
-- Description:         PH user shipping address information aggregated by order
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-12-15 - chengguo.liu - 初始化
-- =============================================================================

--DROP TABLE IF EXISTS ${SCHEMA}.ads_2bscore_ph_user_address_info_nd;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_ph_user_address_info_nd
(
    user_id             string comment 'shopee user id'
    ,shipping_phone     string comment 'shipping phone number from order'
    ,normalized_phone   string comment 'normalized phone number'
    ,address            string comment 'shipping address detail'
    ,state              string comment 'shipping address state'
    ,city               string comment 'shipping address city'
    ,district           string comment 'shipping address district'
    ,town               string comment 'shipping address town'
    ,zipcode            string comment 'shipping address zipcode'    
    ,order_cnt          bigint comment 'order count for this address'
    ,is_self_addr       int comment 'flag if address phone matches user phone: 1=match, 0=not match'
)
comment 'risk feature summary table'
PARTITIONED BY
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2bscore_user_address_info_nd/grass_region=PH';
--MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_ph_user_address_info_nd;


add JAR hdfs://R2/projects/risk/hdfs/udf/phone_normalizer_udf.jar;
create or replace temporary function phone_normalizer_udf as 'com.shopee.udf.PhoneNormalizerUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/phone_normalizer_udf.jar';


insert overwrite table ${SCHEMA}.ads_2bscore_ph_user_address_info_nd partition (grass_date = '${ds}')
select
    t1.user_id
    ,t1.shipping_phone
    ,t1.normalized_phone
    ,t1.address
    ,t1.state
    ,t1.city
    ,t1.district
    ,t1.town
    ,t1.zipcode
    ,t1.order_cnt
    ,case
        when t2.normalized_phone is not null and t1.normalized_phone = t2.normalized_phone then 1
        else 0
    end as is_self_addr
from
    (
        select
            cast(buyer_id as string) as user_id
            ,GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.phone') as shipping_phone
            ,phone_normalizer_udf (
                GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.phone')
                ,'PH'
            ) as normalized_phone
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.address'),'') as address
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.state'),'') as state
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.city'),'') as city
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.district'),'') as district
            ,coalesce(GET_JSON_OBJECT (extinfo,'$.logistics_info.buyer_address.town'),'') as town
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.zipcode'),'') as zipcode
            ,count(1) as order_cnt
        from mp_order.dwd_ofo_all_ent_df__reg_live
        where
            tz_type = 'local'
            and grass_region = 'PH'
            and grass_date >= date('${ds}') - interval '${offset}' day
            and grass_date <= date('${ds}')
            and logistics_status_id = 5
        group by 1, 2, 3, 4, 5, 6, 7, 8, 9
    ) as t1
    left join (
        select
            user_id
            ,phone_number as phone
            ,phone_normalizer_udf (phone_number, 'PH') as normalized_phone
        from mp_user.dim_user__reg_s1_live
        where
            tz_type = 'local'
            and grass_region = 'PH'
            and grass_date = '${ds}'
    ) as t2 on t1.user_id = t2.user_id
;