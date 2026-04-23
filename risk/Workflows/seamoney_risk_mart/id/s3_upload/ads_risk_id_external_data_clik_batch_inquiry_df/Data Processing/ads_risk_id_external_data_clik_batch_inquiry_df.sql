--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2024-11-01
-- Theme Domain：      
-- Description:         [SPFDT-45650] 
-- Data Granularity:    
-- 变更历史： https://casement.scredit.io/project/78703/version?versionTab=task&versionId=7013&jiraKey=SPFDT-45650
--********************************************************************--
insert overwrite table risk.ads_risk_id_external_data_clik_batch_inquiry_df partition(grass_date='${grass_date}')
select 

    platform_user_id        --string
    ,user_name              --string
    ,cast(birth_date as string)            --string   
    ,gender                 --string 
    ,address                --string
    ,sub_district           --string
    ,district               --string 
    ,country                --string 
    ,id_card_no             --string
    ,phone_number           --string 
    -- ,grass_date
from smcdrisk_policy.id_external_data_clik_batch_inquiry
where grass_date = (select max(grass_date) from smcdrisk_policy.id_external_data_clik_batch_inquiry)
;