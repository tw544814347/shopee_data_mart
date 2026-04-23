--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-09
-- Theme Domain：       外部数据 bpjs
-- Description:         外部数据 bpjs
-- Data Granularity:    
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-07-09 https://jira.shopee.io/browse/SPFDT-41811  需要用history表，非history表会删除数据
--      update by zongyi.lu@shopee.com, 2024-07-26 https://jira.shopee.io/browse/SPFDT-42727  platform_user_id 逻辑优化,优先取原来的，取不到再取dim_id_uc_ic_to_uid_df（原来的user_id 不一定是null也可能是空串,因此改成通过长度来判断）
--      update by zongyi.lu@shopee.com, 2024-10-11 新增相关的文档 https://docs.google.com/spreadsheets/d/1pP7fbfdS-UnefS6F8Pdt7B5mYU79p0_z5TUbUZKmZEg/edit?gid=0#gid=0
--      update by zongyi.lu@shopee.com, 2024-10-16  platform_user_id&credit_user_id 优先取uc表之后再取外数 -- zhicheng后续再补jira单
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table risk.dwd_risk_${region}_uw_user_bpjs_df partition(grass_date = '${grass_date}')
select 
-- nvl(t2.platform_user_id,t3.platform_user_id)      as platform_user_id
-- case when length(t2.platform_user_id)<=0 and t3.platform_user_id is not null then t3.platform_user_id
--      else t2.platform_user_id end                 as platform_user_id
case when t3.platform_user_id is not null then t3.platform_user_id else t2.platform_user_id end as platform_user_id
-- ,nvl(t2.credit_user_id,t3.credit_user_id)         as credit_user_id
-- ,case when length(t2.credit_user_id)<=0 and t3.credit_user_id is not null then t3.credit_user_id
--      else t2.credit_user_id end                   as credit_user_id
,case when t3.credit_user_id is not null then t3.credit_user_id else t2.credit_user_id end as credit_user_id
,t2.income_status                                 as income_status
,t2.name_check                                    as name_check
,t2.nik_check                                     as nik_check
,t2.gender                                        as gender
,t2.company_address                               as company_address
,t2.phone_no                                      as phone_no
,t2.company_name                                  as company_name
,t2.income_mask                                   as income_mask
,t2.income_unmask                                 as income_unmask
,case when t2.income_unmask >0 and t2.income_unmask<= 2500000 then '0-2.5JT'
    when t2.income_unmask > 2500000 and t2.income_unmask<=  3500000 then '2.5-3.5JT'
    when t2.income_unmask > 3500000 and t2.income_unmask<=  4500000 then '3.5-4.5JT'
    when t2.income_unmask > 4500000 and t2.income_unmask<=  5500000 then '4.5-5.5JT'
    when t2.income_unmask > 5500000 and t2.income_unmask<=  6500000 then '5.5-6.5JT'
    when t2.income_unmask > 6500000 and t2.income_unmask<=  7500000 then '6.5-7.5JT'
    when t2.income_unmask > 7500000 and t2.income_unmask<=  8500000 then '7.5-8.5JT'
    when t2.income_unmask > 8500000 and t2.income_unmask<=  10500000 then '8.5-10.5JT'
    when t2.income_unmask > 10500000 and t2.income_unmask<= 13000000 then '10.5-13JT'
    when t2.income_unmask > 13000000 and t2.income_unmask<= 16000000 then '13-16JT'
    when t2.income_unmask > 16000000 and t2.income_unmask<= 20000000 then '16-20JT'
    when t2.income_unmask > 20000000 and t2.income_unmask<= 30000000 then '20-30JT'
    when t2.income_unmask > 30000000 and t2.income_unmask<= 40000000 then '30-40JT'
    when t2.income_unmask > 40000000 and t2.income_unmask<= 55000000 then '40-55JT'
    when t2.income_unmask > 55000000 and t2.income_unmask<= 70000000 then '55-70JT'
    when t2.income_unmask > 70000000 and t2.income_unmask<= 85000000 then '70-85JT'
    when t2.income_unmask > 85000000 and t2.income_unmask<= 100000000 then '85-100JT'
    when t2.income_unmask > 100000000 then '>100JT'
    else null end                 as income_range
,t2.latest_salary_month              as latest_salary_month
,t2.registration_date                as registration_date
,t2.account_status                   as account_status
,t2.latest_inquiry_date              as latest_inquiry_date
,t2.data_source_name                 as data_source_name
,t2.ktp_req                          as ktp_req
from (
select 
get_json_object(header_data, '$.PlatformUserId')                                           as platform_user_id
,get_json_object(header_data, '$.CreditUserId')                                            as credit_user_id
,case when get_json_object(resp_raw_data, '$.msg')='Sukses' then "Has Income"
     when get_json_object(resp_raw_data, '$.msg')='Data tidak ditemukan' then "No Income"
     else 'NA' end                                                                         as income_status
,get_json_object(resp_raw_data,'$.score.namaLengkap')                                      as name_check
,get_json_object(resp_raw_data,'$.score.nomorIdentitas')                                   as nik_check
,get_json_object(resp_raw_data,'$.score.jenisKelamin')                                     as gender
,get_json_object(resp_raw_data,'$.score.alamatTK')                                         as company_address
,get_json_object(resp_raw_data,'$.score.handphone')                                        as phone_no
,get_json_object(resp_raw_data,'$.score.namaPerusahaan')                                   as company_name
,get_json_object(resp_raw_data,'$.score.upahMask')                                         as income_mask
,cast(replace(replace(get_json_object(resp_raw_data,'$.score.upahMask'),',',''),'*','0') as bigint)   as income_unmask
,''                                                  as income_range
,get_json_object(resp_raw_data,'$.score.blthUpah')   as latest_salary_month
,get_json_object(resp_raw_data,'$.score.tglDaftar')  as registration_date
,get_json_object(resp_raw_data,'$.score.aktif')      as account_status
,format_time(create_time,upper('${region}'))         as latest_inquiry_date
,data_source_name                                    as data_source_name
,get_json_object(req_data,'$.NomorIdentitas')        as ktp_req
,row_number() over(partition by get_json_object(req_data,'$.NomorIdentitas') order by format_time(create_time,upper('${region}')) desc ) as rn 
from risk.ods__credit_risk_datafetch_${region}_db__identity_data_history_tab__df t1 
where t1.grass_date ='${grass_date}'
and t1.data_source_name = 'BPJSData'
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