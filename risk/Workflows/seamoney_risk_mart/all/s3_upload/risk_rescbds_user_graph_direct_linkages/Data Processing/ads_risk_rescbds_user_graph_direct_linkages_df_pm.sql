--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-12-28
-- Theme Domain：       rescbds user_graph
-- Description:         rescbds user_graph 同步到s3数据,留备份
-- Data Granularity:    userid
-- 变更历史：
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_rescbds_user_graph_direct_linkages_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_rescbds_user_graph_direct_linkages_df
(
    userid            string comment 'platform_user_id',
    metadata          string comment 'metadata',
    create_time       string comment 'create_time'
)
comment 'risk sync to holmes user list'
partitioned by
(
    grass_region string comment 'region'
    ,grass_date string comment 'grass_date'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_rescbds_user_graph_direct_linkages_df';
;

create or replace temporary view temp_user_graph_direct_linkages as 
select 
userid     
,metadata   
,create_time
,'BR' as grass_region 
from rescbds_credit.rescbds_credit_prod_br__user_graph_direct_linkages
where grass_date ='${grass_date}'
union all 
select 
userid     
,metadata   
,create_time
,'PH' as grass_region 
from rescbds_credit.rescbds_credit_prod_ph__user_graph_direct_linkages
where grass_date ='${grass_date}'
union all 
select 
userid     
,metadata   
,create_time
,'TH' as grass_region 
from rescbds_credit.rescbds_credit_prod_th__user_graph_direct_linkages
where grass_date ='${grass_date}'
;

insert overwrite table ${SCHEMA}.ads_risk_rescbds_user_graph_direct_linkages_df partition(grass_region,grass_date)
select 
userid     
,metadata   
,create_time
,grass_region 
,'${grass_date}' as grass_date
from temp_user_graph_direct_linkages
;


msck repair table ${SCHEMA}.ads_risk_rescbds_user_graph_direct_linkages_df
;