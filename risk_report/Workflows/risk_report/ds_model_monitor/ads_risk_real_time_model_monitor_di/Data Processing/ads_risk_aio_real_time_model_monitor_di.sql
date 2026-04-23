--drop table if exists ${SCHEMA}.ads_risk_mx_real_time_model_monitor_di;
create external table if not exists ${SCHEMA}.ads_risk_aio_real_time_model_monitor_di (
    time_window             STRING  comment 'Hour-truncated Timestamp Partition key'
    ,fs_version             STRING  comment 'Feature Service Version'
    ,fs_status              STRING  comment 'Feature Service Status'
    ,score_state_1          STRING  comment 'Reserved Score State 1'
    ,score_state_2          STRING  comment 'Reserved Score State 2'
    ,score_state_3          STRING  comment 'Reserved Score State 3'
    ,score_state_4          STRING  comment 'Reserved Score State 4'
    ,score_state_5          STRING  comment 'Reserved Score State 5'
    ,score_type             STRING  comment 'Score Type'
    ,score_type_rank        BIGINT  comment 'Score Type Rank'
    ,score_bin              STRING  comment 'Score Bin'
    ,bin_rank               DECIMAL(30,10)  comment 'Bin Rank'
    ,bin_count              BIGINT  comment 'Bin Count'
    ,duration_sum           BIGINT  comment 'Duration Sum'
    ,duration_max           BIGINT  comment 'Duration Max'
    ,timeout_request_count  BIGINT  comment 'Timeout Request Count'
) partitioned by (
    grass_region   STRING  comment 'PH/TH/BR/MY……'
    ,fs_id      string       comment 'Feature Service Nmae'
    ,grass_date string      comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/ads/ads_risk_real_time_model_monitor_di/'
;
msck repair table ${SCHEMA}.ads_risk_aio_real_time_model_monitor_di;

create or replace view ${SCHEMA}.ads_risk_th_real_time_model_monitor_di AS 
select * from ${SCHEMA}.ads_risk_aio_real_time_model_monitor_di where grass_region='TH'
;

create or replace view ${SCHEMA}.ads_risk_ph_real_time_model_monitor_di AS 
select * from ${SCHEMA}.ads_risk_aio_real_time_model_monitor_di where grass_region='PH'
;


create or replace view ${SCHEMA}.ads_risk_mx_real_time_model_monitor_di AS 
select * from ${SCHEMA}.ads_risk_aio_real_time_model_monitor_di where grass_region='MX'
;


create or replace view ${SCHEMA}.ads_risk_mx_real_time_model_monitor_di AS 
select * from ${SCHEMA}.ads_risk_aio_real_time_model_monitor_di where grass_region='BR'
;


