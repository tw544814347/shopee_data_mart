create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table ${SCHEMA}.dwd_risk_${region_lower}_credit_custom_list_rare_type_df partition (grass_date = '${ds}')
select  
 id                                                                                                   as id
,data                                                                                                 as data
,data_type                                                                                            as data_type
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,format_time(create_time,'${region_upper}')                                                           as create_time
,format_time(update_time,'${region_upper}')                                                           as update_time
,format_time(${expire_time},'${region_upper}')                                                           as expire_time
from    risk.ods__credit_risk_control_${region_lower}_db__custom_list_rare_type_tab__df
where   grass_date = '${ds}'
;

