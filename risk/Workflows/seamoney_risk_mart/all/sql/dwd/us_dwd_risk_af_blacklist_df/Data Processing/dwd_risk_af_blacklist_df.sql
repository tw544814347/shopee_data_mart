--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-30
-- Theme Domain：       反欺诈-custom_list
-- Description:         名单同步到holmes
-- Data Granularity:    data
-- 变更历史：
--      update by zongyi.lu@shopee.com， 增加注释，切换risk.dwd_risk_{region}_credit_custom_list_df Mart表

create or replace temporary view all_custom_list_tab as
select 
data            as data 
,data_type_name 
,data_type
,t1.data_source 
,t1.action_detail
,t1.remark 
,t1.description 
,case when t1.status=1      then 'Active' 
    when t1.status=-1  then 'Delete' 
    when t1.status=0   then 'Unactive'  
    when t1.status=2   then 'Waiting' 
    else t1.status end as status
,t1.status             as status_type
,t1.creator 
,t1.update_time
,t1.expire_time expire_time
,'BR' as grass_region 
,t1.grass_date 
from risk.dwd_risk_br_credit_custom_list_df  t1 
where t1.grass_date ='${grass_date}'  
;


-- dict_tab 

create or replace temporary view all_dict_tab as
   select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'BR' as grass_region
    from risk.dim_risk_br_credit_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
;

insert overwrite table risk.dwd_risk_af_blacklist_df partition(grass_region,grass_date )
select 
    t1.data
   ,nvl(t2.dict_name,t1.data_type_name) as data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,t1.status
   ,t1.status_type 
   ,t1.creator 
   ,t1.update_time
   ,t1.expire_time
   ,t1.grass_region 
   ,t1.grass_date 
from all_custom_list_tab t1
left join (
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,grass_region
    from all_dict_tab          
 ) t2 
on t1.data_type = t2.dict_value
and t1.grass_region = t2.grass_region 
;