-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-12-04
-- Theme Domain:        Customer Stability Check Input Backtesting
-- Data Granularity:    
-- Description:         Address and GPS location distance calculation for KTP backtesting
--                      Calculate haversine distance between user input address GPS and KTP registered address
--                      Generate distance score (1-7) based on distance threshold
--                      Include detailed address information (level1/2/3, zip_code)
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-28 - chenyingying - 原始需求Jira: https://jira.shopee.io/browse/SPFDT-54670
--  2025-12-04 - chengguo.liu - 修复 address backtesting逻辑 - Jira: https://jira.shopee.io/browse/SPFDT-58191
--  2026-04-01 taowei 新增 id  方便后续读表按照 id 排序传文件 https://jira.shopee.io/browse/SPFDT-62032
-- =============================================================================


--drop table if exists ${SCHEMA}.ads_risk_${region}_address_ktp_phone_backtesting_info_rt;
create external table if not exists ${SCHEMA}.ads_risk_${region}_address_ktp_phone_backtesting_info_rt (
    backtest_date   string comment 'task_data.backtest_date'
    ,ktp_no         string comment 'task_data.ktp_no'
    ,phone_no       string comment 'task_data.msisdn'
    ,address_level1	    string comment 'task_data.address_level1'
    ,address_level2	    string comment 'task_data.address_level2'
    ,address_level3	    string comment 'task_data.address_level3'
    ,address	        string comment 'address'
    ,zip_code           string comment 'zipcode'	
    ,gps                string comment 'gps'	
    ,distance_score     int comment ''	
    ,confidence_level   string comment ''
    ,is_ktp_match       int comment '是否ktp匹配'
    ,is_phone_match     int comment '是否phone匹配'
    ,id                 bigint comment ''

)
partitioned by (
    grass_date string 
    ,task_id string
) 
stored as orc 
comment ''
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_feature/ads/ads_risk_address_ktp_phone_backtesting_info_rt/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.ads_risk_${region}_address_ktp_phone_backtesting_info_rt;


uncache table if exists t_backtesting_task_id_list;
cache table t_backtesting_task_id_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    t1.task_id
    ,t2.id
    ,t1.task_status
    ,t1.hash_method
    ,get_json_object(t2.task_data, '$.ktp_no') as ktp_no
    ,get_json_object(t2.task_data, '$.msisdn') as phone_no
    ,get_json_object(t2.task_data, '$.backtest_date') as backtest_date
    ,get_json_object(t2.task_data, '$.gps') as gps
    ,cast(split(regexp_replace(get_json_object(t2.task_data, '$.gps'), '[()]', ''), ',')[0] as double) as gps_x
    ,cast(split(regexp_replace(get_json_object(t2.task_data, '$.gps'), '[()]', ''), ',')[1] as double) as gps_y
    ,get_json_object(t2.task_data, '$.address_level1') as address_level1
    ,get_json_object(t2.task_data, '$.address_level2') as address_level2
    ,get_json_object(t2.task_data, '$.address_level3') as address_level3
    ,get_json_object(t2.task_data, '$.address') as address
    ,get_json_object(t2.task_data, '$.zip_code') as zip_code
from
(
    select
        task_id
        ,task_status
        ,lower(hash_method) as hash_method
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_tab__spark
    where 1=1
    and task_status = 5
    and service_name_list = 'CustomerStabilityCheckInput'
) t1
left join
(
    select
        task_id
        ,task_data
        ,id
    from risk.view__scoring_open_platform_id_db__auto_backtesting_task_data_tab__spark
) t2
on t1.task_id = t2.task_id
left join
(
    select
        task_id
    from ${SCHEMA}.ads_risk_${region}_address_ktp_phone_backtesting_info_rt
    where grass_date = '${ds}'
    group by task_id
) t3
on t1.task_id = t3.task_id
where t3.task_id is null
;

uncache table if exists t_backtesting_backtest_date_list;
cache table t_backtesting_backtest_date_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    backtest_date
from t_backtesting_task_id_list
group by backtest_date
;

