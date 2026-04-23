drop table if exists risk.dws_risk_${region_lower}_user_withdraw_info_df;
CREATE TABLE  risk.dws_risk_${region_lower}_user_withdraw_info_df  (
  `row_key`                             STRING,
  `credit_user_id`                      STRING,
  `postloan_reject_cnt_bcl`             BIGINT,
  `postloan_reject_cnt_spl`             BIGINT,
  `preloan_reject_cnt_bcl`              BIGINT,
  `preloan_reject_cnt_spl`              BIGINT,
  `postloan_reject_cnt_90d_bcl`         BIGINT,
  `postloan_reject_cnt_90d_spl`         BIGINT,
  `preloan_reject_cnt_90d_bcl`          BIGINT,
  `preloan_reject_cnt_90d_spl`          BIGINT,
  `postloan_reject_cnt_180d_bcl`        BIGINT,
  `postloan_reject_cnt_180d_spl`        BIGINT,
  `preloan_reject_cnt_180d_bcl`         BIGINT,
  `preloan_reject_cnt_180d_spl`         BIGINT,
  `rejected_num_90d_bcl`                BIGINT,
  grass_date                            String 
    )
   PARTITIONED BY ( grass_date)
   stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
   LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_kafka/dwd/dws_risk_${region_lower}_user_withdraw_info_df';
   msck repair table risk.dws_risk_${region_lower}_user_withdraw_info_df;
