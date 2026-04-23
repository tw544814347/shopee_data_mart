--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-12
-- Theme Domain：       user mission
-- Description:         user mission, 只取  mission_type in (2,3) 1：KYC任务 2：SPL订单量任务 3：SPL GMV任务
-- Data Granularity:    user_mission_id
-- Update               dongbo.yu 2025-02-24 fix issue
/* 
jira: https://jira.shopee.io/browse/SPFDT-27197
PRD: https://confluence.shopee.io/display/SK/%5BID+SPL%5D+Mission+-+Data+Pipeline
FRF: https://docs.google.com/document/d/1inckCBqkMEQXCN42OK1RO7-CekYpqqhqbgaxCM5M3JQ/edit#heading=h.g49m8gm30j3f
S3文件格式: https://confluence.shopee.io/pages/viewpage.action?pageId=2125146355
逻辑文档 : https://docs.google.com/spreadsheets/d/1-RfHcHswKJp9xnUY7HzwAadqpsBZaDTgp2o3kW9TaBQ/edit#gid=0
DE 维护开发文档: https://confluence.shopee.io/pages/viewpage.action?pageId=2255502730
注意: mission_criteria 中的条件是不固定的,且与order表中对应的字段也是手动映射的,因此mission_criteria 如果有新增或者调整,都需要走迭代改sql
字段映射
--    { "min_spend_amount":1000, //对应 credit_spl_transaction_id_db__order_info_tab.disburse_amount   credit_mart.dwd_spl_id_order_df
--    "tenure_num_list":[1,3,6], //对应 credit_spl_transaction_id_db__order_info_tab.total_term_num    credit_mart.dwd_spl_id_order_df
--    "business_domain_list":[1,3], //对应 credit_spl_transaction_id_db__order_info_tab.channel_id 
--    "category_list":[11023301,11023302], //对应 credit_spl_transaction_id_db__order_item_info_tab.category_id  
--    -- 关联category_id 如果有包含, 则取整个order disburse_amount, 如果category 都匹配不到则disburse_amount 给0 
--    "shop_list":[4294968409,429496840932] } mp_user.dim_user__reg_s0_live user_id为platform_user_id  
*/
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- add by dongbo.yu 2025-04-18 
-- 加工用户参与的mission,包括用户参与时间,开始任务的时间,结束时间,领奖时间,任务完成状态,任务需要满足的领奖条件,奖励物品的id等信息
create or replace temporary  view tmp_user_mission_info_${region} as 
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
    ,t1.complete_value     
    ,format_time(t1.create_time,upper('${region}'))   as create_time 
    ,t2.mission_criteria
    ,t2.min_spend_amount
    ,case when t2.min_spend_amount='[]' or t2.min_spend_amount is null then 0 else 1 end need_min_spend_amount
    ,t2.tenure_num_list
    ,case when t2.tenure_num_list='[]' or t2.tenure_num_list is null then 0 else 1 end need_tenure_num_list
    ,t2.business_domain_list
    ,case when t2.business_domain_list='[]' or t2.business_domain_list is null then 0 else 1 end need_business_domain_list
    ,t2.category_list
    ,case when t2.category_list='[]' or t2.category_list is null then 0 else 1 end need_category_list
    ,t2.shop_list
    ,case when t2.shop_list='[]' or t2.shop_list is null then 0 else 1 end need_shop_list
    ,t2.reward_rank
    ,t2.action_id
    ,t1.user_mission_status
    -- 用户参与的mission表
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
    and mission_type in (2,3)     --add by dongbo.yu  1：KYC任务 2：SPL订单量任务 3：SPL GMV任务
) t2 on t1.mission_id = t2.mission_id 
where t1.grass_date ='${grass_date}'
;

