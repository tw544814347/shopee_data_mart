--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2026-04-02
-- Theme Domain：       user referral
-- Description:         处理用户 referral 活动的 dim 中间表
-- 枚举解释
-- biz_type:            1=BCL 3=SPL
-- task_type:           1=注册任务(referee 注册即完成), 2=消费任务(referee 需完成最低消费)
-- user_referral_status:1=进行中, 3=已完成/已发奖
-- reminder_pn_send_status: 1=已发送 PN 提醒, 2=未发送
-- Data Granularity:    user_referral_id (每条记录 = 一个用户参与某期 referral 的某个 task)
-- Source Tables:
--   t1: credit.ods__credit_promotion_banner_${region}_db__pr_user_referral_tab__df
--   t2: credit.ods__credit_promotion_banner_${region}_db__pr_referral_tab__df
-- change logs
/*
    1. 所有地区整合为模版开发
*/
--********************************************************************--
ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time;
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

drop table if exists ${SCHEMA}.dim_risk_${region}_promotion_referral_info_df;
create external table if not exists ${SCHEMA}.dim_risk_${region}_promotion_referral_info_df
(
-- ─── Referral 活动维度（来自 pr_referral_tab + 展开 task_detail_list）───
 referral_id              string   comment 'referral 活动 ID'
,referral_name            string   comment 'referral 活动名称'
,biz_type                 string   comment 'biz_type: 3=SPL'
,complete_duration        bigint   comment '活动有效天数，referee 须在此天数内完成任务'
,task_type                string   comment '任务类型: 1=注册任务, 2=消费任务'
,task_min_spend_amount    bigint   comment '任务最低消费金额'
,task_min_tenure          bigint   comment '任务最小贷款期数'
,task_min_withdrawal_amount double comment '任务最小贷款金额'
,task_reminder            bigint   comment '是否开启 PN 提醒: 0=不提醒, 其他值=提醒次数/间隔配置'
,referrer_action_id       string   comment 'referrer 的奖励 action_id（取 task_reward[0].referrer_action_id_list[0]）'
,referee_action_id        string   comment 'referee 的奖励 action_id（取 task_reward[0].referee_action_id_list[0]）'
-- ─── 用户参与记录（来自 pr_user_referral_tab）───
,user_referral_id         string   comment '用户 referral 记录 ID'
,referrer_credit_user_id  string   comment 'referrer 的 credit_user_id'
,referrer_platform_type   bigint   comment 'referrer 的平台类型: 1=Shopee'
,referrer_platform_user_id string  comment 'referrer 的平台 user_id（Shopee user_id）'
,referee_credit_user_id   string   comment 'referee 的 credit_user_id'
,referee_platform_type    bigint   comment 'referee 的平台类型: 1=Shopee'
,referee_platform_user_id string   comment 'referee 的平台 user_id（Shopee user_id）'
,start_time               string   comment '任务开始时间（本地时间）'
,complete_time            string   comment '任务完成时间（本地时间）'
,start_timestamp          bigint   comment '任务开始时间戳（Unix 秒）'
,complete_timestamp       bigint   comment '任务完成时间戳（Unix 秒）'
,complete_value           bigint   comment '任务完成标记: 0=未达标, 1=已达标'
,user_referral_status     bigint   comment '用户 referral 状态: 1=进行中, 3=已完成/已发奖'
,reminder_pn_send_status  bigint   comment 'PN 提醒发送状态: 1=已发送, 2=未发送'
,reminder_pn_send_time    string   comment 'PN 提醒发送时间（本地时间）'
,reminder_pn_send_timestamp bigint comment 'PN 提醒发送时间戳（Unix 秒）'
,traffic_platform_type    bigint   comment '流量来源平台类型'
,traffic_platform_user_id string   comment '流量来源平台 user_id'
,create_time              string   comment '记录创建时间（本地时间）'
)
partitioned by (grass_date string comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_reg_promotion_referral_info_df/grass_region=${upper_region}';
;


msck repair table ${SCHEMA}.dim_risk_${region}_promotion_referral_info_df;
refresh table ${SCHEMA}.dim_risk_${region}_promotion_referral_info_df;

-- ─── 数据加工逻辑 ───
-- 加工用户参与的 referral 活动记录，包含：
--   活动配置维度（活动名、有效天数、task 类型、最低消费门槛、奖励 action_id）
--   用户参与维度（referrer/referee 信息、任务完成状态、时间、PN 提醒信息）
insert overwrite table ${SCHEMA}.dim_risk_${region}_promotion_referral_info_df partition(grass_date='${grass_date}')
select
    -- ─── 活动维度 ───
     t2.referral_id
    ,t2.referral_name
    ,t2.biz_type
    ,t2.complete_duration
    ,t2.task_type
    ,t2.task_min_spend_amount
    ,t2.task_min_tenure
    ,t2.task_min_withdrawal_amount
    ,t2.task_reminder
    ,t2.referrer_action_id
    ,t2.referee_action_id
    -- ─── 用户记录维度 ───
    ,cast(t1.user_referral_id as string)        as user_referral_id
    ,cast(t1.referrer_credit_user_id as string) as referrer_credit_user_id
    ,t1.referrer_platform_type
    ,t1.referrer_platform_user_id
    ,cast(t1.referee_credit_user_id as string)  as referee_credit_user_id
    ,t1.referee_platform_type
    ,t1.referee_platform_user_id
    ,format_time(t1.start_time,    upper('${region}')) as start_time
    ,format_time(t1.complete_time, upper('${region}')) as complete_time
    ,t1.start_time    as start_timestamp
    ,t1.complete_time as complete_timestamp
    ,t1.complete_value
    ,t1.user_referral_status
    ,t1.reminder_pn_send_status
    ,format_time(t1.reminder_pn_send_time, upper('${region}')) as reminder_pn_send_time
    ,t1.reminder_pn_send_time as reminder_pn_send_timestamp
    ,t1.traffic_platform_type
    ,t1.traffic_platform_user_id
    ,format_time(cast(unix_timestamp(t1.create_time, 'yyyy-MM-dd HH:mm:ss') as bigint), upper('${region}')) as create_time

from credit.ods__credit_promotion_banner_${region}_db__pr_user_referral_tab__df t1
join (
    -- 活动配置维度：将 task_detail_list JSON 数组展开为每个 task 一行，
    -- 再与用户记录按 (referral_id, task_type) 关联
    select
         referral_id
        ,referral_name
        ,cast(biz_type as string)                                                              as biz_type
        ,complete_duration
        ,cast(get_json_object(task_item, '$.task_type') as string)                            as task_type
        ,cast(get_json_object(task_item, '$.task_criteria.min_spend_amount') as bigint)       as task_min_spend_amount
        ,cast(get_json_object(task_item, '$.task_criteria.min_tenure') as bigint)             as task_min_tenure
        ,cast(get_json_object(task_item, '$.task_criteria.min_withdrawal_amount') as double)  as task_min_withdrawal_amount
        ,cast(get_json_object(task_item, '$.task_reminder') as bigint)                        as task_reminder
        ,get_json_object(task_item, '$.task_reward[0].referrer_action_id_list[0]')            as referrer_action_id
        ,get_json_object(task_item, '$.task_reward[0].referee_action_id_list[0]')             as referee_action_id
    from (
        select
             cast(referral_id as string)  as referral_id
            ,referral_name
            ,biz_type
            ,complete_duration
            ,explode(from_json(task_detail_list, 'array<string>')) as task_item
        from credit.ods__credit_promotion_banner_${region}_db__pr_referral_tab__df
        where grass_date = '${grass_date}'
    )
) t2
    on  cast(t1.referral_id as string) = t2.referral_id
    and cast(t1.task_type   as string) = t2.task_type
where t1.grass_date = '${grass_date}'
;
