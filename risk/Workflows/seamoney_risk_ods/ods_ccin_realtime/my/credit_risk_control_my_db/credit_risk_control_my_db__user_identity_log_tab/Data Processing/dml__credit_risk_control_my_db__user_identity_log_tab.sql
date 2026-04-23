

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,id_no                                                                                                as id_no
,name                                                                                                 as name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,name_match                                                                                           as name_match
,birth_date_match                                                                                     as birth_date_match
,birth_place_match                                                                                    as birth_place_match
,rsp_address                                                                                          as rsp_address
,selfie_photo_match_score                                                                             as selfie_photo_match_score
,rsp_code                                                                                             as rsp_code
,errors                                                                                               as errors
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_time                                                                                             as req_time
,req_status                                                                                           as req_status
,req_channel                                                                                          as req_channel
,asli_version                                                                                         as asli_version
 
,_event
 from(
    select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,id_no                                                                                                as id_no
,name                                                                                                 as name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,name_match                                                                                           as name_match
,birth_date_match                                                                                     as birth_date_match
,birth_place_match                                                                                    as birth_place_match
,rsp_address                                                                                          as rsp_address
,selfie_photo_match_score                                                                             as selfie_photo_match_score
,rsp_code                                                                                             as rsp_code
,errors                                                                                               as errors
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_time                                                                                             as req_time
,req_status                                                                                           as req_status
,req_channel                                                                                          as req_channel
,asli_version                                                                                         as asli_version
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,id_no                                                                                                as id_no
,name                                                                                                 as name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,name_match                                                                                           as name_match
,birth_date_match                                                                                     as birth_date_match
,birth_place_match                                                                                    as birth_place_match
,rsp_address                                                                                          as rsp_address
,selfie_photo_match_score                                                                             as selfie_photo_match_score
,rsp_code                                                                                             as rsp_code
,errors                                                                                               as errors
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_time                                                                                             as req_time
,req_status                                                                                           as req_status
,req_channel                                                                                          as req_channel
,asli_version                                                                                         as asli_version
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__user_identity_log_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.id_no') as string)                                                      as id_no
,cast(get_json_object(data,'$.name') as string)                                                       as name
,cast(get_json_object(data,'$.birth_date') as string)                                                 as birth_date
,cast(get_json_object(data,'$.birth_place') as string)                                                as birth_place
,cast(get_json_object(data,'$.identity_photo_url') as string)                                         as identity_photo_url
,cast(get_json_object(data,'$.selfie_photo_url') as string)                                           as selfie_photo_url
,cast(get_json_object(data,'$.name_match') as bigint)                                                 as name_match
,cast(get_json_object(data,'$.birth_date_match') as bigint)                                           as birth_date_match
,cast(get_json_object(data,'$.birth_place_match') as bigint)                                          as birth_place_match
,cast(get_json_object(data,'$.rsp_address') as string)                                                as rsp_address
,cast(get_json_object(data,'$.selfie_photo_match_score') as bigint)                                   as selfie_photo_match_score
,cast(get_json_object(data,'$.rsp_code') as bigint)                                                   as rsp_code
,cast(get_json_object(data,'$.errors') as string)                                                     as errors
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.req_time') as bigint)                                                   as req_time
,cast(get_json_object(data,'$.req_status') as bigint)                                                 as req_status
,cast(get_json_object(data,'$.req_channel') as string)                                                as req_channel
,cast(get_json_object(data,'$.asli_version') as string)                                               as asli_version
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'user_identity_log_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__user_identity_log_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,id_no                                                                                                as id_no
,name                                                                                                 as name
,birth_date                                                                                           as birth_date
,birth_place                                                                                          as birth_place
,identity_photo_url                                                                                   as identity_photo_url
,selfie_photo_url                                                                                     as selfie_photo_url
,name_match                                                                                           as name_match
,birth_date_match                                                                                     as birth_date_match
,birth_place_match                                                                                    as birth_place_match
,rsp_address                                                                                          as rsp_address
,selfie_photo_match_score                                                                             as selfie_photo_match_score
,rsp_code                                                                                             as rsp_code
,errors                                                                                               as errors
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_time                                                                                             as req_time
,req_status                                                                                           as req_status
,req_channel                                                                                          as req_channel
,asli_version                                                                                         as asli_version
 
 ,_event
 ;