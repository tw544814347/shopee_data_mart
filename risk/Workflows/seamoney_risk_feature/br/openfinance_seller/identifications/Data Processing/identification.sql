-- =====================================================
-- OpenFinance Seller Identification - Offline Spark SQL
-- =====================================================
-- Purpose: Generate seller identification data for OpenFinance API
-- Source: Offline Hive tables (brseller_onboarding_tab, brseller_shareholder_tab)
-- Target: Staging table for HBase bulk load
-- Business Logic: 
--   - Each cpf_id generates one record (rowkey based on cpf_id)
--   - parties field contains ALL shareholders of the same shop_id
--   - Within same shop_id: smallest cpf_id is ADMINISTRADOR, others are SOCIO
-- =====================================================

-- Spark SQL Configuration
SET spark.sql.session.timeZone = UTC;

-- Register UDF functions
CREATE OR REPLACE TEMPORARY FUNCTION aes_encrypt AS 'com.seamoneydata.of.udf.SparkAesEncryptUDF' USING JAR 'hdfs://R2/projects/shopeepay/hdfs/prod/scripts/openfinance/spark-udf-1.0.jar';

-- Create staging table
CREATE TABLE IF NOT EXISTS ${SCHEMA}.tmp_of_seller_identification_df (
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
TRUNCATE TABLE ${SCHEMA}.tmp_of_seller_identification_df;

-- Step 1: Pre-calculate distinct shareholder count per shop_id
CREATE OR REPLACE TEMPORARY VIEW shop_shareholder_counts AS
SELECT
    ob.shop_id,
    COUNT(DISTINCT sh.cpf_id) AS shareholder_count,
    MIN(sh.cpf_id) AS min_cpf_id
FROM 
    marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
INNER JOIN 
    marketplace.ods_shopee_shop_kyb_record_br_db__brseller_shareholder_tab_df__reg sh
ON 
    ob.shop_id = sh.shop_id AND sh.status = 1
WHERE
    ob.tax_type = 2
    AND sh.cpf_id IS NOT NULL
GROUP BY ob.shop_id;

-- Step 2: Get all shop_id and cpf_id relationships with party type
CREATE OR REPLACE TEMPORARY VIEW shop_shareholder_base AS
SELECT
    sh.cpf_id,
    ob.shop_id,
    ob.tax_type,
    ob.tax_id,
    ob.tax_name,
    ob.baddress_street_name,
    ob.nationality,
    COALESCE(ob.mtime, sh.update_timestamp, 0) AS update_time,
    -- Mark the minimum cpf_id within each shop_id as ADMINISTRADOR
    CASE 
        WHEN sh.cpf_id = sc.min_cpf_id THEN 'ADMINISTRADOR'
        ELSE 'SOCIO'
    END AS party_type,
    sc.shareholder_count
FROM 
    marketplace.shopee_shop_kyb_record_br_db__brseller_onboarding_tab__br_df ob
INNER JOIN 
    marketplace.ods_shopee_shop_kyb_record_br_db__brseller_shareholder_tab_df__reg sh
ON 
    ob.shop_id = sh.shop_id AND sh.status = 1
INNER JOIN
    shop_shareholder_counts sc
ON
    ob.shop_id = sc.shop_id
WHERE
    ob.tax_type = 2
    AND sh.cpf_id IS NOT NULL;

-- Step 3: Build parties JSON array for each shop_id
CREATE OR REPLACE TEMPORARY VIEW shop_parties_aggregated AS
SELECT
    shop_id,
    CONCAT(
        '[',
        CONCAT_WS(
            ',',
            COLLECT_LIST(party_json)
        ),
        ']'
    ) AS parties_json
FROM (
    SELECT 
        shop_id,
        cpf_id,
        CONCAT(
            '{',
                '"personType": "PESSOA_NATURAL",',
                '"type": "', party_type, '",',
                '"documentType": "CPF",',
                '"documentNumber": "', REPLACE(REPLACE(cpf_id, '.', ''), '-', ''), '"',
            '}'
        ) AS party_json
    FROM (
        SELECT 
            shop_id,
            cpf_id,
            party_type,
            update_time,
            ROW_NUMBER() OVER(PARTITION BY shop_id, cpf_id ORDER BY update_time DESC) AS rn
        FROM shop_shareholder_base
    )
    WHERE rn = 1
    ORDER BY cpf_id  -- Sort by cpf_id to ensure smallest cpf_id (ADMINISTRADOR) comes first
)
GROUP BY shop_id;

-- Step 4: Join back to get complete record for each cpf_id
CREATE OR REPLACE TEMPORARY VIEW seller_identification_complete AS
SELECT
    base.cpf_id,
    base.shop_id,
    base.tax_id,
    base.tax_name,
    base.baddress_street_name,
    base.nationality,
    base.update_time,
    spa.parties_json,
    -- Ensure only one record per cpf_id (take the first shop_id if multiple)
    ROW_NUMBER() OVER(PARTITION BY base.cpf_id ORDER BY base.shop_id) AS cpf_rn
FROM shop_shareholder_base base
LEFT JOIN shop_parties_aggregated spa
ON base.shop_id = spa.shop_id;

-- Step 5: Generate final JSON and insert into target table
INSERT INTO ${SCHEMA}.tmp_of_seller_identification_df PARTITION (region = 'br')
SELECT
    CONCAT(
        SUBSTRING(MD5(REPLACE(REPLACE(cpf_id, '.', ''), '-', '')), 1, 2),
        '_',
        REPLACE(REPLACE(cpf_id, '.', ''), '-', ''),
        '_',
        CAST(aes_encrypt(cpf_id) AS STRING)
    ) AS rowkey,
    CONCAT(
        '{',
            '"updateDateTime": ', CASE WHEN updateDateTime IS NOT NULL THEN CONCAT('"', updateDateTime, '"') ELSE 'null' END, ',',
            '"businessId": ', CASE WHEN businessId IS NOT NULL THEN CONCAT('"', businessId, '"') ELSE 'null' END, ',',
            '"companyName": ', CASE WHEN companyName IS NOT NULL THEN CONCAT('"', companyName, '"') ELSE 'null' END, ',',
            '"incorporationDate": null,',
            '"cnpjNumber": ', CASE WHEN cnpjNumber IS NOT NULL THEN CONCAT('"', cnpjNumber, '"') ELSE 'null' END, ',',
            '"otherDocuments": [',
                '{',
                    '"type": "",',
                    '"number": "",',
                    '"country": ', CASE WHEN otherDocCountry IS NOT NULL THEN CONCAT('"', otherDocCountry, '"') ELSE 'null' END,
                '}',
            '],',
            '"parties": ', parties_json, ',',
            '"contacts": {',
                '"postalAddresses": [',
                    '{',
                        '"isMain": true,',
                        '"townName": ', CASE WHEN townName IS NOT NULL THEN CONCAT('"', townName, '"') ELSE 'null' END, ',',
                        '"country": ', CASE WHEN country IS NOT NULL THEN CONCAT('"', country, '"') ELSE 'null' END, ',',
                        '"countryCode": ', CASE WHEN countryCode IS NOT NULL THEN CONCAT('"', countryCode, '"') ELSE 'null' END, ',',
                        '"geographicCoordinates": {',
                            '"latitude": null,',
                            '"longitude": null',
                        '}',
                    '}',
                '],',
                '"phones": [],',
                '"emails": []',
            '}',
        '}'
    ) AS qf
FROM (
    SELECT 
        cpf_id,
        FROM_UNIXTIME(update_time, "yyyy-MM-dd'T'HH:mm:ss'Z'") AS updateDateTime,
        CAST(shop_id AS STRING) AS businessId,
        tax_name AS companyName,
        REPLACE(REPLACE(tax_id, '.', ''), '-', '') AS cnpjNumber,
        -- Map nationality to country name for otherDocuments
        CASE nationality
            WHEN 'BRA' THEN 'Brasil'
            WHEN 'ARG' THEN 'Argentina'
            WHEN 'CHL' THEN 'Chile'
            WHEN 'COL' THEN 'Colombia'
            WHEN 'PER' THEN 'Peru'
            WHEN 'URY' THEN 'Uruguay'
            WHEN 'USA' THEN 'United States'
            WHEN 'CAN' THEN 'Canada'
            WHEN 'MEX' THEN 'Mexico'
            WHEN 'PRT' THEN 'Portugal'
            WHEN 'ESP' THEN 'Spain'
            WHEN 'CHN' THEN 'China'
            ELSE NULL
        END AS otherDocCountry,
        baddress_street_name AS townName,
        -- Map nationality to country name for postalAddresses
        CASE nationality
            WHEN 'BRA' THEN 'Brasil'
            WHEN 'ARG' THEN 'Argentina'
            WHEN 'CHL' THEN 'Chile'
            WHEN 'COL' THEN 'Colombia'
            WHEN 'PER' THEN 'Peru'
            WHEN 'URY' THEN 'Uruguay'
            WHEN 'USA' THEN 'United States'
            WHEN 'CAN' THEN 'Canada'
            WHEN 'MEX' THEN 'Mexico'
            WHEN 'PRT' THEN 'Portugal'
            WHEN 'ESP' THEN 'Spain'
            WHEN 'CHN' THEN 'China'
            ELSE NULL
        END AS country,
        nationality AS countryCode,
        parties_json
    FROM seller_identification_complete
    WHERE cpf_rn = 1
);
