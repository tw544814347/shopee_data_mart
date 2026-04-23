--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-30
-- Theme Domain：       反欺诈-custom_list
-- Description:         名单同步到holmes
-- Data Granularity:    data
-- 变更历史：
--      update by zongyi.lu@shopee.com， 增加注释，切换risk.dwd_risk_{region}_shopeepay_custom_list_df Mart表

create or replace temporary view all_custom_list_tab as
-- select 
--     t1.custom_list_id 
--    ,t1.data
--    ,t1.data_type_name
--    ,t1.data_type
--    ,t1.data_source 
--    ,t1.action_detail
--    ,t1.remark 
--    ,t1.description 
--    ,case when t1.status=1  then 'Active' 
--     when t1.status=-1 then 'Delete' 
--     when t1.status=0  then 'Unactive'  
--     when t1.status=2  then 'Waiting' 
--     else t1.status end as status
--    ,t1.status          as status_type
--    ,t1.creator 
--    ,t1.create_time
--    ,t1.update_time
--    ,t1.expire_time
--    ,'BR' as grass_region 
--    ,t1.grass_date 
--    ,t1.custom_list_name as list_name
--    ,t1.list_status
-- from risk.dwd_risk_br_shopeepay_custom_list_df  t1 
-- where t1.grass_date ='${grass_date}'
-- union all 
select 
    t1.custom_list_id 
   ,t1.data
   ,t1.data_type_name
   ,t1.data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,case when t1.status=1  then 'Active' 
    when t1.status=-1 then 'Delete' 
    when t1.status=0  then 'Unactive'  
    when t1.status=2  then 'Waiting' 
    else t1.status end as status
   ,t1.status          as status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,'ID' as grass_region 
   ,t1.grass_date 
   ,t1.custom_list_name as list_name
   ,t1.list_status
from risk.dwd_risk_id_shopeepay_custom_list_df  t1 
where t1.grass_date ='${grass_date}'
union all 
select 
    t1.custom_list_id 
   ,t1.data
   ,t1.data_type_name
   ,t1.data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,case when t1.status=1  then 'Active' 
    when t1.status=-1 then 'Delete' 
    when t1.status=0  then 'Unactive'  
    when t1.status=2  then 'Waiting' 
    else t1.status end as status
   ,t1.status          as status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,'MY' as grass_region 
   ,t1.grass_date 
   ,t1.custom_list_name as list_name
   ,t1.list_status
from risk.dwd_risk_my_shopeepay_custom_list_df  t1 
where t1.grass_date ='${grass_date}'
union all 
select 
    t1.custom_list_id 
   ,t1.data
   ,t1.data_type_name
   ,t1.data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,case when t1.status=1  then 'Active' 
    when t1.status=-1 then 'Delete' 
    when t1.status=0  then 'Unactive'  
    when t1.status=2  then 'Waiting' 
    else t1.status end as status
   ,t1.status          as status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,'PH' as grass_region 
   ,t1.grass_date 
   ,t1.custom_list_name as list_name
   ,t1.list_status
from risk.dwd_risk_ph_shopeepay_custom_list_df  t1 
where t1.grass_date ='${grass_date}'
union all 
select 
    t1.custom_list_id 
   ,t1.data
   ,t1.data_type_name
   ,t1.data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,case when t1.status=1  then 'Active' 
    when t1.status=-1 then 'Delete' 
    when t1.status=0  then 'Unactive'  
    when t1.status=2  then 'Waiting' 
    else t1.status end as status
   ,t1.status          as status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,'SG' as grass_region 
   ,t1.grass_date 
   ,t1.custom_list_name as list_name
   ,t1.list_status
from risk.dwd_risk_sg_shopeepay_custom_list_df  t1 
where t1.grass_date ='${grass_date}'
union all 
select 
    t1.custom_list_id 
   ,t1.data
   ,t1.data_type_name
   ,t1.data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,case when t1.status=1  then 'Active' 
    when t1.status=-1 then 'Delete' 
    when t1.status=0  then 'Unactive'  
    when t1.status=2  then 'Waiting' 
    else t1.status end as status
   ,t1.status          as status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,'TH' as grass_region 
   ,t1.grass_date 
   ,t1.custom_list_name as list_name
   ,t1.list_status
