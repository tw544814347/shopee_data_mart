--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-04-08
-- Theme Domain：       risk model
-- Description:         
-- Data Granularity:    
-- 变更历史：
--********************************************************************--

-- ${common_head};

-- drop table if exists ${SCHEMA}.ads_risk_br_spl_acard_monitor_di;
create external table if not exists ${SCHEMA}.ads_risk_br_spl_acard_monitor_di (
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
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/ads/ads_risk_real_time_model_monitor_di/garss_region=${grass_region}/fs_id=${service_name}'
;

-- msck repair table ${SCHEMA}.ads_risk_br_spl_acard_monitor_di;

insert overwrite ${SCHEMA}.ads_risk_br_spl_acard_monitor_di partition(grass_date)
select cast(time_window as string)  as time_window        
        ,fs_version           
        ,fs_status            
        ,score_state_1        
        ,score_state_2        
        ,score_state_3        
        ,score_state_4        
        ,score_state_5        
        ,score_type           
        ,score_type_rank      
        ,score_bin            
        ,bin_rank             
        ,bin_count            
        ,duration_sum         
        ,duration_max         
        ,timeout_request_count
        ,grass_date
from    regsm_riskmgmt.aimos_fs_monitoring
where   grass_date = '${ds}'
and     fs_id = '${service_name}'