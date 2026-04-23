--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-09
-- Theme Domain：       外部数据 asd npwp
-- Description:         对dwd表取按照ktp取唯一,并且将platform_user_id/credit_user_id 加上兜底逻辑(https://jira.shopee.io/browse/SPFDT-42867)
-- Data Granularity:    
-- 变更历史：
--********************************************************************--

insert overwrite table risk.ads_risk_${region}_uw_user_npwp_df partition(grass_date = '${grass_date}')
select
t11.tax_status                  
,t11.platform_user_id         
,t11.credit_user_id              
,t11.id_card_no                 
,t11.tax_taxpayer_status        
,t11.if_profile_match           
,t11.tax_taxpayer_id            
,t11.tax_result                 
,t11.tax_result_code            
,t11.latest_inquiry_date        
,t11.data_source_name           
,t11.ktp_req
from (
    select   
    t1.tax_status                  
    ,case when length(t1.platform_user_id) <=0 then t2.platform_user_id
        else t1.platform_user_id end                as platform_user_id         
    ,case when length(t1.credit_user_id) <=0 then t2.credit_user_id
        else t1.credit_user_id end                  as credit_user_id              
    ,t1.id_card_no                 
    ,t1.tax_taxpayer_status        
    ,t1.if_profile_match           
    ,t1.tax_taxpayer_id            
    ,t1.tax_result                 
    ,t1.tax_result_code            
    ,t1.latest_inquiry_date        
    ,t1.data_source_name           
    ,t1.ktp_req        
    ,row_number() over(partition by t1.ktp_req order by t1.latest_inquiry_date desc ) as rn 
    from risk.dwd_risk_${region}_uw_user_npwp_df t1 
    left join (
        select  
        id_card_no
        ,credit_user_id
        ,platform_user_id_1 as platform_user_id
        FROM credit_uc.dim_${region}_uc_ic_to_uid_df
        where grass_date ='${grass_date}'
    ) t2  on t1.ktp_req = t2.id_card_no
    where t1.grass_date ='${grass_date}'
) t11 
where t11.rn=1
;