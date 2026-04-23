ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_base_info_history_address_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                     as source_pk              
    ,platform_user_id                                as platform_user_id
    ,get_json_object(tbl.address,'$.Street')         as address_street      
    ,get_json_object(tbl.address,'$.Number')         as address_number      
    ,get_json_object(tbl.address,'$.Complement')     as address_complement  
    ,get_json_object(tbl.address,'$.Neighborhood')   as address_neighborhood
    ,get_json_object(tbl.address,'$.City')           as address_city        
    ,get_json_object(tbl.address,'$.State')          as address_state       
    ,get_json_object(tbl.address,'$.PostalCode')     as address_postal_code 
    ,concat(get_json_object(tbl.address,'$.DateLastSeen.Year'),'-',get_json_object(tbl.address,'$.DateLastSeen.Month'),'-',get_json_object(tbl.address,'$.DateLastSeen.Day')) as address_update_date 
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')    as create_time       
from risk.dwd_risk_br_uw_risk_trade_df t1 
lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.AddressHistory.Address'))) tbl as address 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
;

