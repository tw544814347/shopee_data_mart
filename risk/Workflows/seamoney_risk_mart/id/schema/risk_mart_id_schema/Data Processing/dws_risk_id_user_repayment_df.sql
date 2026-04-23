drop table if exists ${SCHEMA}.dws_risk_id_user_repayment_df;
create external table if not exists ${SCHEMA}.dws_risk_id_user_repayment_df
(
    credit_user_id STRING
    ,days_to_next_spl_repay BIGINT
    ,next_spl_bill_principal_os decimal(30, 10)
    ,days_to_next_bcl_repay BIGINT
    ,next_bcl_bill_principal_os decimal(30, 10)
    ,avg_weighted_remaining_tenure decimal(30, 10) comment '用户名下SPL,BCL,HPL所有产品未结清loan的平均remaining tenure:'
) 
partitioned by
(
    grass_date string comment 'YYYY-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc
tblproperties
(
    "orc.compress" = "SNAPPY"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_repayment_df/grass_region=ID';
msck repair table ${SCHEMA}.dws_risk_id_user_repayment_df;