-- add by dongbo.yu 用户做任务时,下单所在的category, 将list展开,方便后续判断
create or replace temporary  view tmp_user_category_id_list_${region} as
select 
t1.mission_id
,t1.user_mission_id
,t1.platform_user_id
,t1.credit_user_id
,t1.mission_type
,tbl.category_id
,t1.need_category_list
from tmp_user_mission_info_${region} t1
lateral view explode(split(regexp_replace(t1.category_list, "[\\[\\]]", ""),',')) tbl as category_id 
where t1.category_list is not null 
;



-- 判断mission 中的category_list 是否包含order_item 中的 category_id 
-- 如果有取整单 disburse_amount(包含一个category_id就行),如果都不包含,则disburse_amount=0
create or replace temporary  view tmp_user_is_contain_category_id_${region} as
select 
t1.order_id 
,1  as is_contain_category_id
,count(1)
from credit.ods__credit_spl_transaction_${region}_db__order_item_info_tab__df t1 
join tmp_user_category_id_list_${region} t2 on t1.user_id = t2.credit_user_id and t1.category_id = t2.category_id
where t1.grass_date = "${grass_date}"
group by t1.order_id 
;

-- 汇总
insert overwrite table risk.dwd_risk_${region}_${biz_name}_mission_result_df partition(biz_name='${biz_name}',grass_date='${grass_date}')
select 
    t3.mission_id        
    ,t3.mission_name     
    ,t3.mission_type     
    ,t3.biz_type         
    ,t3.complete_duration
    ,t3.reward_duration  
    ,t3.user_mission_id  
    ,t3.platform_user_id 
    ,t3.credit_user_id   
    ,t3.start_time   
    ,t3.complete_time   
    ,t3.reward_time      
    ,t3.complete_value
    ,case when t3.mission_type = 2 then t3.order_cnt 
          when t3.mission_type = 3 then t3.disburse_amount else null end mission_result
    ,t3.create_time
    ,cast(t3.reward_rank as bigint) as reward_rank
    ,t3.action_id
    ,t3.user_mission_status
