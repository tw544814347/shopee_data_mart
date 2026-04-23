drop table if exists risk.dwd_risk_id_spl_referral_result_df;
create external table if not exists risk.dwd_risk_id_spl_referral_result_df
(
referral_id                     string comment 'referral_id'
,referral_name                   string comment 'referral_name'
,user_referral_id                string comment 'user_referral_id'
,task_type                       int    comment '任务类型, 1: activation, 2: purchase'
,biz_type                        int    comment 'biz_type'
,referrer_platform_user_id       string comment '推荐人puid'
,referee_platform_user_id        string comment '被推荐人puid'
,referrer_credit_user_id         string comment '推荐人credit_uid'
,referee_credit_user_id          string comment '被推荐人credit_uid'
,referrer_platform_type          string comment '推荐人platform_type'
,referee_platform_type           string comment '被推荐人platform_type'
,complete_duration               int    comment '推荐任务完成时间配置,n: n天，单位为Day'
,referrer_start_time             string comment '推荐任务开始时间 local'
,referrer_complete_time          string comment '推荐任务完成时间 local'
,user_referral_status            int    comment '推荐任务状态 1:doing, 2:completed, 3:rewarded'
,referral_create_time            string comment '推荐任务创建时间local'
,referral_update_time            string comment '推荐任务更新local'
,referee_order_id                string comment '被推荐人的order_id' 
,referee_order_amount            decimal(32,10) comment '被推荐人order amount'
,completed_value                 string comment 'completed_value'
-- ,min_spend_amount                string comment 'min_spend_amount'
)
partitioned by (
biz_name        string comment 'biz_name '
,grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_spl_referral_result_df/grass_region=ID';
;