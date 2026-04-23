--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-11
-- Theme Domain：       user_info
-- Description:         risk mp user_info, https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit#gid=617476295
-- Data Granularity:    
-- 变更历史：
--********************************************************************--
--drop table if exists ${SCHEMA}.dim_risk_${region}_user_info_df;
create external table if not exists ${SCHEMA}.dim_risk_${region}_user_info_df (
    platform_user_id string comment 'platform_user_id'
    ,is_seller bigint comment 'is_seller'
    ,shopee_age bigint comment 'datediff(format_time(ctime,upper({region})),current_date)'
    ,is_phone_verified bigint comment 'is_phone_verified'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_user_info_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dim_risk_${region}_user_info_df;

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dim_risk_${region}_user_info_df partition(grass_date)
select 
t1.userid                 as platform_user_id
,is_seller                as is_seller
,datediff('${smd_grass_date}',format_time(ctime,upper('${region}'))) as shopee_age
,phone_verified   as is_phone_verified
,'${grass_date}'  as grass_date
from marketplace.shopee_account_v2_db__account_tab__my_df t1 
;