use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-10-09T14:00:00
-- Description:         
--                      flow_no as business key
-- Data Granularity:    flow_no+grass_date+grass_region
-- PRD                  
-- Jira                 https://jira.shopee.io/browse/SPFDT-56340
-- 1. nd 改名成为 di 表
-- 2. apply_no 字段解析修改为 判断 _ 或者 | 分割之后的取第0个值,且应该为数字,否则为null
-- 3. channel_id为数字且<10000为合法,否则null
-- 4. checkout_id和loan_id均应为数字,否则null
--********************************************************************--

SET spark.sql.adaptive.enabled = true;
SET spark.sql.adaptive.skewJoin.enabled = true;
SET spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes = 512MB;
SET spark.sql.shuffle.partitions = 1200;

-- drop table if exists ${SCHEMA}.`dws_risk_${region}_af_${product}_workflow_di`;

create table if not exists ${SCHEMA}.`dws_risk_${region}_af_${product}_workflow_di` (
    `platform_user_id` STRING COMMENT 'platform_user_id',
    `app_id` STRING COMMENT 'app_id',
    `scene_id` BIGINT COMMENT 'scene_id',
    `req_no` STRING COMMENT 'req_no',
    `apply_no` STRING COMMENT 'apply_no',
    `channel_id` STRING COMMENT 'channel_id',
    `checkout_id` STRING COMMENT 'checkout_id',
    `loan_id` STRING COMMENT 'loan_id',
    `flow_no` STRING COMMENT 'flow_no',
    `run_step` STRING COMMENT 'run_step',
    `workflow_create_time` STRING COMMENT 'workflow_create_time',
    `workflow_update_time` STRING COMMENT 'workflow_update_time',
    `create_date` STRING COMMENT 'create_time, YYYY-MM-dd',
    `rank_id_for_flow_no` INT COMMENT 'rank_id_for_flow_no',
    `rank_id_for_apply_no` INT COMMENT 'rank_id_for_apply_no',
    `rank_id_for_checkout_id_channel_id` INT COMMENT 'rank_id_for_checkout_id_channel_id',
    `rank_id_for_loan_id` INT COMMENT 'rank_id_for_loan_id',
    `flow_trace_id`       STRING COMMENT 'flow_trace_id, this flow_trace_id for spp,migrated to the extend info table'
) 
-- comment 'credit mart summary table' 
partitioned by (
    grass_date string comment 'Date of refreshed data, contains recent 190 days data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dws_risk_reg_af_biz_workflow_di/biz_name=${product}/grass_region=${REGION}'
;


-- msck repair table ${SCHEMA}.dws_risk_${region}_af_${product}_workflow_di;
refresh table ${SCHEMA}.dws_risk_${region}_af_${product}_workflow_di;

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- =======================================================
-- 目标：
--   解决 flow_no 分布极度不均造成的数据倾斜问题
--   使用随机盐打散大 Key，然后再聚合回 flow_no 层级
-- =======================================================
cache table flow_no_deduped options ('storageLevel' 'MEMORY_AND_DISK')
WITH base AS (
    SELECT
        platform_user_id,
        app_id,
        scene_id,
        req_no,

        -- 贷前 激活 + 调额
        -- SPLIT(req_no, '\\|')[0] AS apply_no,
        CASE WHEN regexp_extract(split(regexp_replace(req_no, '\\|', '_'), '_')[0], '^[0-9]+$', 0) != ''
        THEN regexp_extract(split(regexp_replace(req_no, '\\|', '_'), '_')[0], '^[0-9]+$', 0) ELSE NULL END AS apply_no,

        -- 贷中 支付
        CASE WHEN regexp_extract(SPLIT(req_no, '_')[1], '^[0-9]+$', 0) != '' AND cast(regexp_extract(SPLIT(req_no, '_')[1], '^[0-9]+$', 0) as bigint) < 10000 THEN regexp_extract(SPLIT(req_no, '_')[1], '^[0-9]+$', 0) ELSE NULL END AS channel_id,
        CASE WHEN regexp_extract(SPLIT(req_no, '_')[2], '^[0-9]+$', 0) != '' THEN regexp_extract(SPLIT(req_no, '_')[2], '^[0-9]+$', 0) ELSE NULL END AS checkout_id,

        -- 贷中 提现
        CASE WHEN regexp_extract(SPLIT(req_no, '_')[2], '^[0-9]+$', 0) != '' THEN regexp_extract(SPLIT(req_no, '_')[2], '^[0-9]+$', 0)  ELSE NULL END AS loan_id,

        flow_no,
        run_step,
        create_time  AS workflow_create_time,
        update_time  AS workflow_update_time,
        -- GET_JSON_OBJECT(CAST(UNBASE64(GET_JSON_OBJECT(input, '$.Params')) AS STRING),'$.flow_trace_id') AS flow_trace_id,
        -- 读取input的内容太大了,迁移至extend info表
        null AS flow_trace_id, 
        grass_date
        --  Step 1: 添加随机盐（0~9之间整数，用于打散大Key）
        -- ,CAST(RAND() * 10 AS INT) AS salt
    FROM risk.dwd_risk_${region}_af_${product}_workflow_di
    WHERE grass_date >= date('${grass_date}') - INTERVAL '${grass_cnt}' DAYS
      AND grass_date <= '${grass_date}'
),
-- =======================================================
-- Step 2: 先按 flow_no + salt 做 Row_Number
--         将相同 flow_no 的数据分散到 10 个不同 Executor
-- =======================================================
with_salt_rank AS (
    SELECT
        *
        ,ROW_NUMBER() OVER (
            PARTITION BY flow_no
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        ) AS rank_id_for_flow_no
    FROM base
)
-- =======================================================
-- Step 3: 按flow_no取最新的记录
-- =======================================================
-- ,flow_no_deduped AS (
    SELECT
        platform_user_id,
        app_id,
        scene_id,
        req_no,
        apply_no,
        channel_id,
        checkout_id,
        loan_id,
        flow_no,
        run_step,
        workflow_create_time,
        workflow_update_time,
        grass_date as create_date,
        grass_date,
        rank_id_for_flow_no,
        flow_trace_id
    FROM with_salt_rank
    WHERE rank_id_for_flow_no = 1   -- 先取每个 flow_no 的最新记录
-- )
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_af_${product}_workflow_di  partition(grass_date)
select platform_user_id,
        app_id,
        scene_id,
        req_no,
        apply_no,
        channel_id,
        checkout_id,
        loan_id,
        flow_no,
        run_step,
        workflow_create_time,
        workflow_update_time,
        create_date,
        rank_id_for_flow_no
        ,ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id, apply_no
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        ) AS rank_id_for_apply_no,
        -- 针对 checkout_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,channel_id,checkout_id
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        )  AS rank_id_for_checkout_id_channel_id,
        -- 针对 loan_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,loan_id
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        ) AS rank_id_for_loan_id
        ,flow_trace_id
        ,grass_date
    FROM flow_no_deduped
    where checkout_id is not null and apply_no is not null 