create or replace temporary view t_backtesting_task_result as
select  task_id
        ,id
        ,backtest_date
        ,ktp_no
        ,phone_no
        ,address_level1
        ,address_level2
        ,address_level3
        ,address
        ,zip_code
        ,gps
        ,case   when distance <= 0.25 then 7
                when distance > 0.25 and distance <= 0.5 then 6
                when distance > 0.5 and distance <= 1 then 5
                when distance > 1 and distance <= 2 then 4
                when distance > 2 and distance <= 3 then 3
                when distance > 3 and distance <= 5 then 2
                when distance > 5 then 1
                else 0 end as distance_score
        ,case   when distance is null then null
                else confidence_level end as confidence_level
        ,is_ktp_match
        ,is_phone_match
from
(
    select task_id
        ,id
        ,ktp_no
        ,phone_no
        ,backtest_date
        ,gps
        ,address_level1
        ,address_level2
        ,address_level3
        ,address
        ,zip_code
        ,distance
        ,confidence_level
        ,is_ktp_match
        ,is_phone_match
    from (
        select *
                ,row_number() over (partition by id order by distance asc) as rn
        from (
            select task_id
                    ,id
                    ,ktp_no
                    ,phone_no
                    ,backtest_date
                    ,gps
                    ,address_level1
                    ,address_level2
                    ,address_level3
                    ,address
                    ,zip_code
                    ,2 * 6371 * asin(
                        sqrt(
                            pow(sin(radians((gps_x - address_x) / 2)), 2) 
                            + cos(radians(gps_x)) * cos(radians(address_x)) 
                            * pow(sin(radians((gps_y - address_y) / 2)), 2)
                        )
                    ) as distance
                    ,confidence_level
                    ,is_ktp_match
                    ,is_phone_match
            from (
                select task_id
                        ,id
                        ,ktp_no
                        ,phone_no
                        ,backtest_date
                        ,gps
                        ,address_level1
                        ,address_level2
                        ,address_level3
                        ,address
                        ,zip_code
                        ,gps_x
                        ,gps_y
                        ,is_ktp_match
                        ,is_phone_match
                        ,item.confidence_level as confidence_level
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[0] as double) as address_x
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[1] as double) as address_y
                from
                    (
                        select
                            t1.task_id
                            ,t1.id
                            ,t1.ktp_no
                            ,t1.phone_no
                            ,t1.gps
                            ,t1.gps_x
                            ,t1.gps_y
                            ,t1.backtest_date
                            ,t1.address_level1
                            ,t1.address_level2
                            ,t1.address_level3
                            ,t1.address
                            ,t1.zip_code
                            ,coalesce(t2.address_info, t3.address_info) as address_info
                            ,case when t2.ktp_no is not null then 1 else 0 end as is_ktp_match
                            ,case when t3.phone_no is not null then 1 else 0 end as is_phone_match
                        from t_backtesting_task_id_list t1
                        left join
                        (
                            select ktp_no
                                    ,ktp_no_sha256
                                    ,ktp_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_id_user_ktp_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t2
                        on t1.backtest_date = t2.grass_date
                        and t1.ktp_no = t2.ktp_no
                        left join
                        (
                            select phone_no
                                    ,phone_no_sha256
                                    ,phone_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_id_user_phone_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t3
                        on t1.backtest_date = t3.grass_date
                        and t1.phone_no = t3.phone_no
                        where coalesce(t1.hash_method, '') = ''
                    )
                    lateral view outer explode(from_json(address_info, 'array<struct<address:string,confidence_level:string>>')) tmp AS item
            )
        )
    )
    where rn = 1
);

