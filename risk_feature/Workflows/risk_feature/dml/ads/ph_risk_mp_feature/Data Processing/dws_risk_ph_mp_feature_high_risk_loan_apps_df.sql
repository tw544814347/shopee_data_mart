--********************************************************************--
-- Author:              siyuan.sun@shopee.com
-- Created Time:        2026-01-12 T14:10:00
-- Description:         This script is to add risk feature - number of high risk loan apps at PH region about MP metrics. 
-- Data Granularity   
-- PRD                  https://docs.google.com/spreadsheets/d/1YIi5CpeZkcxdRGsTyEmxsSjt52LQrEL40lm8_eJw3MI/edit?gid=755412075#gid=755412075
-- Casement             https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-59381
--********************************************************************--

-- Register Java UDF for AES Decryption - create a UDF Function to decrpty the data column from tracking.shopee_tracking_ods_dps_merge_installed_app_di__ph_s1_live 
add JAR hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-aes-decrypt-udf-2.0.jar;
create function if not exists aes_decrypt_v2 as 'com.shopee.udf.AesDecryptUDF' 
using JAR 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-aes-decrypt-udf-2.0.jar';
 
-- drop table if exists risk_feature.dws_risk_ph_mp_feature_high_risk_loan_apps_df;
create table if not exists risk_feature.dws_risk_ph_mp_feature_high_risk_loan_apps_df (
    platform_user_id                         string comment ''
    ,number_of_high_risk_loan_apps_l90d      bigint comment ''
    ,number_of_high_risk_loan_apps_l180d     bigint comment ''
    ,number_of_high_risk_loan_apps_l360d     bigint comment ''
) partitioned by (
    grass_date string 
) 
stored as orc 
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)
location '${HDFS_PATH}/risk_feature/ads/dws_risk_ph_mp_feature_high_risk_loan_apps_df'
;
-- msck repair table ${SCHEMA}.dws_risk_ph_mp_feature_high_risk_loan_apps_df;

-- Decrypted log table with decrypted data column 
-- Extract app_info JSON string which contains app_id, app_name, first_installed_time, last_updated_time 
-- t2: app_info_extracted table contains userid, device_id, grass_date, app_info_str 
with app_info as (
    select  userid
            ,device_id
            ,grass_date
            ,app_info_str
    from    (
                select  userid                                              as userid
                        ,deviceid                                           as device_id
                        ,device_fingerprint                                 as device_fingerprint
                        ,task_id                                            as task_id
                        ,to_timestamp(from_unixtime(log_timestamp / 1000))  as log_timestamp
                        ,grass_date                                         as grass_date
                        ,platform                                           as platform
                        ,trigger_source                                     as trigger_source
                        ,get_json_object(aes_decrypt_v2(data, 'A936239294314A85059330B047B35282', '0000000000000000'),'$.app_info')    as app_info_str
                from tracking.shopee_tracking_ods_dps_merge_installed_app_di__ph_s1_live
                where grass_date between date_sub('${ds}', 360) 
                and '${ds}' 
            )  --decrypted_log 
    where app_info_str is not null 
    and app_info_str != ''
    and app_info_str != '[]'
),
-- Parse JSON array - handles multiple apps per array
-- Actual structure: [{"app_id":"xxx","app_name":"yyy","first_installed_time":number/timestamp, "last_updated_time":number/timestamp}, {"app_id":"yyy",...}, ...]
-- Use structField to parse JSON object fields, no need to do the regex expression here 
parsed_apps as (
    select  t1.userid
            ,t1.device_id
            ,t1.grass_date
            ,t2.col.app_id as app_id
            ,datediff('${ds}', t1.grass_date) as days_ago
    from app_info t1
    lateral view explode(
        from_json(
            app_info_str, 
            'array<struct<app_id:string,app_name:string,first_installed_time:bigint,last_updated_time:bigint>>')) t2
    where t2.col.app_id is not null
)

insert overwrite risk_feature.dws_risk_ph_mp_feature_high_risk_loan_apps_df  partition (grass_date)
select  t3.userid as platform_user_id
        ,coalesce(count(distinct case when t4.days_ago <= 90  then t4.app_id end),0)   as number_of_high_risk_loan_apps_l90d
        ,coalesce(count(distinct case when t4.days_ago <= 180 then t4.app_id end),0)   as number_of_high_risk_loan_apps_l180d
        ,coalesce(count(distinct case when t4.days_ago <= 360 then t4.app_id end),0)   as number_of_high_risk_loan_apps_l360d
        ,'${ds}'                                                                    as grass_date
from    (
    select distinct userid
    from parsed_apps 
    )  t3 
    left join   (  
                select distinct t1.userid
                                ,t1.app_id
                                ,t1.days_ago --distinct_user_app, drop duplicates based on user_id and app_id and filter out the apps that are not in the list of high-risk loan apps.
                from  parsed_apps t1 
                inner join risk_feature.dim_risk_ph_high_risk_loan_dpp_df t2 -- filter out non-high-risk loan apps 
                on t1.app_id = t2.app_id and t2.flag = 'Yes'
                ) t4 
on t3.userid = t4.userid
where t3.userid is not null
group by t3.userid; 