union all 

select platform_user_id,
        app_id,
        scene_id,
        req_no,
        apply_no,
        channel_id,
        checkout_id,
        loan_id,
        flow_no,
        run_step,
        workflow_create_time,
        workflow_update_time,
        create_date,
        rank_id_for_flow_no
        ,ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id, apply_no
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        ) AS rank_id_for_apply_no,
        -- 针对 checkout_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        null  AS rank_id_for_checkout_id_channel_id,
        -- 针对 loan_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        null AS rank_id_for_loan_id
        ,flow_trace_id
        ,grass_date
    FROM flow_no_deduped
    where checkout_id is null and apply_no is not null 
union all 


select platform_user_id,
        app_id,
        scene_id,
        req_no,
        apply_no,
        channel_id,
        checkout_id,
        loan_id,
        flow_no,
        run_step,
        workflow_create_time,
        workflow_update_time,
        create_date,
        rank_id_for_flow_no
        ,null AS rank_id_for_apply_no,
        -- 针对 checkout_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,channel_id,checkout_id
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        )  AS rank_id_for_checkout_id_channel_id,
        -- 针对 loan_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,loan_id
            ORDER BY workflow_create_time DESC, workflow_update_time DESC
        ) AS rank_id_for_loan_id
        ,flow_trace_id
        ,grass_date
    FROM flow_no_deduped
    where checkout_id is not null and apply_no is null 
union all 

-- 处理partition key 为空的数据倾斜的情况
select platform_user_id,
        app_id,
        scene_id,
        req_no,
        apply_no,
        channel_id,
        checkout_id,
        loan_id,
        flow_no,
        run_step,
        workflow_create_time,
        workflow_update_time,
        create_date,
        rank_id_for_flow_no
        ,null AS rank_id_for_apply_no,
        -- 如果为null,会数据倾斜,则rank也为null
        null AS rank_id_for_checkout_id_channel_id,
        -- 如果为null,会数据倾斜,则rank也为null
        null AS rank_id_for_loan_id
        ,flow_trace_id
        ,grass_date
    FROM flow_no_deduped
    where checkout_id is null   and apply_no is null 
;