from risk.dwd_risk_th_shopeepay_custom_list_df  t1 
where t1.grass_date ='${grass_date}'
-- union all 
-- select 
--     t1.custom_list_id 
--    ,t1.data
--    ,t1.data_type_name
--    ,t1.data_type
--    ,t1.data_source 
--    ,t1.action_detail
--    ,t1.remark 
--    ,t1.description 
--    ,case when t1.status=1  then 'Active' 
--     when t1.status=-1 then 'Delete' 
--     when t1.status=0  then 'Unactive'  
--     when t1.status=2  then 'Waiting' 
--     else t1.status end as status
--    ,t1.status          as status_type
--    ,t1.creator 
--    ,t1.create_time
--    ,t1.update_time
--    ,t1.expire_time
--    ,'TW' as grass_region 
--    ,t1.grass_date 
--    ,t1.custom_list_name as list_name
--    ,t1.list_status
-- from risk.dwd_risk_tw_shopeepay_custom_list_df  t1 
-- where t1.grass_date ='${grass_date}'
union all 
select 
    t1.custom_list_id 
   ,t1.data
   ,t1.data_type_name
   ,t1.data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,case when t1.status=1  then 'Active' 
    when t1.status=-1 then 'Delete' 
    when t1.status=0  then 'Unactive'  
    when t1.status=2  then 'Waiting' 
    else t1.status end as status
   ,t1.status          as status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,'VN' as grass_region 
   ,t1.grass_date 
   ,t1.custom_list_name as list_name
   ,t1.list_status
from risk.dwd_risk_vn_shopeepay_custom_list_df  t1 
where t1.grass_date ='${grass_date}'
;

-- dict_tab 

create or replace temporary view all_dict_tab as
--    select 
--     dict_key  
--     ,parent_dict_key          
--     ,dict_name           
--     ,dict_value           
--     ,'BR' as grass_region
--     from risk.dim_risk_br_shopeepay_dict_df
--     where grass_date ='${grass_date}'
--     and parent_dict_key = 'dataType'
--     group by dict_key  
--     ,parent_dict_key          
--     ,dict_name           
--     ,dict_value 
--     union all 
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'ID' as grass_region
    from risk.dim_risk_id_shopeepay_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
    union all 
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'MY' as grass_region
    from risk.dim_risk_my_shopeepay_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
    union all 
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'PH' as grass_region
    from risk.dim_risk_ph_shopeepay_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
    union all 
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'SG' as grass_region
    from risk.dim_risk_sg_shopeepay_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
    union all 
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'TH' as grass_region
    from risk.dim_risk_th_shopeepay_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
    union all 
    select 
    dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value           
    ,'VN' as grass_region
    from risk.dim_risk_vn_shopeepay_dict_df
    where grass_date ='${grass_date}'
    and parent_dict_key = 'dataType'
    group by dict_key  
    ,parent_dict_key          
    ,dict_name           
    ,dict_value 
;

insert overwrite table risk.dwd_risk_spp_af_blacklist_df partition(grass_region,grass_date )
select 
    a.custom_list_id  as list_id
   ,a.list_name       as list_name
   ,case when a.list_status=1 then 'Active' 
         when a.list_status=0 then 'Paused' else a.list_status end   as list_status
   ,a.data
   ,a.data_type 
   ,a.data_source 
   ,a.action_detail
   ,a.remark 
   ,a.description 
   ,a.status
   ,a.status_type
   ,a.creator 
   ,a.create_time
   ,a.update_time
   ,a.expire_time 
   ,from_unixtime(a.create_time) as create_time_regional
   ,from_unixtime(a.update_time) as update_time_regional
   ,from_unixtime(a.expire_time) as expire_time_regional
   ,a.grass_region 
   ,a.grass_date 
from (
select 
    t1.custom_list_id 
   ,t1.data
   ,nvl(t2.dict_name,t1.data_type_name) as data_type
   ,t1.data_source 
   ,t1.action_detail
   ,t1.remark 
   ,t1.description 
   ,t1.status
   ,t1.status_type
   ,t1.creator 
   ,t1.create_time
   ,t1.update_time
   ,t1.expire_time
   ,t1.grass_region
   ,t1.grass_date 
   ,t1.list_name
   ,t1.list_status
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
) a 
