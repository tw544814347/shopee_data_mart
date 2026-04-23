
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite ${SCHEMA}.dwd_credit_ph_risk_ticket_ops_df partition (grass_date = '${grass_date}')
select 
    id,
    ticket_id,
    ticket_id as flow_no,
    operator,
    content,
    version,
    format_time(create_time, '${upper_region}') as create_time,
    format_time(update_time, '${upper_region}') as update_time,
    notes,
    content_notes,
    operation_type,
    update_time - create_time as second_diff_create_update,
    format_time(start_time, '${upper_region}') as start_time,
    role
from risk.ods__credit_risk_control_ph_db__ticket_ops_tab__df
where grass_date = '${grass_date}'
;
