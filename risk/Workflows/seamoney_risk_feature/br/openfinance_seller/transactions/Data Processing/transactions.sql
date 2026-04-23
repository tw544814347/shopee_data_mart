-- =====================================================
-- OpenFinance Seller Transactions - Offline Spark SQL
-- =====================================================
-- Purpose: Generate seller transaction data
-- Input: merchant_id (from merchant_order_tab, equals to shop_id)
-- Output: Transaction details including type, amount, datetime
-- =====================================================

-- Spark SQL Configuration
SET spark.sql.session.timeZone = UTC;

-- Register UDF functions
CREATE OR REPLACE TEMPORARY FUNCTION aes_encrypt AS 'com.seamoneydata.of.udf.SparkAesEncryptUDF' USING JAR 'hdfs://R2/projects/shopeepay/hdfs/prod/scripts/openfinance/spark-udf-1.0.jar';

-- Create staging table
CREATE TABLE IF NOT EXISTS ${SCHEMA}.tmp_of_seller_transactions_df (
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
TRUNCATE TABLE ${SCHEMA}.tmp_of_seller_transactions_df;

-- Create a view to get merchant orders with deduplication
CREATE OR REPLACE TEMPORARY VIEW merchant_orders_filtered AS
SELECT 
    order_id,
    merchant_id,
    order_type,
    amount,
    currency,
    order_status,
    create_time,
    completed_time,
    ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY update_time DESC) AS rn
FROM 
    shopeepay.shopee_shopeepay_wss_order_br_db__merchant_order_tab__reg_continuous_s0_live
WHERE
    order_type IN (3, 4, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);

-- Create a view to map transaction types and names
CREATE OR REPLACE TEMPORARY VIEW merchant_orders_with_transaction_name AS
SELECT
    order_id,
    merchant_id,
    amount,
    currency,
    create_time,
    CASE 
        WHEN order_type = 3 THEN 'Ajuste De Saldo'
        WHEN order_type = 4 THEN 'Ajuste De Saldo'
        WHEN order_type = 7 THEN 'Pagamento'
        WHEN order_type = 8 THEN 'Reembolso'
        WHEN order_type = 9 THEN 'Reembolso'
        WHEN order_type = 10 THEN 'Transferência Pix Recebida'
        WHEN order_type = 11 THEN 'Devolução Pix Enviada'
        WHEN order_type = 12 THEN 'Pagamento'
        WHEN order_type = 13 THEN 'Cobrança Direta'
        WHEN order_type = 14 THEN 'Reembolso'
        WHEN order_type = 15 THEN 'Reembolso'
        WHEN order_type = 16 THEN 'Pagamento Parcelado'
        WHEN order_type = 17 THEN 'Taxa De Pagamento Parcelado'
        WHEN order_type = 18 THEN 'Pagamento Migrado'
        WHEN order_type = 19 THEN 'Transferência Pix Enviada'
        WHEN order_type = 20 THEN 'Devolução Pix Recebida'
        WHEN order_type = 21 THEN 'Transferência Pix Recebida'
        WHEN order_type = 22 THEN 'Devolução Pix Enviada'
        WHEN order_type = 23 THEN 'Transferência Pix Enviada'
        WHEN order_type = 24 THEN 'Devolução Pix Recebida'
        WHEN order_type = 25 THEN 'Transferência Pix Recebida'
        WHEN order_type = 26 THEN 'Devolução Pix Enviada'
        WHEN order_type = 27 THEN 'Pix Saque'
        ELSE 'Outros'
    END AS transaction_name,
    CASE
        WHEN order_type IN (3, 8, 9, 10, 14, 15, 20, 21, 24, 25) THEN 'CREDITO'
        WHEN order_type IN (4, 7, 11, 12, 13, 16, 17, 18, 19, 22, 23, 26, 27) THEN 'DEBITO'
        ELSE 'DEBITO'
    END AS credit_debit_type,
    CASE
        WHEN order_status IN (1, 2, 5, 6, 10, 12) THEN 'TRANSACAO_PROCESSANDO'
        WHEN order_status IN (7, 8, 9, 11) THEN 'TRANSACAO_EFETIVADA'      
        WHEN order_status IN (3, 4, 13) THEN 'LANCAMENTO_FUTURO'
        ELSE 'TRANSACAO_PROCESSANDO'
    END AS completedAuthorisedPaymentType,
    CASE
        WHEN order_type IN (19, 20, 21, 22, 23, 24, 25, 26, 27) THEN 'PIX'
        WHEN order_type IN (7, 12, 16, 17, 18) THEN 'BOLETO'
        WHEN order_type IN (10, 11) THEN 'TRANSFERENCIA_MESMA_INSTITUICAO'
        WHEN order_type IN (27) THEN 'SAQUE'
        WHEN order_type IN (13) THEN 'CARTAO'
        WHEN order_type IN (3, 4, 8, 9, 14, 15) THEN 'OUTROS'
        ELSE 'OUTROS'
    END AS transaction_type
FROM merchant_orders_filtered
WHERE rn = 1;

-- Create a view with formatted JSON output
CREATE OR REPLACE TEMPORARY VIEW merchant_orders_json_view AS
SELECT
    merchant_id,
    create_time,
    credit_debit_type,
    order_id,
    CONCAT(
        '{',
            '"transactionId": "', CAST(order_id AS STRING), '",',
            '"completedAuthorisedPaymentType": "', CAST(completedAuthorisedPaymentType AS STRING), '",',
            '"creditDebitType": "', credit_debit_type, '",',
            '"transactionName": "', transaction_name, '",',
            '"type": "', transaction_type, '",',
            '"transactionAmount": {',
                '"amount": "', CAST(ROUND(CAST(amount AS DECIMAL(38, 10))/100000, 4) AS STRING), '",',
                '"currency": "', currency, '"',
            '},',
            '"transactionDateTime": "', FROM_UNIXTIME(CAST(create_time AS BIGINT), "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), '"',
        '}'
    ) AS qf
FROM merchant_orders_with_transaction_name;

-- Insert into the output table with both credit_debit_type and ALL rowkeys
INSERT INTO ${SCHEMA}.tmp_of_seller_transactions_df PARTITION (region = 'br')
SELECT
    CONCAT(
        SUBSTRING(MD5(CAST(merchant_id AS STRING)), 1, 2),
        '_',
        CAST(merchant_id AS STRING),
        '_',
        credit_debit_type,
        '_',
        CAST(create_time AS STRING),
        '_',
        CAST(order_id AS STRING)
    ) AS rowkey,
    qf
FROM merchant_orders_json_view

UNION ALL

SELECT
    CONCAT(
        SUBSTRING(MD5(CAST(merchant_id AS STRING)), 1, 2),
        '_',
        CAST(merchant_id AS STRING),
        '_ALL_',
        CAST(create_time AS STRING),
        '_',
        CAST(order_id AS STRING)
    ) AS rowkey,
    qf
FROM merchant_orders_json_view;
