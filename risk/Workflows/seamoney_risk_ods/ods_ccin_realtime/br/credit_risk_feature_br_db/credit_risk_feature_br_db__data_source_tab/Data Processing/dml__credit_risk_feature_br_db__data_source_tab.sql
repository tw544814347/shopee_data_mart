



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,data_source_desc                                                                                     as data_source_desc
,row_key_format                                                                                       as row_key_format
,column_key_format                                                                                    as column_key_format
,person_in_charge                                                                                     as person_in_charge
,storage_location                                                                                     as storage_location
,related_original_data                                                                                as related_original_data
,data_source_type                                                                                     as data_source_type
,expiration_time                                                                                      as expiration_time
,store_time                                                                                           as store_time
,offline_data_refresh_time                                                                            as offline_data_refresh_time
,outer_person_in_charge                                                                               as outer_person_in_charge
,outer_interface                                                                                      as outer_interface
,outer_interface_protocol                                                                             as outer_interface_protocol
,data_structure                                                                                       as data_structure
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,usage_scene                                                                                          as usage_scene
,data_source_link                                                                                     as data_source_link
,region                                                                                               as region

,_event
 from(
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,data_source_desc                                                                                     as data_source_desc
,row_key_format                                                                                       as row_key_format
,column_key_format                                                                                    as column_key_format
,person_in_charge                                                                                     as person_in_charge
,storage_location                                                                                     as storage_location
,related_original_data                                                                                as related_original_data
,data_source_type                                                                                     as data_source_type
,expiration_time                                                                                      as expiration_time
,store_time                                                                                           as store_time
,offline_data_refresh_time                                                                            as offline_data_refresh_time
,outer_person_in_charge                                                                               as outer_person_in_charge
,outer_interface                                                                                      as outer_interface
,outer_interface_protocol                                                                             as outer_interface_protocol
,data_structure                                                                                       as data_structure
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,usage_scene                                                                                          as usage_scene
,data_source_link                                                                                     as data_source_link
,region                                                                                               as region

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,data_source_desc                                                                                     as data_source_desc
,row_key_format                                                                                       as row_key_format
,column_key_format                                                                                    as column_key_format
,person_in_charge                                                                                     as person_in_charge
,storage_location                                                                                     as storage_location
,related_original_data                                                                                as related_original_data
,data_source_type                                                                                     as data_source_type
,expiration_time                                                                                      as expiration_time
,store_time                                                                                           as store_time
,offline_data_refresh_time                                                                            as offline_data_refresh_time
,outer_person_in_charge                                                                               as outer_person_in_charge
,outer_interface                                                                                      as outer_interface
,outer_interface_protocol                                                                             as outer_interface_protocol
,data_structure                                                                                       as data_structure
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,usage_scene                                                                                          as usage_scene
,data_source_link                                                                                     as data_source_link
,region                                                                                               as region

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_feature_br_db__data_source_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name 
,cast(get_json_object(data,'$.data_source_desc') as string)                                           as data_source_desc 
,cast(get_json_object(data,'$.row_key_format') as string)                                             as row_key_format 
,cast(get_json_object(data,'$.column_key_format') as string)                                          as column_key_format 
,cast(get_json_object(data,'$.person_in_charge') as string)                                           as person_in_charge 
,cast(get_json_object(data,'$.storage_location') as string)                                           as storage_location 
,cast(get_json_object(data,'$.related_original_data') as string)                                      as related_original_data 
,cast(get_json_object(data,'$.data_source_type') as bigint)                                           as data_source_type 
,cast(get_json_object(data,'$.expiration_time') as bigint)                                            as expiration_time 
,cast(get_json_object(data,'$.store_time') as bigint)                                                 as store_time 
,cast(get_json_object(data,'$.offline_data_refresh_time') as bigint)                                  as offline_data_refresh_time 
,cast(get_json_object(data,'$.outer_person_in_charge') as string)                                     as outer_person_in_charge 
,cast(get_json_object(data,'$.outer_interface') as string)                                            as outer_interface 
,cast(get_json_object(data,'$.outer_interface_protocol') as string)                                   as outer_interface_protocol 
,cast(get_json_object(data,'$.data_structure') as bigint)                                             as data_structure 
,cast(get_json_object(data,'$.create_time') as decimal(20,0))                                         as create_time 
,cast(get_json_object(data,'$.update_time') as decimal(20,0))                                         as update_time 
,cast(get_json_object(data,'$.usage_scene') as bigint)                                                as usage_scene 
,cast(get_json_object(data,'$.data_source_link') as string)                                           as data_source_link 
,cast(get_json_object(data,'$.region') as string)                                                     as region 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'credit_risk_feature_br_db' and base_table = 'data_source_tab'
        --base_database like 'credit_risk_feature_br_db%' and base_table like 'data_source_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_feature_br_db__data_source_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,data_source_desc                                                                                     as data_source_desc
,row_key_format                                                                                       as row_key_format
,column_key_format                                                                                    as column_key_format
,person_in_charge                                                                                     as person_in_charge
,storage_location                                                                                     as storage_location
,related_original_data                                                                                as related_original_data
,data_source_type                                                                                     as data_source_type
,expiration_time                                                                                      as expiration_time
,store_time                                                                                           as store_time
,offline_data_refresh_time                                                                            as offline_data_refresh_time
,outer_person_in_charge                                                                               as outer_person_in_charge
,outer_interface                                                                                      as outer_interface
,outer_interface_protocol                                                                             as outer_interface_protocol
,data_structure                                                                                       as data_structure
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,usage_scene                                                                                          as usage_scene
,data_source_link                                                                                     as data_source_link
,region                                                                                               as region

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_feature_br_db__data_source_tab__df__private;

refresh table risk.ods__credit_risk_feature_br_db__data_source_tab__df__private;

    