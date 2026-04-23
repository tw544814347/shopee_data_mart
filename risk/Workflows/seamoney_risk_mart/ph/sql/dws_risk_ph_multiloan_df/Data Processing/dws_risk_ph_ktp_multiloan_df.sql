--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-04-06
-- Theme Domain：       multiloan 
-- Description:         
-- Data Granularity:               
--********************************************************************--

add JAR hdfs://R2/projects/risk/hdfs/udf/phone_normalizer_udf.jar;
drop temporary function if exists normalize_phone;
create temporary function normalize_phone as 'com.shopee.udf.PhoneNormalizerUDF' 
    using jar 'hdfs://R2/projects/risk/hdfs/udf/phone_normalizer_udf.jar';

-- drop table if exists risk.dws_risk_ph_ktp_multiloan_df;
create table if not exists risk.dws_risk_ph_ktp_multiloan_df 
( 
    userid STRING,
    mh_query_count_7d INT,
    mh_query_count_14d INT,
    mh_query_count_30d INT,
    mh_query_count_90d INT,
    mh_query_count_180d INT,
    mh_query_count_360d INT,
    mh_query_count_720d INT,
    mh_query_count_1440d INT,
    mh_query_hr_count_7d INT,
    mh_query_hr_count_14d INT,
    mh_query_hr_count_30d INT,
    mh_query_hr_count_90d INT,
    mh_query_hr_count_180d INT,
    mh_query_hr_count_360d INT,
    mh_query_hr_count_720d INT,
    mh_query_hr_count_1440d INT,
    mh_latest_query_to_now_days INT,
    mh_first_query_to_now_days INT,
    mh_consecutive_query_day_min_7d Decimal(30,10),
    mh_consecutive_query_day_min_14d Decimal(30,10),
    mh_consecutive_query_day_min_30d Decimal(30,10),
    mh_consecutive_query_day_min_90d Decimal(30,10),
    mh_consecutive_query_day_min_180d Decimal(30,10),
    mh_consecutive_query_day_min_360d Decimal(30,10),
    mh_consecutive_query_day_min_720d Decimal(30,10),

    id_no STRING,
    id_type STRING
) 
partitioned by (grass_date string comment 'YYYY-MM-dd') 
stored as orc tblproperties (
    "orc.compress" = "zstd",
    "orc.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk/dwd/dws_risk_ph_ktp_multiloan_df';
-- msck repair table ${SCHEMA}.dws_risk_ph_ktp_multiloan_df;


WITH raw_tab AS (
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY userid, app_id ORDER BY start_date) AS install_rank
  FROM (
    SELECT 
      CAST(user_id AS BIGINT) AS userid,
      device_id,
      app_id,
      app_name,
      start_date,
      end_date,
      DATEDIFF(DATE('${grass_date}'), DATE(start_date)) AS diff_days
    FROM 
      risk.dwd_datapoint_applist_zi
    WHERE grass_region = 'PH'
      AND DATE(start_date) <= DATE('${grass_date}')
  )
),

filtered_apps AS (
  SELECT 
    userid,
    app_id,
    diff_days
  FROM raw_tab
  WHERE install_rank = 1 
    AND diff_days <= 1440
),

loan_app_list AS (
  SELECT app_id, Note 
  FROM
    rescbds_credit.ph_mh_app_list
),

joined_data AS (
  SELECT 
    f.userid,
    f.app_id,
    f.diff_days,
    l.Note
  FROM filtered_apps f
  INNER JOIN loan_app_list l ON f.app_id = l.app_id
),

                                                 
           
                                                 
time_window_features AS (
  SELECT 
    userid,
             
    COUNT(CASE WHEN diff_days <= 7 THEN app_id END) AS mh_query_count_7d,
    COUNT(CASE WHEN diff_days <= 14 THEN app_id END) AS mh_query_count_14d,
    COUNT(CASE WHEN diff_days <= 30 THEN app_id END) AS mh_query_count_30d,
    COUNT(CASE WHEN diff_days <= 90 THEN app_id END) AS mh_query_count_90d,
    COUNT(CASE WHEN diff_days <= 180 THEN app_id END) AS mh_query_count_180d,
    COUNT(CASE WHEN diff_days <= 360 THEN app_id END) AS mh_query_count_360d,
    COUNT(CASE WHEN diff_days <= 720 THEN app_id END) AS mh_query_count_720d,
    COUNT(app_id) AS mh_query_count_1440d,

              
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 7 THEN 1 END) AS mh_query_hr_count_7d,
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 14 THEN 1 END) AS mh_query_hr_count_14d,
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 30 THEN 1 END) AS mh_query_hr_count_30d,
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 90 THEN 1 END) AS mh_query_hr_count_90d,
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 180 THEN 1 END) AS mh_query_hr_count_180d,
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 360 THEN 1 END) AS mh_query_hr_count_360d,
    COUNT(CASE WHEN Note = 'high_risk' AND diff_days <= 720 THEN 1 END) AS mh_query_hr_count_720d,
    COUNT(CASE WHEN Note = 'high_risk' THEN 1 END) AS mh_query_hr_count_1440d,

            
    MIN(diff_days) AS mh_latest_query_to_now_days,
    MAX(diff_days) AS mh_first_query_to_now_days
  FROM joined_data
  GROUP BY userid
),

                                                 
           
                                                 
gap_calculation AS (
  SELECT 
    userid,
    diff_days,
    LAG(diff_days) OVER (PARTITION BY userid ORDER BY diff_days) AS prev_diff_days
  FROM joined_data
),

