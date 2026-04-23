-- -- 将 ODS 表中的 VidaCfDemog 数据写入 DWD 表
-- DROP TABLE IF EXISTS risk.dwd_risk_id_af_vida_di_dist_vidadata;
-- CREATE TABLE IF NOT EXISTS risk.dwd_risk_id_af_vida_di_dist_vidadata (
--   credit_user_id STRING COMMENT '用户ID',
--   request_key STRING COMMENT '请求标识',
--   --data_source_name STRING COMMENT '数据源名称',
--   data_source_code STRING COMMENT '数据源代码',
--   kyc_event_id STRING COMMENT 'KYC事件ID',
--   kyc_status_raw STRING COMMENT 'KYC原始状态',
--   score_pob DOUBLE COMMENT '出生地评分',
--   score_full_name DOUBLE COMMENT '全名评分',
--   score_address DOUBLE COMMENT '地址评分',
--   score_province DOUBLE COMMENT '省份评分',
--   score_city DOUBLE COMMENT '城市评分',
--   score_dob DOUBLE COMMENT '出生日期评分',
--   score_district DOUBLE COMMENT '区域评分',
--   score_village DOUBLE COMMENT '村庄评分',
--   score_nik DOUBLE COMMENT 'NIK评分',
--   score_mother_maiden_name DOUBLE COMMENT '母亲婚前姓氏评分',
--   score_family_card_no DOUBLE COMMENT '家庭卡号评分',
--   score_demographic DOUBLE COMMENT '人口统计评分',
--   score_selfiephoto DOUBLE COMMENT '自拍照评分',
--   score_liveness DOUBLE COMMENT '活体检测评分',
--   trace_id STRING COMMENT '追踪ID',
--   create_time STRING COMMENT '创建时间',
--   update_time STRING COMMENT '更新时间'
-- ) 
-- COMMENT 'dwd_risk_id_af_vida_di_dist_vidadata'
-- partitioned by (grass_date string comment "partition date yyyy-MM-dd")
-- stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_af_vida_di_v2/data_source_name=VidaData';

WITH exploded_fields AS (
  SELECT 
    resp_raw_data,
    header_data,
    request_key,
    data_source_name,
    data_source_code,
    trace_id,
    create_time,
    update_time,
    field_obj.field AS field_name,
    field_obj.score AS field_score
  FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
  LATERAL VIEW EXPLODE(
    FROM_JSON(
      get_json_object(resp_raw_data, '$.data.fields'),
      'array<struct<field:string,score:double>>'
    )
  ) fields AS field_obj
  WHERE data_source_name IN ('VidaData') AND grass_date = '${ds}'
)

INSERT INTO TABLE risk.dwd_risk_id_af_vida_di_dist_vidadata

SELECT
  get_json_object(header_data, '$.CreditUserId') AS credit_user_id,
  request_key AS request_key,
  -- data_source_name AS data_source_name,
  data_source_code AS data_source_code,
  get_json_object(resp_raw_data, '$.data.kycEventId') AS kyc_event_id,
  get_json_object(resp_raw_data, '$.data.kyc_status_raw') AS kyc_status_raw,
  -- 使用 MAX + CASE WHEN 来获取各个字段的 score
  MAX(CASE WHEN field_name = 'pob' THEN field_score END) AS score_pob,
  MAX(CASE WHEN field_name = 'full_name' THEN field_score END) AS score_full_name,
  MAX(CASE WHEN field_name = 'address' THEN field_score END) AS score_address,
  MAX(CASE WHEN field_name = 'province' THEN field_score END) AS score_province,
  MAX(CASE WHEN field_name = 'city' THEN field_score END) AS score_city,
  MAX(CASE WHEN field_name = 'dob' THEN field_score END) AS score_dob,
  MAX(CASE WHEN field_name = 'district' THEN field_score END) AS score_district,
  MAX(CASE WHEN field_name = 'village' THEN field_score END) AS score_village,
  MAX(CASE WHEN field_name = 'nik' THEN field_score END) AS score_nik,
  MAX(CASE WHEN field_name = 'mother_maiden_name' THEN field_score END) AS score_mother_maiden_name,
  MAX(CASE WHEN field_name = 'family_card_no' THEN field_score END) AS score_family_card_no,
  -- 计算平均分 (使用AVG函数直接计算)
  AVG(field_score) AS score_demographic,
  MAX(CASE WHEN field_name = 'selfiePhoto' THEN field_score END) AS score_selfiephoto,
  MAX(CASE WHEN field_name = 'liveness' THEN field_score END) AS score_liveness,
  trace_id AS trace_id,
  create_time AS create_time,
  update_time AS update_time,
  '${ds}' AS grass_date
FROM exploded_fields 
WHERE data_source_name = 'VidaData'
GROUP BY 
  resp_raw_data,
  header_data,
  request_key,
  -- data_source_name,
  data_source_code,
  trace_id,
  create_time,
  update_time
;
