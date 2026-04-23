

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,id_no                                                                                                as id_no
,id_type                                                                                              as id_type
,user_name                                                                                            as user_name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,photo_match_score                                                                                    as photo_match_score
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,id_no                                                                                                as id_no
,id_type                                                                                              as id_type
,user_name                                                                                            as user_name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,photo_match_score                                                                                    as photo_match_score
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,id_no                                                                                                as id_no
,id_type                                                                                              as id_type
,user_name                                                                                            as user_name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,photo_match_score                                                                                    as photo_match_score
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__user_identity_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.id_no') as string)                                                      as id_no
,cast(get_json_object(data,'$.id_type') as bigint)                                                    as id_type
,cast(get_json_object(data,'$.user_name') as string)                                                  as user_name
,cast(get_json_object(data,'$.birth_date') as string)                                                 as birth_date
,cast(get_json_object(data,'$.birth_place') as string)                                                as birth_place
,cast(get_json_object(data,'$.identity_photo_url') as string)                                         as identity_photo_url
,cast(get_json_object(data,'$.selfie_photo_url') as string)                                           as selfie_photo_url
,cast(get_json_object(data,'$.photo_match_score') as bigint)                                          as photo_match_score
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'user_identity_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__user_identity_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,id_no                                                                                                as id_no
,id_type                                                                                              as id_type
,user_name                                                                                            as user_name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,photo_match_score                                                                                    as photo_match_score
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;