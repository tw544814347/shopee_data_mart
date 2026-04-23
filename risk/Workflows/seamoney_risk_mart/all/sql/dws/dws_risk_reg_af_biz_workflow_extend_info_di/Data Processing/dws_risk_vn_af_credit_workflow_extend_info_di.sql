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

-- SET spark.sql.adaptive.enabled = true;
-- SET spark.sql.adaptive.skewJoin.enabled = true;
-- SET spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes = 512MB;
-- SET spark.sql.shuffle.partitions = 1200;

-- drop table if exists ${SCHEMA}.`dws_risk_${region}_af_${product}_workflow_extend_info_di`;

create table if not exists ${SCHEMA}.`dws_risk_${region}_af_${product}_workflow_extend_info_di` (
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
    flow_trace_id STRING COMMENT 'flow_trace_id, this flow_trace_id for spp',
    input STRING COMMENT 'input',
    output STRING COMMENT 'output'
) 
-- comment 'credit mart summary table' 
partitioned by (
    grass_date string comment 'Date of refreshed data, contains recent 190 days data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dws_risk_reg_af_biz_workflow_extend_info_di/biz_name=${product}/grass_region=${REGION}'
;


-- msck repair table ${SCHEMA}.dws_risk_${region}_af_${product}_workflow_extend_info_di;
refresh table ${SCHEMA}.dws_risk_${region}_af_${product}_workflow_extend_info_di;

-- ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
-- drop temporary function if exists format_time; 
-- create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table ${SCHEMA}.dws_risk_${region}_af_${product}_workflow_extend_info_di  partition(grass_date)
select  t1.platform_user_id,
        t1.app_id,
        t1.scene_id,
        t1.req_no,
        t1.apply_no,
        t1.channel_id,
        t1.checkout_id,
        t1.loan_id,
        t1.flow_no,
        t1.run_step,
        t1.workflow_create_time,
        t1.workflow_update_time,
        t1.create_date,
        t1.rank_id_for_flow_no
        ,t1.rank_id_for_apply_no
        ,t1.rank_id_for_checkout_id_channel_id
        ,t1.rank_id_for_loan_id
        ,t2.flow_trace_id
        ,t2.input
        ,t2.output
        ,t1.grass_date
from 
(
    SELECT
    platform_user_id
    ,app_id
    ,scene_id
    ,req_no
    ,apply_no
    ,channel_id
    ,checkout_id
    ,loan_id
    ,flow_no
    ,run_step
    ,workflow_create_time
    ,workflow_update_time
    ,create_date
    ,rank_id_for_flow_no
    ,rank_id_for_apply_no
    ,rank_id_for_checkout_id_channel_id
    ,rank_id_for_loan_id
    ,grass_date
    FROM risk.dws_risk_${region}_af_${product}_workflow_di
    WHERE grass_date >= date('${grass_date}') - INTERVAL '${grass_cnt}' DAYS
      AND grass_date <= '${grass_date}'
)
 t1 inner join (
    select flow_no
    -- shopeepay业务下,input字段太大了,在spll/shuffle过程中会使得单个Executor 磁盘超过 25GB而报错,所以需要截断  by dongbo.yu at 2026-02-25
    -- 此处采取阉割input字段,只保留比较常用的CommonHeader部分,其他内容丢弃,待有需求再做优化 by dongbo.yu at 2026-02-25
    ,case when '${product}'='shopeepay' then get_json_object(CAST(UNBASE64(GET_JSON_OBJECT(input, '$.Params')) AS STRING),'$.CommonHeader') else input end as input
    ,output
    ,GET_JSON_OBJECT(CAST(UNBASE64(GET_JSON_OBJECT(input, '$.Params')) AS STRING),'$.flow_trace_id') AS flow_trace_id
    ${comment_flag},ROW_NUMBER() OVER ( PARTITION BY flow_no ORDER BY create_time DESC, update_time DESC) as rn 
    FROM risk.dwd_risk_${region}_af_${product}_workflow_di
    WHERE grass_date >= date('${grass_date}') - INTERVAL '${grass_cnt}' DAYS
      AND grass_date <= '${grass_date}'
      -- AND length(flow_no)>0   -- 过滤掉flow_no为空的情况 add by dongbo.yu at 2026-02-24  去掉这个条件,基本不存在flow_no为空的情况
) t2 
on t1.flow_no=t2.flow_no
 ${comment_flag} where t2.rn=1
;
