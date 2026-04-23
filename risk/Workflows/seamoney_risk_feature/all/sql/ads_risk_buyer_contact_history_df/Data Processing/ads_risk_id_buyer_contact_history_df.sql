-- jira: https://jira.shopee.io/browse/SPFDT-57503
-- author:wei.tao@shopee.com
-- create_time:20251117
-- note:避免过长 address_list 针对过去最新的不超过100个收货地址做截断

-- drop TABLE IF EXISTS risk.ads_risk_id_buyer_contact_history_df;
CREATE TABLE IF NOT EXISTS risk.ads_risk_id_buyer_contact_history_df (
    buyer_id                 STRING        COMMENT 'platform_buyer_id',
    all_shipping_addresses   STRING  COMMENT 'buyer_shipping_address的累积列表（去重）',
    all_recipient_phones     STRING  COMMENT 'recipient_phone的累积列表（去重）'
)
PARTITIONED BY (
    grass_region             STRING       COMMENT '',
    grass_date               STRING       COMMENT ''
)
stored as orc tblproperties ("orc.compress" = "zstd") 
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_id_buyer_contact_history_df'
;



WITH base AS (
    SELECT
        buyer_id,
        regexp_replace(buyer_shipping_address, ',', '') AS buyer_shipping_address,
        recipient_phone,
        create_timestamp
    FROM mp_order.dwd_order_all_ent_df__reg_s1_live
    WHERE grass_region = 'ID'
      AND order_be_status_id IN (4,11,12,13,14,15)
),

-- Step 1: buyer_id + address 粒度取最新时间
addr_latest AS (
    SELECT
        buyer_id,
        buyer_shipping_address,
        MAX(create_timestamp) AS latest_ts
    FROM base
    WHERE buyer_shipping_address IS NOT NULL
    GROUP BY buyer_id, buyer_shipping_address
),

-- Step 2: 在去重后的 address 中取最近 100 个
addr_ranked AS (
    SELECT
        buyer_id,
        buyer_shipping_address,
        ROW_NUMBER() OVER (
            PARTITION BY buyer_id
            ORDER BY latest_ts DESC
        ) AS rn
    FROM addr_latest
),

-- Step 1: buyer_id + phone 粒度取最新时间
phone_latest AS (
    SELECT
        buyer_id,
        recipient_phone,
        MAX(create_timestamp) AS latest_ts
    FROM base
    WHERE recipient_phone IS NOT NULL
    GROUP BY buyer_id, recipient_phone
),

-- Step 2: 在去重后的 phone 中取最近 100 个
phone_ranked AS (
    SELECT
        buyer_id,
        recipient_phone,
        ROW_NUMBER() OVER (
            PARTITION BY buyer_id
            ORDER BY latest_ts DESC
        ) AS rn
    FROM phone_latest
)

INSERT OVERWRITE TABLE risk.ads_risk_id_buyer_contact_history_df
PARTITION (grass_region = 'ID', grass_date = '${ds}')

SELECT
    a.buyer_id,
    concat_ws(',', collect_list(a.buyer_shipping_address)) AS all_shipping_addresses,
    concat_ws(',', collect_list(p.recipient_phone)) AS all_recipient_phones
FROM addr_ranked a
LEFT JOIN phone_ranked p
    ON a.buyer_id = p.buyer_id
WHERE a.rn <= 100
  AND p.rn <= 100
GROUP BY a.buyer_id;