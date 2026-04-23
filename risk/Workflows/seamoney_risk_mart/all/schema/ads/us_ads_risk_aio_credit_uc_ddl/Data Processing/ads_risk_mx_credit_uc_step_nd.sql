drop table IF EXISTS ads_risk_${region_lower}_credit_uc_step_nd;
CREATE TABLE IF NOT EXISTS ads_risk_${region_lower}_credit_uc_step_nd (
    apply_no                    String,
    credit_user_id              String,
    platform_type               bigint,
    sp_user_id                  String,
    version                     String,
    step_no                     bigint,
    step_rank_id                bigint,
    step_name                   String,
    step_is_automated           bigint,
    front_show                  bigint,
    step_status                 bigint,
    create_time                 String,
    step_start_time             String,
    step_end_time               String,
    step_sla_seconds            bigint,
    is_old_shopee_id            bigint,
    is_old_user_id              bigint,
    need_jump_spp               bigint,
    apply_type                  bigint,
    apply_status                bigint,
    is_submit                   bigint, -- added by wei.tao jira:https://jira.shopee.io/browse/SPFDT-47383 for mx 一起加上
    activate_create_date        String,
    activate_start_date         String,
    activate_submit_date        String,
    spl_kyc_af_wf_task_run_step STRING, -- MX combined limit 特殊工作流
    bcl_af_wf_task_run_step     STRING  -- MX combined limit 特殊工作流
) PARTITIONED BY (
    product_id                  bigint,
    grass_date                  String
)
STORED AS orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_credit_uc_step_nd/grass_region=${region_upper}';

