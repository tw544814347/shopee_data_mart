

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,customer_id                                                                                          as customer_id
,company_name                                                                                         as company_name
,tax_no                                                                                               as tax_no
,business_email                                                                                       as business_email
,basic_info                                                                                           as basic_info
,legal_person                                                                                         as legal_person
,picture_info                                                                                         as picture_info
,address                                                                                              as address
,ip_whitelist                                                                                         as ip_whitelist
,customer_status                                                                                      as customer_status
,create_by                                                                                            as create_by
,create_time                                                                                          as create_time
,update_by                                                                                            as update_by
,update_time                                                                                          as update_time
,company_mobile_no                                                                                    as company_mobile_no
,category                                                                                             as category
 
,_event
 from(
    select 
 id                                                                                                   as id
,customer_id                                                                                          as customer_id
,company_name                                                                                         as company_name
,tax_no                                                                                               as tax_no
,business_email                                                                                       as business_email
,basic_info                                                                                           as basic_info
,legal_person                                                                                         as legal_person
,picture_info                                                                                         as picture_info
,address                                                                                              as address
,ip_whitelist                                                                                         as ip_whitelist
,customer_status                                                                                      as customer_status
,create_by                                                                                            as create_by
,create_time                                                                                          as create_time
,update_by                                                                                            as update_by
,update_time                                                                                          as update_time
,company_mobile_no                                                                                    as company_mobile_no
,category                                                                                             as category
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,customer_id                                                                                          as customer_id
,company_name                                                                                         as company_name
,tax_no                                                                                               as tax_no
,business_email                                                                                       as business_email
,basic_info                                                                                           as basic_info
,legal_person                                                                                         as legal_person
,picture_info                                                                                         as picture_info
,address                                                                                              as address
,ip_whitelist                                                                                         as ip_whitelist
,customer_status                                                                                      as customer_status
,create_by                                                                                            as create_by
,create_time                                                                                          as create_time
,update_by                                                                                            as update_by
,update_time                                                                                          as update_time
,company_mobile_no                                                                                    as company_mobile_no
,category                                                                                             as category
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__scoring_open_platform_id_db__customer_info_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.customer_id') as string)                                                as customer_id
,cast(get_json_object(data,'$.company_name') as string)                                               as company_name
,cast(get_json_object(data,'$.tax_no') as string)                                                     as tax_no
,cast(get_json_object(data,'$.business_email') as string)                                             as business_email
,cast(get_json_object(data,'$.basic_info') as string)                                                 as basic_info
,cast(get_json_object(data,'$.legal_person') as string)                                               as legal_person
,cast(get_json_object(data,'$.picture_info') as string)                                               as picture_info
,cast(get_json_object(data,'$.address') as string)                                                    as address
,cast(get_json_object(data,'$.ip_whitelist') as string)                                               as ip_whitelist
,cast(get_json_object(data,'$.customer_status') as bigint)                                            as customer_status
,cast(get_json_object(data,'$.create_by') as string)                                                  as create_by
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_by') as string)                                                  as update_by
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.company_mobile_no') as string)                                          as company_mobile_no
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'scoring_open_platform_id_db' and base_table= 'customer_info_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__scoring_open_platform_id_db__customer_info_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,customer_id                                                                                          as customer_id
,company_name                                                                                         as company_name
,tax_no                                                                                               as tax_no
,business_email                                                                                       as business_email
,basic_info                                                                                           as basic_info
,legal_person                                                                                         as legal_person
,picture_info                                                                                         as picture_info
,address                                                                                              as address
,ip_whitelist                                                                                         as ip_whitelist
,customer_status                                                                                      as customer_status
,create_by                                                                                            as create_by
,create_time                                                                                          as create_time
,update_by                                                                                            as update_by
,update_time                                                                                          as update_time
,company_mobile_no                                                                                    as company_mobile_no
,category                                                                                             as category
 
 ,_event
 ;