create or replace temporary view t_backtesting_sha256_task_result as
select  task_id
        ,id
        ,backtest_date
        ,ktp_no
        ,phone_no
        ,address_level1
        ,address_level2
        ,address_level3
        ,address
        ,zip_code
        ,gps
        ,case   when distance <= 0.25 then 7
                when distance > 0.25 and distance <= 0.5 then 6
                when distance > 0.5 and distance <= 1 then 5
                when distance > 1 and distance <= 2 then 4
                when distance > 2 and distance <= 3 then 3
                when distance > 3 and distance <= 5 then 2
                when distance > 5 then 1
                else 0 end as distance_score
        ,case   when distance is null then null
                else confidence_level end as confidence_level
        ,is_ktp_match
        ,is_phone_match
from
(
    select task_id
        ,id
        ,ktp_no
        ,phone_no
        ,backtest_date
        ,gps
        ,address_level1
        ,address_level2
        ,address_level3
        ,address
        ,zip_code
        ,distance
        ,confidence_level
        ,is_ktp_match
        ,is_phone_match
    from (
        select *
                ,row_number() over (partition by id order by distance asc) as rn
        from (
            select task_id
                    ,id
                    ,ktp_no
                    ,phone_no
                    ,backtest_date
                    ,gps
                    ,address_level1
                    ,address_level2
                    ,address_level3
                    ,address
                    ,zip_code
                    ,2 * 6371 * asin(
                        sqrt(
                            pow(sin(radians((gps_x - address_x) / 2)), 2) 
                            + cos(radians(gps_x)) * cos(radians(address_x)) 
                            * pow(sin(radians((gps_y - address_y) / 2)), 2)
                        )
                    ) as distance
                    ,confidence_level
                    ,is_ktp_match
                    ,is_phone_match
            from (
                select task_id
                        ,id
                        ,ktp_no
                        ,phone_no
                        ,backtest_date
                        ,gps
                        ,address_level1
                        ,address_level2
                        ,address_level3
                        ,address
                        ,zip_code
                        ,gps_x
                        ,gps_y
                        ,is_ktp_match
                        ,is_phone_match
                        ,item.confidence_level as confidence_level
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[0] as double) as address_x
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[1] as double) as address_y
                from
                    (
                        select
                            t1.task_id
                            ,t1.id
                            ,t1.ktp_no
                            ,t1.phone_no
                            ,t1.gps
                            ,t1.gps_x
                            ,t1.gps_y
                            ,t1.backtest_date
                            ,t1.address_level1
                            ,t1.address_level2
                            ,t1.address_level3
                            ,t1.address
                            ,t1.zip_code
                            ,coalesce(t2.address_info, t3.address_info) as address_info
                            ,case when t2.ktp_no_sha256 is not null then 1 else 0 end as is_ktp_match
                            ,case when t3.phone_no_sha256 is not null then 1 else 0 end as is_phone_match
                        from t_backtesting_task_id_list t1
                        left join
                        (
                            select ktp_no
                                    ,ktp_no_sha256
                                    ,ktp_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_id_user_ktp_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t2
                        on t1.backtest_date = t2.grass_date
                        and t1.ktp_no = t2.ktp_no_sha256
                        left join
                        (
                            select phone_no
                                    ,phone_no_sha256
                                    ,phone_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_id_user_phone_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t3
                        on t1.backtest_date = t3.grass_date
                        and t1.phone_no = t3.phone_no_sha256
                        where t1.hash_method = 'sha256'
                    )
                    lateral view outer explode(from_json(address_info, 'array<struct<address:string,confidence_level:string>>')) tmp AS item
            )
        )
    )
    where rn = 1
);

create or replace temporary view t_backtesting_base64_task_result as
select  task_id
        ,id
        ,backtest_date
        ,ktp_no
        ,phone_no
        ,address_level1
        ,address_level2
        ,address_level3
        ,address
        ,zip_code
        ,gps
        ,case   when distance <= 0.25 then 7
                when distance > 0.25 and distance <= 0.5 then 6
                when distance > 0.5 and distance <= 1 then 5
                when distance > 1 and distance <= 2 then 4
                when distance > 2 and distance <= 3 then 3
                when distance > 3 and distance <= 5 then 2
                when distance > 5 then 1
                else 0 end as distance_score
        ,case   when distance is null then null
                else confidence_level end as confidence_level
        ,is_ktp_match
        ,is_phone_match
