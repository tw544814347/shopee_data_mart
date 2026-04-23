--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-09
-- Theme Domain：       外部数据 npwp
-- Description:         外部数据 npwp
-- Data Granularity:    
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-07-09 https://jira.shopee.io/browse/SPFDT-41811  需要用history表，非history表会删除数据
--      update by zongyi.lu@shopee.com, 2024-07-26 https://jira.shopee.io/browse/SPFDT-42727  platform_user_id 逻辑优化,优先取原来的，取不到再取dim_id_uc_ic_to_uid_df
--      update by zongyi.lu@shopee.com, 2024-10-11 新增相关的文档 https://docs.google.com/spreadsheets/d/1pP7fbfdS-UnefS6F8Pdt7B5mYU79p0_z5TUbUZKmZEg/edit?gid=0#gid=0
--                                      排序去重逻辑 排序和去重我放到数仓的ads层哈 #ads_risk_id_uw_npwp_df https://docs.google.com/spreadsheets/d/1pP7fbfdS-UnefS6F8Pdt7B5mYU79p0_z5TUbUZKmZEg/edit?gid=0#gid=0
--      update by zongyi.lu@shopee.com, 2024-10-16  platform_user_id&credit_user_id 优先取uc表之后再取外数 -- zhicheng后续再补jira单
--      modify bu xiaoke.zhou@shopee.com 2025-07-09 https://jira.shopee.io/browse/SPFDT-53667 新增 NPWPv2 ,上游数据源变更，新旧数据都包含进来
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table risk.dwd_risk_${region}_uw_user_npwp_df partition(grass_date = '${grass_date}')
select 
get_json_object(t1.resp_raw_data, '$.kodestatus')                               as tax_status             
-- ,case when length(get_json_object(t1.header_data, '$.PlatformUserId')) <=0 then t2.platform_user_id
--       else get_json_object(t1.header_data, '$.PlatformUserId') end              as platform_user_id
,case when t2.platform_user_id is not null then t2.platform_user_id else get_json_object(t1.header_data, '$.PlatformUserId') end as platform_user_id
-- ,case when length(get_json_object(t1.header_data, '$.CreditUserId')) <=0 then t2.credit_user_id
--       else get_json_object(t1.header_data, '$.CreditUserId') end                as credit_user_id
,case when t2.credit_user_id is not null then t2.credit_user_id else get_json_object(t1.header_data, '$.CreditUserId') end as credit_user_id
,get_json_object(t1.req_data, '$.Nik')                                          as id_card_no            
,get_json_object(t1.resp_raw_data, '$.data[0].datawp.statusWp')                 as tax_taxpayer_status   
,get_json_object(t1.resp_raw_data, '$.data[0].datawp.statusSpt')                as if_profile_match      
,get_json_object(t1.resp_raw_data, '$.data[0].datawp.npwp')                     as tax_taxpayer_id       
,get_json_object(t1.resp_raw_data, '$.data[0].keterangan')                      as tax_result            
,get_json_object(t1.resp_raw_data, '$.data[0].kodestatus')                      as tax_result_code       
,format_time(t1.create_time,upper('${region}'))                                 as latest_inquiry_date
,t1.data_source_name                                                            as data_source_name
,get_json_object(t1.req_data,'$.Nik')                                           as ktp_req
from risk.ods__credit_risk_datafetch_${region}_db__identity_data_history_tab__df t1 
left join (
    select  
       id_card_no
       ,credit_user_id
       ,platform_user_id_1 as platform_user_id
    FROM credit_uc.dim_${region}_uc_ic_to_uid_df
    where grass_date ='${grass_date}'
) t2  on get_json_object(req_data,'$.Nik') = t2.id_card_no
where t1.grass_date ='${grass_date}'
and t1.data_source_name in ('NPWP','NPWPv2')
;