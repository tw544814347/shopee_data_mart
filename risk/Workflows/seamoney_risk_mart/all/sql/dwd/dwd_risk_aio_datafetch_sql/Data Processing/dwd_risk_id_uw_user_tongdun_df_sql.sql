--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-09
-- Theme Domain：       外部数据 tongdun
-- Description:         外部数据 tongdun
-- Data Granularity:    
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-07-09 https://jira.shopee.io/browse/SPFDT-41811  需要用history表，非history表会删除数据 (key 映射关系 https://confluence.shopee.io/pages/viewpage.action?pageId=2192833631)
--      update by zongyi.lu@shopee.com, 2024-07-26 https://jira.shopee.io/browse/SPFDT-42727  platform_user_id 逻辑优化,优先取原来的，取不到再取dim_id_uc_ic_to_uid_df（原来的user_id 不一定是null也可能是空串,因此改成通过长度来判断）
--      update by zongyi.lu@shopee.com, 2024-10-11 新增相关的文档 https://docs.google.com/spreadsheets/d/1pP7fbfdS-UnefS6F8Pdt7B5mYU79p0_z5TUbUZKmZEg/edit?gid=0#gid=0
--      update by zongyi.lu@shopee.com, 2024-10-16  platform_user_id&credit_user_id 优先取uc表之后再取外数 -- zhicheng后续再补jira单

--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table risk.dwd_risk_${region}_uw_user_tongdun_df partition(grass_date = '${grass_date}')
select 
-- nvl(t2.platform_user_id,t3.platform_user_id)      as platform_user_id
-- case when length(t2.platform_user_id)<=0 and t3.platform_user_id is not null then t3.platform_user_id
--      else t2.platform_user_id end                 as platform_user_id
case when t3.platform_user_id is not null then t3.platform_user_id else t2.platform_user_id end  as platform_user_id
-- ,nvl(t2.credit_user_id,t3.credit_user_id)         as credit_user_id
-- ,case when length(t2.credit_user_id)<=0 and t3.credit_user_id is not null then t3.credit_user_id
--      else t2.credit_user_id end                   as credit_user_id
,case when t3.credit_user_id is not null then t3.credit_user_id else t2.credit_user_id end as credit_user_id
,t2.income_status           as income_status
,t2.company_name            as company_name            
,t2.company_address         as company_address         
,t2.registration_date       as registration_date       
,t2.latest_salary_month     as latest_salary_month     
,t2.salary_range            as salary_range            
,t2.gender_check            as gender_check            
,t2.birthday_check          as birthday_check          
,t2.package_check           as package_check           
,t2.email_check             as email_check             
,t2.employee_address_check  as employee_address_check  
,t2.latest_inquiry_date     as latest_inquiry_date
,t2.data_source_name        as data_source_name
,t2.ktp_req                 as ktp_req
from (
select 
get_json_object(header_data, '$.PlatformUserId')                                           as platform_user_id
,get_json_object(header_data, '$.CreditUserId')                                            as credit_user_id

,case when get_json_object(resp_raw_data, '$.result')='hit' then "Has Income"
     when get_json_object(resp_raw_data, '$.result')='no_record' then "No Income"
     else 'NA' end                                                                         as income_status
,get_json_object(resp_raw_data,'$.data.company')             as company_name            
,get_json_object(resp_raw_data,'$.data.address_company')     as company_address         
,get_json_object(resp_raw_data,'$.data.date_first_salary')   as registration_date       
,get_json_object(resp_raw_data,'$.data.month_last_salary')   as latest_salary_month     
,get_json_object(resp_raw_data,'$.data.range_salary')        as salary_range            
,get_json_object(resp_raw_data,'$.data.sex')                 as gender_check            
,get_json_object(resp_raw_data,'$.data.birthdate')           as birthday_check          
,get_json_object(resp_raw_data,'$.data.package')             as package_check           
,get_json_object(resp_raw_data,'$.data.email')               as email_check             
,get_json_object(resp_raw_data,'$.data.address_employee')    as employee_address_check  
,format_time(create_time,upper('${region}'))                 as latest_inquiry_date
,data_source_name                                            as data_source_name
,get_json_object(req_data,'$.IdNumber')                      as ktp_req
,row_number() over(partition by get_json_object(req_data,'$.IdNumber') order by format_time(create_time,upper('${region}')) desc ) as rn 
from risk.ods__credit_risk_datafetch_${region}_db__identity_data_history_tab__df t1 
where t1.grass_date ='${grass_date}'
and t1.data_source_name = 'TongdunIncome'
) t2 
left join (
    select  
       id_card_no
       ,credit_user_id
       ,platform_user_id_1 as platform_user_id
    FROM credit_uc.dim_${region}_uc_ic_to_uid_df
    where grass_date ='${grass_date}'
) t3 on t2.ktp_req = t3.id_card_no
where rn =1 
;