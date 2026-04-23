------------------------------------------------------------------------
-- Author:              wei.tao
-- Created Time:        2025-03-05
-- Description:         Risk Graph需求， kyc边，因为kyc每个地区逻辑不一致,因此单独将kyc加工之后再edge中使用模板
-- Data Granularity:    
-- PRD:                 https://jira.shopee.io/browse/SPFDT-49676
------------------------------------------------------------------------
-- MX kyc edge

insert overwrite table risk.dws_risk_graph_edge_user_info_di partition(grass_region,edge_name,grass_date)
select 
    platform_user_id
    ,hash_platform_user_id
    ,destination_node
    ,hash_destination_node
    ,create_date
    ,last_date
    ,extend_info
    ,grass_region
    ,edge_name
    ,grass_date
from risk.dws_risk_graph_edge_user_info_df
where grass_region = '${grass_region}'
  and   grass_date = '${grass_date}'
  and   last_date = '${grass_date}'
;