gap_features AS (
  SELECT 
    userid,
                
    MIN(CASE WHEN diff_days <= 7 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_7d,
    MIN(CASE WHEN diff_days <= 14 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_14d,
    MIN(CASE WHEN diff_days <= 30 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_30d,
    MIN(CASE WHEN diff_days <= 90 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_90d,
    MIN(CASE WHEN diff_days <= 180 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_180d,
    MIN(CASE WHEN diff_days <= 360 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_360d,
    MIN(CASE WHEN diff_days <= 720 THEN (diff_days - prev_diff_days) END) AS mh_consecutive_query_day_min_720d
  FROM gap_calculation
  WHERE prev_diff_days IS NOT NULL            
  GROUP BY userid
),

                                                 
       
                                                 
combined_features AS (
  SELECT 
    COALESCE(t.userid, g.userid) AS userid,
             
    COALESCE(t.mh_query_count_7d, -9999) AS mh_query_count_7d,
    COALESCE(t.mh_query_count_14d, -9999) AS mh_query_count_14d,
    COALESCE(t.mh_query_count_30d, -9999) AS mh_query_count_30d,
    COALESCE(t.mh_query_count_90d, -9999) AS mh_query_count_90d,
    COALESCE(t.mh_query_count_180d, -9999) AS mh_query_count_180d,
    COALESCE(t.mh_query_count_360d, -9999) AS mh_query_count_360d,
    COALESCE(t.mh_query_count_720d, -9999) AS mh_query_count_720d,
    COALESCE(t.mh_query_count_1440d, -9999) AS mh_query_count_1440d,

            
    COALESCE(t.mh_query_hr_count_7d, -9999) AS mh_query_hr_count_7d,
    COALESCE(t.mh_query_hr_count_14d, -9999) AS mh_query_hr_count_14d,
    COALESCE(t.mh_query_hr_count_30d, -9999) AS mh_query_hr_count_30d,
    COALESCE(t.mh_query_hr_count_90d, -9999) AS mh_query_hr_count_90d,
    COALESCE(t.mh_query_hr_count_180d, -9999) AS mh_query_hr_count_180d,
    COALESCE(t.mh_query_hr_count_360d, -9999) AS mh_query_hr_count_360d,
    COALESCE(t.mh_query_hr_count_720d, -9999) AS mh_query_hr_count_720d,
    COALESCE(t.mh_query_hr_count_1440d, -9999) AS mh_query_hr_count_1440d,

            
    COALESCE(t.mh_latest_query_to_now_days, -9999) AS mh_latest_query_to_now_days,
    COALESCE(t.mh_first_query_to_now_days, -9999) AS mh_first_query_to_now_days,

           
    COALESCE(g.mh_consecutive_query_day_min_7d, -9999) AS mh_consecutive_query_day_min_7d,
    COALESCE(g.mh_consecutive_query_day_min_14d, -9999) AS mh_consecutive_query_day_min_14d,
    COALESCE(g.mh_consecutive_query_day_min_30d, -9999) AS mh_consecutive_query_day_min_30d,
    COALESCE(g.mh_consecutive_query_day_min_90d, -9999) AS mh_consecutive_query_day_min_90d,
    COALESCE(g.mh_consecutive_query_day_min_180d, -9999) AS mh_consecutive_query_day_min_180d,
    COALESCE(g.mh_consecutive_query_day_min_360d, -9999) AS mh_consecutive_query_day_min_360d,
    COALESCE(g.mh_consecutive_query_day_min_720d, -9999) AS mh_consecutive_query_day_min_720d
  FROM time_window_features t
  FULL OUTER JOIN gap_features g USING (userid)
),

user_features as (                                     
SELECT 
  c.userid,
           
  CAST(c.mh_query_count_7d AS INT) AS mh_query_count_7d,
  CAST(c.mh_query_count_14d AS INT) AS mh_query_count_14d,
  CAST(c.mh_query_count_30d AS INT) AS mh_query_count_30d,
  CAST(c.mh_query_count_90d AS INT) AS mh_query_count_90d,
  CAST(c.mh_query_count_180d AS INT) AS mh_query_count_180d,
  CAST(c.mh_query_count_360d AS INT) AS mh_query_count_360d,
  CAST(c.mh_query_count_720d AS INT) AS mh_query_count_720d,
  CAST(c.mh_query_count_1440d AS INT) AS mh_query_count_1440d,
          
  CAST(c.mh_query_hr_count_7d AS INT) AS mh_query_hr_count_7d,
  CAST(c.mh_query_hr_count_14d AS INT) AS mh_query_hr_count_14d,
  CAST(c.mh_query_hr_count_30d AS INT) AS mh_query_hr_count_30d,
  CAST(c.mh_query_hr_count_90d AS INT) AS mh_query_hr_count_90d,
  CAST(c.mh_query_hr_count_180d AS INT) AS mh_query_hr_count_180d,
  CAST(c.mh_query_hr_count_360d AS INT) AS mh_query_hr_count_360d,
  CAST(c.mh_query_hr_count_720d AS INT) AS mh_query_hr_count_720d,
  CAST(c.mh_query_hr_count_1440d AS INT) AS mh_query_hr_count_1440d,
          
  CAST(c.mh_latest_query_to_now_days AS INT) AS mh_latest_query_to_now_days,
  CAST(c.mh_first_query_to_now_days AS INT) AS mh_first_query_to_now_days,
         
  CAST(c.mh_consecutive_query_day_min_7d AS Decimal(30,10)) AS mh_consecutive_query_day_min_7d,
  CAST(c.mh_consecutive_query_day_min_14d AS Decimal(30,10)) AS mh_consecutive_query_day_min_14d,
  CAST(c.mh_consecutive_query_day_min_30d AS Decimal(30,10)) AS mh_consecutive_query_day_min_30d,
  CAST(c.mh_consecutive_query_day_min_90d AS Decimal(30,10)) AS mh_consecutive_query_day_min_90d,
  CAST(c.mh_consecutive_query_day_min_180d AS Decimal(30,10)) AS mh_consecutive_query_day_min_180d,
  CAST(c.mh_consecutive_query_day_min_360d AS Decimal(30,10)) AS mh_consecutive_query_day_min_360d,
  CAST(c.mh_consecutive_query_day_min_720d AS Decimal(30,10)) AS mh_consecutive_query_day_min_720d
FROM 
    combined_features c 
), 

VerifiedPhones AS (
  SELECT
    s0.user_id AS userid,
    s1.phone_number AS raw_phone,
    s0.registration_timestamp,
    s0.grass_region AS country
  FROM
    mp_user.dim_user__reg_s0_live s0
  LEFT JOIN
    mp_user.dim_user__reg_s1_live s1
  ON
    s0.user_id = s1.user_id
  WHERE
    s0.grass_region = '${grass_region}'
    AND s1.grass_region = '${grass_region}'
    AND DATE(s0.grass_date) = DATE_SUB('${grass_date}', 1)
    AND DATE(s1.grass_date) = DATE_SUB('${grass_date}', 1)
    AND s0.is_phone_verified = 1
    AND s1.phone_number IS NOT NULL
    AND s1.phone_number != ''
),

-- 应用电话号码标准化
NormalizedPhones AS (
  SELECT
    userid,
    normalize_phone(raw_phone, country) AS phone,
    registration_timestamp
  FROM
    VerifiedPhones
  WHERE
    normalize_phone(raw_phone, country) != ''
),

-- 窗口函数去重
RankedPhones AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY phone
      ORDER BY registration_timestamp DESC
    ) AS rank
  FROM
    NormalizedPhones
),

-- 最终结果
final_user_phone as (
SELECT
  userid,
  phone,
  registration_timestamp
FROM
  RankedPhones
WHERE
  rank = 1
),


-- user_admin_map_tab as (
--     select * 
--            ,row_number() over(partition by platform_user_id order by update_time desc) as rk
--     from credit_uc.dwd_uc_ph_user_admin_map_tab_df
--     where grass_date = '${ds}'
-- ),

id_type_mapping as (
  select distinct 
          platform_user_id
          ,id_card_no
          ,new_id_card_type
  from risk.dim_risk_ph_id_type_mapping_df
  where grass_date = '${ds}'
),


final_tab as (
select t1.*,
       t2.phone as phone,
       t4.id_card_no as id_no,
       t4.new_id_card_type as id_type
from user_features t1
left join final_user_phone t2
on t1.userid = cast(t2.userid as string )
-- left join user_admin_map_tab t3
-- on t1.userid = t3.platform_user_id
left join id_type_mapping t4
on t1.userid = t4.platform_user_id
)

insert overwrite table risk.dws_risk_ph_ktp_multiloan_df partition(grass_date = '${ds}')
SELECT
    userid,
    mh_query_count_7d,
    mh_query_count_14d,
    mh_query_count_30d,
    mh_query_count_90d,
    mh_query_count_180d,
    mh_query_count_360d,
    mh_query_count_720d,
    mh_query_count_1440d,
    mh_query_hr_count_7d,
    mh_query_hr_count_14d,
    mh_query_hr_count_30d,
    mh_query_hr_count_90d,
    mh_query_hr_count_180d,
    mh_query_hr_count_360d,
    mh_query_hr_count_720d,
    mh_query_hr_count_1440d,
    mh_latest_query_to_now_days,
    mh_first_query_to_now_days,
    mh_consecutive_query_day_min_7d,
    mh_consecutive_query_day_min_14d,
    mh_consecutive_query_day_min_30d,
    mh_consecutive_query_day_min_90d,
    mh_consecutive_query_day_min_180d,
    mh_consecutive_query_day_min_360d,
    mh_consecutive_query_day_min_720d,
    id_no,
    id_type
FROM final_tab