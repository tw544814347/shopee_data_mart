
    set hive.exec.compress.intermediate=true;
    set hive.intermediate.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
    set hive.intermediate.compression.type=BLOCK;
    set hive.exec.compress.output=true;
    set mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
    set mapred.output.compression.type=BLOCK;

    set dfs.blocksize=4294967296;
    

    insert overwrite table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df__private__temp partition(grass_date = '${grass_date}')
    select
    id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info
,notes                                                                                                as notes

    ,_event
    from(
        select 
        id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info
,notes                                                                                                as notes

        ,_event
        ,row_number() over(partition by platform_user_id,app_id,platform_type,sub_biz_type order by update_time desc) rn
        from (
            select 
             id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info
,notes                                                                                                as notes

             ,_event
            from risk.ods__cf_risk_underwriting_id_db__limit_rate_tab__df__private
            where grass_date ='${grass_date}'
            and app_id in(1,6,9)
            union all 
            select 
             id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info
,notes                                                                                                as notes

             ,_event
            from risk.ods__ldn_risk_underwriting_id_db__limit_rate_tab__df__private
            where grass_date ='${grass_date}'
            and app_id in(2,3,4,5,7,8)
            
    union all 
    select 
    id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info
,notes                                                                                                as notes

     ,_event
    from risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df__private
    where grass_date ='${grass_date}'
    
        ) a 
    ) a 
    where rn =1
    ;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df__private;

refresh table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df__private;

    