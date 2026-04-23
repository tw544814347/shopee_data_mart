-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-20
-- Theme Domain:        Risk Mart Antifraud
-- Data Granularity:    rowKey
-- Description:         datapoint hbase2hive数据保留切片表
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-11-19 - chengguo.liu - 初始化  datapoint hbase设置了ttl，hbase2hive数据去重保留到切片表
-- =============================================================================

----risk.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_df是hbase2hive dump自动生成的表，指向最新分区，不方便改动
----hbase to hive同步数据任务，dump hdfs路径，建临时外表，用于初始化
--drop table if exists ${SCHEMA}.tmp_dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_df;
--create external table if not exists ${SCHEMA}.tmp_dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_df (
--    rowKey string
--    ,comms string
--    ,app_id string
--    ,event_timestamp bigint
--    ,env string
--    ,userid bigint
--    ,log_timestamp bigint
--    ,task_id string
--)
--partitioned by
--(
--    grass_date     string
--)
--stored as parquet
--location 'hdfs://R2/projects/risk/hdfs/ingestion/hbi/hbase_to_hive/hbase_dump_result/SG-AT/risk/dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_df'
--;
--msck repair table risk.tmp_dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_df;


--drop table if exists ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df;
create external table if not exists ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df
(
    rowkey string comment 'shopee user id'
    ,comms string comment 'the ip of first login time'
    ,app_id string
    ,event_timestamp bigint
    ,env string
    ,userid bigint
    ,log_timestamp bigint
    ,task_id string
)
comment 'risk mart summary table'
partitioned by
(
    grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df';
--msck repair table ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df;


insert overwrite table ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df partition (grass_date)
select
    rowkey
    ,comms
    ,app_id
    ,event_timestamp
    ,env
    ,userid
    ,log_timestamp
    ,task_id
    ,'${grass_date}' as grass_date
from
(
    select
        rowkey
        ,comms
        ,app_id
        ,event_timestamp
        ,env
        ,userid
        ,log_timestamp
        ,task_id
        ,row_number() over(partition by rowkey order by event_timestamp desc, log_timestamp desc) as rn
    from
    (
        select
            rowkey
            ,comms
            ,app_id
            ,event_timestamp
            ,env
            ,userid
            ,log_timestamp
            ,task_id
        from ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df
        where grass_date = date_sub('${grass_date}', 1)
        union all
        select
            rowkey
            ,comms
            ,app_id
            ,event_timestamp
            ,env
            ,userid
            ,log_timestamp
            ,task_id
        from risk.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_df  --hbase dump hdfs表，指向的是最新分区
    ) t1
) tt1
where rn = 1
;