--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-06
-- Theme Domain：       id_screen
-- Description:         jira： https://jira.shopee.io/browse/SPFDT-45475 prd: https://docs.google.com/spreadsheets/d/19_oUp4HrCc_pa4oc_nqDmVos7JqOEbLjQbkwzlcFdkI/edit?pli=1&gid=0#gid=0
-- Data Granularity:    
-- 变更历史：
-- https://jira.shopee.io/browse/SPFDT-50133 更换数据源 
-- 新增 mapping 关系： when tt1.product_code = '2cscore' then 5
--********************************************************************--
--drop table if exists ${SCHEMA}.dwd_credit_id_risk_screen_df;
create external table if not exists ${SCHEMA}.dwd_credit_id_risk_screen_df (
    id                                  string comment '申请单ID'
    ,apply_no                           string comment '申请单编号'
    ,platform_type                      bigint comment '平台类型ID：0-none;1-shopee;2-airpay;3-merchat'
    ,platform_type_name                 string comment '平台类型名'
    ,platform_user_id                   string comment '平台id'
    ,credit_user_id                     string comment '用户id'
    ,apply_type                         bigint comment '申请业务类型: 0-NONE; 1-ACTIVATION(激活); 2-INCREASE_LIMIT(提额); 3-UPDATE_KYC_INFO(更新kyc资料)'
    ,apply_type_name                    string comment '申请业务类型: 0-NONE; 1-ACTIVATION(激活); 2-INCREASE_LIMIT(提额); 3-UPDATE_KYC_INFO(更新kyc资料)'
    ,apply_status                       bigint comment '申请单状态，4=通过，5=拒绝，apply_activation_order_tab也能取到'
    ,is_apply_type_activation           bigint comment '申请类型是否是激活：1:yes,0:no'
    ,post_update_info                   string comment '更新信息'
    ,operator                           string comment 'ops操作者邮箱'
    ,create_time                        string comment '创建时间'
    ,update_time                        string comment '更新时间'
    ,audit_not_mother_name              string comment 'additionalInfo.notMotherName'
    ,audit_not_occupation               string comment 'additionalInfo.notOccupation'
    ,audit_not_company_name             string comment 'additionalInfo.notCompanyName'
    ,audit_not_risk_level               string comment 'additionalInfo.notRiskLevel'
    ,audit_not_real_human_photo         string comment 'additionalInfo.notRealHumanPhoto'
    ,audit_not_face_match               string comment 'additionalInfo.notFaceMatch'
    ,operator_start_time                string comment '派单审核开始时间'
    ,operator_end_time                  string comment '派单审核提交时间'
    ,audit_extra_info                   string comment 'BRScreenRejectType'
    ,maker_operator                     string comment 'maker审核人'
    ,maker_extra_info                   string comment 'maker审核扩展信息'
    ,maker_update_info                  string comment 'maker更新时间'
    ,maker_submit_time                  string comment 'maker审核提交时间'
    ,audit_other                        string comment '审核输出other内容'
    ,maker_audit_other                  string comment 'maker审核输出other内容'
    ,context                            string comment '工单拒绝原因'
    ,reject_code                        string comment '工单拒绝码'
    ,screen_platform                    bigint comment '0=UC 1=Risk'
    ,submission_time                    string comment 'submission_time'
    ,screen_completed_time              string comment '审核完成时间'
    ,audit_not_ektp_number_not_clear    string comment 'additionalInfo.notEktpOrNumberNotClear'
    ,audit_ic_screenshot_or_copy       string comment 'additionalInfo.icScreenshotOrCopy'
    ,audit_not_main_information         string comment 'additionalInfo.notMainInformation'
    ,kyc_freeze_reasons                 string comment '冻结原因-kyc'
    ,fraud_freeze_reasons               string comment '冻结原因-欺诈'
    ,is_skip_idwall                     bigint comment '是否跳过idwall'
    ,operator_map_no                    string comment '审核人map_no'
    ,broken_ektp_name                   bigint comment '审核输出'
    ,audit_not_allow_age                string comment 'additionalInfo.notAllowAge'
    ,not_nik_clear                      string comment 'additionalInfo.notIdCardNoClear'
    ,not_ektp                           string comment 'additionalInfo.notEktp'
    ,broken_ektp_nik                    string comment 'additionalInfo.notEktp=false&&additionalInfo.brokenNik=true'
    ,broken_ektp_photo                  string comment 'additionalInfo.notEktp=false&&additionalInfo.brokenPhoto=true'
    ,user_label                         string comment ''
    ,screen_type                        string comment 'screen_type'
) partitioned by (
    product_id  bigint
    ,grass_date string comment 'YYYY-MM-dd'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dwd_risk_credit_screen_df/grass_region=ID'
;
--msck repair table ${SCHEMA}.dwd_credit_id_risk_screen_df;

create
or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

create
or replace temporary function json_to_array as 'com.shopee.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar'
;

insert overwrite table ${SCHEMA}.dwd_credit_id_risk_screen_df partition (product_id, grass_date)

select
    t1.id                                 
    ,t1.apply_no                          
    ,t1.platform_type                     
    ,e4.name as platform_type_name                
    ,t1.platform_user_id                  
    ,t1.credit_user_id                    
    ,t1.apply_type                        
    ,e1.name as apply_type_name                   
    ,t1.apply_status                      
    ,if (t1.apply_type = 1, 1, 0) as is_apply_type_activation          
    ,t1.post_update_info                  
    ,t1.operator                          
    ,t1.create_time                       
    ,t1.update_time        
    ,t1.audit_not_mother_name  
    ,t1.audit_not_occupation   
    ,t1.audit_not_company_name                
    ,t1.audit_not_risk_level              
    ,t1.audit_not_real_human_photo        
    ,t1.audit_not_face_match              
    ,t1.operator_start_time               
    ,t1.operator_end_time                 
    ,t1.audit_extra_info                  
    ,t1.maker_operator                    
    ,t1.maker_extra_info                  
    ,t1.maker_update_info                 
    ,t1.maker_submit_time                 
    ,t1.audit_other                       
    ,t1.maker_audit_other                 
    ,t1.context                           
    ,t1.reject_code                       
    ,t1.screen_platform                   
    ,t1.submission_time                   
    ,t1.screen_completed_time             
    ,t1.audit_not_ektp_number_not_clear   
    ,t1.audit_ic_screenshot_or_copy      
    ,t1.audit_not_main_information        
    ,t1.kyc_freeze_reasons                
    ,t1.fraud_freeze_reasons              
    ,t1.is_skip_idwall                    
    ,t1.operator_map_no                   
    ,t1.broken_ektp_name                  
    ,t1.audit_not_allow_age               
    ,t1.not_nik_clear                     
    ,t1.not_ektp                          
    ,t1.broken_ektp_nik                   
    ,t1.broken_ektp_photo                 
    ,t1.user_label
    ,t1.screen_type                        
    ,t1.biz_type         as product_id
    ,'${grass_date}'     as grass_date
from
    (
        select
            id                                  
            ,apply_no                           
            ,platform_type                                     
            ,platform_user_id                   
            ,user_id                        as credit_user_id                     
            ,apply_type
            ,apply_status                                 
            ,post_update_info                   
            ,operator                           
            ,format_time(create_time, 'ID') as create_time
            ,format_time(update_time, 'ID') as update_time                       
            ,audit_not_mother_name          as audit_not_mother_name      
            ,audit_not_occupation           as audit_not_occupation       
            ,audit_not_company_name         as audit_not_company_name     
            ,audit_not_risk_level           as audit_not_risk_level        
            ,audit_not_real_human_photo     as audit_not_real_human_photo   
            ,audit_not_face_match           as audit_not_face_match                   
            ,format_time(operator_start_time, 'ID') as operator_start_time
            ,format_time(operator_end_time, 'ID')   as operator_end_time                
            ,audit_extra_info                   
            ,maker_operator                     
            ,maker_extra_info                   
            ,maker_update_info                  
            ,maker_submit_time                  
            ,audit_other                        
            ,maker_audit_other                  
            ,context                            
            ,null as reject_code                        
            ,null as screen_platform                    
            ,format_time(submission_time, 'ID') as  submission_time                    
            ,format_time(screen_completed_time, 'ID') as screen_completed_time              
            ,audit_not_ektp_number_not_clear    
            ,audit_ic_screenshot_or_copy       
            ,audit_not_main_information         
            ,kyc_freeze_reasons                 
            ,fraud_freeze_reasons               
            ,is_skip_idwall                     
            ,operator_map_no                    
            ,broken_ektp_name                   
            ,audit_not_allow_age                
            ,not_nik_clear                      
            ,not_ektp                           
            ,broken_ektp_nik                    
            ,broken_ektp_photo  
            ,user_label
            ,null as screen_type
            ,biz_type
        from credit.ods__credit_usercenter_apply_id_db__apply_activation_order_audit_tab__df 
        where grass_date ='${grass_date}'
        union all
        select
            tt1.id                                  
            ,tt1.req_no                        as apply_no                           
            ,tt1.platform_type                                     
            ,tt1.platform_user_id                   
            ,tt1.credit_user_id                     
            ,case
                when tt1.apply_type = 'Activation' then 1
                when tt1.apply_type = 'UpdateInfo' then 3
            end as apply_type
            ,tt1.screen_status                  as apply_status                                 
            ,tt3.content                        as post_update_info                   
            ,tt3.operator                       as operator                    
            ,format_time(tt1.create_time, 'ID') as create_time
            ,format_time(tt1.update_time, 'ID') as update_time                       
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notMotherName')     as audit_not_mother_name      
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notOccupation')     as audit_not_occupation       
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notCompanyName')    as audit_not_company_name     
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notRiskLevel')      as audit_not_risk_level        
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notRealHumanPhoto') as audit_not_real_human_photo   
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notFaceMatch')      as audit_not_face_match                   
            ,format_time(tt1.maker_start_time, 'ID')                               as operator_start_time
            ,format_time(tt1.maker_submit_time, 'ID')                              as operator_end_time                 
            ,null                                                                  as audit_extra_info                   
            ,tt1.maker                                                             as maker_operator                     
            ,null                                                                  as maker_extra_info                   
            ,null                                                                  as maker_update_info                  
            ,format_time(tt1.maker_submit_time, 'ID')                              as maker_submit_time                  
            ,null                                                                  as audit_other                        
            ,null                                                                  as maker_audit_other                  
            ,null                                                                  as context                            
            ,tt1.reject_code                                                       as reject_code                        
            ,null                                                                  as screen_platform                    
            ,format_time(tt1.create_time, 'ID')                                    as submission_time                    
            ,format_time(tt1.maker_submit_time, 'ID')                              as screen_completed_time              
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notEktpOrNumberNotClear') as audit_not_ektp_number_not_clear    
            ,get_json_object(tt1.screen_info,'$.additionalInfo.icScreenshotOrCopy') as audit_ic_screenshot_or_copy       
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notMainInformation') as audit_not_main_information         
            ,null as kyc_freeze_reasons                 
            ,null as fraud_freeze_reasons               
            ,null as is_skip_idwall                     
            ,tt1.maker_map_no as operator_map_no                    
            ,case when lower(get_json_object(tt1.screen_info,'$.additionalInfo.NotEktp')) ='false' and lower(get_json_object(tt1.screen_info,'$.additionalInfo.BrokenEktpNik')) ='true' then 1 else 0 end broken_ektp_name                   
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notAllowAge')      as audit_not_allow_age                
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notIdCardNoClear') as not_nik_clear                      
            ,get_json_object(tt1.screen_info,'$.additionalInfo.notEktp')          as not_ektp                           
            ,case when lower(get_json_object(tt1.screen_info,'$.additionalInfo.NotEktp')) ='false' and lower(get_json_object(tt1.screen_info,'$.additionalInfo.BrokenEktpName')) ='true' then 1 else 0 end as abroken_ektp_nik                    
            ,case when lower(get_json_object(tt1.screen_info,'$.additionalInfo.NotEktp')) ='false' and lower(get_json_object(tt1.screen_info,'$.additionalInfo.BrokenEktpPhoto')) ='true' then 1 else 0 end as broken_ektp_photo 
            ,null as user_label 
            ,tt1.screen_type
            ,cast(e.biz_type as bigint) as biz_type
        from
            (
                select
                    *
                from risk.ods__credit_risk_control_id_ldn_db__screen_tab__df
                where grass_date = '${grass_date}'
                union all 
                select
                    *
                from risk.ods__credit_risk_control_id_cf_db__screen_tab__df
                where grass_date = '${grass_date}'
            ) tt1
            left join (
                select 
                    risk_kafka_app_id
                    ,biz_type
                from risk.dim_risk_prod_enum_df
            ) e
            on tt1.product_code = e.risk_kafka_app_id
            left join (
                select 
                screen_id 
                ,operator
                ,content 
                from (
                    select 
                    screen_id 
                    ,operator
                    ,content 
                    ,row_number() over(partition by screen_id order by update_time desc ) rn 
                    from (
                        select 
                        ticket_id as screen_id
                        ,operator
                        ,content
                        ,update_time
                        from risk.ods__credit_risk_control_id_ldn_db__ticket_ops_tab__df
                        where grass_date ='${grass_date}'
                        and operation_type in (3, 4)
                        union all 
                        select 
                        ticket_id as screen_id
                        ,operator
                        ,content
                        ,update_time
                        from risk.ods__credit_risk_control_id_cf_db__ticket_ops_tab__df
                        where grass_date ='${grass_date}'
                        and operation_type in (3, 4)
                    ) t2 
                ) t22
                where t22.rn =1 
            ) tt3 on tt1.screen_id = tt3.screen_id
    ) t1
    left join (
        select
            name
            ,value
        from risk.dim_risk_uc_enum_df
        where enum_name = 'apply_type'
    ) e1 on t1.apply_type = e1.value
    left join (
        select
            name
            ,value
        from risk.dim_risk_uc_enum_df
        where enum_name = 'platform_type'
    ) e4 on t1.platform_type = e4.value
;



