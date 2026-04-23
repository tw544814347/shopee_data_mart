--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-01-21
-- Theme Domain：       risk graph promotion feature
-- Description:         
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-57942
-- 变更历史：
--  2026-01-21 wei.tao@shopee.com 部署成模版 
--  2026-02-12 wei.tao 新增3 类 promotion type 对应的 list 
    /*补充 
        mission_task_id - list_mission_task_id_non_transactional
        daily_checkin_id - list_daily_checkin_id_non_transactional
        campaign_id_non_transactional - list_campaign_id_non_transactional_nui
    */
--********************************************************************--


-- drop table if exists ${SCHEMA}.ads_risk_${region}_graph_spp_af_policy_promo_df;
create external table if not exists ${SCHEMA}.ads_risk_${region}_graph_spp_af_policy_promo_df
(          
    rowkey	        string
    ,qf	            string
) partitioned by(
    grass_region    string
    ,grass_date     string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
location '${HDFS_PATH}/risk_feature/dws/ads_risk_${region}_graph_spp_af_policy_promo_df'
;
WITH middle_table AS (
    SELECT 
        platform_user_id,
        shopeepay_user_id,
        spp_registration_date,
        list_campaign_id_transactional_campaign,
        list_voucher_template_id_transactional_voucher,
        list_referral_promotion_id_non_transactional,
        list_reward_package_id_non_transactional_reward_package,
        list_mission_task_id_non_transactional,
        list_daily_checkin_id_non_transactional,
        list_campaign_id_non_transactional_nui,
        community_id,
        sp_fraud_tag_monitor,
        sp_fraud_tag_confirmed
    FROM rescbds_credit.ds_graph_spp_af_policy_promo_middle_table
    WHERE grass_date = (select max(grass_date) from rescbds_credit.ds_graph_spp_af_policy_promo_middle_table where grass_region = '${grass_region}') 
        AND grass_region = '${grass_region}'
),
list_table AS (
    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'campaign_id' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_campaign_id_transactional_campaign, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'voucher_template_id' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_voucher_template_id_transactional_voucher, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'referral_promotion_id' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_referral_promotion_id_non_transactional, array())) t AS id
    
    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'reward_package_id' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_reward_package_id_non_transactional_reward_package, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'mission_task_id' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_mission_task_id_non_transactional, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'daily_checkin_id' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_daily_checkin_id_non_transactional, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'campaign_id_non_transaction' AS list_type,
        id AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_campaign_id_non_transactional_nui, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_campaign_id_transactional_campaign, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_voucher_template_id_transactional_voucher, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_referral_promotion_id_non_transactional, array())) t AS id
    
    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_reward_package_id_non_transactional_reward_package, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_mission_task_id_non_transactional, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_daily_checkin_id_non_transactional, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS list_type,
        'all' AS list_id,
        community_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(list_campaign_id_non_transactional_nui, array())) t AS id
),
fraud_table AS (
    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'fraud_monitor' AS fraud_type,
        id AS fraud_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(sp_fraud_tag_monitor, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'fraud_confirmed' AS fraud_type,
        id AS fraud_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(sp_fraud_tag_confirmed, array())) t AS id

    UNION ALL 

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS fraud_type,
        'all' AS fraud_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(sp_fraud_tag_monitor, array())) t AS id

    UNION ALL

    SELECT
        platform_user_id,
        shopeepay_user_id,
        unix_timestamp(
            to_utc_timestamp(
                to_timestamp(concat(spp_registration_date, ' 23:59:59')),
                '${time_zone_area}'
            )
            ) AS ts_10,
        'all' AS fraud_type,
        'all' AS fraud_id
    FROM middle_table
    LATERAL VIEW explode(coalesce(sp_fraud_tag_confirmed, array())) t AS id
),
id_mapping AS (
    SELECT
        platform_user_id,
        shopeepay_user_id,
        concat(platform_user_id,'_',shopeepay_user_id) as combine_uid_key,
        community_id
    FROM middle_table
    GROUP BY 
        platform_user_id,
        shopeepay_user_id,
        concat(platform_user_id,'_',shopeepay_user_id),
        community_id
)

INSERT OVERWRITE TABLE ${SCHEMA}.ads_risk_${region}_graph_spp_af_policy_promo_df 
PARTITION(grass_region='${grass_region}',grass_date='${grass_date}')
SELECT
    concat_ws('_',
        substr(md5(cast(concat(coalesce(l.platform_user_id,f.platform_user_id),'_',coalesce(l.shopeepay_user_id,f.shopeepay_user_id)) as string)),0,2),
        concat(coalesce(l.platform_user_id,f.platform_user_id),'_',coalesce(l.shopeepay_user_id,f.shopeepay_user_id)),
        coalesce(l.list_type,'none'),
        coalesce(l.list_id,'none'),
        coalesce(f.fraud_type,'none'),
        coalesce(f.fraud_id,'none'),
        coalesce(l.ts_10,f.ts_10),
        mapping.combine_uid_key
    ) as rowkey,
    1 as qf
FROM list_table l
FULL OUTER JOIN fraud_table f
    ON l.platform_user_id = f.platform_user_id
   AND l.shopeepay_user_id = f.shopeepay_user_id
INNER JOIN id_mapping mapping
    ON l.community_id = mapping.community_id
WHERE mapping.combine_uid_key is not null
;