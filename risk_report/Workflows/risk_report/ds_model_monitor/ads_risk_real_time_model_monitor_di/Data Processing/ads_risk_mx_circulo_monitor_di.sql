--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-04-08
-- Theme Domain：       risk model
-- Description:         risk mp user_info, https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit#gid=617476295
-- Data Granularity:    
-- 变更历史：
--********************************************************************--

-- ${common_head};

-- drop table if exists ${SCHEMA}.ads_risk_mx_circulo_monitor_di;
create external table if not exists ${SCHEMA}.ads_risk_mx_circulo_monitor_di (
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
-- msck repair table ${SCHEMA}.ads_risk_mx_circulo_monitor_di;

-- 1	(0.03,0.091]
-- 2	(0.0911,0.1167]
-- 3	(0.1169,0.1419]
-- 4	(0.1419,0.1645]
-- 5	(0.1645,0.1853]
-- 6	(0.1855,0.2017]
-- 7	(0.2018,0.2195]
-- 8	(0.2199,0.2375]
-- 9	(0.2377,0.2545]
-- 10	(0.2545,0.27]
-- 11	(0.27,0.2887]
-- 12	(0.2887,0.3079]
-- 13	(0.3079,0.3264]
-- 14	(0.3265,0.3467]
-- 15	(0.3468,0.368]
-- 16	(0.3682,0.3736]
-- 17	(0.3736,0.3926]
-- 18	(0.3928,0.4256]
-- 19	(0.4256,0.4823]
-- 20	(0.4824,0.7609]

with mx_circulo as (
    select 'MX-circulo_model_v3_0' AS fs_id,
            req_time,
            duration,
            fs_status,
            fs_version,
            case when duration > 1300 then 1 else 0 end AS duration_risk_timeout,
            case    when mega_score > 0.03 and mega_score <= 0.091 then '(0.03,0.091]'
                    when mega_score > 0.0911 and mega_score <= 0.1167 then '(0.0911,0.1167]'
                    when mega_score > 0.1169 and mega_score <= 0.1419 then '(0.1169,0.1419]'
                    when mega_score > 0.1419 and mega_score <= 0.1645 then '(0.1419,0.1645]'
                    when mega_score > 0.1645 and mega_score <= 0.1853 then '(0.1645,0.1853]'
                    when mega_score > 0.1855 and mega_score <= 0.2017 then '(0.1855,0.2017]'
                    when mega_score > 0.2018 and mega_score <= 0.2195 then '(0.2018,0.2195]'
                    when mega_score > 0.2199 and mega_score <= 0.2375 then '(0.2199,0.2375]'
                    when mega_score > 0.2377 and mega_score <= 0.2545 then '(0.2377,0.2545]'
                    when mega_score > 0.2545 and mega_score <= 0.27 then '(0.2545,0.27]'
                    when mega_score > 0.27 and mega_score <= 0.2887 then '(0.27,0.2887]'
                    when mega_score > 0.2887 and mega_score <= 0.3079 then '(0.2887,0.3079]'
                    when mega_score > 0.3079 and mega_score <= 0.3264 then '(0.3079,0.3264]'
                    when mega_score > 0.3265 and mega_score <= 0.3467 then '(0.3265,0.3467]'
                    when mega_score > 0.3468 and mega_score <= 0.368 then '(0.3468,0.368]'
                    when mega_score > 0.3682 and mega_score <= 0.3736 then '(0.3682,0.3736]'
                    when mega_score > 0.3736 and mega_score <= 0.3926 then '(0.3736,0.3926]'
                    when mega_score > 0.3928 and mega_score <= 0.4256 then '(0.3928,0.4256]'
                    when mega_score > 0.4256 and mega_score <= 0.4823 then '(0.4256,0.4823]'
                    when mega_score > 0.4824 and mega_score <= 0.7609 then '(0.4824,0.7609]'
                    else 'Invalid'
            end as mega_score_bin
            
    from (
        select trace_id,
                req_time as req_time,
                case    when node_type = 'END' then     finishedat  -   req_time end as duration,
                status as fs_status,
                version as fs_version,
                -- mega
                case    when node_type = 'END' then cast(get_json_object(output,'$.score') AS decimal(30,10)) end as mega_score,
                row_number() over(partition by trace_id order by req_time desc) as rn
        from szfin_feature_management.dwd_aimos_service_node_log_di_mx
        where   grass_date between '${ds}' and '${ds_t_0}'
        and     node_type = 'END'
        and     service_name = 'mx_circulo_model_v3_0'
        and     tag = 'online'
    )
    where rn = 1
)
insert overwrite ${SCHEMA}.ads_risk_mx_circulo_monitor_di partition (grass_date)
select cast(date_trunc('hour', from_unixtime(req_time / 1000)) as string) AS time_window, --1
        fs_version, --2
        fs_status, --3
        null AS score_state_1, --4
        null AS score_state_2, --5
        null AS score_state_3, --6
        null AS score_state_4, --7
        null AS score_state_5, --8
        'mega' AS score_type, --9
        0 AS score_type_rank, --10
        mega_score_bin AS score_bin, --11
        CASE    WHEN mega_score_bin = 'Invalid' THEN NULL
            WHEN mega_score_bin LIKE '%(-inf%' THEN NULL
            WHEN instr(mega_score_bin, ',') > 0 THEN CAST(
            TRIM(REGEXP_REPLACE(substring(mega_score_bin, 1, instr(mega_score_bin, ',') - 1),'[()\\[\\]]','')) AS DECIMAL(30,10))
        ELSE    CAST(REGEXP_REPLACE(mega_score_bin, '[()\\[\\]]', '') AS DECIMAL(30,10))
        END AS bin_rank, --12
        count(1) AS bin_count, --13
        sum(duration) AS duration_sum, --14
        max(duration) AS duration_max, --15
        sum(duration_risk_timeout) AS timeout_request_count, --16
        -- fs_id, --17
        date_format(from_unixtime(req_time / 1000), 'yyyy-MM-dd') AS grass_date --18
from mx_circulo
group by 1,2,3,9,11,12,17