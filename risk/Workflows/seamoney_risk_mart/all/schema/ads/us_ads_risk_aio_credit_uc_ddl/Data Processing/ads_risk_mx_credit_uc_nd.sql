drop table if exists risk.ads_risk_mx_credit_uc_nd;

CREATE TABLE IF NOT EXISTS ads_risk_mx_credit_uc_nd (
    -- UC fields
    apply_no                    STRING,
    main_apply_no               STRING,
    platform_type               STRING,
    platform_user_id            STRING,
    credit_user_id              STRING,
    apply_type                  INT,
    apply_status                INT,
    rejected_reason_type        STRING,
    screen_status               INT,
    rejected_reason             STRING,
    reject_code                 STRING,
    risk_resp_flow_no           STRING,
    create_time                 STRING,
    activate_start_time         STRING,
    activate_submit_time        STRING,
    -- Risk fields
    spl_kyc_af_wf_task_run_step  STRING,
    spl_kyc_af_wf_final_result   STRING,
    spl_kyc_af_wf_uw_result      INT,
    spl_kyc_af_wf_flow_no        STRING,
    bcl_af_wf_task_run_step      STRING,
    bcl_af_wf_final_result       STRING,
    bcl_af_wf_uw_result          INT,
    bcl_af_wf_flow_no            STRING
) PARTITIONED BY (
    grass_region                STRING,
    product_id                  INT,
    grass_date                  STRING
) STORED AS orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_credit_uc_nd/grass_region=${region_upper}';