from (
    select 
        t1.mission_id        
        ,t1.mission_name     
        ,t1.mission_type     
        ,t1.biz_type         
        ,t1.complete_duration
        ,t1.reward_duration  
        ,t1.user_mission_id  
        ,t1.platform_user_id 
        ,t1.credit_user_id   
        ,t1.start_time   
        ,t1.complete_time   
        ,t1.reward_time      
        ,t1.complete_value   
        -- 2：SPL订单量任务 3：SPL GMV任务
        ,count(distinct case when t1.mission_type = 2 
                and t2.confirm_time >= t1.start_time and t2.confirm_time <=t1.complete_time
                and t2.order_create_time >= t1.start_time and t2.order_create_time <=t1.complete_time
                and cast(t2.disburse_amount as decimal)>=cast(nvl(t1.min_spend_amount,0)  as decimal)
                -- modify by dongbo.yu 2025-02-24 需要用数组来判断是否包含配置的信息
                -- and (case when need_tenure_num_list=1 then instr(t1.tenure_num_list,t2.total_term_num)>0 else 1=1 end)
                and (case when need_tenure_num_list=1 then array_contains(split(regexp_replace(t1.tenure_num_list, '\\[|\\]', ''), ','), t2.total_term_num) else 1=1 end)
                -- and (case when need_business_domain_list=1 then instr(t1.business_domain_list,t2.channel_id)>0 else 1=1 end)
                and (case when need_business_domain_list=1 then array_contains(split(regexp_replace(t1.business_domain_list, '\\[|\\]', ''), ','), t2.channel_id) else 1=1 end)
                -- and (case when need_shop_list=1 then instr(t1.shop_list,t2.shop_id)>0 else 1=1 end)
                and (case when need_shop_list=1 then array_contains(split(regexp_replace(t1.shop_list, '\\[|\\]', ''), ','), t2.shop_id) else 1=1 end)
                and (case when t1.need_category_list=1 then t3.is_contain_category_id=1 else 1=1 end)
            then t2.order_id else null end)  as order_cnt
        ,sum( case when t1.mission_type = 3 
                and t2.confirm_time >= t1.start_time and t2.confirm_time <=t1.complete_time
                and t2.order_create_time >= t1.start_time and t2.order_create_time <=t1.complete_time
                and cast(t2.disburse_amount as decimal)>=cast(nvl(t1.min_spend_amount,0)  as decimal)
                -- modify by dongbo.yu 2025-02-24 需要用数组来判断是否包含配置的信息
                -- and (case when need_tenure_num_list=1 then instr(t1.tenure_num_list,t2.total_term_num)>0 else 1=1 end)
                and (case when need_tenure_num_list=1 then array_contains(split(regexp_replace(t1.tenure_num_list, '\\[|\\]', ''), ','), t2.total_term_num) else 1=1 end)
                -- and (case when need_business_domain_list=1 then instr(t1.business_domain_list,t2.channel_id)>0 else 1=1 end)
                and (case when need_business_domain_list=1 then array_contains(split(regexp_replace(t1.business_domain_list, '\\[|\\]', ''), ','), t2.channel_id) else 1=1 end)
                -- and (case when need_shop_list=1 then instr(t1.shop_list,t2.shop_id)>0 else 1=1 end)
                and (case when need_shop_list=1 then array_contains(split(regexp_replace(t1.shop_list, '\\[|\\]', ''), ','), t2.shop_id) else 1=1 end)
                and (case when t1.need_category_list=1 then t3.is_contain_category_id=1 else 1=1 end)
            then t2.disburse_amount
            else 0 end)  as disburse_amount
        ,t1.create_time
        -- add by dongbo.yu 2025-02-27 新增任务完成的领奖条件reward_rank和奖励的物品action_id
        ,t1.reward_rank
        ,t1.action_id
        ,t1.user_mission_status
    from tmp_user_mission_info_${region} t1 
    left join (
        select 
             t21.platform_user_id
            ,t21.order_id 
            ,t21.disburse_amount
            -- modify by dongbo.yu 2025-02-24 把他们转成string类型,用于上面的判断是否包含在配置的信息数组内
            ,cast(t21.total_term_num as string) as total_term_num
            ,cast(t21.channel_id as string) as channel_id
            ,format_time(t21.confirm_time,upper('${region}')) as confirm_time
            ,format_time(t21.create_time,upper('${region}')) as order_create_time
            -- ,cast(t22.shop_id as string) as shop_id
            -- spl 里面的seller_id 就是 mp的 shop_id add by dongbo.yu 
            ,cast(t21.seller_id as string) as shop_id
        from credit.ods__credit_spl_transaction_${region}_db__order_info_tab__df t21
        -- 以下逻辑为错误逻辑,注释不用  add by dongbo.yu 
        -- join (
        --     select 
        --     user_id as platform_user_id
        --     ,shop_id
        --     from mp_user.dim_user__reg_s0_live
        --     where grass_region = upper('${region}')
        --     and grass_date ='${grass_date}'
        -- ) t22 on t21.platform_user_id = t22.platform_user_id
        where t21.grass_date ='${grass_date}'
        and t21.confirm_status=3 -- 确认收货
        group by t21.platform_user_id
            ,t21.order_id 
            ,t21.disburse_amount
            ,cast(t21.total_term_num as string)
            ,cast(t21.channel_id as string)
            ,format_time(t21.confirm_time,upper('${region}'))
            ,format_time(t21.create_time,upper('${region}'))
            ,cast(t21.seller_id as string)
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join tmp_user_is_contain_category_id_${region} t3 on t2.order_id = t3.order_id 
    group by t1.mission_id        
        ,t1.mission_name     
        ,t1.mission_type     
        ,t1.biz_type         
        ,t1.complete_duration
        ,t1.reward_duration  
        ,t1.user_mission_id  
        ,t1.platform_user_id 
        ,t1.credit_user_id   
        ,t1.start_time   
        ,t1.complete_time   
        ,t1.reward_time      
        ,t1.complete_value
        ,t1.create_time 
        ,t1.reward_rank
        ,t1.action_id
        ,t1.user_mission_status
) t3 
;