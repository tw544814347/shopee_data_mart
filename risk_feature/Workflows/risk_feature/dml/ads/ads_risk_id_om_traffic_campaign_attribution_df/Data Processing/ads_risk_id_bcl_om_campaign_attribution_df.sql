-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-04
-- Theme Domain:        Underwriting
-- Data Granularity:    shopee_user_id
-- Description:         BCL Traffic OM 特征表 DQC
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-04 - chenyingying - 初始化
-- =============================================================================

-- drop table if exists risk_feature.ads_risk_id_bcl_om_campaign_attribution_df;
create external table if not exists risk_feature.ads_risk_id_bcl_om_campaign_attribution_df (
    shopee_user_id                                  string  comment 'shopee user id'
    ,campaign_name_openapp_activation               string  comment 'campaign_name_openapp_activation'
    ,utm_source_openapp_activation                  string  comment 'utm source, like: facebook, rtbhouse, google, organic (default)'
    ,campaign_attribution_timestamp_activation      bigint  comment 'campaign_attribution_timestamp_activation'
    ,campaign_name_openapp_install                  string  comment 'utm_source_openapp_install'
    ,utm_source_openapp_install                     string  comment 'utm source, like: facebook, rtbhouse, google, organic (default)'
    ,campaign_attribution_timestamp_install         bigint  comment 'campaign_attribution_timestamp_install'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location 'hdfs://R2/projects/risk_feature/hdfs/prod/risk_feature/ads/ads_risk_id_bcl_om_campaign_attribution_df'
;
-- msck repair table risk_feature.ads_risk_id_bcl_om_campaign_attribution_df;


WITH new_attr AS (
    SELECT 
        shopee_user_id,
        MAX(CASE WHEN campaign_objective = 'activation' THEN campaign END)
            AS campaign_name_openapp_activation,
        MAX(CASE WHEN campaign_objective = 'activation' THEN utm_source END)
            AS utm_source_openapp_activation,
        MAX(CASE WHEN campaign_objective = 'activation' THEN campaign_attribution_timestamp END)
            AS campaign_attribution_timestamp_activation,
        MAX(CASE WHEN campaign_objective = 'install' THEN campaign END)
            AS campaign_name_openapp_install,
        MAX(CASE WHEN campaign_objective = 'install' THEN utm_source END)
            AS utm_source_openapp_install,
        MAX(CASE WHEN campaign_objective = 'install' THEN campaign_attribution_timestamp END)
            AS campaign_attribution_timestamp_install
    FROM (
        SELECT  
            user_id AS shopee_user_id,
            campaign_objective,
            utm_source,
            campaign,
            campaign_attribution_timestamp,
            row_number() OVER (
                PARTITION BY user_id, campaign_objective 
                ORDER BY campaign_attribution_timestamp DESC
            ) AS rn
        FROM fp_traffic.mart_dwd_om_campaign_attribution_di__id
        WHERE event_date = '${ds}'
          AND biz_type = 'BCL'
          AND campaign_objective IN ('activation', 'install')
    ) t
    WHERE rn = 1
    GROUP BY shopee_user_id
),

old AS (
    SELECT  
        shopee_user_id,
        campaign_name_openapp_activation,
        utm_source_openapp_activation,
        campaign_attribution_timestamp_activation,
        campaign_name_openapp_install,
        utm_source_openapp_install,
        campaign_attribution_timestamp_install
    FROM risk_feature.ads_risk_id_bcl_om_campaign_attribution_df
    WHERE grass_date = '${ds_t_2}'
)

insert overwrite ${SCHEMA}.ads_risk_id_bcl_om_campaign_attribution_df partition (grass_date = '${ds}')
SELECT 
    COALESCE(o.shopee_user_id, n.shopee_user_id) AS shopee_user_id,
    -- activation（新优先）
    COALESCE(n.campaign_name_openapp_activation, o.campaign_name_openapp_activation)
        AS campaign_name_openapp_activation,
    COALESCE(n.utm_source_openapp_activation, o.utm_source_openapp_activation)
        AS utm_source_openapp_activation,
    COALESCE(n.campaign_attribution_timestamp_activation, o.campaign_attribution_timestamp_activation)
        AS campaign_attribution_timestamp_activation,
    -- install（新优先）
    COALESCE(n.campaign_name_openapp_install, o.campaign_name_openapp_install)
        AS campaign_name_openapp_install,
    COALESCE(n.utm_source_openapp_install, o.utm_source_openapp_install)
        AS utm_source_openapp_install,
    COALESCE(n.campaign_attribution_timestamp_install, o.campaign_attribution_timestamp_install)
        AS campaign_attribution_timestamp_install
FROM old o
FULL OUTER JOIN new_attr n
    ON o.shopee_user_id = n.shopee_user_id
;