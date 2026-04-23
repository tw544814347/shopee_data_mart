--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-04-27
-- Theme Domain：       user referral
-- Description:         异常情况监控
--                      1. referral_id 的order_id 会越来越大,不会变小
--                      2. 后续可再补充。。
-- Data Granularity:    
--********************************************************************--

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
drop temporary function if exists json_to_array; 
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';


-- drop table if exists risk.ads_risk_id_spl_referral_result_df_dqc;
-- create external table if not exists risk.ads_risk_id_spl_referral_result_df_dqc
-- (
-- referral_id           string comment 'referral_id'
-- ,referral_name        string comment 'referral_name'
-- ,task_type            string comment 'task_type'
-- ,dqc_type            string comment 'criteria_dqc or referral_result_dqc'
-- ,dqc_result          string comment 'dqc_result 1-异常 0-正常'
-- )
-- partitioned by (
-- biz_name        string comment 'biz_name '
-- ,grass_date     string   comment "YYYY-MM-DD")
-- stored as orc tblproperties ("orc.compress"="zstd")
-- location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_spl_referral_result_df_dqc/grass_region=ID';
-- ;

-- msck repair table risk.ads_risk_id_spl_referral_result_df_dqc;


insert overwrite table risk.ads_risk_id_spl_referral_result_df_dqc partition(biz_name,grass_date)
select 
t1.referral_id    
,t1.referral_name    
,t1.task_type     
,'referral_result_dqc'  as dqc_type 
,case when t1.order_cnt>= nvl(t2.order_cnt,0) then 0 else 1 end dqc_result
,'spl'           as biz_name
,'${grass_date}' as grass_date 
from (
    select 
     t1.referral_id    
    ,t1.referral_name    
    ,t1.task_type 
    ,count(referee_order_id) order_cnt
    from risk.dwd_risk_id_spl_referral_result_df t1 
    where grass_date='${grass_date}'
    group by t1.referral_id    
    ,t1.referral_name    
    ,t1.task_type 
) t1 
left join (
    select 
    t1.referral_id    
    ,t1.referral_name    
    ,t1.task_type 
    ,count(referee_order_id) order_cnt
    from risk.dwd_risk_id_spl_referral_result_df t1
    where grass_date =date_sub('${grass_date}',1)
    group by t1.referral_id    
    ,t1.referral_name    
    ,t1.task_type 
) t2 on t1.referral_id = t2.referral_id and t1.referral_name = t2.referral_name and t1.task_type =t2.task_type
union all 
select 
t1.referral_id    
,t1.referral_name    
,t1.task_type     
,'referral_task_criteria_dqc'  as dqc_type 
,case when size(json_object_keys(task_criteria))>=2 then 1 else 0 end dqc_result
,'spl'           as biz_name
,'${grass_date}' as grass_date
 from (select 
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
 ) t1
;
