--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-12
-- Theme Domain：       user referral
-- Description:         user referral 
-- Data Granularity:    user_referral_id
/*
jira: https://jira.shopee.io/browse/SPFDT-43159
备注: task_detail_list 是数组关联需要task_type
    2026-04-09 按照 credit uid 聚合，DFS 改造将之前 spuid 文件改为输出 credituid 文件输出
*/
--********************************************************************--

drop table if exists ${SCHEMA}.dwd_risk_${region}_credit_user_${biz_name}_referral_result_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_credit_user_${biz_name}_referral_result_df
(
referral_id                     string comment 'referral_id'
,referral_name                   string comment 'referral_name'
,user_referral_id                string comment 'user_referral_id'
,task_type                       int    comment '任务类型, 1: activation, 2: purchase'
,biz_type                        int    comment 'biz_type'
,referrer_platform_user_id       string comment '推荐人puid'
,referee_platform_user_id        string comment '被推荐人puid'
,referrer_credit_user_id         string comment '推荐人credit_uid'
,referee_credit_user_id          string comment '被推荐人credit_uid'
,referrer_platform_type          string comment '推荐人platform_type'
,referee_platform_type           string comment '被推荐人platform_type'
,complete_duration               int    comment '推荐任务完成时间配置,n: n天，单位为Day'
,referrer_start_time             string comment '推荐任务开始时间 local'
,referrer_complete_time          string comment '推荐任务完成时间 local'
,user_referral_status            int    comment '推荐任务状态 1:doing, 2:completed, 3:rewarded'
,referral_create_time            string comment '推荐任务创建时间local'
,referral_update_time            string comment '推荐任务更新local'
,referee_order_id                string comment '被推荐人的order_id' 
,referee_order_amount            decimal(32,10) comment '被推荐人order amount'
,completed_value                 string comment 'completed_value'
-- ,min_spend_amount                string comment 'min_spend_amount'
)
partitioned by (
biz_name        string comment 'biz_name '
,grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${biz_name}_credit_user_referral_result_df/grass_region=${grass_region}';
;

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
    ,format_time(from_unixtime(t1.start_time),upper('${region}'))    as referrer_start_time   
    ,format_time(from_unixtime(t1.complete_time),upper('${region}')) as referrer_complete_time 
    ,format_time(t1.create_time,upper('${region}'))   as referral_create_time
    ,format_time(t1.update_time,upper('${region}'))   as referral_update_time
    ,t1.user_referral_status 
    ,t2.task_criteria
    ,t2.min_spend_amount
    ,case when t2.min_spend_amount='[]' or t2.min_spend_amount is null then 0 else 1 end need_min_spend_amount
from credit.ods__credit_promotion_banner_${region}_db__pr_user_referral_tab__df t1 
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
    from credit.ods__credit_promotion_banner_${region}_db__pr_referral_tab__df t 
    lateral view explode(json_to_array(task_detail_list)) tbl as task_detail      
    where grass_date ='${grass_date}'
) t2 on t1.referral_id = t2.referral_id and t1.task_type = t2.task_type 
where t1.grass_date ='${grass_date}'
and t1.biz_type=3  -- biz_type=3是spl, biz_type=1是bcl  add by dongbo.yu at 2026-03-31
;


-- 汇总
insert overwrite table ${SCHEMA}.dwd_risk_${region}_credit_user_${biz_name}_referral_result_df partition(biz_name='${biz_name}',grass_date='${grass_date}')
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
        -- t21.platform_user_id
        t21.user_id
        ,t21.order_id as referee_order_id
        ,t21.disburse_amount as referee_order_amount
        ,format_time(t21.confirm_time,upper('${region}')) as confirm_time
        ,format_time(t21.create_time,upper('${region}')) as order_create_time
    from credit.ods__credit_${biz_name}_transaction_${region}_db__order_info_tab__df t21
    where t21.grass_date ='${grass_date}'
    and t21.confirm_status=3 -- 确认收货
    group by 
        t21.user_id
        -- t21.platform_user_id
        ,t21.order_id 
        ,t21.disburse_amount
        ,format_time(t21.confirm_time,upper('${region}'))
        ,format_time(t21.create_time,upper('${region}'))
) t2 on t1.referee_credit_user_id = t2.user_id
where t1.referrer_start_time<=t2.confirm_time
and t1.min_spend_amount<=t2.referee_order_amount
;