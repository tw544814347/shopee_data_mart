--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-01-06
-- Theme Domain：       SPP MP Freq Device List
-- Description:         https://jira.shopee.io/browse/SPFDT-58784
-- Data Granularity:   
-- 变更历史：
--********************************************************************--

drop TABLE IF EXISTS risk.ads_risk_${region}_spp_frequent_device_nd;
CREATE TABLE IF NOT EXISTS risk.ads_risk_${region}_spp_frequent_device_nd (
    buyer_id                 STRING  COMMENT 'same as shopee_user_id',
    fre_mp_szdf              STRING  COMMENT 'fre_mp_szdf',
    shopee_user_id           STRING  COMMENT 'shopee_user_id',
    frequency_sz_dfp_device_id_list_1y STRING 
)
PARTITIONED BY (
    grass_region             STRING       COMMENT '',
    grass_date               STRING       COMMENT ''
)
stored as orc tblproperties ("orc.compress" = "zstd") 
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_${region}_spp_frequent_device_nd';


ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

WITH order_data AS (
    SELECT
        buyer_id,
        sz_dfp_device_id AS szdf,

        CASE
            WHEN complete_timestamp > 0 THEN
                date_trunc(
                    'week',
                    to_date(format_time(create_timestamp, '${grass_region}'))
                )
            ELSE NULL
        END AS create_week,

        CASE
            WHEN complete_timestamp > 0 THEN
                date_trunc(
                    'month',
                    to_date(format_time(create_timestamp, '${grass_region}'))
                )
            ELSE NULL
        END AS create_month

    FROM risk.dwd_risk_order_item_complete_di
    WHERE grass_region = '${grass_region}'
      AND to_date(grass_date) <= to_date('${ds}')
      AND to_date(grass_date) >= date_sub(to_date('${ds}'), 360)
      AND length(sz_dfp_device_id) > 1
),

user_df AS (
    SELECT
        buyer_id,
        szdf,
        COUNT(DISTINCT create_week)  AS cnt_paid_order_weeks,
        COUNT(DISTINCT create_month) AS cnt_paid_order_months
    FROM order_data
    GROUP BY buyer_id, szdf
)

INSERT OVERWRITE TABLE risk.ads_risk_${region}_spp_frequent_device_nd
PARTITION (grass_region = '${grass_region}', grass_date = '${ds}')
select 
    t1.user_id,
    fre_mp_szdf,
    shopee_user_id,
    frequency_sz_dfp_device_id_list_1y
from (
    select
        user_id, frequency_sz_dfp_device_id_list_1y
    FROM risk.ads_risk_profile_user_df
    where grass_date = '${ds}' and grass_region = '${grass_region}'
) t1
left join 
(
SELECT
    buyer_id,
    -- CAST(collect_set(cast(szdf as string)) AS string) AS fre_mp_szdf,
    to_json(collect_set(cast(szdf as string)))
        as fre_mp_szdf,
    buyer_id as shopee_user_id
FROM user_df
WHERE cnt_paid_order_weeks >= 3
GROUP BY buyer_id
) t2 on t1.user_id = t2.buyer_id

