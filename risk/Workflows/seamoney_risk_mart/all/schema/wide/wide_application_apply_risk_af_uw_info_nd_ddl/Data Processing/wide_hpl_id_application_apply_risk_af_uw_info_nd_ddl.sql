drop table if exists risk.wide_${product}_${region}_application_apply_risk_af_uw_info_nd;
create  external table  risk.wide_${product}_${region}_application_apply_risk_af_uw_info_nd  (
    apply_no                                string   comment 'apply_no'
   ,platform_user_id                        string   comment 'platform_user_id'
   ,credit_user_id                          string   comment 'credit_user_id'
   ,apply_create_time                       string   comment 'apply_create_time'
   ,activate_submit_time                    string   comment 'activate_submit_time'
   ,apply_type                              string   comment 'apply_type'
   ,apply_status                            string   comment 'apply_status'
   ,rejected_reason_type                    string   comment 'rejected_reason_type'
   ,screen_status                           string   comment 'screen_status'
   ,risk_resp_flow_no                       string   comment 'risk_resp_flow_no'
   ,af_share_kyc_type                       string   comment 'kyc,voi'
   ,af_result_share_kyc_10001               string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_share_kyc_10001_10012         string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_share_kyc_10001_10012_screen  string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10011                         string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10011_10012                   string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10011_10013                   string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10011_10014                   string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,uw_result                               string   comment 'null=no log,-1=other,1=pass,2=reject,3=pending'
   ,user_label                              string   comment 'user_label'
   ,is_af_inner_platform_user_id            string   comment '1=yes 0=no'
   ,is_uw_inner_platform_user_id            string   comment '1=yes 0=no'
   ,af_result_spr_10001                     string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq ph bcl special strategy'
   ,uc_screen_update_info_result            string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq ID spl special strategy'
   ,af_result_10001                         string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10001_10012                   string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10001_10013                   string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,rejected_reason                         string   comment 'rejected_reason'
   ,reject_code                             string   comment 'reject_code'   
   ,af_result_10001_10003                   string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10011_10012_screen            string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10001_10012_screen            string   comment 'null:no log data, 1:pass, 2:reject, other : https://shp.ee/sq'
   ,af_result_10001_10003_screen            string   comment 'only for TH scl'
   ,is_skip_idwall                          string   comment 'only for br spl, null:no data, 0:no, 1:yes'
   ,otp_status                              string   comment 'TP Bank OTP result. 1-pending;2-pass;3-reject,only for VN,other region set null'
   ,bank_status                             string   comment 'TP Bank uw result. 1-pending;2-pass;3-reject,only for VN,other region set null' 
   ,af_kyc_risk_screen_sla                  bigint   comment 'kyc ->screen sla Unit: seconds'
   ,af_kyc_workflow_flow_no                 string   comment 'af_kyc_workflow_flow_no'
   ,af_af_workflow_flow_no                  string   comment 'af_af_workflow_flow_no'
   ,af_kyc_workflow_task_run_step           string   comment ''
   ,af_af_workflow_task_run_step            string   comment ''
   ) 
comment 'last 70days apply_no'
partitioned by (
grass_date    string   comment 'grass_date')
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/wide_application_apply_info_nd/grass_region=${upper_region}/biz_name=${product}'
stored as orc TBLPROPERTIES (
  'orc.compress' = 'zstd')
;

msck repair table risk.wide_${product}_${region}_application_apply_risk_af_uw_info_nd;