--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-06-25
-- Theme Domain：       user mission 新做一张保留所有符合任务的order 
-- Description:         user mission, 只取  mission_type in (2,3) 1：KYC任务 2：SPL订单量任务 3：SPL GMV任务
-- Data Granularity:    user_mission_id
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
-- update by zongyi.lu@shopee.com 2024-06-25 新增一张order 明细表, 协助分析 https://jira.shopee.io/browse/SPFDT-41414
-- update by zongyi.lu@shopee.com 2024-10-11 新增 mission_reward字段里的rank
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';




create or replace temporary  view tmp_user_mission_info_id as 
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
    ,format_time(t1.start_time,upper('id'))    as start_time   
    ,format_time(t1.complete_time,upper('id')) as complete_time   
    ,format_time(t1.reward_time,upper('id'))   as reward_time      
    ,t1.complete_value     
    ,format_time(t1.create_time,upper('id'))   as create_time 
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
    ,t2.rank as rank 
from credit.ods__credit_promotion_banner_id_db__pr_user_mission_tab__df t1 
join (
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
        ,complete_duration
        ,reward_duration  
        ,get_json_object(substr(mission_reward,2,length(mission_reward)-2),'$.rank')as rank
    from credit.ods__credit_promotion_banner_id_db__pr_mission_tab__df
    where grass_date ='${grass_date}'
    and mission_type in (2,3)
) t2 on t1.mission_id = t2.mission_id 
where t1.grass_date ='${grass_date}'
;

create or replace temporary  view tmp_user_category_id_list_id as
select 
t1.mission_id
,t1.user_mission_id
,t1.platform_user_id
,t1.credit_user_id
,t1.mission_type
,tbl.category_id
,t1.need_category_list
from tmp_user_mission_info_id t1
lateral view explode(split(regexp_replace(t1.category_list, "[\\[\\]]", ""),',')) tbl as category_id 
where t1.category_list is not null 
;


-- 判断mission 中的category_list 是否包含order_item 中的 category_id 
-- 如果有取整单 disburse_amount(包含一个category_id就行),如果都不包含,则disburse_amount=0
create or replace temporary  view tmp_user_is_contain_category_id_id as
select 
t1.order_id 
,1  as is_contain_category_id
,cast(collect_set(t1.category_id) as string) as category_id_list
,count(1)
from credit.ods__credit_spl_transaction_id_db__order_item_info_tab__df t1 
join tmp_user_category_id_list_id t2 on t1.user_id = t2.credit_user_id and t1.category_id = t2.category_id
where t1.grass_date = "${grass_date}"
group by t1.order_id 
;

-- order信息 
create or replace temporary  view tmp_all_result_id as
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
    ,t3.start_time     as user_mission_start_time
    ,t3.complete_time  as user_mission_expiry_time
    ,t3.order_id
    ,null as seller_type
    ,t3.disburse_amount 
    ,t3.total_term_num
    ,t3.order_create_time
    ,t3.order_confirm_time  as order_complete_time
    ,t3.is_mission_type_2
    ,t3.is_mission_type_3
    ,t3.category_id_list   
    ,t3.rank
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
        ,t2.order_create_time
        ,t2.confirm_time as order_confirm_time
        ,t3.category_id_list
        ,t2.total_term_num
        ,t2.order_id
        ,t2.disburse_amount
        ,case when t1.mission_type = 2 
                and t2.confirm_time >= t1.start_time and t2.confirm_time <=t1.complete_time
                and t2.order_create_time >= t1.start_time and t2.order_create_time <=t1.complete_time
                and cast(t2.disburse_amount as decimal)>=cast(nvl(t1.min_spend_amount,0)  as decimal)
                and (case when need_tenure_num_list=1 then instr(t1.tenure_num_list,t2.total_term_num)>0 else 1=1 end)
                and (case when need_business_domain_list=1 then instr(t1.business_domain_list,t2.channel_id)>0 else 1=1 end)
                and (case when need_shop_list=1 then instr(t1.shop_list,t2.shop_id)>0 else 1=1 end)
                and (case when t1.need_category_list=1 then t3.is_contain_category_id=1 else 1=1 end)
            then 1 else 0 end  as is_mission_type_2
        ,case when t1.mission_type = 3 
                and t2.confirm_time >= t1.start_time and t2.confirm_time <=t1.complete_time
                and t2.order_create_time >= t1.start_time and t2.order_create_time <=t1.complete_time
                and cast(t2.disburse_amount as decimal)>=cast(nvl(t1.min_spend_amount,0)  as decimal)
                and (case when need_tenure_num_list=1 then instr(t1.tenure_num_list,t2.total_term_num)>0 else 1=1 end)
                and (case when need_business_domain_list=1 then instr(t1.business_domain_list,t2.channel_id)>0 else 1=1 end)
                and (case when need_shop_list=1 then instr(t1.shop_list,t2.shop_id)>0 else 1=1 end)
                and (case when t1.need_category_list=1 then t3.is_contain_category_id=1 else 1=1 end)
            then 1 else 0 end is_mission_type_3
        ,t1.create_time  
        ,t1.rank
    from tmp_user_mission_info_id t1 
    left join (
        select 
             t21.platform_user_id
            ,t21.order_id 
            ,t21.disburse_amount
            ,t21.total_term_num
            ,t21.channel_id
            ,format_time(t21.confirm_time,upper('id')) as confirm_time
            ,format_time(t21.create_time,upper('id')) as order_create_time
            ,t22.shop_id
        from credit.ods__credit_spl_transaction_id_db__order_info_tab__df t21
        join (
            select 
            user_id as platform_user_id
            ,shop_id
            from mp_user.dim_user__reg_s0_live
            where grass_region = upper('id')
            and grass_date ='${grass_date}'
        ) t22 on t21.platform_user_id = t22.platform_user_id
        where t21.grass_date ='${grass_date}'
        and t21.confirm_status=3 -- 确认收货
        group by t21.platform_user_id
            ,t21.order_id 
            ,t21.disburse_amount
            ,t21.total_term_num
            ,t21.channel_id
            ,format_time(t21.confirm_time,upper('id'))
            ,format_time(t21.create_time,upper('id'))
            ,t22.shop_id
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join tmp_user_is_contain_category_id_id t3 on t2.order_id = t3.order_id 
) t3 
where t3.is_mission_type_2 =1 or  t3.is_mission_type_3 =1
;

