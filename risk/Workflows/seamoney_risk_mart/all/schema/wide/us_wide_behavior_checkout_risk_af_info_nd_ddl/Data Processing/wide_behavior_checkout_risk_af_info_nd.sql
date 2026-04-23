drop table if exists risk.wide_behavior_checkout_risk_af_info_nd;
create  external table  risk.wide_behavior_checkout_risk_af_info_nd  (
    checkout_id                             string   comment 'apply_no'
   ,platform_user_id                        string   comment 'platform_user_id'
   ,credit_user_id                          string   comment 'credit_user_id'
   ,create_time                             string   comment 'checkout create time'
   ,channel_id                              string   comment 'checkout channel id '
   ,risk_check_type                         string   comment 'check type,0-CheckType_NONE,1-CheckType_NORMAL,2-CheckType_ESIGN,3-CheckType_LIVE,4-CheckType_OTP'
   ,risk_check_result                       string   comment 'check result,0-RiskControlResult_None,1-RiskControlResult_Pass,2-RiskControlResult_Reject'
   ,payment_result                          string   comment 'payment result,0-none,1-pending,2-succeess,3-failed,4-cancelled,5-combined: spl paid success; downpay paying,6-combined: spl cancled; downpay cancel'
   ,workflow_af_result                      string   comment 'workflow final_result,null=no log|0=undefine|1=pass|2=reject|3=challenge|other'
   ,workflow_step_af_result                 string   comment 'workflow_step final_result,null=no log|0=undefine|1=pass|2=reject|3=challenge|other'
   ,workflow_req_time                       string   comment 'workflow req time'
   ,workflow_step_req_time                  string   comment 'workflow step req time'
   ,uw_result                               string   comment 'uw_reuslt'
   ,af_tag_isonus                           string   comment 'af_tag isonus: 0-no 1-yea -1:nolog'
   ,af_tag_online                           string   comment 'tag_option_list_en_name'
   ,is_first_disbursement                   string   comment 'is first disbursement' 
   ,workflow_flow_no                        string   comment 'workflow flow no' 
   ,workflow_step_flow_no                   string   comment 'workflow step flow no'
   ,af_screen_result                        string   comment '0 - Unreviewed, 1 - Approved, 2 - Rejected' 
   ,af_screen_sla                           string   comment 'af screen sla seconds'
   ,workflow_task_run_step                  string 
   ,workflow_step_task_run_step             string 
   
   ) 
comment 'last 70days apply_no'
partitioned by (
grass_region  string   comment 'grass_region'  ,
biz_name      string   comment 'biz_name',
grass_date    string   comment 'grass_date')
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/ads/wide_behavior_checkout_risk_af_info_nd'
stored as orc TBLPROPERTIES (
  'orc.stripe.size' = '2147483648',
  'orc.compress' = 'SNAPPY')
;

msck repair table risk.wide_behavior_checkout_risk_af_info_nd;