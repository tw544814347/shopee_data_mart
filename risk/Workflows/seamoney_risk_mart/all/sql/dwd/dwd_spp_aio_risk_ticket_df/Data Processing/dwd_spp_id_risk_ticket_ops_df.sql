-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-08-25
-- Theme Domain:        Anti-Fraud 
-- Data Granularity:    ticket_id
-- Description:         ticket_ops_tab dwd表
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-21 - chengguo.liu - 初始化
-- =============================================================================


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

