ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_protest_content_registry_df partition(grass_date ='${grass_date}')
select 
    t1.source_pk                                                             as source_pk              
    ,t1.create_time                                                          as create_time              
    ,t1.platform_user_id                                                     as platform_user_id 
    ,cast(get_json_object(tbl.cartorio,'$.codigo_cidade') as bigint)         as city_code          
    ,cast(get_json_object(tbl.cartorio,'$.codigo_cartorio') as bigint)       as notary_code       
    ,get_json_object(tbl.cartorio,'$.nome')                                  as notary_name       
    ,get_json_object(tbl.cartorio,'$.telefone')                              as notary_phone      
    ,get_json_object(tbl.cartorio,'$.endereco')                              as notary_address    
    ,get_json_object(tbl.cartorio,'$.cidade')                                as notary_city       
    ,cast(get_json_object(tbl.cartorio,'$.protestos') as int)                as no_of_protests    
    ,cast(get_json_object(tbl.cartorio,'$.valor_protestado') as double )     as value_of_protests            
from risk.dwd_risk_br_uw_quod_score_protest_df t1 
lateral view explode(json_to_array(get_json_object(t1.conteudo,'$.cartorio'))) tbl as cartorio 
where t1.grass_date ='${grass_date}' 
;