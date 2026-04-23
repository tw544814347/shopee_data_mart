--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-09
-- Theme Domain：       外部数据 tongdun
-- Description:         外部数据 tongdun
-- Data Granularity:    
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-07-09 https://jira.shopee.io/browse/SPFDT-41811  需要用history表，非history表会删除数据
-- #!!!!排序规则
-- 第1步排序
-- 选用户最新1个create_date的数据
-- select the latest inquiry date record from Tongdun & BPJS
-- 第2步排序 如果2个外数同1天都有就先选BPJS
-- -- 给这2个外数打上flag_rank
-- flag_rank = 1 -- BPJS
-- flag_rank = 2 -- TONGDUN
-- -- 优先选BPJS, 然后选Tongdun
--********************************************************************--

insert overwrite table risk.dws_risk_${region}_uw_user_bpjs_tongdun_income_conso_df partition(grass_date = '${grass_date}')
select
    t4.platform_user_id       
    ,t4.credit_user_id        
    ,t4.income_status         
    ,t4.company_name          
    ,t4.company_address       
    ,t4.registration_date     
    ,t4.latest_salary_month   
    ,t4.salary_range           
    ,t4.salary_unmask          
    ,t4.latest_inquiry_date   
    ,t4.data_source_name 
    ,t4.ktp_req
from(
    select 
        t3.platform_user_id       
        ,t3.credit_user_id        
        ,t3.income_status         
        ,t3.company_name          
        ,t3.company_address       
        ,t3.registration_date     
        ,t3.latest_salary_month   
        ,t3.salary_range           
        ,t3.salary_unmask          
        ,t3.latest_inquiry_date   
        ,t3.data_source_name
        ,t3.ktp_req
        ,row_number() over(partition by t3.ktp_req order by t3.flag_rank asc) rn
    from (
        select 
        t2.platform_user_id       
        ,t2.credit_user_id        
        ,t2.income_status         
        ,t2.company_name          
        ,t2.company_address       
        ,t2.registration_date     
        ,t2.latest_salary_month   
        ,t2.salary_range           
        ,t2.salary_unmask          
        ,t2.latest_inquiry_date   
        ,t2.data_source_name
        ,t2.ktp_req
        ,t2.flag_rank
        ,rank() over(partition by t2.ktp_req order by to_date(latest_inquiry_date) desc ) rn 
        from (
        select 
        t1.platform_user_id       
        ,t1.credit_user_id        
        ,t1.income_status         
        ,t1.company_name          
        ,t1.company_address       
        ,t1.registration_date     
        ,t1.latest_salary_month   
        ,t1.income_range        as salary_range          
        ,t1.income_unmask       as salary_unmask         
        ,t1.latest_inquiry_date   
        ,t1.data_source_name   
        ,t1.ktp_req
        ,1                      as flag_rank        
        from risk.dwd_risk_${region}_uw_user_bpjs_df t1 
        where grass_date ='${grass_date}'
        union all 
        select 
        t1.platform_user_id       
        ,credit_user_id        
        ,t1.income_status         
        ,t1.company_name          
        ,t1.company_address       
        ,t1.registration_date     
        ,t1.latest_salary_month   
        ,t1.salary_range          
        ,null as salary_unmask         
        ,t1.latest_inquiry_date   
        ,t1.data_source_name 
        ,t1.ktp_req
        ,2 as flag_rank  
        from risk.dwd_risk_${region}_uw_user_tongdun_df t1 
        where grass_date ='${grass_date}'
        ) t2 
    ) t3
    where t3.rn=1
) t4 
where t4.rn=1

;