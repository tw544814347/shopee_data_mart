-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-05
-- Theme Domain:        Anti-Fraud 
-- Data Granularity:    ticket_id
-- Description:         ticket_ops_tab dwd表
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-11-05 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.dwd_spp_${region}_risk_ticket_ops_df;
create table if not exists ${SCHEMA}.dwd_spp_${region}_risk_ticket_ops_df
(
    id  bigint
    ,ticket_id string
    ,flow_no string
    ,operator  string
    ,content string
    ,version bigint
    ,create_time string
    ,update_time string
    ,notes string
    ,content_notes string
    ,operation_type  bigint
    ,second_diff_create_update bigint
    ,start_time  string
    ,role  string
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
location '${HDFS_PATH}/risk_mart/dwd/dwd_spp_aio_risk_ticket_ops_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dwd_spp_${region}_risk_ticket_ops_df;


create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite ${SCHEMA}.dwd_spp_${region}_risk_ticket_ops_df PARTITION (grass_date = '${bizdate}')
select
    id
    ,ticket_id
    ,ticket_id as flow_no
    ,operator
    ,content
    ,version
    ,format_time(create_time, '${grass_region}') as create_time
    ,format_time(update_time, '${grass_region}') as update_time
    ,notes
    ,content_notes
    ,operation_type
    ,update_time - create_time as second_diff_create_update
    ,format_time(start_time, '${grass_region}') as start_time
    ,role
from risk.ods__shopeepay_risk_control_${region}_db__ticket_ops_tab__df
where grass_date = '${bizdate}'
;

