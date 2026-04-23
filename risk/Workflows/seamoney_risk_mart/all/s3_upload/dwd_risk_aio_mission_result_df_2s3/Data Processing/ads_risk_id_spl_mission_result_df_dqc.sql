--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-04-27
-- Theme Domain：       user mission
-- Description:         异常情况监控
-- 1.mission配置条件criteria发生变化，主要指criteria的条件项不在之前约定的范围内，目前约定的范围有 {     "min_spend_amount":1000,  //最低支付金额，超过该金额的订单才会累计到任务完成指标中     "tenure_num_list":[1,3,6], //SPL分期， 使用了 X1, X3, X6的SPL订单才会累计到任务完成指标中     "business_domain_list":[1,3], // 订单来源业务平台     "category_list":[11023301,11023302],  // 类目列表     "shop_list":[4294968409,429496840932]  //商店列表 }
-- 2.mission的result值理论上是越来越大的，可以比较T-1和T-2的值，如果T-1比T-2还小，可能会有问题
-- Data Granularity:    user_mission_id
-- update by zongyi.lu@shopee.com 增加DQC监控Mission类型的枚举值，目前只有Order Count和Order GMV2种，如果有第3种就报错 https://jira.shopee.io/browse/SPFDT-44657
--********************************************************************--

-- drop table if exists risk.ads_risk_id_spl_mission_result_df_dqc;
-- create external table if not exists risk.ads_risk_id_spl_mission_result_df_dqc
-- (
-- mission_id           string comment 'mission_id'
-- ,user_mission_id     string comment 'user_mission_id'
-- ,mission_name        string comment 'mission_name'
-- ,mission_type        string comment 'mission_type'
-- ,dqc_type            string comment 'criteria_dqc or mission_result_dqc'
-- ,dqc_result          string comment 'dqc_result 1-异常 0-正常'
-- )
-- partitioned by (
-- biz_name        string comment 'biz_name '
-- ,grass_date     string   comment "YYYY-MM-DD")
-- stored as orc tblproperties ("orc.compress"="zstd")
-- location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_spl_mission_result_df_dqc/grass_region=ID';
-- ;

-- msck repair table risk.ads_risk_id_spl_mission_result_df_dqc;


insert overwrite table risk.ads_risk_id_spl_mission_result_df_dqc partition(biz_name,grass_date)
select 
    mission_id      
    ,'' as user_mission_id  
    ,mission_name     
    ,mission_type     
    ,'criteria_dqc'  as dqc_type      
    ,case when size(json_object_keys(mission_criteria))>5 then 1 
          when sort_array(json_object_keys(mission_criteria)) <> sort_array(json_object_keys('{"business_domain_list":null,"category_list":null,"min_spend_amount":null,"shop_list":null,"tenure_num_list":null')) then 1 else 0 end as dqc_result
    ,'spl'           as biz_name
    ,'${grass_date}' as grass_date 
from credit.ods__credit_promotion_banner_id_db__pr_mission_tab__df
where grass_date ='${grass_date}'
and mission_type in (2,3)
union all 
select 
t1.mission_id    
,t1.user_mission_id    
,t1.mission_name     
,t1.mission_type 
,'mission_result_dqc'  as dqc_type 
,case when t2.user_mission_id is not null and cast(t1.mission_result as decimal)<cast(t2.mission_result as decimal) then 1 else 0 end dqc_result
,'spl'           as biz_name
,'${grass_date}' as grass_date 
from risk.dwd_risk_id_spl_mission_result_df t1 
left join (
    select 
    mission_id    
    ,user_mission_id 
    ,mission_result
    from risk.dwd_risk_id_spl_mission_result_df
    where grass_date =date_sub('${grass_date}',1)
) t2 on t1.mission_id =t2.mission_id and t1.user_mission_id = t2.user_mission_id
where t1.grass_date='${grass_date}' 
-- union all
-- select 
--     mission_id      
--     ,'' as user_mission_id  
--     ,mission_name     
--     ,mission_type     
--     ,'mission_type_dqc'  as dqc_type      
--     ,case when mission_type not in (2,3) then 1 else 0 end as dqc_result
--     ,'spl'           as biz_name
--     ,'${grass_date}' as grass_date 
-- from credit.ods__credit_promotion_banner_id_db__pr_mission_tab__df
-- where grass_date ='${grass_date}'
-- and mission_type not in (2,3)
;