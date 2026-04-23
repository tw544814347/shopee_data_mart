--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-30
-- Theme Domain：       dpd
-- Description:         anti-fraud dpd in graph info https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=1275162343#gid=1275162343
-- Data Granularity:    platform_user_id
-- 变更历史：

--********************************************************************--

drop table if exists ${SCHEMA}.dws_risk_th_user_af_graph_dpd_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_af_graph_dpd_df  (
    platform_user_id                    string comment 'platform user id'
    ,uui_dpd30_cluster_user_cnt         bigint comment 'uui_dpd30_cluster_user_cnt'
)
partitioned by (
    grass_date                          string comment 'yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd") 
location  '${HDFS_PATH}/risk_mart/dws/dws_risk_user_af_graph_dpd_df/grass_region=TH';
msck repair table ${SCHEMA}.dws_risk_th_user_af_graph_dpd_df;


insert overwrite table ${SCHEMA}.dws_risk_th_user_af_graph_dpd_df partition (grass_date='${grass_date}')
select 
platform_user_id
,count(case when historical_max_dpd>=30 then 1 else null end) as uui_dpd30_cluster_user_cnt
from credit_mart.wide_spl_th_behavior_user_df 
where grass_date ='${grass_date}'
group by platform_user_id

