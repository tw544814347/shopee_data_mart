
--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-11-01T14:00:00
-- Theme Domain：       反欺诈(临时任务,不用日常调度)
-- Description:         risk上线了VN税务数据爬虫功能，需要DE帮忙提供爬虫的id card no数据 PRD https://confluence.shopee.io/pages/viewpage.action?pageId=2184279892
-- 变更历史：
--     update by zongyi.lu@shopee.com 2024-08-01 提供前一天的数据 https://jira.shopee.io/browse/SPFDT-42326
--********************************************************************--


-- DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_vn_user_id_card_no_df;
-- CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_vn_user_id_card_no_df
-- (
--     platform_user_id      string comment 'platform_user_id',
--     credit_user_id        string comment 'credit_user_id',
--     id_card_no            string comment 'id_card_no'
-- )
-- comment 'risk user id card'
-- partitioned by
-- (
--     grass_date string comment 'partition key, yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="snappy")
-- location '${HDFS_PATH}/risk_feature/ads/ads_risk_user_id_card_no_df/grass_region=VN';



 -- 20240606更新逻辑
 insert overwrite table ${SCHEMA}.ads_risk_vn_user_id_card_no_df partition(grass_date)
select
    a.platform_user_id
    ,null credit_user_id
    ,b.id_card_no
    ,'${grass_date}' as grass_date
from
(
    select 
        platform_user_id
    from 
    (
        select 
            platform_user_id,
            ROW_NUMBER() OVER (PARTITION BY platform_user_id ORDER BY request_time DESC) AS row_request_time
        from risk.ads_risk_vn_uw_spl_process_di
        where region = 'VN'
        and grass_date ='${grass_date}'
        and app_id = 'kredit'
        and policy_status IN (1, 2)
        and request_id IS NOT NULL
        and policy_type_id = 1
        and NOT (request_id LIKE '%test%')
    )
    where row_request_time = 1
) a
join
(
    select 
        platform_user_id,
        id_card_no 
    from risk.dwd_risk_vn_strategy_final_result_merge_di
    where risk_scene_id = 10013
    and grass_date >= '${grass_date}'
    and id_card_no is not null 
    group by platform_user_id,id_card_no
) b on a.platform_user_id = b.platform_user_id
;

msck repair table risk.ads_risk_vn_user_id_card_no_df;