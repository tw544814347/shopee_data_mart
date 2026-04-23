CREATE TABLE IF NOT EXISTS dws_risk_${region_lower}_credit_af_uw_nd (
    app_id                  String,
    scene_id                Int,
    flow_no                 String,
    is_workflow             Int,
    run_step                String,
    product_code            String,
    workflow_flow_no        String,
    req_no                  String,
    final_result            String,
    req_time                String,
    req_time_local          String,
    seq_id                  String,
    platform_type           String,
    platform_user_id        String,
    credit_user_id          String,
    handle_begin_time       String,
    handle_end_time         String,
    app_type                String,
    check_result            String,
    check_result_code       String,
    task_run_step           String,
    last_task_run_step      String,
    scene_type_1            String,
    uw_result               Int
) PARTITIONED BY (
    grass_date              String
) 
STORED AS orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_credit_af_uw_nd/grass_region=${region_upper}';
