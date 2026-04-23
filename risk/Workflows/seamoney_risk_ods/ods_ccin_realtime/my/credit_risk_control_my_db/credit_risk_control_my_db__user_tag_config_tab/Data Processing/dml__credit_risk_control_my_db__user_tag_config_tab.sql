

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,tag_name                                                                                             as tag_name
,tag_type                                                                                             as tag_type
,operator                                                                                             as operator
,tag_desc                                                                                             as tag_desc
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sis_field                                                                                            as sis_field
,is_active                                                                                            as is_active
,default_value                                                                                        as default_value
,is_delete                                                                                            as is_delete
,scene_ids                                                                                            as scene_ids
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,tag_name                                                                                             as tag_name
,tag_type                                                                                             as tag_type
,operator                                                                                             as operator
,tag_desc                                                                                             as tag_desc
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sis_field                                                                                            as sis_field
,is_active                                                                                            as is_active
,default_value                                                                                        as default_value
,is_delete                                                                                            as is_delete
,scene_ids                                                                                            as scene_ids
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,tag_name                                                                                             as tag_name
,tag_type                                                                                             as tag_type
,operator                                                                                             as operator
,tag_desc                                                                                             as tag_desc
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sis_field                                                                                            as sis_field
,is_active                                                                                            as is_active
,default_value                                                                                        as default_value
,is_delete                                                                                            as is_delete
,scene_ids                                                                                            as scene_ids
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__user_tag_config_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.tag_name') as string)                                                   as tag_name
,cast(get_json_object(data,'$.tag_type') as bigint)                                                   as tag_type
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.tag_desc') as string)                                                   as tag_desc
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.sis_field') as string)                                                  as sis_field
,cast(get_json_object(data,'$.is_active') as bigint)                                                  as is_active
,cast(get_json_object(data,'$.default_value') as string)                                              as default_value
,cast(get_json_object(data,'$.is_delete') as bigint)                                                  as is_delete
,cast(get_json_object(data,'$.scene_ids') as string)                                                  as scene_ids
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'user_tag_config_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__user_tag_config_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,tag_name                                                                                             as tag_name
,tag_type                                                                                             as tag_type
,operator                                                                                             as operator
,tag_desc                                                                                             as tag_desc
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sis_field                                                                                            as sis_field
,is_active                                                                                            as is_active
,default_value                                                                                        as default_value
,is_delete                                                                                            as is_delete
,scene_ids                                                                                            as scene_ids
 
 ,_event
 ;