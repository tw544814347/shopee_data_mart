--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-09
-- Theme Domain：       flow_no_tag
-- Description:         因为目前只有ID才有处理逻辑，其他region都是空表,此任务用于发marker,方便后续的任务能统一使用模板
-- Data Granularity:    flow_no
-- 变更历史：
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.dwd_${region}_af_flow_no_tag_di;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dwd_${region}_af_flow_no_tag_di
(   
    flow_no         string
    ,mis_merchant   string
    ,is_first_disbursement string
)partitioned by (
    app_id          string,
    scene_id        string,
    grass_date      string
)
stored as parquet tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/dwd/dwd_af_flow_no_tag_di/grass_region=${upper_region}';
msck repair table ${SCHEMA}.dwd_${region}_af_flow_no_tag_di;