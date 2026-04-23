-- =====================================================
-- OpenFinance Seller Accounts - Offline Spark SQL
-- =====================================================
-- Purpose: Generate seller accounts data for OpenFinance API
-- Source: Offline Hive tables (onboarding, shareholder, dim_shop, wallet_account_number)
-- Target: Staging table for HBase bulk load
-- =====================================================

-- Spark SQL Configuration
SET spark.sql.session.timeZone = UTC;

-- Register UDF functions
CREATE OR REPLACE TEMPORARY FUNCTION aes_encrypt AS 'com.seamoneydata.of.udf.SparkAesEncryptUDF' USING JAR 'hdfs://R2/projects/shopeepay/hdfs/prod/scripts/openfinance/spark-udf-1.0.jar';

-- Create staging table
CREATE TABLE IF NOT EXISTS ${SCHEMA}.tmp_of_seller_accounts_df (
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
TRUNCATE TABLE ${SCHEMA}.tmp_of_seller_accounts_df;

-- Create temporary view for account data processing
CREATE OR REPLACE TEMPORARY VIEW tmp_of_seller_accounts_view AS
SELECT
    CPF,
    shop_id,
    user_id,
    account_number,
    start_time,
    CONCAT(
        '{',
            '"type": "CONTA_PAGAMENTO_PRE_PAGA",',
            '"number": ', CASE WHEN accountNumber IS NOT NULL THEN CONCAT('"', accountNumber, '"') ELSE 'null' END, ',',
            '"checkDigit": ', CASE WHEN checkDigit IS NOT NULL THEN CONCAT('"', checkDigit, '"') ELSE 'null' END, ',',
            '"accountId": ', CASE WHEN shop_id IS NOT NULL THEN CONCAT('"', CAST(shop_id AS STRING), '"') ELSE 'null' END,
        '}'
    ) AS qf
FROM
(
    SELECT 
        cpf_id AS CPF,
        shop_id,
        user_id,
        account_number,
        start_time,
        -- Extract account number (before the dash)
        CASE 
            WHEN account_number IS NOT NULL AND instr(account_number, '-') > 0 
            THEN substring(account_number, 1, instr(account_number, '-') - 1)
            ELSE account_number
        END AS accountNumber,
        -- Extract check digit (after the dash)
        CASE 
            WHEN account_number IS NOT NULL AND instr(account_number, '-') > 0 
            THEN substring(account_number, instr(account_number, '-') + 1)
            ELSE NULL
        END AS checkDigit
    FROM
    (
        SELECT
            sh.cpf_id,
            ob.shop_id,
            ds.user_id,
            wa.account_number,
            wa.start_time,
            ROW_NUMBER() OVER(PARTITION BY sh.cpf_id ORDER BY ob.shop_id) AS rn
        FROM 
            marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
        LEFT JOIN 
            marketplace.ods_shopee_shop_kyb_record_br_db__brseller_shareholder_tab_df__reg sh
        ON 
            ob.shop_id = sh.shop_id AND sh.status = 1
        LEFT JOIN
            mp_user.dim_shop__br_s0_live ds
        ON
            ob.shop_id = ds.shop_id
        LEFT JOIN
            marketplace.shopee_seller_wallet_account_number_br_db__wallet_account_number_tab__reg_continuous_s0_live wa
        ON
            ds.user_id = wa.user_id
        WHERE
            ob.tax_type = 2
            AND sh.cpf_id IS NOT NULL
            AND wa.account_number IS NOT NULL
    )
    WHERE rn = 1
);

-- Insert seller accounts data with both CONTAPAGAMENTOPREPAGA and ALL rowkeys
INSERT INTO ${SCHEMA}.tmp_of_seller_accounts_df PARTITION (region = 'br')
SELECT
    CONCAT(
        SUBSTRING(MD5(REPLACE(REPLACE(CPF, '.', ''), '-', '')), 1, 2),
        '_',
        REPLACE(REPLACE(CPF, '.', ''), '-', ''),
        '_CONTAPAGAMENTOPREPAGA_',
        CAST(start_time AS STRING),
        '_',
        CAST(shop_id AS STRING)
    ) AS rowkey,
    qf
FROM 
    tmp_of_seller_accounts_view

UNION ALL

SELECT
    CONCAT(
        SUBSTRING(MD5(REPLACE(REPLACE(CPF, '.', ''), '-', '')), 1, 2),
        '_',
        REPLACE(REPLACE(CPF, '.', ''), '-', ''),
        '_ALL_',
        CAST(start_time AS STRING),
        '_',
        CAST(shop_id AS STRING)
    ) AS rowkey,
    qf
FROM 
    tmp_of_seller_accounts_view;
