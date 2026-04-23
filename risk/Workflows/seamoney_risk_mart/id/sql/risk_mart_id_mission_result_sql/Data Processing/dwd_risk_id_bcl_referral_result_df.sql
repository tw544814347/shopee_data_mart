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
--   t1: credit.ods__credit_promotion_banner_region_db__pr_user_referral_tab__df
--   t2: credit.ods__credit_promotion_banner_region_db__pr_referral_tab__df
-- change logs
-- 需求在第12行,https://docs.google.com/spreadsheets/d/1ChkkJhYdCJfk_cud72xAJX58N6Zi4L-_rD2iMHRAWbY/edit?gid=0#gid=0
/*
    1. 所有地区整合为模版开发
*/
--********************************************************************--
ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time;
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

drop table if exists ${SCHEMA}.dwd_risk_${region}_bcl_referral_result_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_bcl_referral_result_df
(
-- ─── Referral 活动维度（来自 pr_referral_tab + 展开 task_detail_list）───
 referral_id              string   comment 'referral 活动 ID'
,referral_name            string   comment 'referral 活动名称'
,user_referral_id         STRING   COMMENT 'user_referral_id'
,task_type                INT COMMENT '任务类型, 1: activation, 2: purchase'
,biz_type                 Int   comment 'biz_type: 3=SPL, 1=BCL'
,`referrer_platform_user_id` STRING COMMENT '推荐人puid',
    `referee_platform_user_id` STRING COMMENT '被推荐人puid',
    `referrer_credit_user_id` STRING COMMENT '推荐人credit_uid',
    `referee_credit_user_id` STRING COMMENT '被推荐人credit_uid',
    `referrer_platform_type` STRING COMMENT '推荐人platform_type',
    `referee_platform_type` STRING COMMENT '被推荐人platform_type',
    `complete_duration` INT COMMENT '推荐任务完成时间配置,n: n天，单位为Day',
    `referrer_start_time` STRING COMMENT '推荐任务开始时间 local',
    `referrer_complete_time` STRING COMMENT '推荐任务完成时间 local',
    `user_referral_status` INT COMMENT '推荐任务状态 1:doing, 2:completed, 3:rewarded',
    `referral_create_time` STRING COMMENT '推荐任务创建时间local',
    `referral_update_time` STRING COMMENT '推荐任务更新local',
    `referee_order_id` STRING COMMENT '被推荐人的loan_id',
    `referee_order_amount` DECIMAL(32, 10) COMMENT '被推荐人loan principal',
    `completed_value` STRING COMMENT 'completed_value',
    term_num bigint comment '被推荐人的loan tenure',
    transaction_time STRING comment '被推荐人的loan交易时间'
)
partitioned by (grass_date string comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_reg_bcl_referral_result_df/grass_region=${upper_region}';
;


show create table risk.dwd_risk_id_spl_referral_result_df;

msck repair table ${SCHEMA}.dwd_risk_${region}_bcl_referral_result_df;
refresh table ${SCHEMA}.dwd_risk_${region}_bcl_referral_result_df;

-- ─── 数据加工逻辑 ───
-- 加工用户参与的 referral 活动记录，包含：
--   活动配置维度（活动名、有效天数、task 类型、最低消费门槛、奖励 action_id）
--   用户参与维度（referrer/referee 信息、任务完成状态、时间、PN 提醒信息）
insert overwrite table ${SCHEMA}.dwd_risk_${region}_bcl_referral_result_df partition(grass_date='${grass_date}')
    select 
    t1.referral_id               
    ,t1.referral_name            
    ,t1.user_referral_id         
    ,cast(t1.task_type as int) as task_type              
    ,cast(t1.biz_type as int) as biz_type                
    ,t1.referrer_platform_user_id
    ,t1.referee_platform_user_id 
    ,t1.referrer_credit_user_id  
    ,t1.referee_credit_user_id   
    ,t1.referrer_platform_type   
    ,t1.referee_platform_type    
    ,cast(t1.complete_duration as int) as complete_duration        
    ,t1.start_time    as referrer_start_time      
    ,t1.complete_time as referrer_complete_time   
    ,cast(t1.user_referral_status as int) as user_referral_status         
    ,t1.create_time as referral_create_time     
    ,null as referral_update_time                 -- 上游dim表没有保留update_time,这里先置空,有需要再添加该信息  add by dongbo.yu at 2026-04-07
    ,t2.referee_order_id
    ,cast(t2.referee_order_amount as decimal) as referee_order_amount   
    ,1 as completed_value  
    ,t2.term_num
    ,t2.transaction_time
from risk.dim_risk_${region}_promotion_referral_info_df t1 
left join (
    select 
        t21.credit_user_id as credit_user_id
        ,t21.loan_id as referee_order_id
        ,t21.loan_tenure as term_num
        ,t21.principal as referee_order_amount
        ,t21.disburse_actual_done_time as transaction_time
    from credit_mart.dwd_bcl_${region}_txn_order_df t21
    where t21.grass_date ='${grass_date}'
    -- biztype为1（BCL）且满足以上时间条件和任务标准的订单即视为任务完成，completevalue设为1
    -- 贷款状态：cl_loan_info_tab.status（>=499 视为完成贷款放款）
    and t21.loan_status>=499
    group by t21.credit_user_id
        ,t21.loan_id 
        ,t21.loan_tenure
        ,t21.principal
        ,t21.disburse_actual_done_time
) t2 on t1.referee_credit_user_id = t2.credit_user_id
where
t1.biz_type=1
-- 需判断订单时间（放款时间）在[pr_user_referral_tab.start_time,pr_user_referral_tab.complete_time]范围内
and cast(t1.start_time as timestamp) <= cast(t2.transaction_time as timestamp)
and cast(t1.complete_time as timestamp) >= cast(t2.transaction_time as timestamp)
-- min_tenure为最小期数，min_withdrawal_amount为最小贷款数（min_tenure和min_withdrawal_amount都可以为0，都为0代表只需要满足任意贷款即可）
and t1.task_min_withdrawal_amount <= t2.referee_order_amount
and t1.task_min_tenure <= t2.term_num
;
