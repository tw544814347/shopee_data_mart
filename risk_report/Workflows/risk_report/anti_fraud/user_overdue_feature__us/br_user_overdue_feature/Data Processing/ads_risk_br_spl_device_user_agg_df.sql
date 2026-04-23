--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--


CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${reg}_${risk_tab_biz_type}_device_user_agg_tmp_df (
    sz_dfp_device_id                       STRING         COMMENT 'sz_dfp_device_id',

    cnt_user_l3m                           BIGINT         COMMENT 'cnt distinct users in last 3 months',
    cnt_user_l1m                           BIGINT         COMMENT 'cnt distinct users in last 1 month',
    cnt_user_l10d                          BIGINT         COMMENT 'cnt distinct users in last 10 days',
    cnt_user_login_3d                      BIGINT         COMMENT 'cnt users with login days <=3 in last 3 months',
    cnt_user_login_2d                      BIGINT         COMMENT 'cnt users with login days <=2 in last 3 months',
    cnt_user_login_1d                      BIGINT         COMMENT 'cnt users with login days <=1 in last 3 months',
    cnt_user_dpd30_l24m                    BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 24 months',
    cnt_user_dpd30_l12m                    BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 12 months',
    cnt_user_dpd30_l6m                     BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 6 months',
    cnt_user_dpd30_l3m                     BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 3 months',
    cnt_user_dpd30_l1m                     BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 1 month',
    cnt_user_dpd30_limit90_l24m            BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 24 months',
    cnt_user_dpd30_limit90_l12m            BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 12 months',
    cnt_user_dpd30_limit90_l6m             BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 6 months',
    cnt_user_dpd30_limit90_l3m             BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 3 months',
    cnt_user_dpd30_limit90_l1m             BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 1 month',
    cnt_user_dpd90_l24m                    BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 24 months',
    cnt_user_dpd90_l12m                    BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 12 months',
    cnt_user_dpd90_l6m                     BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 6 months',
    cnt_user_dpd90_l3m                     BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 3 months',
    cnt_user_dpd90_l1m                     BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 1 month',
    cnt_user_dpd90_limit90_l24m            BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 24 months',
    cnt_user_dpd90_limit90_l12m            BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 12 months',
    cnt_user_dpd90_limit90_l6m             BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 6 months',
    cnt_user_dpd90_limit90_l3m             BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 3 months',
    cnt_user_dpd90_limit90_l1m             BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 1 month',
    cnt_user_fpd30_l24m                    BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 24 months',
    cnt_user_fpd30_l12m                    BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 12 months',
    cnt_user_fpd30_l6m                     BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 6 months',
    cnt_user_fpd30_l3m                     BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 3 months',
    cnt_user_fpd30_l1m                     BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 1 month',
    cnt_user_fpd30_limit90_l24m            BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 24 months',
    cnt_user_fpd30_limit90_l12m            BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 12 months',
    cnt_user_fpd30_limit90_l6m             BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 6 months',
    cnt_user_fpd30_limit90_l3m             BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 3 months',
    cnt_user_fpd30_limit90_l1m             BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 1 month',
    cnt_user_cpd1_l24m                     BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 24 months',
    cnt_user_cpd1_l12m                     BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 12 months',
    cnt_user_cpd1_l6m                      BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 6 months',
    cnt_user_cpd1_l3m                      BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 3 months',
    cnt_user_cpd1_l1m                      BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 1 month',
    cnt_user_cpd1_limit90_l24m             BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 24 months',
    cnt_user_cpd1_limit90_l12m             BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 12 months',
    cnt_user_cpd1_limit90_l6m              BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 6 months',
    cnt_user_cpd1_limit90_l3m              BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 3 months',
    cnt_user_cpd1_limit90_l1m              BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 1 month',
    cnt_user_cpd7_l24m                     BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 24 months',
    cnt_user_cpd7_l12m                     BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 12 months',
    cnt_user_cpd7_l6m                      BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 6 months',
    cnt_user_cpd7_l3m                      BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 3 months',
    cnt_user_cpd7_l1m                      BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 1 month',
    cnt_user_cpd7_limit90_l24m             BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 24 months',
    cnt_user_cpd7_limit90_l12m             BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 12 months',
    cnt_user_cpd7_limit90_l6m              BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 6 months',
    cnt_user_cpd7_limit90_l3m              BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 3 months',
    cnt_user_cpd7_limit90_l1m              BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 1 month',
    cnt_user_cpd30_l24m                    BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 24 months',
    cnt_user_cpd30_l12m                    BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 12 months',
    cnt_user_cpd30_l6m                     BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 6 months',
    cnt_user_cpd30_l3m                     BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 3 months',
    cnt_user_cpd30_l1m                     BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 1 month',
    cnt_user_cpd30_limit90_l24m            BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 24 months',
    cnt_user_cpd30_limit90_l12m            BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 12 months',
    cnt_user_cpd30_limit90_l6m             BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 6 months',
    cnt_user_cpd30_limit90_l3m             BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 3 months',
    cnt_user_cpd30_limit90_l1m             BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 1 month',
    cnt_user_dpd30_l2y_l24m                BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 24 months',
    cnt_user_dpd30_l2y_l12m                BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 12 months',
    cnt_user_dpd30_l2y_l6m                 BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 6 months',
    cnt_user_dpd30_l2y_l3m                 BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 3 months',
    cnt_user_dpd30_l2y_l1m                 BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 1 month',
    cnt_user_dpd30_l2y_limit90_l24m        BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 24 months',
    cnt_user_dpd30_l2y_limit90_l12m        BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 12 months',
    cnt_user_dpd30_l2y_limit90_l6m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 6 months',
    cnt_user_dpd30_l2y_limit90_l3m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 3 months',
    cnt_user_dpd30_l2y_limit90_l1m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 1 month',
    cnt_user_cpd1_credit_l24m              BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 24 months',
    cnt_user_cpd1_credit_l12m              BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 12 months',
    cnt_user_cpd1_credit_l6m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 6 months',
    cnt_user_cpd1_credit_l3m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 3 months',
    cnt_user_cpd1_credit_l1m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 1 month',
    cnt_user_cpd7_credit_l24m              BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 24 months',
    cnt_user_cpd7_credit_l12m              BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 12 months',
    cnt_user_cpd7_credit_l6m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 6 months',
    cnt_user_cpd7_credit_l3m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 3 months',
    cnt_user_cpd7_credit_l1m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 1 month',
    cnt_user_cpd30_credit_l24m             BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 24 months',
    cnt_user_cpd30_credit_l12m             BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 12 months',
    cnt_user_cpd30_credit_l6m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 6 months',
    cnt_user_cpd30_credit_l3m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 3 months',
    cnt_user_cpd30_credit_l1m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 1 month',
    cnt_user_dpd30_l2y_limit90_credit_l24m BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 24 months',
    cnt_user_dpd30_l2y_limit90_credit_l12m BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 12 months',
    cnt_user_dpd30_l2y_limit90_credit_l6m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 6 months',
    cnt_user_dpd30_l2y_limit90_credit_l3m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 3 months',
    cnt_user_dpd30_l2y_limit90_credit_l1m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 1 month',
    is_gps_palembang                       BIGINT         COMMENT 'is city contain palembang in last 30d',
    is_ip_palembang                        BIGINT         COMMENT 'is ip contain palembang in last 30d'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/ads/ads_aio_risk_device_user_agg_df/grass_region=${grass_region}/product_id=${biz_type_code}'
;

with palembang_base as 
(
  SELECT
      get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') AS sz_dfp_device_id,
      lower(get_json_object(extension, '$.CommonHeader.location.address.city')) AS gps_city,
      lower(get_json_object(extension, '$.CommonHeader.extension_process_data.ip_city_info.ip_city_name_v2')) AS ip_city
  FROM
      risk.dwd_risk_${reg}_strategy_final_result_merge_di
  WHERE
      grass_date >= cast(date_sub(to_date('${ds}'), 30) as string)
      AND topic_name IN (
          '${reg}_live_credit_risk_gateway_req_rsp_voi',
          '${reg}_live_credit_risk_gateway_req_rsp_spjup',
          '${reg}_live_credit_risk_gateway_req_rsp_kyc',
          '${reg}_live_credit_risk_gateway_req_rsp_kredit',
          '${reg}_live_credit_risk_gateway_req_rsp_fes'
      )
      AND risk_scene_id LIKE '100%'
      AND risk_scene_id NOT IN ('10025','10035')
),
palembang as 
(
  SELECT
      sz_dfp_device_id,
      MAX(CASE WHEN gps_city LIKE '%palembang%' THEN 1 ELSE 0 END) AS is_gps_palembang,
      MAX(CASE WHEN ip_city LIKE '%palembang%' THEN 1 ELSE 0 END) AS is_ip_palembang
  FROM palembang_base
  WHERE
      (gps_city LIKE '%palembang%' OR ip_city LIKE '%palembang%')
      AND sz_dfp_device_id IS NOT NULL 
      AND sz_dfp_device_id <> ''
  GROUP BY sz_dfp_device_id
),
all_devices as
(
  SELECT sz_dfp_device_id FROM ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_af_device_user_agg_df WHERE sz_dfp_device_id IS NOT NULL AND grass_date = '${ds}'
  UNION
  SELECT sz_dfp_device_id FROM ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_szdf_device_user_agg_df WHERE sz_dfp_device_id IS NOT NULL AND grass_date = '${ds}'
  UNION
  SELECT sz_dfp_device_id FROM ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_login_szdf_device_user_agg_df WHERE sz_dfp_device_id IS NOT NULL AND grass_date = '${ds}'
)

insert overwrite table ${SCHEMA}.ads_risk_${reg}_${risk_tab_biz_type}_device_user_agg_tmp_df partition(grass_date = '${ds}')
select 
  base.sz_dfp_device_id
  ,coalesce(cnt_user_l3m, 0)
  ,coalesce(cnt_user_l1m, 0)
  ,coalesce(cnt_user_l10d, 0)
  ,coalesce(cnt_user_login_3d, 0)
  ,coalesce(cnt_user_login_2d, 0)
  ,coalesce(cnt_user_login_1d, 0)
  ,coalesce(cnt_user_dpd30_l24m, 0)
  ,coalesce(cnt_user_dpd30_l12m, 0)
  ,coalesce(cnt_user_dpd30_l6m, 0)
  ,coalesce(cnt_user_dpd30_l3m, 0)
  ,coalesce(cnt_user_dpd30_l1m, 0)
  ,coalesce(cnt_user_dpd30_limit90_l24m, 0)
  ,coalesce(cnt_user_dpd30_limit90_l12m, 0)
  ,coalesce(cnt_user_dpd30_limit90_l6m, 0)
  ,coalesce(cnt_user_dpd30_limit90_l3m, 0)
  ,coalesce(cnt_user_dpd30_limit90_l1m, 0)
  ,coalesce(cnt_user_dpd90_l24m, 0)
  ,coalesce(cnt_user_dpd90_l12m, 0)
  ,coalesce(cnt_user_dpd90_l6m, 0)
  ,coalesce(cnt_user_dpd90_l3m, 0)
  ,coalesce(cnt_user_dpd90_l1m, 0)
  ,coalesce(cnt_user_dpd90_limit90_l24m, 0)
  ,coalesce(cnt_user_dpd90_limit90_l12m, 0)
  ,coalesce(cnt_user_dpd90_limit90_l6m, 0)
  ,coalesce(cnt_user_dpd90_limit90_l3m, 0)
  ,coalesce(cnt_user_dpd90_limit90_l1m, 0)
  ,coalesce(cnt_user_fpd30_l24m, 0)
  ,coalesce(cnt_user_fpd30_l12m, 0)
  ,coalesce(cnt_user_fpd30_l6m, 0)
  ,coalesce(cnt_user_fpd30_l3m, 0)
  ,coalesce(cnt_user_fpd30_l1m, 0)
  ,coalesce(cnt_user_fpd30_limit90_l24m, 0)
  ,coalesce(cnt_user_fpd30_limit90_l12m, 0)
  ,coalesce(cnt_user_fpd30_limit90_l6m, 0)
  ,coalesce(cnt_user_fpd30_limit90_l3m, 0)
  ,coalesce(cnt_user_fpd30_limit90_l1m, 0)
  ,coalesce(cnt_user_cpd1_l24m, 0)
  ,coalesce(cnt_user_cpd1_l12m, 0)
  ,coalesce(cnt_user_cpd1_l6m, 0)
  ,coalesce(cnt_user_cpd1_l3m, 0)
  ,coalesce(cnt_user_cpd1_l1m, 0)
  ,coalesce(cnt_user_cpd1_limit90_l24m, 0)
  ,coalesce(cnt_user_cpd1_limit90_l12m, 0)
  ,coalesce(cnt_user_cpd1_limit90_l6m, 0)
  ,coalesce(cnt_user_cpd1_limit90_l3m, 0)
  ,coalesce(cnt_user_cpd1_limit90_l1m, 0)
  ,coalesce(cnt_user_cpd7_l24m, 0)
  ,coalesce(cnt_user_cpd7_l12m, 0)
  ,coalesce(cnt_user_cpd7_l6m, 0)
  ,coalesce(cnt_user_cpd7_l3m, 0)
  ,coalesce(cnt_user_cpd7_l1m, 0)
  ,coalesce(cnt_user_cpd7_limit90_l24m, 0)
  ,coalesce(cnt_user_cpd7_limit90_l12m, 0)
  ,coalesce(cnt_user_cpd7_limit90_l6m, 0)
  ,coalesce(cnt_user_cpd7_limit90_l3m, 0)
  ,coalesce(cnt_user_cpd7_limit90_l1m, 0)
  ,coalesce(cnt_user_cpd30_l24m, 0)
  ,coalesce(cnt_user_cpd30_l12m, 0)
  ,coalesce(cnt_user_cpd30_l6m, 0)
  ,coalesce(cnt_user_cpd30_l3m, 0)
  ,coalesce(cnt_user_cpd30_l1m, 0)
  ,coalesce(cnt_user_cpd30_limit90_l24m, 0)
  ,coalesce(cnt_user_cpd30_limit90_l12m, 0)
  ,coalesce(cnt_user_cpd30_limit90_l6m, 0)
  ,coalesce(cnt_user_cpd30_limit90_l3m, 0)
  ,coalesce(cnt_user_cpd30_limit90_l1m, 0)
  ,coalesce(cnt_user_dpd30_l2y_l24m, 0)
  ,coalesce(cnt_user_dpd30_l2y_l12m, 0)
  ,coalesce(cnt_user_dpd30_l2y_l6m, 0)
  ,coalesce(cnt_user_dpd30_l2y_l3m, 0)
  ,coalesce(cnt_user_dpd30_l2y_l1m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_l24m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_l12m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_l6m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_l3m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_l1m, 0)
  ,coalesce(cnt_user_cpd1_credit_l24m, 0)
  ,coalesce(cnt_user_cpd1_credit_l12m, 0)
  ,coalesce(cnt_user_cpd1_credit_l6m, 0)
  ,coalesce(cnt_user_cpd1_credit_l3m, 0)
  ,coalesce(cnt_user_cpd1_credit_l1m, 0)
  ,coalesce(cnt_user_cpd7_credit_l24m, 0)
  ,coalesce(cnt_user_cpd7_credit_l12m, 0)
  ,coalesce(cnt_user_cpd7_credit_l6m, 0)
  ,coalesce(cnt_user_cpd7_credit_l3m, 0)
  ,coalesce(cnt_user_cpd7_credit_l1m, 0)
  ,coalesce(cnt_user_cpd30_credit_l24m, 0)
  ,coalesce(cnt_user_cpd30_credit_l12m, 0)
  ,coalesce(cnt_user_cpd30_credit_l6m, 0)
  ,coalesce(cnt_user_cpd30_credit_l3m, 0)
  ,coalesce(cnt_user_cpd30_credit_l1m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_credit_l24m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_credit_l12m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_credit_l6m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_credit_l3m, 0)
  ,coalesce(cnt_user_dpd30_l2y_limit90_credit_l1m, 0)
  ,coalesce(is_gps_palembang, 0)
  ,coalesce(is_ip_palembang, 0)
from all_devices base
left join (
  select 
    sz_dfp_device_id
    ,cnt_user_dpd30_l24m
    ,cnt_user_dpd30_l12m
    ,cnt_user_dpd30_l6m
    ,cnt_user_dpd30_l3m
    ,cnt_user_dpd30_l1m
    ,cnt_user_dpd30_limit90_l24m
    ,cnt_user_dpd30_limit90_l12m
    ,cnt_user_dpd30_limit90_l6m
    ,cnt_user_dpd30_limit90_l3m
    ,cnt_user_dpd30_limit90_l1m
    ,cnt_user_dpd90_l24m
    ,cnt_user_dpd90_l12m
    ,cnt_user_dpd90_l6m
    ,cnt_user_dpd90_l3m
    ,cnt_user_dpd90_l1m
    ,cnt_user_dpd90_limit90_l24m
    ,cnt_user_dpd90_limit90_l12m
    ,cnt_user_dpd90_limit90_l6m
    ,cnt_user_dpd90_limit90_l3m
    ,cnt_user_dpd90_limit90_l1m
    ,cnt_user_fpd30_l24m
    ,cnt_user_fpd30_l12m
    ,cnt_user_fpd30_l6m
    ,cnt_user_fpd30_l3m
    ,cnt_user_fpd30_l1m
    ,cnt_user_fpd30_limit90_l24m
    ,cnt_user_fpd30_limit90_l12m
    ,cnt_user_fpd30_limit90_l6m
    ,cnt_user_fpd30_limit90_l3m
    ,cnt_user_fpd30_limit90_l1m
    ,cnt_user_cpd1_l24m
    ,cnt_user_cpd1_l12m
    ,cnt_user_cpd1_l6m
    ,cnt_user_cpd1_l3m
    ,cnt_user_cpd1_l1m
    ,cnt_user_cpd1_limit90_l24m
    ,cnt_user_cpd1_limit90_l12m
    ,cnt_user_cpd1_limit90_l6m
    ,cnt_user_cpd1_limit90_l3m
    ,cnt_user_cpd1_limit90_l1m
    ,cnt_user_cpd7_l24m
    ,cnt_user_cpd7_l12m
    ,cnt_user_cpd7_l6m
    ,cnt_user_cpd7_l3m
    ,cnt_user_cpd7_l1m
    ,cnt_user_cpd7_limit90_l24m
    ,cnt_user_cpd7_limit90_l12m
    ,cnt_user_cpd7_limit90_l6m
    ,cnt_user_cpd7_limit90_l3m
    ,cnt_user_cpd7_limit90_l1m
    ,cnt_user_cpd30_l24m
    ,cnt_user_cpd30_l12m
    ,cnt_user_cpd30_l6m
    ,cnt_user_cpd30_l3m
    ,cnt_user_cpd30_l1m
    ,cnt_user_cpd30_limit90_l24m
    ,cnt_user_cpd30_limit90_l12m
    ,cnt_user_cpd30_limit90_l6m
    ,cnt_user_cpd30_limit90_l3m
    ,cnt_user_cpd30_limit90_l1m
    ,cnt_user_dpd30_l2y_l24m
    ,cnt_user_dpd30_l2y_l12m
    ,cnt_user_dpd30_l2y_l6m
    ,cnt_user_dpd30_l2y_l3m
    ,cnt_user_dpd30_l2y_l1m
    ,cnt_user_dpd30_l2y_limit90_l24m
    ,cnt_user_dpd30_l2y_limit90_l12m
    ,cnt_user_dpd30_l2y_limit90_l6m
    ,cnt_user_dpd30_l2y_limit90_l3m
    ,cnt_user_dpd30_l2y_limit90_l1m
  from ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_szdf_device_user_agg_df 
  where grass_date = '${ds}'
) szdf 
  on base.sz_dfp_device_id = szdf.sz_dfp_device_id
left join (
  select 
    sz_dfp_device_id
    ,cnt_user_cpd1_credit_l24m
    ,cnt_user_cpd1_credit_l12m
    ,cnt_user_cpd1_credit_l6m
    ,cnt_user_cpd1_credit_l3m
    ,cnt_user_cpd1_credit_l1m
    ,cnt_user_cpd7_credit_l24m
    ,cnt_user_cpd7_credit_l12m
    ,cnt_user_cpd7_credit_l6m
    ,cnt_user_cpd7_credit_l3m
    ,cnt_user_cpd7_credit_l1m
    ,cnt_user_cpd30_credit_l24m
    ,cnt_user_cpd30_credit_l12m
    ,cnt_user_cpd30_credit_l6m
    ,cnt_user_cpd30_credit_l3m
    ,cnt_user_cpd30_credit_l1m
    ,cnt_user_dpd30_l2y_limit90_credit_l24m
    ,cnt_user_dpd30_l2y_limit90_credit_l12m
    ,cnt_user_dpd30_l2y_limit90_credit_l6m
    ,cnt_user_dpd30_l2y_limit90_credit_l3m
    ,cnt_user_dpd30_l2y_limit90_credit_l1m
  from ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_af_device_user_agg_df 
  where grass_date = '${ds}'
) af
  on base.sz_dfp_device_id = af.sz_dfp_device_id
left join (
  select 
    sz_dfp_device_id
    ,cnt_user_l3m
    ,cnt_user_l1m
    ,cnt_user_l10d
    ,cnt_user_login_3d
    ,cnt_user_login_2d
    ,cnt_user_login_1d
  from ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_login_szdf_device_user_agg_df 
  where grass_date = '${ds}'
) login_szdf 
  on base.sz_dfp_device_id = login_szdf.sz_dfp_device_id
left join palembang 
  on base.sz_dfp_device_id = palembang.sz_dfp_device_id
distribute by base.sz_dfp_device_id
;

create or replace view ads_risk_${reg}_${risk_tab_biz_type}_device_user_agg_df
COMMENT 'risk mart summary table'
as 
select 
    sz_dfp_device_id                          
    ,grass_date
    ,cnt_user_l3m                           
    ,cnt_user_l1m                           
    ,cnt_user_l10d                          
    ,cnt_user_login_3d                           as cnt_user_login_3d_l3m                  
    ,cnt_user_login_2d                           as cnt_user_login_2d_l3m                  
    ,cnt_user_login_1d                           as cnt_user_login_1d_l3m                     
    ,cnt_user_dpd30_l24m                         as cnt_user_dpd30_eod_l24m
    ,cnt_user_dpd30_l12m                         as cnt_user_dpd30_eod_l12m
    ,cnt_user_dpd30_l6m                          as cnt_user_dpd30_eod_l6m
    ,cnt_user_dpd30_l3m                          as cnt_user_dpd30_eod_l3m
    ,cnt_user_dpd30_l1m                          as cnt_user_dpd30_eod_l1m
    ,cnt_user_dpd30_limit90_l24m                 as cnt_user_dpd30_eod_limit90_l24m
    ,cnt_user_dpd30_limit90_l12m                 as cnt_user_dpd30_eod_limit90_l12m
    ,cnt_user_dpd30_limit90_l6m                  as cnt_user_dpd30_eod_limit90_l6m
    ,cnt_user_dpd30_limit90_l3m                  as cnt_user_dpd30_eod_limit90_l3m
    ,cnt_user_dpd30_limit90_l1m                  as cnt_user_dpd30_eod_limit90_l1m
    ,cnt_user_dpd90_l24m                         as cnt_user_dpd90_eod_l24m
    ,cnt_user_dpd90_l12m                         as cnt_user_dpd90_eod_l12m
    ,cnt_user_dpd90_l6m                          as cnt_user_dpd90_eod_l6m
    ,cnt_user_dpd90_l3m                          as cnt_user_dpd90_eod_l3m
    ,cnt_user_dpd90_l1m                          as cnt_user_dpd90_eod_l1m
    ,cnt_user_dpd90_limit90_l24m                 as cnt_user_dpd90_eod_limit90_l24m
    ,cnt_user_dpd90_limit90_l12m                 as cnt_user_dpd90_eod_limit90_l12m
    ,cnt_user_dpd90_limit90_l6m                  as cnt_user_dpd90_eod_limit90_l6m
    ,cnt_user_dpd90_limit90_l3m                  as cnt_user_dpd90_eod_limit90_l3m
    ,cnt_user_dpd90_limit90_l1m                  as cnt_user_dpd90_eod_limit90_l1m
    ,cnt_user_fpd30_l24m                         as cnt_user_fpd30_eod_l24m
    ,cnt_user_fpd30_l12m                         as cnt_user_fpd30_eod_l12m
    ,cnt_user_fpd30_l6m                          as cnt_user_fpd30_eod_l6m
    ,cnt_user_fpd30_l3m                          as cnt_user_fpd30_eod_l3m
    ,cnt_user_fpd30_l1m                          as cnt_user_fpd30_eod_l1m
    ,cnt_user_fpd30_limit90_l24m                 as cnt_user_fpd30_eod_limit90_l24m
    ,cnt_user_fpd30_limit90_l12m                 as cnt_user_fpd30_eod_limit90_l12m
    ,cnt_user_fpd30_limit90_l6m                  as cnt_user_fpd30_eod_limit90_l6m
    ,cnt_user_fpd30_limit90_l3m                  as cnt_user_fpd30_eod_limit90_l3m
    ,cnt_user_fpd30_limit90_l1m                  as cnt_user_fpd30_eod_limit90_l1m
    ,cnt_user_cpd1_l24m                          as cnt_user_cpd1_eod_l24m
    ,cnt_user_cpd1_l12m                          as cnt_user_cpd1_eod_l12m
    ,cnt_user_cpd1_l6m                           as cnt_user_cpd1_eod_l6m
    ,cnt_user_cpd1_l3m                           as cnt_user_cpd1_eod_l3m
    ,cnt_user_cpd1_l1m                           as cnt_user_cpd1_eod_l1m
    ,cnt_user_cpd1_limit90_l24m                  as cnt_user_cpd1_eod_limit90_l24m
    ,cnt_user_cpd1_limit90_l12m                  as cnt_user_cpd1_eod_limit90_l12m
    ,cnt_user_cpd1_limit90_l6m                   as cnt_user_cpd1_eod_limit90_l6m
    ,cnt_user_cpd1_limit90_l3m                   as cnt_user_cpd1_eod_limit90_l3m
    ,cnt_user_cpd1_limit90_l1m                   as cnt_user_cpd1_eod_limit90_l1m
    ,cnt_user_cpd7_l24m                          as cnt_user_cpd7_eod_l24m
    ,cnt_user_cpd7_l12m                          as cnt_user_cpd7_eod_l12m
    ,cnt_user_cpd7_l6m                           as cnt_user_cpd7_eod_l6m
    ,cnt_user_cpd7_l3m                           as cnt_user_cpd7_eod_l3m
    ,cnt_user_cpd7_l1m                           as cnt_user_cpd7_eod_l1m
    ,cnt_user_cpd7_limit90_l24m                  as cnt_user_cpd7_eod_limit90_l24m
    ,cnt_user_cpd7_limit90_l12m                  as cnt_user_cpd7_eod_limit90_l12m
    ,cnt_user_cpd7_limit90_l6m                   as cnt_user_cpd7_eod_limit90_l6m
    ,cnt_user_cpd7_limit90_l3m                   as cnt_user_cpd7_eod_limit90_l3m
    ,cnt_user_cpd7_limit90_l1m                   as cnt_user_cpd7_eod_limit90_l1m
    ,cnt_user_cpd30_l24m                         as cnt_user_cpd30_eod_l24m
    ,cnt_user_cpd30_l12m                         as cnt_user_cpd30_eod_l12m
    ,cnt_user_cpd30_l6m                          as cnt_user_cpd30_eod_l6m
    ,cnt_user_cpd30_l3m                          as cnt_user_cpd30_eod_l3m
    ,cnt_user_cpd30_l1m                          as cnt_user_cpd30_eod_l1m
    ,cnt_user_cpd30_limit90_l24m                 as cnt_user_cpd30_eod_limit90_l24m
    ,cnt_user_cpd30_limit90_l12m                 as cnt_user_cpd30_eod_limit90_l12m
    ,cnt_user_cpd30_limit90_l6m                  as cnt_user_cpd30_eod_limit90_l6m
    ,cnt_user_cpd30_limit90_l3m                  as cnt_user_cpd30_eod_limit90_l3m
    ,cnt_user_cpd30_limit90_l1m                  as cnt_user_cpd30_eod_limit90_l1m
    ,cnt_user_dpd30_l2y_l24m                     as cnt_user_dpd30_eod_l2y_l24m
    ,cnt_user_dpd30_l2y_l12m                     as cnt_user_dpd30_eod_l2y_l12m
    ,cnt_user_dpd30_l2y_l6m                      as cnt_user_dpd30_eod_l2y_l6m
    ,cnt_user_dpd30_l2y_l3m                      as cnt_user_dpd30_eod_l2y_l3m
    ,cnt_user_dpd30_l2y_l1m                      as cnt_user_dpd30_eod_l2y_l1m
    ,cnt_user_dpd30_l2y_limit90_l24m             as cnt_user_dpd30_eod_l2y_limit90_l24m
    ,cnt_user_dpd30_l2y_limit90_l12m             as cnt_user_dpd30_eod_l2y_limit90_l12m
    ,cnt_user_dpd30_l2y_limit90_l6m              as cnt_user_dpd30_eod_l2y_limit90_l6m
    ,cnt_user_dpd30_l2y_limit90_l3m              as cnt_user_dpd30_eod_l2y_limit90_l3m
    ,cnt_user_dpd30_l2y_limit90_l1m              as cnt_user_dpd30_eod_l2y_limit90_l1m
    ,cnt_user_cpd1_credit_l24m                   as cnt_user_cpd1_eod_credit_l24m
    ,cnt_user_cpd1_credit_l12m                   as cnt_user_cpd1_eod_credit_l12m
    ,cnt_user_cpd1_credit_l6m                    as cnt_user_cpd1_eod_credit_l6m
    ,cnt_user_cpd1_credit_l3m                    as cnt_user_cpd1_eod_credit_l3m
    ,cnt_user_cpd1_credit_l1m                    as cnt_user_cpd1_eod_credit_l1m
    ,cnt_user_cpd7_credit_l24m                   as cnt_user_cpd7_eod_credit_l24m
    ,cnt_user_cpd7_credit_l12m                   as cnt_user_cpd7_eod_credit_l12m
    ,cnt_user_cpd7_credit_l6m                    as cnt_user_cpd7_eod_credit_l6m
    ,cnt_user_cpd7_credit_l3m                    as cnt_user_cpd7_eod_credit_l3m
    ,cnt_user_cpd7_credit_l1m                    as cnt_user_cpd7_eod_credit_l1m
    ,cnt_user_cpd30_credit_l24m                  as cnt_user_cpd30_eod_credit_l24m
    ,cnt_user_cpd30_credit_l12m                  as cnt_user_cpd30_eod_credit_l12m
    ,cnt_user_cpd30_credit_l6m                   as cnt_user_cpd30_eod_credit_l6m
    ,cnt_user_cpd30_credit_l3m                   as cnt_user_cpd30_eod_credit_l3m
    ,cnt_user_cpd30_credit_l1m                   as cnt_user_cpd30_eod_credit_l1m
    ,cnt_user_dpd30_l2y_limit90_credit_l24m      as cnt_user_dpd30_eod_l2y_limit90_credit_l24m
    ,cnt_user_dpd30_l2y_limit90_credit_l12m      as cnt_user_dpd30_eod_l2y_limit90_credit_l12m
    ,cnt_user_dpd30_l2y_limit90_credit_l6m       as cnt_user_dpd30_eod_l2y_limit90_credit_l6m
    ,cnt_user_dpd30_l2y_limit90_credit_l3m       as cnt_user_dpd30_eod_l2y_limit90_credit_l3m
    ,cnt_user_dpd30_l2y_limit90_credit_l1m       as cnt_user_dpd30_eod_l2y_limit90_credit_l1m  
    ,is_gps_palembang                            as is_gps_palembang_l1m                       
    ,is_ip_palembang                             as is_ip_palembang_l1m                        
from 
${SCHEMA}.ads_risk_${reg}_${risk_tab_biz_type}_device_user_agg_tmp_df;
