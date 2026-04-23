-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-12-04
-- Theme Domain:        Customer Stability Check Backtesting
-- Data Granularity:    
-- Description:         GPS location distance calculation and scoring for KTP backtesting
--                      Calculate haversine distance between user GPS and KTP registered address
--                      Generate distance score (1-7) based on distance threshold
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-12-04 - chengguo.liu - 修复 gps backtesting逻辑 - Jira: https://jira.shopee.io/browse/SPFDT-58191
-- =============================================================================


drop table if exists ${SCHEMA}.ads_risk_${region}_gps_ktp_phone_backtesting_info_df;
create external table ${SCHEMA}.ads_risk_${region}_gps_ktp_phone_backtesting_info_df
(
    task_id string comment 'backtesting task id'
    ,backtest_date string comment 'backtesting date'
    ,id_type string comment 'id type'
    ,id_no string comment 'id number'
    ,phone_no string comment 'phone number'
    ,name string comment 'user name'
    ,dob string comment 'date of birth'
    ,gps string comment 'gps coordinates'
    ,distance_score int comment 'distance score between gps and registered address (1-7)'
    ,confidence_level string comment 'address confidence level'
)
comment 'Tag:GPS KTP Phone Backtesting Info'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/ads/ads_risk_reg_gps_ktp_phone_backtesting_info_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.ads_risk_${region}_gps_ktp_phone_backtesting_info_df;

uncache table if exists t_backtesting_task_id_list;
cache table t_backtesting_task_id_list options ('storageLevel' 'MEMORY_AND_DISK')
as
select
    t1.task_id
    ,t1.task_status
    ,t1.hash_method
    ,get_json_object(t2.task_data, '$.id_type') as id_type
    ,get_json_object(t2.task_data, '$.id_no') as id_no
    ,get_json_object(t2.task_data, '$.msisdn') as phone_no
    ,get_json_object(t2.task_data, '$.name') as name
    ,get_json_object(t2.task_data, '$.dob') as dob
    ,get_json_object(t2.task_data, '$.backtest_date') as backtest_date
    ,get_json_object(t2.task_data, '$.gps') as gps
    ,cast(split(regexp_replace(get_json_object(t2.task_data, '$.gps'), '[()]', ''), ',')[0] as double) as gps_x
    ,cast(split(regexp_replace(get_json_object(t2.task_data, '$.gps'), '[()]', ''), ',')[1] as double) as gps_y
