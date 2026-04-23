-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-18
-- Theme Domain:        User Behavior Login
-- Data Granularity:    user_id, sz_dfp_device_id, grass_region, is_spp_source,grass_date
-- Description:         daily user device login accumulated table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-12 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_user_sz_device_login_di;
create external table if not exists ${SCHEMA}.dws_risk_user_sz_device_login_di
(
    user_id bigint comment 'shopee user id'
    ,sz_dfp_device_id string comment 'sz dfp device id'
    ,fst_login_timestamp bigint comment 'first login timestamp'
    ,lst_login_timestamp bigint comment 'last login timestamp'
    ,cnt_login_1d bigint comment 'a user login event on a device in 1d'
    ,is_spp_source string comment 'is_spp_source'
    ,shopeepay_user_id string comment 'spp uid'
)
comment 'risk feature summary table'
partitioned by
(
    tz_type string comment 'timezone type'
    ,grass_region string comment 'partition key'
    ,grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_sz_device_login_di';
--msck repair table ${SCHEMA}.dws_risk_user_sz_device_login_di;


insert overwrite table ${SCHEMA}.dws_risk_user_sz_device_login_di partition (tz_type='local', grass_region, grass_date)
select
   user_id
   ,sz_dfp_device_id
   ,fst_login_timestamp
   ,lst_login_timestamp
   ,cnt_login_1d
   ,is_spp as is_spp_source
   ,shopeepay_user_id
   ,grass_region
   ,date('${grass_date}') as grass_date
from (
    select
        user_id
        ,sz_dfp_device_id
        ,min(login_timestamp) as fst_login_timestamp
        ,max(login_timestamp) as lst_login_timestamp
        ,count(*) as cnt_login_1d        
        ,is_spp
        ,grass_region
        ,shopeepay_user_id
    from ${SCHEMA}.dwd_risk_szdf_login_di
    where grass_date = date('${grass_date}')
        and grass_region = upper('${region}')
        and sz_dfp_device_id <> ''
    group by user_id, sz_dfp_device_id, grass_region, is_spp, shopeepay_user_id
) t;


create or replace view ${SCHEMA}.dws_risk_${region}_user_sz_device_login_di as
select
    *
from ${SCHEMA}.dws_risk_user_sz_device_login_di
where
    grass_region = upper('${region}')
;