-- 统计gmv 任务的阈值 
create or replace temporary  view tmp_gmv_task_rank as
select 
mission_id             
,user_mission_id  
,platform_user_id
,rank
,result
from (
    select
    mission_id             
    ,user_mission_id 
    ,platform_user_id 
    ,rank
    ,result
    ,row_number() over(partition by user_mission_id,platform_user_id order by abs(result-rank) asc) rn  
    from 
    (
        select  
            t1.mission_id             
            ,t1.user_mission_id  
            ,t1.platform_user_id
            ,t1.rank
            ,sum(disburse_amount) over(partition by t1.user_mission_id,t1.platform_user_id order by t1.order_complete_time asc ) result 
        from tmp_all_result_id t1 
        -- 3：SPL GMV任务, 统计订单金额
        where t1.mission_type='3'
    )  tt1 
) ttt1 
where rn =1 
;

-- 分别按照mission_type 取不同的范围值  2：SPL订单量任务 3：SPL GMV任务
insert overwrite table risk.dwd_risk_id_spl_mission_order_info_df partition(grass_date ='${grass_date}')
select 
    mission_id        
    ,mission_name     
    ,mission_type     
    ,biz_type         
    ,complete_duration
    ,reward_duration  
    ,user_mission_id  
    ,platform_user_id 
    ,credit_user_id   
    ,user_mission_start_time
    ,user_mission_expiry_time
    ,order_id
    ,seller_type
    ,disburse_amount 
    ,total_term_num
    ,order_create_time
    ,order_complete_time
    ,is_mission_type_2
    ,is_mission_type_3
    ,category_id_list
    ,case when t.result <= t.rank then 1 else 0 end as is_threshold_value
from (
    select  
        mission_id        
        ,mission_name     
        ,mission_type     
        ,biz_type         
        ,complete_duration
        ,reward_duration  
        ,user_mission_id  
        ,platform_user_id 
        ,credit_user_id   
        ,user_mission_start_time
        ,user_mission_expiry_time
        ,order_id
        ,seller_type
        ,disburse_amount 
        ,total_term_num
        ,order_create_time
        ,order_complete_time
        ,is_mission_type_2
        ,is_mission_type_3
        ,category_id_list   
        ,t1.rank
        ,count(order_id) over(partition by user_mission_id,platform_user_id order by order_complete_time asc ) result  
    from tmp_all_result_id t1 
    -- 2：SPL订单量任务, 统计订单量 
    where mission_type='2'
) t 
union all 
select 
    tt1.mission_id        
    ,tt1.mission_name     
    ,tt1.mission_type     
    ,tt1.biz_type         
    ,tt1.complete_duration
    ,tt1.reward_duration  
    ,tt1.user_mission_id  
    ,tt1.platform_user_id 
    ,tt1.credit_user_id   
    ,tt1.user_mission_start_time
    ,tt1.user_mission_expiry_time
    ,tt1.order_id
    ,tt1.seller_type
    ,tt1.disburse_amount 
    ,tt1.total_term_num
    ,tt1.order_create_time
    ,tt1.order_complete_time
    ,tt1.is_mission_type_2
    ,tt1.is_mission_type_3
    ,tt1.category_id_list
    ,case when tt1.result<=tt2.result then 1 else 0 end as is_threshold_value
from (
select  
    mission_id        
    ,mission_name     
    ,mission_type     
    ,biz_type         
    ,complete_duration
    ,reward_duration  
    ,user_mission_id  
    ,platform_user_id 
    ,credit_user_id   
    ,user_mission_start_time
    ,user_mission_expiry_time
    ,order_id
    ,seller_type
    ,disburse_amount 
    ,total_term_num
    ,order_create_time
    ,order_complete_time
    ,is_mission_type_2
    ,is_mission_type_3
    ,category_id_list   
    ,rank
    ,sum(disburse_amount) over(partition by user_mission_id,platform_user_id order by order_complete_time asc ) result 
from tmp_all_result_id t1 
-- 3：SPL GMV任务, 统计订单金额
where mission_type='3'
) tt1 
left join tmp_gmv_task_rank tt2 on tt1.user_mission_id = tt2.user_mission_id and tt2.platform_user_id = tt1.platform_user_id
;