from
(
    select
        task_id
        ,task_status
        ,lower(hash_method) as hash_method
    from risk.ods__credit_risk_open_platform_ph_db__auto_backtesting_task_tab__df
    where grass_date = '${ds}'
    and task_status = 5
    and service_name_list = 'CustomerStabilityCheck'
) t1
left join
(
    select
        task_id
        ,task_data
    from risk.ods__credit_risk_open_platform_ph_db__auto_backtesting_task_data_tab__df
    where grass_date = '${ds}'
) t2
on t1.task_id = t2.task_id
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
        ,backtest_date
        ,id_type
        ,id_no
        ,phone_no
        ,name
        ,dob
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
from
(
    select task_id
        ,id_type
        ,id_no
        ,phone_no
        ,name
        ,dob
        ,backtest_date
        ,gps
        ,distance
        ,confidence_level
    from (
        select *
                ,row_number() over (partition by task_id, id_type, id_no, phone_no, backtest_date order by distance asc) as rn
        from (
            select task_id
                    ,id_type
                    ,id_no
                    ,phone_no
                    ,name
                    ,dob
                    ,backtest_date
                    ,gps
                    ,2 * 6371 * asin(
                        sqrt(
                            pow(sin(radians((gps_x - address_x) / 2)), 2) 
                            + cos(radians(gps_x)) * cos(radians(address_x)) 
                            * pow(sin(radians((gps_y - address_y) / 2)), 2)
                        )
                    ) as distance
                    ,confidence_level
            from (
                select task_id
                        ,id_type
                        ,id_no
                        ,phone_no
                        ,name
                        ,dob
                        ,backtest_date
                        ,gps
                        ,gps_x
                        ,gps_y
                        ,item.confidence_level as confidence_level
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[0] as double) as address_x
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[1] as double) as address_y
                from
                    (
                        select
                            t1.task_id
                            ,t1.id_type
                            ,t1.id_no
                            ,t1.phone_no
                            ,t1.name
                            ,t1.dob
                            ,t1.gps
                            ,t1.gps_x
                            ,t1.gps_y
                            ,t1.backtest_date
                            ,coalesce(t2.address_info, t3.address_info) as address_info
                        from t_backtesting_task_id_list t1
                        left join
                        (
                            select id_type
                                    ,id_no
                                    ,id_no_sha256
                                    ,id_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_ph_user_kyc_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t2
                        on t1.backtest_date = t2.grass_date
                        and t1.id_type = t2.id_type
                        and t1.id_no = t2.id_no
                        left join
                        (
                            select phone_no
                                    ,phone_no_sha256
                                    ,phone_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_ph_user_phone_info_df
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
        ,backtest_date
        ,id_type
        ,id_no
        ,phone_no
        ,name
        ,dob
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
from
(
    select task_id
        ,id_type
        ,id_no
        ,phone_no
        ,name
        ,dob
        ,backtest_date
        ,gps
        ,distance
        ,confidence_level
    from (
        select *
                ,row_number() over (partition by task_id, id_type, id_no, phone_no, backtest_date order by distance asc) as rn
        from (
            select task_id
                    ,id_type
                    ,id_no
                    ,phone_no
                    ,name
                    ,dob
                    ,backtest_date
                    ,gps
                    ,2 * 6371 * asin(
                        sqrt(
                            pow(sin(radians((gps_x - address_x) / 2)), 2) 
                            + cos(radians(gps_x)) * cos(radians(address_x)) 
                            * pow(sin(radians((gps_y - address_y) / 2)), 2)
                        )
                    ) as distance
                    ,confidence_level
            from (
                select task_id
                        ,id_type
                        ,id_no
                        ,phone_no
                        ,name
                        ,dob
                        ,backtest_date
                        ,gps
                        ,gps_x
                        ,gps_y
                        ,item.confidence_level as confidence_level
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[0] as double) as address_x
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[1] as double) as address_y
                from
                    (
                        select
                            t1.task_id
                            ,t1.id_type
                            ,t1.id_no
                            ,t1.phone_no
                            ,t1.name
                            ,t1.dob
                            ,t1.gps
                            ,t1.gps_x
                            ,t1.gps_y
                            ,t1.backtest_date
                            ,coalesce(t2.address_info, t3.address_info) as address_info
                        from t_backtesting_task_id_list t1
                        left join
                        (
                            select id_type
                                    ,id_no
                                    ,id_no_sha256
                                    ,id_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_ph_user_kyc_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t2
                        on t1.backtest_date = t2.grass_date
                        and t1.id_type = t2.id_type
                        and t1.id_no = t2.id_no_sha256
                        left join
                        (
                            select phone_no
                                    ,phone_no_sha256
                                    ,phone_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_ph_user_phone_info_df
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
        ,backtest_date
        ,id_type
        ,id_no
        ,phone_no
        ,name
        ,dob
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
from
(
    select task_id
        ,id_type
        ,id_no
        ,phone_no
        ,name
        ,dob
        ,backtest_date
        ,gps
        ,distance
        ,confidence_level
    from (
        select *
                ,row_number() over (partition by task_id, id_type, id_no, phone_no, backtest_date order by distance asc) as rn
        from (
            select task_id
                    ,id_type
                    ,id_no
                    ,phone_no
                    ,name
                    ,dob
                    ,backtest_date
                    ,gps
                    ,2 * 6371 * asin(
                        sqrt(
                            pow(sin(radians((gps_x - address_x) / 2)), 2) 
                            + cos(radians(gps_x)) * cos(radians(address_x)) 
                            * pow(sin(radians((gps_y - address_y) / 2)), 2)
                        )
                    ) as distance
                    ,confidence_level
            from (
                select task_id
                        ,id_type
                        ,id_no
                        ,phone_no
                        ,name
                        ,dob
                        ,backtest_date
                        ,gps
                        ,gps_x
                        ,gps_y
                        ,item.confidence_level as confidence_level
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[0] as double) as address_x
                        ,cast(split(regexp_replace(item.address,'[()]', ''), ',')[1] as double) as address_y
                from
                    (
                        select
                            t1.task_id
                            ,t1.id_type
                            ,t1.id_no
                            ,t1.phone_no
                            ,t1.name
                            ,t1.dob
                            ,t1.gps
                            ,t1.gps_x
                            ,t1.gps_y
                            ,t1.backtest_date
                            ,coalesce(t2.address_info, t3.address_info) as address_info
                        from t_backtesting_task_id_list t1
                        left join
                        (
                            select id_type
                                    ,id_no
                                    ,id_no_sha256
                                    ,id_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_ph_user_kyc_info_df
                            where grass_date in (select backtest_date from t_backtesting_backtest_date_list)
                        ) t2
                        on t1.backtest_date = t2.grass_date
                        and t1.id_type = t2.id_type
                        and t1.id_no = t2.id_no_base64
                        left join
                        (
                            select phone_no
                                    ,phone_no_sha256
                                    ,phone_no_base64
                                    ,address_info
                                    ,grass_date
                            from risk.ads_2bscore_ph_user_phone_info_df
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

insert overwrite ${SCHEMA}.ads_risk_${region}_gps_ktp_phone_backtesting_info_df partition (grass_date = '${ds}')
select * from t_backtesting_task_result
union all
select * from t_backtesting_sha256_task_result
union all
select * from t_backtesting_base64_task_result
;