from
(
    select task_id
        ,id
        ,ktp_no
        ,phone_no
        ,backtest_date
        ,gps
        ,address_level1
        ,address_level2
        ,address_level3
        ,address
        ,zip_code
        ,distance
        ,confidence_level
        ,is_ktp_match
        ,is_phone_match
    from (
        select *
                ,row_number() over (partition by id order by distance asc) as rn
        from (
            select task_id
                    ,id
                    ,ktp_no
                    ,phone_no
                    ,backtest_date
                    ,gps
                    ,address_level1
                    ,address_level2
                    ,address_level3
                    ,address
                    ,zip_code
                    ,2 * 6371 * asin(
                        sqrt(
                            pow(sin(radians((gps_x - address_x) / 2)), 2) 
                            + cos(radians(gps_x)) * cos(radians(address_x)) 
                            * pow(sin(radians((gps_y - address_y) / 2)), 2)
                        )
                    ) as distance
                    ,confidence_level
                    ,is_ktp_match
                    ,is_phone_match
            from (
                select task_id
                        ,id
                        ,ktp_no
                        ,phone_no
                        ,backtest_date
                        ,gps
                        ,address_level1
                        ,address_level2
                        ,address_level3
                        ,address
                        ,zip_code
                        ,gps_x
                        ,gps_y
                        ,is_ktp_match
                        ,is_phone_match
                        ,item.confidence_level as confidence_level
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[0] as double) as address_x
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[1] as double) as address_y
                from
                    (
                        select
                            t1.task_id
                            ,t1.id
                            ,t1.ktp_no
                            ,t1.phone_no
                            ,t1.gps
                            ,t1.gps_x
                            ,t1.gps_y
                            ,t1.backtest_date
                            ,t1.address_level1
                            ,t1.address_level2
                            ,t1.address_level3
                            ,t1.address
                            ,t1.zip_code
                            ,coalesce(t2.address_info, t3.address_info) as address_info
                            ,case when t2.ktp_no_base64 is not null then 1 else 0 end as is_ktp_match
                            ,case when t3.phone_no_base64 is not null then 1 else 0 end as is_phone_match
                        from t_backtesting_task_id_list t1
                        left join
                        (
                            select ktp_no
                                    ,ktp_no_sha256
                                    ,ktp_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_id_user_ktp_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t2
                        on t1.backtest_date = t2.grass_date
                        and t1.ktp_no = t2.ktp_no_base64
                        left join
                        (
                            select phone_no
                                    ,phone_no_sha256
                                    ,phone_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_id_user_phone_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t3
                        on t1.backtest_date = t3.grass_date
                        and t1.phone_no = t3.phone_no_base64
                        where t1.hash_method = 'base64'
                    )
                    lateral view outer explode(from_json(address_info, 'array<struct<address:string,confidence_level:string>>')) tmp AS item
            )
        )
    )
    where rn = 1
);

insert overwrite ${SCHEMA}.ads_risk_${region}_address_ktp_phone_backtesting_info_rt partition (grass_date, task_id)
select
    backtest_date
    ,ktp_no
    ,phone_no
    ,address_level1
    ,address_level2
    ,address_level3
    ,address
    ,zip_code
    ,gps
    ,distance_score
    ,confidence_level
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_task_result
union all
select
    backtest_date
    ,ktp_no
    ,phone_no
    ,address_level1
    ,address_level2
    ,address_level3
    ,address
    ,zip_code
    ,gps
    ,distance_score
    ,confidence_level
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${ds}' as grass_date
    ,task_id   
from t_backtesting_sha256_task_result
union all
select
    backtest_date
    ,ktp_no
    ,phone_no
    ,address_level1
    ,address_level2
    ,address_level3
    ,address
    ,zip_code
    ,gps
    ,distance_score
    ,confidence_level
    ,is_ktp_match
    ,is_phone_match
    ,id
    ,'${ds}' as grass_date
    ,task_id
from t_backtesting_base64_task_result
;

