-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-26
-- Theme Domain:        
-- Data Granularity:    phone_no
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-26 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.ads_risk_id_social_score_phone_info_df;
create external table if not exists ${SCHEMA}.ads_risk_id_social_score_phone_info_df
(
    phone_no                                            string         comment 'phone number'
    ,phone_no_sha256                                    string         comment 'phone number sha256'
    ,phone_no_base64                                    string         comment 'phone number base64'
    ,social_score                                       bigint         comment 'social score'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/ads_risk_reg_social_score_phone_info_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.ads_risk_id_social_score_phone_info_df;

add jar hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-sha-256.jar;
create or replace temporary function sha256 as 'com.shopee.udf.RiskSha256';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table ${SCHEMA}.ads_risk_id_social_score_phone_info_df partition (grass_date)
select
    t1.phone_no
    ,sha256(t1.phone_no) as phone_no_sha256
    ,base64(t1.phone_no) as phone_no_base64
    ,t2.social_score
    ,date_add('${grass_date}', 1) as grass_date
from
(
    select
        regexp_replace(cast(decode(account, 'utf-8') as string), '[^0-9]', '') as phone_no
    from marketplace.shopee_contact_id_db__contact_tab__reg_continuous_s0_live
    where format_time(report_time, 'ID') <= date_add('${grass_date}', 1)
        and acctype = 1  -- 1 phone 2 facebook 3 email
        and report_time > 0
    group by 1 
) t1
left join
(
    select
        phone_number as phone_no
        ,round(score) as social_score
    from rescbds_credit.id_tob_rst_credit_score
    where grass_date = date_add('${grass_date}', 1)
    group by 1, 2  --业务表历史切片，存在整行完全重复的数据，加上去重；
) t2
on t1.phone_no = t2.phone_no
;

