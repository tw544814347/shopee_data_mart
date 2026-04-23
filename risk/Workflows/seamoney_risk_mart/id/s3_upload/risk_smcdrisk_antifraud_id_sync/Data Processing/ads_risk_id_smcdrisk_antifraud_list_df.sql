--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-20
-- Theme Domain：       list
-- Description:         smcdrisk_antifraud 名单同步到s3,不需要跟其他project表有关联处理逻辑
-- Data Granularity:    
-- 变更历史：          
-- 2024-03-20 zongyi.lu 1.新增 VIDA + BPJS + NPWP https://jira.shopee.io/browse/SPFDT-34391
--********************************************************************--

-- 由于需要频繁变更字段,因此直接将ddl放在dml中便于修改
--drop table if exists ${SCHEMA}.ads_risk_id_smcdrisk_antifraud_list_df;
create external table if not exists ${SCHEMA}.ads_risk_id_smcdrisk_antifraud_list_df
(
    nik string comment 'nik'
    ,platform_user_id      string comment 'platform_user_id'
    ,handphone             string comment 'handphone'
    ,nama_lengkap          string comment 'nama_lengkap'
    ,nomor_identitas       string comment 'nomor_identitas'
    ,data_source_name      string comment 'data_source_name'
    ,credit_user_id        string comment 'credit_user_id'
    ,mobile                string comment 'mobile'
    ,email                 string comment 'email'
    ,fullname              string comment 'fullname'
    ,dob                   string comment 'dob'
    ,govid                 string comment 'govid'
    ,pob                   string comment 'pob'
    ,selfiephoto           string comment 'selfiephoto'
    ,first_activation_time string comment 'first_activation_time'
    ,product               string comment 'product'
    ,user_name             string comment 'user_name'
    ,phone_number          string comment 'phone_number'
    ,id_number             string comment 'id_number'
    ,id_type               string comment 'id_type'
    ,entity                string comment 'entity'
)
partitioned by
(
    source_table_name string comment 'source table_name '
    ,grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_smcdrisk_antifraud_list_df/grass_region=ID';
;
--msck repair table ${SCHEMA}.ads_risk_id_smcdrisk_antifraud_list_df;

insert overwrite table ${SCHEMA}.ads_risk_id_smcdrisk_antifraud_list_df partition(source_table_name,grass_date)
select 
null as nik
,t1.platform_user_id
,t1.handphone
,t1.nama_lengkap
,t1.nomor_identitas
,null as data_source_name      
,null as credit_user_id        
,null as mobile                
,null as email                 
,null as fullname              
,null as dob                   
,null as govid                 
,null as pob                   
,null as selfiephoto           
,null as first_activation_time 
,null as product  
,null as user_name   
,null as phone_number
,null as id_number   
,null as id_type             
,t1.entity
,'smcdrisk_policy.id_external_data_bpjs_batch_inquiry' as source_table_name
,'${grass_date}' as grass_date 
from smcdrisk_policy.id_external_data_bpjs_batch_inquiry t1 
where grass_date = (select max(grass_date) from smcdrisk_policy.id_external_data_bpjs_batch_inquiry)
union all 
select 
t1.nik 
,t1.platform_user_id as platform_user_id
,null as handphone
,null as nama_lengkap
,null as nomor_identitas
,null as data_source_name      
,null as credit_user_id        
,null as mobile                
,null as email                 
,null as fullname              
,null as dob                   
,null as govid                 
,null as pob                   
,null as selfiephoto           
,null as first_activation_time 
,null as product 
,null as user_name   
,null as phone_number
,null as id_number   
,null as id_type
,t1.entity
,'smcdrisk_policy.id_external_data_npwp_batch_inquiry' as source_table_name
,'${grass_date}' as grass_date 
from smcdrisk_policy.id_external_data_npwp_batch_inquiry t1 
join (
    select 
    max(grass_date) as grass_date
    from smcdrisk_policy.id_external_data_npwp_batch_inquiry
) t2 on t1.grass_date = t2.grass_date 
union all 
select 
null nik 
,t1.platform_user_id
,null as handphone
,null as nama_lengkap
,null as nomor_identitas
,t1.data_source_name      
,t1.credit_user_id        
,t1.mobile                
,t1.email                 
,t1.fullname              
,t1.dob                   
,t1.govid                 
,null as pob                   
,t1.selfiephoto           
,t1.first_activation_time 
,t1.product 
,null as user_name   
,null as phone_number
,null as id_number   
,null as id_type 
,null as entity
,'smcdbd_regfunding.id_external_data_vida_query_by_batch_funding_df' as source_table_name
,'${grass_date}' as grass_date 
from smcdbd_regfunding.id_external_data_vida_query_by_batch_funding_df t1 
join (
    select 
    max(grass_date) as grass_date
    from smcdbd_regfunding.id_external_data_vida_query_by_batch_funding_df
) t2 on t1.grass_date = t2.grass_date 
union all 
select 
null as nik
,t1.platform_user_id
,null as handphone
,null as nama_lengkap
,null as nomor_identitas
,null as data_source_name      
,null as credit_user_id        
,null as mobile                
,null as email                 
,null as fullname              
,null as dob                   
,null as govid                 
,null as pob                   
,null as selfiephoto           
,null as first_activation_time 
,null as product    
,t1.user_name    as user_name   
,t1.phone_number as phone_number
,t1.id_number    as id_number   
,t1.id_type      as id_type            
,t1.entity
,'smcdrisk_policy.id_external_data_tongdun_batch_inquiry' as source_table_name
,'${grass_date}' as grass_date 
from smcdrisk_policy.id_external_data_tongdun_batch_inquiry t1 
where grass_date = (select max(grass_date) from smcdrisk_policy.id_external_data_tongdun_batch_inquiry)
;

