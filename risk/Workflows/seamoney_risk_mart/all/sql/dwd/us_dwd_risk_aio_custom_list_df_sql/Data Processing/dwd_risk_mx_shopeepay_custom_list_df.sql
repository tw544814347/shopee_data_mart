--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-19
-- Theme Domain：       costom_list
-- Description:         策略名单同步到holmes后写入db对应的表
--                      涉及名单
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_email_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_fbaccount_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_id_no_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_ip_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_kredit_account_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_phone_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_shopee_account_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_tddf_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_uname_tab__df
-- risk.ods__${biz_db}_risk_control_${region}_db__custom_list_rare_type_tab__df
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-11-05 新增字段 de_table_config,screening_switch; jira https://jira.shopee.io/browse/SPSK-184747
-- update by wei.tao@shopee.com 20250701 de_table_config 置为 null
--********************************************************************--


ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
-- add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dwd_risk_${region}_${biz_db}_custom_list_df partition(grass_date='${grass_date}')
select 
t1.id                    as id
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
,t1.create_time          as create_time           
,t1.update_time          as update_time           
,t1.expire_time          as expire_time     
,t2.screening_switch     as screening_switch
,t2.de_table_config      as de_table_config      
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_email_tab__df 
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_fbaccount_tab__df
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_id_no_tab__df
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_ip_tab__df 
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_kredit_account_tab__df
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_phone_tab__df
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_shopee_account_tab__df 
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_tddf_tab__df
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_uname_tab__df 
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_device_id_tab__df 
    where grass_date ='${grass_date}'
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
    ,format_time(create_time,upper('${region}'))    as create_time
    ,format_time(update_time,upper('${region}'))    as update_time
    ,format_time(expire_time,upper('${region}'))    as expire_time
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_rare_type_tab__df t1 
    left join (
        select 
        dict_value
        ,dict_name 
        from risk.ods__${biz_db}_risk_control_${region}_db__dict_tab__df 
        where grass_date='${grass_date}'
        and parent_dict_key='dataType' 
        group by dict_value
        ,dict_name 
    ) t2 on t1.data_type = t2.dict_value
    where t1.grass_date ='${grass_date}'
) t1 left join (
    select 
    id                  as custom_list_id
    ,list_name          as custom_list_name
    ,de_table_name      as de_table_name
    ,status             as list_status
    ,list_source        as list_source
    ,screening_switch   as screening_switch
    ,null               as de_table_config
    from risk.ods__${biz_db}_risk_control_${region}_db__custom_list_tab__df
    where grass_date ='${grass_date}'
) t2 on t1.custom_list_id = t2.custom_list_id
;