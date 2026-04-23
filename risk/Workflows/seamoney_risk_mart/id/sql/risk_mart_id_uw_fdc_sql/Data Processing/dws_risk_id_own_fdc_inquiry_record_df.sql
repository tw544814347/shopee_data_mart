--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_own_fdc_inquiry_record_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_own_fdc_inquiry_record_df
(
    ktp_req       STRING
    ,own_unique_inquiry_3days bigint
    ,own_unique_inquiry_7days bigint
    ,own_unique_inquiry_30days bigint
    ,own_unique_inquiry_90days bigint
    ,own_unique_inquiry_180days bigint
    ,own_unique_inquiry_360days bigint
    ,own_unique_inquiry_over_360days bigint
    ,own_inquiry_3days bigint
    ,own_inquiry_7days bigint
    ,own_inquiry_30days bigint
    ,own_inquiry_90days bigint
    ,own_inquiry_180days bigint
    ,own_inquiry_360days bigint
    ,own_inquiry_over_360days bigint
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dws/dws_risk_own_fdc_inquiry_record_df/grass_region=ID';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_own_fdc_inquiry_record_df;


create or replace temporary view dwd_fdc_query_cnt as
select
    ktp_req
    ,grass_date
    ,case when grass_date >= current_date - interval '3' day then 1 else 0 end as is_in_last_3days
    ,case when grass_date >= current_date - interval '7' day then 1 else 0 end as is_in_last_7days
    ,case when grass_date >= current_date - interval '30' day then 1 else 0 end as is_in_last_30days
    ,case when grass_date >= current_date - interval '90' day then 1 else 0 end as is_in_last_90days
    ,case when grass_date >= current_date - interval '180' day then 1 else 0 end as is_in_last_180days
    ,case when grass_date >= current_date - interval '360' day then 1 else 0 end as is_in_last_360days
    ,1 as is_ever
from risk.dwd_risk_id_fdc_overall_info_di
;

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_id_own_fdc_inquiry_record_df PARTITION (grass_date)
select
    ktp_req
    ,max(is_in_last_3days) as own_unique_inquiry_3days
    ,max(is_in_last_7days) as own_unique_inquiry_7days
    ,max(is_in_last_30days) as own_unique_inquiry_30days
    ,max(is_in_last_90days) as own_unique_inquiry_90days
    ,max(is_in_last_180days) as own_unique_inquiry_180days
    ,max(is_in_last_360days) as own_unique_inquiry_360days
    ,max(is_ever) as own_unique_inquiry_over_360days
    ,sum(is_in_last_3days) as own_inquiry_3days
    ,sum(is_in_last_7days) as own_inquiry_7days
    ,sum(is_in_last_30days) as own_inquiry_30days
    ,sum(is_in_last_90days) as own_inquiry_90days
    ,sum(is_in_last_180days) as own_inquiry_180days
    ,sum(is_in_last_360days) as own_inquiry_360days
    ,sum(is_ever) as own_inquiry_over_360days
    ,'${ds}' as grass_date
from dwd_fdc_query_cnt
group by 1
;