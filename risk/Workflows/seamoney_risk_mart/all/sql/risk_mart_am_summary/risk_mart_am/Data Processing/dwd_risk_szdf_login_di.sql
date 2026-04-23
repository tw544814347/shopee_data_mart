-- =============================================================================
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-01-15
-- Theme Domain:        
-- Data Granularity:    
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-15 - wei.tao - 拆分到分地区跑批，脚本跑 view 发marker
-- =============================================================================

-- drop table if exists ${SCHEMA}.dwd_risk_szdf_login_di;
-- create external table if not exists ${SCHEMA}.dwd_risk_szdf_login_di
-- (
--     user_id bigint comment 'shopee user id'
--     ,login_from string comment 'login from wh'                                          
--     ,is_device string comment 'is device: Y mobile phone device N pc or other platform'
--     ,is_login string comment 'is login: Y login today N not login today'
--     ,login_ip string comment 'login device ip'
--     ,login_timestamp bigint comment 'login timestamp'
--     ,sz_dfp_device_id string                                                            

--     ,is_success string comment ''
--     ,is_auto_login string comment 'is auto login: Y auto login N manual login'
--     ,login_channel string comment 'login channel'
--     ,platform_id string comment 'platform id'
--     ,app_type_name string comment 'app type id mapping'
--     ,latitude string comment 'latitude of login device'
--     ,longitude string comment 'longitude of login device'
--     ,country_ip string comment 'country info by ip'
--     ,region_ip string comment 'region info by ip'
--     ,city_ip string comment 'city info by ip'
--     ,country_gps string comment 'country info by gps'
--     ,region_gps string comment 'region info by gps'
--     ,city_gps string comment 'city info by gps'
--     ,phone string comment 'phone number'
--     ,dfpinfosz__platform int comment 'dfpinfosz__platform'
--     ,is_spp int comment 'spp_source'
--     ,shopeepay_user_id string comment 'spp uid'
-- )
-- comment 'user login record'
-- partitioned by
-- (
--     tz_type        string          comment         'timezone type'
--     ,grass_region   string          comment         'partition key'
--     ,grass_date     string            comment         'partition key, yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
-- location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_szdf_login_di_v2';
-- msck repair table ${SCHEMA}.dwd_risk_szdf_login_di;

create or replace view risk.dwd_risk_v2_login_di
as 
select *
from risk.dwd_risk_szdf_login_di
;

create or replace view risk.dwd_risk_login__internal_use__di
as 
select *
from risk.dwd_risk_szdf_login_di
;
