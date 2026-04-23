-- -- 将 ODS 表中的 VidaCfDemog 数据写入 DWD 表
-- DROP TABLE IF EXISTS risk.dwd_risk_id_af_vida_di_dist_vidaldnfull;
-- CREATE TABLE IF NOT EXISTS risk.dwd_risk_id_af_vida_di_dist_vidaldnfull (
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
-- COMMENT 'dwd_risk_id_af_vida_di_dist_vidaldnfull'
-- partitioned by (grass_date string comment "partition date yyyy-MM-dd")
-- stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_af_vida_di_v2/data_source_name=VidaLdnFull';

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
  WHERE data_source_name = 'VidaLdnFull' AND grass_date = '${ds}'
)

INSERT INTO TABLE risk.dwd_risk_id_af_vida_di_dist_vidaldnfull

SELECT
  get_json_object(t.header_data, '$.credit_user_id') AS credit_user_id,
  t.request_key AS request_key,
  -- t.data_source_name AS data_source_name,
  t.data_source_code AS data_source_code,
  get_json_object(t.resp_raw_data, '$.data.eventId') AS kyc_event_id,
  get_json_object(t.resp_raw_data, '$.data.certificateIssued') AS kyc_status_raw,
  -- 条件表达式处理字段
  CASE 
    WHEN TO_DATE(t.create_time) >= TO_DATE('2024-03-21') THEN NULL
    ELSE 
      CASE 
        WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '200' THEN 10
        WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '444' THEN 0
        ELSE NULL
      END
  END AS score_pob,
  CASE 
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '200' THEN 10
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '444' THEN 0
    ELSE NULL
  END AS score_full_name,
  NULL AS score_address,
  NULL AS score_province,
  NULL AS score_city,
  CASE 
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '200' THEN 10
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '444' THEN 0
    ELSE NULL
  END AS score_dob,
  NULL AS score_district,
  NULL AS score_village,
  CASE 
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '200' THEN 10
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '444' THEN 0
    ELSE NULL
  END AS score_nik,
  NULL AS score_mother_maiden_name,
  NULL AS score_family_card_no,
  CASE 
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '200' THEN 10
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '444' THEN 0
    ELSE NULL
  END AS score_demographic,
  CASE 
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '200' THEN 10
    WHEN get_json_object(t.resp_raw_data, '$.data.certificateIssued') = '444' THEN 0
    ELSE NULL
  END AS score_selfiephoto,
  -- 处理score_liveness字段
  MAX(CASE WHEN f.field_name = 'liveness' THEN f.field_score ELSE NULL END) AS score_liveness,
  t.trace_id AS trace_id,
  t.create_time AS create_time,
  t.update_time AS update_time,
  '${ds}' AS grass_date
FROM (
  SELECT 
    resp_raw_data,
    header_data,
    request_key,
    data_source_name,
    data_source_code,
    trace_id,
    create_time,
    update_time
  FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
  WHERE data_source_name = 'VidaLdnFull' AND grass_date = '${ds}'
) t
LEFT JOIN exploded_fields f 
ON t.resp_raw_data = f.resp_raw_data
AND t.header_data = f.header_data
AND t.request_key = f.request_key
AND t.data_source_code = f.data_source_code
GROUP BY
  t.resp_raw_data,
  t.header_data,
  t.request_key,
  -- t.data_source_name,
  t.data_source_code,
  t.trace_id,
  t.create_time,
  t.update_time
;

