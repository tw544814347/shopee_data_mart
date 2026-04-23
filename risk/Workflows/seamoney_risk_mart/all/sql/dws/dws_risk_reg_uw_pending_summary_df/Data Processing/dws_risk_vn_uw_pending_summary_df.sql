-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-04
-- Theme Domain:        UnderWriting activation pending
-- Data Granularity:    workflow_flow_no
-- Description:         UnderWriting Pending汇总表，统计每个flow的pending次数和时长
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-11-04 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_${region}_uw_pending_summary_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_uw_pending_summary_df
(
    workflow_flow_no            string comment 'workflow flow number'
    ,uw_pending_cnt             bigint comment 'pending次数统计'
    ,uw_pending_second          bigint comment 'pending累计总时长(秒)'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_uw_pending_summary_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_uw_pending_summary_df;


insert overwrite ${SCHEMA}.dws_risk_${region}_uw_pending_summary_df partition (grass_date = '${grass_date}')
select
    flow_no as workflow_flow_no
    ,count(1) as uw_pending_cnt
    ,sum(
        unix_timestamp(pending_finish_time, 'yyyy-MM-dd HH:mm:ss') - 
        unix_timestamp(pending_start_time, 'yyyy-MM-dd HH:mm:ss')
    ) as uw_pending_second
from risk.dwd_risk_${region}_underwriting_invoke_policy_result_history_df
where grass_date = '${grass_date}'
group by flow_no
;

