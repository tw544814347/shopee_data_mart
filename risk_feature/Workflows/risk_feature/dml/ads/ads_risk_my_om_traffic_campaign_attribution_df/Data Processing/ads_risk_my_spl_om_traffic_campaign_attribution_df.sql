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

--drop table if exists ${SCHEMA}.ads_risk_my_spl_om_traffic_campaign_attribution_df;
create external table if not exists ${SCHEMA}.ads_risk_my_spl_om_traffic_campaign_attribution_df (
    shopee_user_id      string  comment 'shopee user id'
    ,utm_source         string  comment 'utm source, like: facebook, rtbhouse, google, organic (default)'
    ,campaign_objective string  comment 'campaign goal type: retargeting / install / branding / activation'
    ,campaign_name      string  comment 'first level: campaign, setting marketing goals'
    ,app_open_to_activate_click_seconds bigint  comment 'app open to activate click seconds'
    ,event_timestamp                    bigint  comment 'event timestamp'      
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/ads/ads_risk_my_spl_om_traffic_campaign_attribution_df'
;
--msck repair table ${SCHEMA}.ads_risk_my_spl_om_traffic_campaign_attribution_df;

insert overwrite ${SCHEMA}.ads_risk_my_spl_om_traffic_campaign_attribution_df partition (grass_date = '${ds}')
select shopee_user_id
        ,utm_source
        ,campaign_objective
        ,campaign_name
        ,app_open_to_activate_click_seconds
        ,event_timestamp
from (
    select  shopee_user_id
            ,utm_source
            ,campaign_objective
            ,campaign_name
            ,app_open_to_activate_click_seconds
            ,event_timestamp
            ,row_number() over(partition by shopee_user_id order by event_timestamp desc) as rn
    from (
        select shopee_user_id
                ,utm_source
                ,campaign_objective
                ,campaign_name
                ,app_open_to_activate_click_seconds
                ,event_timestamp
        from    risk_feature.ads_risk_my_spl_om_traffic_campaign_attribution_df
        where   grass_date = '${ds_t_2}'
        union all
        select  cast(shopee_user_id as string)                      as shopee_user_id
                ,utm_source
                ,campaign_objective
                ,campaign                                           as campaign_name
                ,event_timestamp - campaign_attribution_timestamp   as app_open_to_activate_click_seconds
                ,event_timestamp
        from (
            select  shopee_user_id
                    ,utm_source
                    ,campaign_objective
                    ,campaign
                    ,campaign_attribution_timestamp
                    ,event_timestamp
                    ,row_number() over(partition by shopee_user_id order by event_timestamp desc) as rn
            FROM fp_traffic.mart_dwd_om_traffic_campaign_attribution_di__my
            WHERE event_date = '${ds}'
            and  biz_type = 'SPL'
            and  page_type = 'spl_activate_info'
            and  operation = 'click'
        )
        where rn = 1
    )
)
where rn = 1