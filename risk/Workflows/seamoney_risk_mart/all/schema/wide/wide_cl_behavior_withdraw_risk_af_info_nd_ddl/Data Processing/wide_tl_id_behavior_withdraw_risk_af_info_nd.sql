drop table if exists risk.wide_tl_id_behavior_withdraw_risk_af_info_nd;
create  external table  risk.wide_tl_id_behavior_withdraw_risk_af_info_nd  (
    loan_id                                 string   comment 'loan_id'
   ,credit_user_id                          string   comment 'credit_user_id'
   ,create_time                             string   comment 'loan id create time'
   ,loan_status                             string   comment 'loan status;100:pre submission,200:auditing,201:audit failed,300:audit succeeded,400:disbursing,401:disburse failed,500:disburse succeeded'
   ,workflow_af_result                      string   comment 'workflow final_result,null=no log|0=undefine|1=pass|2=reject|3=challenge|other'
   ,workflow_step_af_result                 string   comment 'workflow_step final_result,null=no log|0=undefine|1=pass|2=reject|3=challenge|other'
   ,workflow_req_time                       string   comment 'workflow req time'
   ,workflow_step_req_time                  string   comment 'workflow step req time'
   ,uw_result                               string   comment 'uw result'
   ,do_submit_time                          string   comment '确认提交时间'
   ,verify_done_time                        string   comment '审核成功时间'
   ,verify_fail_time                        string   comment '审核失败时间'
   ,workflow_flow_no                        string   comment 'workflow_flow_no'
   ,workflow_step_flow_no                   string   comment 'workflow_step_flow_no'
   ,af_screen_result                        string   comment 'risk人审结果'
   ,af_screen_sla                           string   comment 'risk人审sla seconds'
   ,workflow_task_run_step                  string 
   ,workflow_step_task_run_step             string 
   ) 
comment 'last 70days apply_no'
partitioned by (
grass_date    string   comment 'grass_date')
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/wide_cl_behavior_withdraw_risk_af_info_nd/grass_region=ID/biz_name=tl'
stored as orc TBLPROPERTIES (
  'orc.stripe.size' = '2147483648',
  'orc.compress' = 'SNAPPY')
;

msck repair table risk.wide_tl_id_behavior_withdraw_risk_af_info_nd;