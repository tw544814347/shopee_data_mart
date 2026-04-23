



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,ip                                                                                                   as ip
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time

,_event
 from(
    select 
 id                                                                                                   as id
,ip                                                                                                   as ip
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ip                                                                                                   as ip
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__shopeepay_risk_control_br_db__custom_list_ip_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.ip') as bigint)                                                         as ip 
,cast(get_json_object(data,'$.custom_list_id') as decimal(20,0))                                      as custom_list_id 
,cast(get_json_object(data,'$.data_source') as string)                                                as data_source 
,cast(get_json_object(data,'$.action_detail') as string)                                              as action_detail 
,cast(get_json_object(data,'$.action_fail_detail') as string)                                         as action_fail_detail 
,cast(get_json_object(data,'$.action_status') as bigint)                                              as action_status 
,cast(get_json_object(data,'$.remark') as string)                                                     as remark 
,cast(get_json_object(data,'$.status') as bigint)                                                     as status 
,cast(get_json_object(data,'$.description') as string)                                                as description 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.expire_time') as bigint)                                                as expire_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'shopeepay_risk_control_br_db' and base_table = 'custom_list_ip_tab'
        --base_database like 'shopeepay_risk_control_br_db%' and base_table like 'custom_list_ip_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__shopeepay_risk_control_br_db__custom_list_ip_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,ip                                                                                                   as ip
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__shopeepay_risk_control_br_db__custom_list_ip_tab__df__private;

refresh table risk.ods__shopeepay_risk_control_br_db__custom_list_ip_tab__df__private;

    