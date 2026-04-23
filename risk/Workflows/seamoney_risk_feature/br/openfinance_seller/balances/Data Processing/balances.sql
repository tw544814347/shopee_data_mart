-- =====================================================
-- OpenFinance Seller Balances - Offline Spark SQL
-- =====================================================
-- Purpose: Generate seller balance information
-- Input: shop_id (from onboarding_tab)
-- Output: Available amount, blocked amount, automatically invested amount
-- =====================================================

-- Spark SQL Configuration
SET spark.sql.session.timeZone = UTC;

-- Register UDF functions
CREATE OR REPLACE TEMPORARY FUNCTION aes_encrypt AS 'com.seamoneydata.of.udf.SparkAesEncryptUDF' USING JAR 'hdfs://R2/projects/shopeepay/hdfs/prod/scripts/openfinance/spark-udf-1.0.jar';

-- Create staging table
CREATE TABLE IF NOT EXISTS ${SCHEMA}.tmp_of_seller_balances_df (
    rowkey STRING,
    qf STRING,
    region STRING
)
PARTITIONED BY (region) 
STORED AS PARQUET 
TBLPROPERTIES (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
);

-- Truncate staging table
TRUNCATE TABLE ${SCHEMA}.tmp_of_seller_balances_df;

-- Insert seller balances data
INSERT INTO ${SCHEMA}.tmp_of_seller_balances_df PARTITION (region = 'br')
SELECT 
    CONCAT(
        SUBSTRING(MD5(CAST(shop_id AS STRING)), 1, 2),
        '_',
        CAST(shop_id AS STRING),
        '_',
        CAST(shop_id AS STRING)
    ) AS rowkey,
    CONCAT(
        '{',
            '"availableAmount": {',
                '"amount": ', CASE WHEN availableAmount IS NOT NULL THEN CONCAT('"', CAST(ROUND(CAST(availableAmount AS DECIMAL(38, 10))/100000, 4) AS STRING), '"') ELSE 'null' END, ',',
                '"currency": ', CASE WHEN availableCurrency IS NOT NULL THEN CONCAT('"', availableCurrency, '"') ELSE 'null' END,
            '},',
            '"blockedAmount": {',
                '"amount": ', CASE WHEN blockedAmount IS NOT NULL THEN CONCAT('"', CAST(ROUND(CAST(blockedAmount AS DECIMAL(38, 10))/100000, 4) AS STRING), '"') ELSE 'null' END, ',',
                '"currency": ', CASE WHEN blockedCurrency IS NOT NULL THEN CONCAT('"', blockedCurrency, '"') ELSE 'null' END,
            '},',
            '"automaticallyInvestedAmount": {',
                '"amount": ', CASE WHEN automaticallyInvestedAmount IS NOT NULL THEN CONCAT('"', CAST(ROUND(CAST(automaticallyInvestedAmount AS DECIMAL(38, 10))/100000, 4) AS STRING), '"') ELSE 'null' END, ',',
                '"currency": ', CASE WHEN automaticallyInvestedCurrency IS NOT NULL THEN CONCAT('"', automaticallyInvestedCurrency, '"') ELSE 'null' END,
            '},',
            '"updateDateTime": ', CASE WHEN updateDateTime IS NOT NULL THEN CONCAT('"', updateDateTime, '"') ELSE 'null' END,
        '}'
    ) AS qf
FROM
(
    SELECT
        shop_id,
        availableAmount,
        availableCurrency,
        blockedAmount,
        blockedCurrency,
        availableAmount AS automaticallyInvestedAmount,
        availableCurrency AS automaticallyInvestedCurrency,
        FROM_UNIXTIME(update_time, "yyyy-MM-dd'T'HH:mm:ss'Z'") AS updateDateTime
    FROM
    (
        SELECT
            COALESCE(avail.shop_id, blocked.shop_id) AS shop_id,
            avail.availableAmount,
            avail.availableCurrency,
            blocked.blockedAmount,
            blocked.blockedCurrency,
            CASE
                WHEN avail.update_time IS NULL OR blocked.update_time IS NULL THEN COALESCE(avail.update_time, blocked.update_time, NULL)
                WHEN avail.update_time > blocked.update_time THEN avail.update_time
                ELSE blocked.update_time
            END AS update_time
        FROM
        (
            -- Calculate available amount (wallet_type in 1, 5, 6)
            SELECT
                ob.shop_id,
                SUM(
                    CASE 
                        WHEN mw.wallet_type = 1 THEN mw.available
                        WHEN mw.wallet_type = 5 THEN mw.available
                        WHEN mw.wallet_type = 6 THEN -mw.available
                        ELSE 0
                    END
                ) AS availableAmount,
                mw.currency AS availableCurrency,
                MAX(mw.update_time) AS update_time
            FROM 
                marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
            LEFT JOIN
                shopeepay.shopee_shopeepay_wse_br_db__merchant_wallet_account_tab__reg_daily_s0_live ma
            ON
                ob.shop_id = ma.merchant_id
            LEFT JOIN
                shopeepay.shopee_shopeepay_wse_shard_br_db__merchant_wallet_tab__reg_daily_s0_live mw
            ON
                ma.wallet_account_id = mw.wallet_account_id
            WHERE
                ob.tax_type = 2
                AND mw.wallet_type IN (1, 5, 6)
            GROUP BY
                ob.shop_id, mw.currency
        ) avail
        FULL OUTER JOIN
        (
            -- Calculate blocked amount (wallet_type = 3)
            SELECT
                ob.shop_id,
                SUM(mw.available * -1) AS blockedAmount,
                mw.currency AS blockedCurrency,
                MAX(mw.update_time) AS update_time
            FROM 
                marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
            LEFT JOIN
                shopeepay.shopee_shopeepay_wse_br_db__merchant_wallet_account_tab__reg_daily_s0_live ma
            ON
                ob.shop_id = ma.merchant_id
            LEFT JOIN
                shopeepay.shopee_shopeepay_wse_shard_br_db__merchant_wallet_tab__reg_daily_s0_live mw
            ON
                ma.wallet_account_id = mw.wallet_account_id
            WHERE
                ob.tax_type = 2
                AND mw.wallet_type = 3
            GROUP BY
                ob.shop_id, mw.currency
        ) blocked
        ON avail.shop_id = blocked.shop_id
    )
);
