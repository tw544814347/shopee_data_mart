--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dwd 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

drop table if exists risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di;
CREATE TABLE IF NOT EXISTS risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di (
    flow_no STRING,
    platform_user_id STRING,
    app_id STRING,
    scene_id STRING,
    af_result STRING,
    req_time BIGINT,
    szdf STRING,
    bssid STRING,
    device_brand STRING,
    device_model STRING,
    app_version STRING,
    system_type STRING,
    app_type STRING,
    reg_phone STRING,
    client_ip STRING,
    ip_city_name STRING,
    gpshex6 STRING,
    gpshex7 STRING,
    gpshex8 STRING,
    gpshex9 STRING,
    gpshex10 STRING,
    gpshex11 STRING,
    location_status STRING,
    gps_country STRING,
    gps_city STRING,
    gps_province STRING,
    gps_district STRING,
    gps_subdistrict STRING,
    is_spl_reactivate STRING,
    is_bcl_reactivate STRING,
    is_scl_reactivate STRING,
    is_reactivate STRING,
    end_result STRING,
    ip3 STRING --ip3 use
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
location '${HDFS_PATH}/dwd/dwd_risk_reg_group_fraud_feature_trx_base_di/grass_region=${grass_region}';

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;

drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

WITH workflow_result AS (
    SELECT
        flow_no,
        CASE
            WHEN coalesce(
                    get_json_object(output, '$.CheckResult'),
                    get_json_object(output, '$.checkResult')
                ) = '1'
            THEN 'pass'
            ELSE 'reject'
        END AS final_result
    FROM risk.dwd_risk_${reg}_af_credit_workflow_di
    WHERE grass_date >= cast('${ds_t_3}' as string) --考虑晚到
      AND grass_date <= cast('${ds}' as string) 
      AND scene_id IN (10035,10025,10045,10055,10075,10084,10005,10095,10105)
          AND app_id IN ('kredit','spj','chp','2w','tl','spjup','motorloan')
),
final_result AS (
    SELECT
        *,
        CASE
            WHEN (is_spl_reactivate = '1' AND app_id = 'kredit')
              OR (is_bcl_reactivate = '1' AND app_id = 'spj')
              OR (is_scl_reactivate = '1' AND app_id = 'spjup')
            THEN 1 ELSE 0
        END AS is_reactivate,
        CONCAT(SPLIT(client_ip,'\\.')[0],'.',SPLIT(client_ip,'\\.')[1],'.',SPLIT(client_ip,'\\.')[2]) AS ip3
    FROM (
        SELECT DISTINCT
            a.flow_no,
            a.platform_user_id,
            app_id,
            scene_id,
            a.final_result AS af_result,
            b.final_result AS end_result,
            cast(date(format_time(req_time,UPPER('${reg}'))) as string) AS req_dt, --as partition
            req_time,
            get_json_object(extension,'$.CommonHeader.extension_process_data.sz_dfp.device_id') AS szdf,
            get_json_object(extension,'$.CommonHeader.extension_process_data.sz_dfp.bssid') AS bssid,
            device_brand,
            device_model,
            app_version,
            system_type,
            app_type,
            get_json_object(extension,'$.PhoneNo') AS reg_phone,
            get_json_object(extension,'$.CommonHeader.client_ip') AS client_ip,
            get_json_object(extension,'$.CommonHeader.extension_process_data.ip_city_info.ip_city_name_v2') AS ip_city_name,
            get_json_object(extension,'$.CommonHeader.location.GpsHex6') AS gpshex6,
            get_json_object(extension,'$.CommonHeader.location.GpsHex7') AS gpshex7,
            get_json_object(extension,'$.CommonHeader.location.GpsHex8') AS gpshex8,
            get_json_object(extension,'$.CommonHeader.location.GpsHex9') AS gpshex9,
            get_json_object(extension,'$.CommonHeader.location.GpsHex10') AS gpshex10,
            get_json_object(extension,'$.CommonHeader.location.GpsHex11') AS gpshex11,
            get_json_object(extension,'$.CommonHeader.location.status') AS location_status,
            get_json_object(extension,'$.CommonHeader.location.address.levelZero') AS gps_country,
            get_json_object(extension,'$.CommonHeader.location.address.levelOne') AS gps_city,
            get_json_object(extension,'$.CommonHeader.location.address.levelTwo') AS gps_province,
            get_json_object(extension,'$.CommonHeader.location.address.levelThree') AS gps_district,
            get_json_object(extension,'$.CommonHeader.location.address.levelFour') AS gps_subdistrict,
            coalesce(get_json_object(extension, '$.is_spl_activated'), '0') AS is_spl_reactivate,
            coalesce(get_json_object(extension, '$.is_cashloan_activated'), '0') AS is_bcl_reactivate,
            coalesce(get_json_object(extension, '$.is_sellerloan_activated'), '0') AS is_scl_reactivate,
            network_type,
            cellular_type
        FROM risk.dwd_risk_${reg}_strategy_final_result_merge_di a
        INNER JOIN workflow_result b
            ON a.workflow_flow_no = b.flow_no
        WHERE scene_id IN (10034, 10024, 10044, 10054, 10074, 10104, 10094, 10026, 10004, 10085)
          AND app_id IN ('kredit','spj','chp','2w','tl','spjup','motorloan')
          AND grass_date >= cast('${ds_t_3}' as string) --考虑晚到
          AND grass_date <= cast('${ds}' as string) 
    )
)

insert overwrite table risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di partition (grass_date, process_date)
select 
    flow_no,
    platform_user_id,
    app_id,
    cast(scene_id as string),
    cast(af_result as string),
    req_time,
    szdf,
    bssid,
    device_brand,
    device_model,
    app_version,
    system_type,
    app_type, 
    reg_phone,
    client_ip,
    ip_city_name,
    gpshex6,
    gpshex7,
    gpshex8,
    gpshex9,
    gpshex10,
    gpshex11,
    location_status,
    gps_country,
    gps_city,
    gps_province,
    gps_district,
    gps_subdistrict,
    cast(is_spl_reactivate as STRING),
    cast(is_bcl_reactivate as STRING),
    cast(is_scl_reactivate as STRING),
    cast(is_reactivate as STRING),
    end_result,
    ip3,
    req_dt as grass_date,
    '${ds}' as process_date
from final_result
;

msck repair table risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di;
refresh table risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di;