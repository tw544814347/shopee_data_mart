--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-10-21
-- Theme Domain：       Login Device
-- Description:         每个设备在每个用户上的最早登陆时间(北美地区)
-- Data Granularity:    platform_user_id+sz_dfp_device_id
-- new dws table
-- https://jira.shopee.io/browse/SPFDT-43628
-- 验数时间窗口2024-10-21
-- platform_user_id 空值率为0，sz_sdp_device_id 空值率为0
-- shopee_df 空值率为9/158692667，hash_shopee_df 空值率为0
-- login_cnt 增长符合di增量变化
-- fst_login_timestamp为 2021-09-14 00:00:00 （当地时间），符合预期
-- lst_login_timestamp为 2024-10-21 23:59:59  (当地时间)，符合预期
--********************************************************************--

-- create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

--drop table if exists ${SCHEMA}.dws_risk_user_sz_device_login_df;
create external table if not exists ${SCHEMA}.dws_risk_user_sz_device_login_df (
    platform_user_id        string comment 'user platform id'
    ,sz_dfp_device_id       string comment 'device id'
    ,fst_login_timestamp    bigint comment 'first login timestamp'
    ,lst_login_timestamp    bigint comment 'last login timestamp' 
    ,cnt_login              bigint comment 'login counter'
)
partitioned by (
    grass_date      string comment 'YYYY-MM-dd'
    ,grass_region   string comment 'TH/ID/VN/TW/PH/MY/SG'
    ,tz_type        string comment 'local'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_sz_device_login_df/';
--msck repair table ${SCHEMA}.dws_risk_user_sz_device_login_df;

alter table ${SCHEMA}.dws_risk_user_sz_device_login_df drop if exists partition (grass_date='2024-10-20 00:00:00');

insert overwrite table ${SCHEMA}.dws_risk_user_sz_device_login_df
select  platform_user_id
        ,sz_dfp_device_id
        ,nvl(min(fst_login_timestamp),null)     as fst_login_timestamp
        ,nvl(max(lst_login_timestamp),null)     as lst_login_timestamp
        ,nvl(sum(cnt_login), null)              as cnt_login
        ,'${ds}'                                as grass_date
        ,grass_region                           as grass_region
        ,tz_type                                as tz_type
from    (
    select  platform_user_id
            ,sz_dfp_device_id
            ,fst_login_timestamp
            ,lst_login_timestamp
            ,cnt_login
            ,grass_region as grass_region
            ,tz_type as tz_type
    from    risk.dws_risk_user_sz_device_login_df
    where   grass_date = date('${ds}' - interval '1' day) -- T-2
    and     grass_region = upper('${region}')
    and     sz_dfp_device_id is not null 
    and     sz_dfp_device_id <> ''
    and     platform_user_id is not null
    union all
    select  user_id as platform_user_id
            ,sz_dfp_device_id
            ,fst_login_timestamp    as fst_login_timestamp
            ,lst_login_timestamp    as lst_login_timestamp
            ,cnt_login_1d           as cnt_login
            ,grass_region           as grass_region
            ,tz_type                as tz_type
    from    risk.dws_risk_user_sz_device_login_di
    where   grass_date = '${ds}' -- 增量
    and     grass_region = upper('${region}')
    and     sz_dfp_device_id is not null 
    and     sz_dfp_device_id <> ''
    and     user_id is not null
)
group by    platform_user_id, sz_dfp_device_id, grass_region, tz_type
;

create or replace view ${SCHEMA}.dws_risk_${region}_user_sz_device_login_df as
select
    *
from ${SCHEMA}.dws_risk_user_sz_device_login_df
where
    grass_region = upper('${region}')
;
