--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dwd 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

DROP TABLE IF EXISTS risk_report.dwd_risk_${reg}_group_fraud_gpshexn_di;
CREATE TABLE risk_report.dwd_risk_${reg}_group_fraud_gpshexn_di (
    gpshex8 STRING COMMENT '',
    gpshex9 STRING COMMENT '',
    gpshex10 STRING COMMENT '',
    gpshex11 STRING COMMENT '',
    app_id STRING COMMENT '',
    scene_id STRING COMMENT '',
    platform_user_id STRING COMMENT '',
    req_time BIGINT COMMENT '',

    end_result STRING COMMENT '',
    is_batch_registration INT COMMENT '',
    is_reactivate INT COMMENT ''
)
COMMENT ''
PARTITIONED BY (
    grass_date STRING,
    process_date STRING
)
STORED AS parquet
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/dwd/dwd_risk_reg_group_fraud_gpshexn_agg_di/grass_region=${grass_region}';

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;

drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

WITH batch_users AS (
    SELECT DISTINCT user_id, 1 as is_batch_registration
    FROM risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df
    WHERE grass_date = '${ds}'
),

gpshexn_base_today AS (
    SELECT DISTINCT
        gpshex8,
        gpshex9,
        gpshex10,
        gpshex11,
        app_id,
        scene_id, 
        platform_user_id,
        req_time,

        end_result,
        COALESCE(b.is_batch_registration, 0) as is_batch_registration,
        is_reactivate
    FROM risk_report.dwd_risk_${reg}_group_fraud_feature_act_base_di a
    LEFT JOIN batch_users b ON a.platform_user_id = b.user_id
    WHERE a.process_date = '${ds}'
      AND ((a.gpshex8 IS NOT NULL AND a.gpshex8 != '' AND a.gpshex8 != '""') or
            (a.gpshex9 IS NOT NULL AND a.gpshex9 != '' AND a.gpshex9 != '""') or
            (a.gpshex10 IS NOT NULL AND a.gpshex10 != '' AND a.gpshex10 != '""') or 
            (a.gpshex11 IS NOT NULL AND a.gpshex11 != '' AND a.gpshex11 != '""')
          )

)

insert overwrite table risk_report.dwd_risk_${reg}_group_fraud_gpshexn_di partition (grass_date, process_date)

SELECT  gpshex8,
        gpshex9,
        gpshex10,
        gpshex11,
        app_id,
        scene_id, 
        platform_user_id,
        req_time,
        end_result,
        is_batch_registration,
        cast(is_reactivate as int),
        cast(date(format_time(req_time,UPPER('${reg}'))) as string) as grass_date,
        '${ds}' as process_date
FROM gpshexn_base_today;


msck repair table risk_report.dwd_risk_${reg}_group_fraud_gpshexn_di;
refresh table risk_report.dwd_risk_${reg}_group_fraud_gpshexn_di;