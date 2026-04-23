--drop view if exists ${SCHEMA}.risk_${region}_${biz_name}_holmes_list_full_table_to_s3_pm_view;
drop table if exists ${SCHEMA}.risk_${region}_${biz_name}_holmes_list_full_table_to_s3_pm_view;
create table IF NOT EXISTS ${SCHEMA}.risk_${region}_${biz_name}_holmes_list_full_table_to_s3_pm_view
as 
    
    select 

    '${grass_date}' as grass_date
    ,t1.id                    as id
    ,t1.data                 as data
    ,t1.data_type            as data_type    
    ,t1.data_type_name       as data_type_name     
    ,t1.custom_list_id       as custom_list_id     
    ,t2.custom_list_name     as custom_list_name   
    ,t2.de_table_name        as de_table_name  
    ,t2.list_source          as list_source           
    ,t2.list_status          as list_status           
    ,t1.data_source          as data_source           
    ,t1.action_detail        as action_detail         
    ,t1.action_fail_detail   as action_fail_detail    
    ,t1.action_status        as action_status         
    ,t1.remark               as remark                
    ,t1.status               as status                
    ,t1.description          as description           
    ,t1.creator              as creator               
    
    ,t2.screening_switch     as screening_switch
          
    from (
        select 
        id                                             as id
        ,email_addr                                     as data
        ,16                                             as data_type
        ,'email'                                        as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_email_tab__spark 
       
        union all 
        select
        id                                             as id
        ,fb_account                                     as data
        ,15                                             as data_type
        ,'facebookAccount'                              as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_fbaccount_tab__spark
       
        union all 
        select
        id                                             as id
        ,id_no                                          as data
        ,3                                              as data_type
        ,'IDNo'                                         as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_id_no_tab__spark
        
        union all 
        select
        id                                             as id
        ,ip                                             as data
        ,7                                              as data_type
        ,'IP'                                           as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_ip_tab__spark 
        
        union all 
        select
        id                                             as id
        ,kredit_account                                 as data
        ,2                                              as data_type
        ,'shopeeKreditAccount'                          as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_kredit_account_tab__spark
        
        union all 
        select
        id                                             as id
        ,phone_no                                       as data
        ,4                                              as data_type
        ,'phoneNo'                                      as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_phone_tab__spark
        
        union all 
        select
        id                                             as id
        ,shopee_account                                 as data
        ,1                                              as data_type
        ,'shopeeAccount'                                as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_shopee_account_tab__spark 
        
        union all 
        select
        id                                             as id
        ,tddf                                           as data
        ,14                                             as data_type
        ,'tongdundeviceFingerprint'                     as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_tddf_tab__spark
        
        union all 
        select
        id                                             as id
        ,uname                                          as data
        ,17                                             as data_type
        ,'userName'                                     as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_uname_tab__spark 
        
        union all 
        select
        id                                             as id
        ,device_id                                      as data
        ,5                                              as data_type
        ,'deviceId'                                     as data_type_name
        ,custom_list_id                                 as custom_list_id
        ,data_source                                    as data_source
        ,action_detail                                  as action_detail
        ,action_fail_detail                             as action_fail_detail
        ,action_status                                  as action_status
        ,remark                                         as remark
        ,status                                         as status
        ,description                                    as description
        ,creator                                        as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_device_id_tab__spark 
        
        union all 
        select
        t1.id                                          as id
        ,t1.data                                        as data
        ,t1.data_type                                   as data_type
        ,t2.dict_name                                   as data_type_name
        ,t1.custom_list_id                              as custom_list_id
        ,t1.data_source                                 as data_source
        ,t1.action_detail                               as action_detail
        ,t1.action_fail_detail                          as action_fail_detail
        ,t1.action_status                               as action_status
        ,t1.remark                                      as remark
        ,t1.status                                      as status
        ,t1.description                                 as description
        ,t1.creator                                     as creator
        
        
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_rare_type_tab__spark t1 
        left join (
            select 
            dict_value
            ,dict_name 
            from risk.view__${biz_db}_risk_control_${region}_db__dict_tab__spark 
            
            where parent_dict_key='dataType' 
            group by dict_value
            ,dict_name 
        ) t2 on t1.data_type = t2.dict_value
        
    ) t1 left join (
        select 
        id                  as custom_list_id
        ,list_name          as custom_list_name
        ,de_table_name      as de_table_name
        ,status             as list_status
        ,list_source        as list_source
        ,screening_switch   as screening_switch
        
        from risk.view__${biz_db}_risk_control_${region}_db__custom_list_tab__spark
 
    ) t2 on t1.custom_list_id = t2.custom_list_id

    