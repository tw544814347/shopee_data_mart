--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-12
-- Theme Domain：       user referral
-- Description:         user referral 
-- Data Granularity:    user_referral_id
/*
jira: https://jira.shopee.io/browse/SPFDT-43159
备注: task_detail_list 是数组关联需要task_type
*/
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
drop temporary function if exists json_to_array; 
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

create or replace temporary  view tmp_user_referral_info_id as 
select 
    t1.referral_id        
    ,t2.referral_name     
    ,t1.user_referral_id     
    ,t1.task_type
    ,t1.biz_type  
    ,t1.referrer_platform_user_id
    ,t1.referee_platform_user_id 
    ,t1.referrer_credit_user_id  
    ,t1.referee_credit_user_id   
    ,t1.referrer_platform_type   
    ,t1.referee_platform_type           
    ,t2.complete_duration
    ,format_time(from_unixtime(t1.start_time),upper('id'))    as referrer_start_time   
    ,format_time(from_unixtime(t1.complete_time),upper('id')) as referrer_complete_time 
    ,format_time(t1.create_time,upper('id'))   as referral_create_time
    ,format_time(t1.update_time,upper('id'))   as referral_update_time
    ,t1.user_referral_status 
    ,t2.task_criteria
    ,t2.min_spend_amount
    ,case when t2.min_spend_amount='[]' or t2.min_spend_amount is null then 0 else 1 end need_min_spend_amount
from credit.ods__credit_promotion_banner_id_db__pr_user_referral_tab__df t1 
join (
    select 
        referral_id        
        ,referral_name          
        ,biz_type       
        ,task_detail
        ,get_json_object(task_detail,'$.task_type') as task_type   
        ,get_json_object(task_detail,'$.task_criteria') as task_criteria  
        ,get_json_object(task_detail,'$.task_criteria.min_spend_amount') as min_spend_amount  
        ,complete_duration  
    from credit.ods__credit_promotion_banner_id_db__pr_referral_tab__df t 
    lateral view explode(json_to_array(task_detail_list)) tbl as task_detail      
    where grass_date ='${grass_date}'
) t2 on t1.referral_id = t2.referral_id and t1.task_type = t2.task_type 
where t1.grass_date ='${grass_date}'
and t1.biz_type=3  -- biz_type=3是spl, biz_type=1是bcl  add by dongbo.yu at 2026-03-31
;


-- 汇总
insert overwrite table risk.dwd_risk_id_spl_referral_result_df partition(biz_name='spl',grass_date='${grass_date}')
    select 
    t1.referral_id               
    ,t1.referral_name            
    ,t1.user_referral_id         
    ,cast(t1.task_type as int) as task_type              
    ,cast(t1.biz_type as int) as biz_type                
    ,t1.referrer_platform_user_id
    ,t1.referee_platform_user_id 
    ,t1.referrer_credit_user_id  
    ,t1.referee_credit_user_id   
    ,t1.referrer_platform_type   
    ,t1.referee_platform_type    
    ,cast(t1.complete_duration as int) as complete_duration        
    ,t1.referrer_start_time      
    ,t1.referrer_complete_time   
    ,cast(t1.user_referral_status as int) as user_referral_status         
    ,t1.referral_create_time     
    ,t1.referral_update_time     
    ,t2.referee_order_id         
    ,cast(t2.referee_order_amount as decimal) as referee_order_amount   
    ,1 as completed_value  
from tmp_user_referral_info_id t1 
left join (
    select 
        t21.user_id
        ,t21.order_id as referee_order_id
        ,t21.disburse_amount as referee_order_amount
        ,format_time(t21.confirm_time,upper('id')) as confirm_time
        ,format_time(t21.create_time,upper('id')) as order_create_time
    from credit.ods__credit_spl_transaction_id_db__order_info_tab__df t21
    where t21.grass_date ='${grass_date}'
    and t21.confirm_status=3 -- 确认收货
    group by 
        t21.user_id
        ,t21.order_id 
        ,t21.disburse_amount
        ,format_time(t21.confirm_time,upper('id'))
        ,format_time(t21.create_time,upper('id'))
) t2 on t1.referee_credit_user_id = t2.user_id
where t1.referrer_start_time<=t2.confirm_time
and t1.min_spend_amount<=t2.referee_order_amount
;