--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-04-06
-- Theme Domain：       multiloan 
-- Description:         
-- Data Granularity:               
--********************************************************************--

-- drop table if exists risk.dws_risk_ph_multiloan_df;
create table if not exists risk.dws_risk_ph_multiloan_df 
( 
    userid STRING,
    biz_type INT,
    key STRING,
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
    mh_consecutive_query_day_min_720d Decimal(30,10)
) 
partitioned by (grass_date string comment 'YYYY-MM-dd') 
stored as orc tblproperties (
    "orc.compress" = "zstd",
    "orc.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk/dwd/dws_risk_ph_multiloan_df';
-- msck repair table ${SCHEMA}.dws_risk_ph_multiloan_df;



insert overwrite table risk.dws_risk_ph_multiloan_df partition(grass_date = '${ds}')
SELECT
    userid,
    1 as biz_type,
    concat('1_', coalesce(id_type,''), '_', coalesce(id_no,'')) as key,

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
    mh_consecutive_query_day_min_720d
FROM risk.dws_risk_ph_ktp_multiloan_df
WHERE grass_date = '${ds}'

UNION ALL 

SELECT
    userid,
    2 as biz_type,
    concat('2_', coalesce(phone,'')) as key,

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
    mh_consecutive_query_day_min_720d
FROM risk.dws_risk_ph_phone_multiloan_df
WHERE grass_date = '${ds}'