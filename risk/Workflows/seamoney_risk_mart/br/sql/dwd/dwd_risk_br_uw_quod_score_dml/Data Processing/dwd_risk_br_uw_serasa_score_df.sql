
insert overwrite table risk.dwd_risk_br_uw_serasa_score_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                                                   as platform_user_id
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                                            as document_number
    ,cast(get_json_object(t1.resp_raw_data,'$.reports[0].score.score') as bigint)                                         as score
    ,get_json_object(t1.resp_raw_data,'$.reports[0].score.scoreModel')                                                    as score_model       
    ,get_json_object(t1.resp_raw_data,'$.reports[0].score.range')                                                         as range            
    ,cast(regexp_replace(get_json_object(t1.resp_raw_data,'$.reports[0].score.defaultRate'),',','.') as decimal(32,4))    as default_rate            
    ,cast(get_json_object(t1.resp_raw_data,'$.reports[0].score.codeMessage') as bigint)                                   as code_message       
    ,get_json_object(t1.resp_raw_data,'$.reports[0].score.message')                                                       as message             
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
;