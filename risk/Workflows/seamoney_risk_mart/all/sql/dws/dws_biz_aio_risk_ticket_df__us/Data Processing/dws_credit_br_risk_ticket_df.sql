-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-27
-- Theme Domain:        Risk Ticket and Operations
-- Data Granularity:    workflow_flow_no
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-11-27 - chengguo.liu - 初始化 - jira: https://jira.shopee.io/browse/SPFDT-58048, SG/TW目前没有工单数据
-- =============================================================================


drop table if exists ${SCHEMA}.dws_credit_${region}_risk_ticket_df;
create external table if not exists ${SCHEMA}.dws_credit_${region}_risk_ticket_df
(
    workflow_flow_no string comment 'ticket no'
    ,app_id string comment 'app_id'
    ,scene_id bigint comment 'scene_id'
    ,product_code string comment 'product_code'
    ,ticket_category int comment '0 - Undefined, 1 - Liveness Check, 2 - KYC, 3 - IVR, 4 - Listing, 5 - Common 6 - Transaction 7- spr, 100-invokepolicy not real ticket'
    ,ticket_category_name string comment 'ticket category name'
    ,ticket_subtype int comment 'ticket subtype'
    ,platform_user_id string comment 'platform user id'
    ,credit_user_id string comment 'credit user id'
    ,shopeepay_user_id string comment 'shopeepay user id'
    ,status int comment '0 - Unassigned, 1 - Waiting, 2 - Done'
    ,status_name string comment 'status name'
    ,result int comment '0 - Unreviewed, 1 - Approved, 2 - Rejected'
    ,result_name string comment 'result name'
    ,assignee string comment 'assignee'
    ,maker_email string comment 'maker email'
    ,maker_map_no string comment 'maker map no'
    ,ticket_start_time string comment 'ticket start time'
    ,ticket_end_time string comment 'ticket end time'
    ,ticket_sla_seconds bigint comment 'ticket sla seconds'
    ,maker_end_time string comment 'maker end time'
    ,maker_start_time string comment 'maker start time'
    ,operator string comment 'operator'
)
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_credit_${region}_risk_ticket_df';
msck repair table ${SCHEMA}.dws_credit_${region}_risk_ticket_df;


create or replace temporary view tmp_ticket_ops_dedup as (
    select
        ticket_id as workflow_flow_no
        ,operator
        ,create_time as maker_start_time
    from
        (
            select
                ticket_id
                ,create_time
                ,operator
                ,row_number() over (
                    partition by ticket_id
                    order by create_time desc, update_time desc
                ) as rn
            from risk.dwd_credit_${region}_risk_ticket_ops_df
            where
                grass_date = '${grass_date}'
                and operation_type = 1 -- 分配工单
        ) as ranked_ops
    where rn = 1
)
;


insert overwrite table ${SCHEMA}.dws_credit_${region}_risk_ticket_df partition (grass_date = '${grass_date}')
select
    t1.workflow_flow_no
    ,t1.app_id
    ,t1.scene_id
    ,t1.product_code
    ,t1.ticket_category
    ,t1.ticket_category_name
    ,t1.ticket_subtype
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,'null' as shopeepay_user_id
    ,t1.status
    ,t1.status_name
    ,t1.result
    ,t1.result_name
    ,t1.assignee
    ,t1.maker_email
    ,t1.maker_map_no
    ,t1.ticket_start_time
    ,t1.ticket_end_time
    ,t1.ticket_sla_seconds
    ,t1.ticket_end_time as maker_end_time
    ,t2.maker_start_time
    ,t2.operator
from
    risk.dwd_credit_${region}_risk_ticket_df as t1
    left join tmp_ticket_ops_dedup as t2 on t1.workflow_flow_no = t2.workflow_flow_no
where t1.grass_date = '${grass_date}'
;