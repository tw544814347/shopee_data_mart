drop table if exists ${SCHEMA}.dwd_risk_id_af_vida_di;
create external table if not exists ${SCHEMA}.dwd_risk_id_af_vida_di
(
  credit_user_id STRING,
  request_key STRING,
  data_source_name STRING,
  data_source_code STRING,
  kyc_event_id STRING,
  kyc_status_raw STRING,
  score_pob DECIMAL(10,2),
  score_full_name DECIMAL(10,2),
  score_address DECIMAL(10,2),
  score_province DECIMAL(10,2),
  score_city DECIMAL(10,2),
  score_dob DECIMAL(10,2),
  score_district DECIMAL(10,2),
  score_village DECIMAL(10,2),
  score_nik DECIMAL(10,2),
  score_mother_maiden_name DECIMAL(10,2),
  score_family_card_no DECIMAL(10,2),
  score_demographic DECIMAL(10,2),
  score_selfiePhoto DECIMAL(10,2),
  score_liveness DECIMAL(20,10),
  trace_id STRING,
  create_time STRING,
  update_time STRING
)
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_af_vida_di';
msck repair table ${SCHEMA}.dwd_risk_id_af_vida_di;