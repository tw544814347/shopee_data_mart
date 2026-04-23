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
    activate_create_date        String,
    activate_start_date         String,
    activate_submit_date        String,
    kyc_wf_task_run_step        String,
    af_wf_task_run_step         String
) PARTITIONED BY (
    product_id                  bigint,
    grass_date                  String
) 
STORED AS orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_credit_uc_step_nd/grass_region=${region_upper}';

