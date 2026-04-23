-- =====================================================
-- OpenFinance Seller Find Account by ID - Offline Spark SQL
-- =====================================================
-- Purpose: Find seller account details by shop_id (accountId)
-- Input: shop_id (same as accountId from accounts API)
-- Output: Account details including number, checkDigit, type, subtype, currency
-- =====================================================

-- Spark SQL Configuration
SET spark.sql.session.timeZone = UTC;

-- Register UDF functions
CREATE OR REPLACE TEMPORARY FUNCTION aes_encrypt AS 'com.seamoneydata.of.udf.SparkAesEncryptUDF' USING JAR 'hdfs://R2/projects/shopeepay/hdfs/prod/scripts/openfinance/spark-udf-1.0.jar';

-- Create staging table
CREATE TABLE IF NOT EXISTS ${SCHEMA}.tmp_of_seller_find_account_df (
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
TRUNCATE TABLE ${SCHEMA}.tmp_of_seller_find_account_df;

-- Create temporary view for account data processing
CREATE OR REPLACE TEMPORARY VIEW tmp_of_seller_find_account_view AS
SELECT
    shop_id,
    user_id,
    account_number,
    currency,
    CONCAT(
        '{',
            '"number": ', CASE WHEN walletNumber IS NOT NULL THEN CONCAT('"', walletNumber, '"') ELSE 'null' END, ',',
            '"checkDigit": ', CASE WHEN checkDigit IS NOT NULL THEN CONCAT('"', checkDigit, '"') ELSE 'null' END, ',',
            '"type": "CONTA_PAGAMENTO_PRE_PAGA",',
            '"subtype": "INDIVIDUAL",',
            '"currency": ', CASE WHEN currency IS NOT NULL THEN CONCAT('"', currency, '"') ELSE '"BRL"' END,
        '}'
    ) AS qf
FROM
(
    SELECT 
        shop_id,
        user_id,
        account_number,
        currency,
        -- Extract wallet number (before the dash)
        CASE 
            WHEN account_number IS NOT NULL AND instr(account_number, '-') > 0 
            THEN substring(account_number, 1, instr(account_number, '-') - 1)
            ELSE account_number
        END AS walletNumber,
        -- Extract check digit (after the dash)
        CASE 
            WHEN account_number IS NOT NULL AND instr(account_number, '-') > 0 
            THEN substring(account_number, instr(account_number, '-') + 1)
            ELSE NULL
        END AS checkDigit
    FROM
    (
        SELECT
            ob.shop_id,
            ds.user_id,
            wa.account_number,
            ma.currency,
            ROW_NUMBER() OVER(PARTITION BY ob.shop_id ORDER BY ob.shop_id) AS rn
        FROM 
            marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
        LEFT JOIN
            mp_user.dim_shop__br_s0_live ds
        ON
            ob.shop_id = ds.shop_id
        LEFT JOIN
            marketplace.shopee_seller_wallet_account_number_br_db__wallet_account_number_tab__reg_continuous_s0_live wa
        ON
            ds.user_id = wa.user_id
        LEFT JOIN
            shopeepay.shopee_shopeepay_wse_br_db__merchant_wallet_account_tab__reg_daily_s0_live ma
        ON
            ob.shop_id = ma.merchant_id
        WHERE
            ob.tax_type = 2
            AND wa.account_number IS NOT NULL 
    )
    WHERE rn = 1
);

-- Insert seller find account data
INSERT INTO ${SCHEMA}.tmp_of_seller_find_account_df PARTITION (region = 'br')
SELECT
    CONCAT(
        SUBSTRING(MD5(CAST(shop_id AS STRING)), 1, 2),
        '_',
        CAST(shop_id AS STRING),
        '_',
        CAST(shop_id AS STRING)
    ) AS rowkey,
    qf
FROM 
    tmp_of_seller_find_account_view;
