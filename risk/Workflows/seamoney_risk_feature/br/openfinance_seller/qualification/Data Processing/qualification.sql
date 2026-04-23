-- =====================================================
-- OpenFinance Seller Qualifications - Offline Spark SQL
-- =====================================================
-- Purpose: Generate seller qualifications data for OpenFinance API
-- Source: Offline Hive tables (brseller_onboarding_tab, brseller_shareholder_tab)
-- Target: Staging table for HBase bulk load
-- =====================================================

-- Spark SQL Configuration
SET spark.sql.session.timeZone = UTC;

-- Register UDF functions
CREATE OR REPLACE TEMPORARY FUNCTION aes_encrypt AS 'com.seamoneydata.of.udf.SparkAesEncryptUDF' USING JAR 'hdfs://R2/projects/shopeepay/hdfs/prod/scripts/openfinance/spark-udf-1.0.jar';

-- Create staging table
CREATE TABLE IF NOT EXISTS ${SCHEMA}.tmp_of_seller_qualification_df (
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
TRUNCATE TABLE ${SCHEMA}.tmp_of_seller_qualification_df;

-- Insert seller qualifications data
INSERT INTO ${SCHEMA}.tmp_of_seller_qualification_df PARTITION (region = 'br')
SELECT
    CONCAT(
        SUBSTRING(MD5(REPLACE(REPLACE(CPF, '.', ''), '-', '')), 1, 2),
        '_',
        REPLACE(REPLACE(CPF, '.', ''), '-', ''),
        '_',
        CAST(aes_encrypt(CPF) AS STRING)
    ) AS rowkey,
    CONCAT(
        '{',
            '"updateDateTime": ', CASE WHEN updateDateTime IS NOT NULL THEN CONCAT('"', updateDateTime, '"') ELSE 'null' END, ',',
            '"economicActivities": [],',
            '"informedRevenue": {',
                '"frequency": null,',
                '"frequencyAdditionalInfo": null,',
                '"amount": {',
                    '"amount": null,',
                    '"currency": null',
                '},',
                '"year": null',
            '},',
            '"informedPatrimony": {',
                '"amount": {',
                    '"amount": null,',
                    '"currency": null',
                '},',
                '"date": null',
            '}',
        '}'
    ) AS qf
FROM
(
    SELECT 
        cpf_id AS CPF,
        FROM_UNIXTIME(update_time, "yyyy-MM-dd'T'HH:mm:ss'Z'") AS updateDateTime
    FROM
    (
        SELECT
            sh.cpf_id,
            ROW_NUMBER() OVER(PARTITION BY sh.cpf_id ORDER BY ob.shop_id) AS rn,
            COALESCE(ob.mtime, sh.update_timestamp, 0) AS update_time
        FROM 
            marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
        LEFT JOIN 
            marketplace.ods_shopee_shop_kyb_record_br_db__brseller_shareholder_tab_df__reg sh
        ON 
            ob.shop_id = sh.shop_id AND sh.status = 1
        WHERE
            ob.tax_type = 2
            AND sh.cpf_id IS NOT NULL
    )
    WHERE rn = 1
);
