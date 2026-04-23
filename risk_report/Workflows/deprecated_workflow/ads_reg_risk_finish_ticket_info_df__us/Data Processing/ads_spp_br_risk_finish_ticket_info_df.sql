--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-06
-- Theme Domain：       Risk Ticket综合信息表(SPP)
-- Description:         整合ticket主表和最新操作记录,提供完整的ticket数据
-- Data Granularity:    ticket_id
-- 变更历史：
--  2025-11-06 Initial version - 整合dwd_spp_${region}_risk_ticket_df和dwd_spp_${region}_risk_ticket_ops_df
--********************************************************************--


drop table if exists ${SCHEMA}.ads_spp_${region}_risk_finish_ticket_info_df;
create table if not exists ${SCHEMA}.ads_spp_${region}_risk_finish_ticket_info_df
(
    -- ticket主表字段
    ticket_id                          string comment 'ticket_id'
    ,app_id                             string comment 'app_id'
    ,scene_id                           string comment 'scene_id'
    ,ticket_category                    int comment '0 - Undefined, 1 - Liveness Check, 2 - KYC, 3 - IVR, 4 - Listing, 5 - Common 6 - Transaction 7- spr, 100-invokepolicy not real ticket'
    ,ticket_subtype                     int comment 'ticket_subtype'
    ,platform_user_id                   string comment 'platform_user_id'
    ,shopeepay_user_id                  string comment 'shopeepay_user_id'
    ,case_id                            string comment 'case_id'
    ,application_source                 string comment 'application_source'
    ,assignee                           string comment 'assignee from ticket table'
    ,status                             int comment '0 - Unassigned, 1 - Waiting, 2 - Done'
    ,af_screen_result                   int comment '0 - Unreviewed, 1 - Approved, 2 - Rejected'
    ,reject_reason                      string comment 'reject_reason'
    ,af_screen_start_time               string comment 'create_time, Approximate business time using system time'
    ,af_screen_update_time              string comment 'update_time, Approximate business time using system time'
    ,af_screen_sla_second               bigint comment 'update_time - create_time'
    ,kyc_tag_list                       string comment 'kyc_tag_list'
    ,ic_type                            string comment 'ic_type'
    ,notes                              string comment 'notes from ticket table'
    ,application_id                     string comment 'application_id'
    ,kyc_level                          string comment 'kyc_level'
    -- ticket_ops表字段 (最新操作记录)
    ,ops_operator                       string comment 'operator from ops table'
    ,ops_content                        string comment 'operation content'
    ,ops_version                        bigint comment 'version from ops table'
    ,ops_create_time                    string comment 'ops record create time'
    ,ops_update_time                    string comment 'ops record update time'
    ,ops_notes                          string comment 'notes from ops table'
    ,ops_content_notes                  string comment 'content notes from ops table'
    ,ops_operation_type                 bigint comment 'operation type'
    ,ops_second_diff_create_update      bigint comment 'seconds between create and update in ops'
    ,ops_start_time                     string comment 'operation start time'
    ,ops_role                           string comment 'operator role'
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
location '${HDFS_PATH}/risk_mart/ads/ads_spp_reg_risk_finish_ticket_info_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.ads_spp_${region}_risk_finish_ticket_info_df;


-- 创建临时视图：从ops表中按ticket_id取最新操作记录
create or replace temporary view tmp_latest_ticket_ops as
select 
    ticket_id
    ,operator
    ,content
    ,version
    ,create_time
    ,update_time
    ,notes
    ,content_notes
    ,operation_type
    ,second_diff_create_update
    ,start_time
    ,role
from (
    select 
        ticket_id
        ,operator
        ,content
        ,version
        ,create_time
        ,update_time
        ,notes
        ,content_notes
        ,operation_type
        ,second_diff_create_update
        ,start_time
        ,role
        ,row_number() over (partition by ticket_id order by start_time desc) as row_num
    from risk.dwd_spp_${region}_risk_ticket_ops_df
    where grass_date = '${grass_date}'
    and role = 'maker'
    and start_time is not null
) t
where row_num = 1
;

-- 插入数据：关联ticket主表和最新操作记录
insert overwrite ${SCHEMA}.ads_spp_${region}_risk_finish_ticket_info_df partition (grass_date = '${grass_date}')
select
    -- ticket主表字段
    t.ticket_id                         as ticket_id
    ,t.app_id                           as app_id
    ,t.scene_id                         as scene_id
    ,t.ticket_category                  as ticket_category
    ,t.ticket_subtype                   as ticket_subtype
    ,t.platform_user_id                 as platform_user_id
    ,t.shopeepay_user_id                as shopeepay_user_id
    ,t.case_id                          as case_id
    ,t.application_source               as application_source
    ,t.assignee                         as assignee
    ,t.status                           as status
    ,t.af_screen_result                 as af_screen_result
    ,t.reject_reason                    as reject_reason
    ,t.af_screen_start_time             as af_screen_start_time
    ,t.af_screen_update_time            as af_screen_update_time
    ,t.af_screen_sla_second             as af_screen_sla_second
    ,t.kyc_tag_list                     as kyc_tag_list
    ,t.ic_type                          as ic_type
    ,t.notes                            as notes
    ,t.application_id                   as application_id
    ,t.kyc_level                        as kyc_level
    -- ticket_ops表字段 (最新操作记录)
    ,ops.operator                       as ops_operator
    ,ops.content                        as ops_content
    ,ops.version                        as ops_version
    ,ops.create_time                    as ops_create_time
    ,ops.update_time                    as ops_update_time
    ,ops.notes                          as ops_notes
    ,ops.content_notes                  as ops_content_notes
    ,ops.operation_type                 as ops_operation_type
    ,ops.second_diff_create_update      as ops_second_diff_create_update
    ,ops.start_time                     as ops_start_time
    ,ops.role                           as ops_role
from risk.dwd_spp_${region}_risk_ticket_df t
left join tmp_latest_ticket_ops ops
    on t.ticket_id = ops.ticket_id
where t.grass_date = '${grass_date}'
  and t.status = 2
;


