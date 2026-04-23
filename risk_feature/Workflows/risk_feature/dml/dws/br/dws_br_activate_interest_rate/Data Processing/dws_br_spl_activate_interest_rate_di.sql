-- =============================================================================
-- Author:              siyuan.sun@shopee.com 
-- Created Time:        2026-03-03
-- Theme Domain:        BR Offline Feature Requests 
-- Data Granularity:    
-- Description:         目前对应的risk feature特征 - 上游表credit_mart只保留了1年的分区，但是业务需求是想要全量用户，所以需要backfill历史分区。
-- Documents:           https://docs.google.com/spreadsheets/d/10ECrH99eEe4T4u_DREPevibN58f0DmDAc5JLnPSBsoI/edit?gid=170680832#gid=170680832 
-- =============================================================================

-- drop table if exists risk_feature.activate_interest_rate_di;

create external table if not exists risk_feature.dws_risk_${table_region}_${table_product}_activate_interest_rate_di (
    credit_user_id  string comment 'Credit User ID', 
    platform_user_id string comment 'Platform User ID', 
    biz_type bigint comment 'credit mart biz_type', 
    activate_interest_rate_1m decimal(30,10) comment 'Interest rate for 1 month tenure at latest activation',
    activate_interest_rate_2m decimal(30,10) comment 'Interest rate for 2 month tenure at latest activation',
    activate_interest_rate_3m decimal(30,10) comment 'Interest rate for 3 month tenure at latest activation',
    activate_interest_rate_6m decimal(30,10) comment 'Interest rate for 6 month tenure at latest activation',
    activate_interest_rate_9m decimal(30,10) comment 'Interest rate for 9 month tenure at latest activation',
    activate_interest_rate_12m decimal(30,10) comment 'Interest rate for 12 month tenure at latest activation',
    activate_interest_rate_18m decimal(30,10) comment 'Interest rate for 18 month tenure at latest activation',
    activate_interest_rate_24m decimal(30,10) comment 'Interest rate for 24 month tenure at latest activation',
    activate_common_credit_limit decimal(30,10) comment 'Common credit limit at latest activation',
    activate_campaign_credit_limit decimal(30,10) comment 'Campaign credit limit at latest activation',
    activate_temp_credit_limit decimal(30,10) comment 'Temporary credit limit at latest activation'
)
partitioned by (
    product_id bigint comment 'credit mart product id'
    ,grass_date string comment 'Partition Date'
)
stored as orc 
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)

location '${HDFS_PATH}/risk_feature/ads/dws_risk_${table_region}_${table_product}_activate_interest_rate_di/grass_region=${REGION}';
-- repair table to register partitions
-- msck repair table risk_feature.activate_interest_rate_di;

insert overwrite table risk_feature.dws_risk_${table_region}_${table_product}_activate_interest_rate_di  partition (product_id, grass_date)

select
    t1.credit_user_id
    ,t1.platform_user_id
    ,t1.biz_type
    -- interest rate mapping
    ,IF(array_position(t2.${first_type}_perm_tenures, 1) > 0, t2.${first_type}_perm_interest_rates[array_position(t2.${first_type}_perm_tenures, 1) - 1], null) as activate_interest_rate_1m -- spl + 1m -> bnpl，会取不同的perm_tenures
    ,IF(array_position(t2.${other_type}_perm_tenures, 2) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 2) - 1], null) as activate_interest_rate_2m
    ,IF(array_position(t2.${other_type}_perm_tenures, 3) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 3) - 1], null) as activate_interest_rate_3m
    ,IF(array_position(t2.${other_type}_perm_tenures, 6) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 6) - 1], null) as activate_interest_rate_6m
    ,IF(array_position(t2.${other_type}_perm_tenures, 9) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 9) - 1], null) as activate_interest_rate_9m
    ,IF(array_position(t2.${other_type}_perm_tenures, 12) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 12) - 1], null) as activate_interest_rate_12m
    ,IF(array_position(t2.${other_type}_perm_tenures, 18) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 18) - 1], null) as activate_interest_rate_18m
    ,IF(array_position(t2.${other_type}_perm_tenures, 24) > 0, t2.${other_type}_perm_interest_rates[array_position(t2.${other_type}_perm_tenures, 24) - 1], null) as activate_interest_rate_24m
    -- credit limits
    ,t2.common_perm_credit_limit + t2.common_temp_credit_limit      as activate_common_credit_limit 
    ,t2.campaign_temp_credit_limit                                  as activate_campaign_credit_limit 
    ,t2.common_temp_credit_limit + t2.campaign_temp_credit_limit    as activate_temp_credit_limit 
    
    ,t1.product_id
    ,'${ds}'                                                        as grass_date 
from (
    select  credit_user_id,
            platform_user_id,
            biz_type,
            product_id
    from credit_mart.dwd_${table_product}_aio_${table_region}_account_df
    where biz_type in (${product_id})
    and grass_date = '${ds}' 
    and substr(activate_time, 1, 10) = '${ds}' 
) t1
left join (
    select *
    from credit_mart.dws_${table_product}_aio_${table_region}_account_df 
    where grass_date = '${ds}' 
    and  biz_type in (${product_id}) 
)t2 on t1.credit_user_id  = t2.credit_user_id 
    and t1.biz_type     = t2.biz_type
    and t1.product_id   = t2.product_id
; 