--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2026-03-20
-- Theme Domain：       user mission
-- Description:         处理成user mission中间表
-- 枚举解释              
-- mission_type=1：KYC任务 2：SPL订单量任务 3：SPL GMV任务
-- mission_type=30 --> shopee订单数
-- mission_type=31 --> shopee订单GMV
-- mission_type=32 --> PDAM Bill
-- mission_type=33 --> PLN Bill
-- mission_type=34 --> BPJS Bill
-- mission_type=35 --> Shopeepay Topup
-- Data Granularity:    user_mission_id
-- change logs
/* 
    1. 所有地区整合为模版开发
*/
--********************************************************************--
ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

drop table if exists risk.dim_risk_${region}_promotion_mission_info_df;
create external table if not exists risk.dim_risk_${region}_promotion_mission_info_df
(
mission_id           string comment 'mission_id'
,mission_name        string comment 'mission_name'
,mission_type        string comment 'mission_type'
,biz_type            string comment '1-bcl,2-scl,3-spl'
,complete_duration   bigint comment 'complete_duration'
,reward_duration     bigint comment 'reward_duration'
,user_mission_id     string comment 'user_mission_id'
,platform_user_id    string comment 'platform_user_id is shopee_user_id'
,credit_user_id      string comment 'credit_user_id'
,start_time          string comment 'user mission start_time(local time)'
,complete_time       string comment 'user mission complete_time(local time)'
,reward_time         string comment 'reward_time'
,start_timestamp     bigint comment 'user mission start_timestamp'
,complete_timestamp  bigint comment 'user mission complete_timestamp'
,reward_timestamp    bigint comment 'reward_timestamp'
,complete_value      string comment 'complete_value'
,create_time         string comment 'create_time local time'
,reward_rank         bigint comment 'mission reward limit condition value'
,action_id           string comment 'mission reward item id'
,user_mission_status bigint comment 'user_mission_status,3 is already reward'
,min_spend_amount      bigint comment ' check min_spend_amount condition'
,need_min_spend_amount int comment ' check min_spend_amount condition'
,tenure_num_list       array<string> comment 'set tenure_num condition'
,need_tenure_num_list  int comment ' check tenure_num condition'
,business_domain_list  array<string> comment 'set channel id condition'
,need_business_domain_list  int comment ' check business_domain condition'
,category_list         array<string> comment 'set category condition'
,need_category_list    int comment ' check category condition'
,shop_list             array<string> comment 'set shop condition'
,need_shop_list        int comment ' check shop condition'
,mission_criteria      struct<min_spend_amount:bigint,tenure_num_list:array<string>,business_domain_list:array<string>,category_list:array<string>,shop_list:array<string>> comment 'mission criteria json'
,mission_reward        array<struct<rank:bigint,action_id_list:array<string>>> comment 'mission reward json'
)
partitioned by (grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_reg_promotion_mission_info_df/grass_region=${upper_region}';
;


-- msck repair table risk.dim_risk_${region}_promotion_mission_info_df;
refresh table risk.dim_risk_${region}_promotion_mission_info_df;

-- add by dongbo.yu 2025-04-18 
-- 加工用户参与的mission,包括用户参与时间,开始任务的时间,结束时间,领奖时间,任务完成状态,任务需要满足的领奖条件,奖励物品的id等信息
insert overwrite table risk.dim_risk_${region}_promotion_mission_info_df partition(grass_date='${grass_date}')
select 
    t2.mission_id        
    ,t2.mission_name     
    ,t2.mission_type     
    ,t2.biz_type         
    ,t2.complete_duration
    ,t2.reward_duration  
    ,t1.user_mission_id  
    ,t1.shopee_user_id as platform_user_id 
    ,t1.credit_user_id   
    ,format_time(t1.start_time,upper('${region}'))    as start_time   
    ,format_time(t1.complete_time,upper('${region}')) as complete_time   
    ,format_time(t1.reward_time,upper('${region}'))   as reward_time
    ,t1.start_time as start_timestamp
    ,t1.complete_time as complete_timestamp
    ,t1.reward_time as reward_timestamp
    ,t1.complete_value     
    ,format_time(t1.create_time,upper('${region}'))   as create_time 
    ,cast(t2.reward_rank as bigint) reward_rank
    ,t2.action_id
    ,t1.user_mission_status
    ,cast(t2.min_spend_amount as bigint) as min_spend_amount
    ,case when t2.min_spend_amount='[]' or t2.min_spend_amount is null then 0 else 1 end need_min_spend_amount
    ,from_json(t2.tenure_num_list, 'array<string>') AS tenure_num_list 
    ,case when t2.tenure_num_list='[]' or t2.tenure_num_list is null then 0 else 1 end need_tenure_num_list
    ,from_json(t2.business_domain_list, 'array<string>') AS business_domain_list
    ,case when t2.business_domain_list='[]' or t2.business_domain_list is null then 0 else 1 end need_business_domain_list
    ,from_json(t2.category_list, 'array<string>') AS category_list
    ,case when t2.category_list='[]' or t2.category_list is null then 0 else 1 end need_category_list
    ,from_json(t2.shop_list, 'array<string>') AS shop_list
    ,case when t2.shop_list='[]' or t2.shop_list is null then 0 else 1 end need_shop_list
    ,from_json(t2.mission_criteria,'struct<min_spend_amount:bigint,tenure_num_list:array<string>,business_domain_list:array<string>,category_list:array<string>,shop_list:array<string>>') as mission_criteria
    ,from_json(t2.mission_reward,'array<struct<rank:bigint,action_id_list:array<string>>>') as mission_reward

from credit.ods__credit_promotion_banner_${region}_db__pr_user_mission_tab__df t1 
join (
    -- 任务维度表,包含任务id,任务类型,任务需要满足的领奖条件,奖励物品的id
    select 
        mission_id        
        ,mission_name     
        ,mission_type     
        ,biz_type       
        ,mission_criteria  
        ,get_json_object(mission_criteria,'$.min_spend_amount')     as min_spend_amount
        ,get_json_object(mission_criteria,'$.tenure_num_list')      as tenure_num_list
        ,get_json_object(mission_criteria,'$.business_domain_list') as business_domain_list
        ,get_json_object(mission_criteria,'$.category_list')        as category_list
        ,get_json_object(mission_criteria,'$.shop_list')            as shop_list
        ,mission_reward
        ,get_json_object(mission_reward, '$[0].rank')               as reward_rank
        ,get_json_object(mission_reward, '$[0].action_id_list[0]')  as action_id
        ,complete_duration
        ,reward_duration  
    from credit.ods__credit_promotion_banner_${region}_db__pr_mission_tab__df
    where grass_date ='${grass_date}'
    -- 1：KYC任务 2：SPL订单量任务 3：SPL GMV任务 30:shopee订单数 31:shopee订单GMV 32:PDAM Bill 33:PLN Bill 34:BPJS Bill 35:Shopeepay Topup
    and mission_type > 0
) t2 on t1.mission_id = t2.mission_id 
where t1.grass_date ='${grass_date}'
;
