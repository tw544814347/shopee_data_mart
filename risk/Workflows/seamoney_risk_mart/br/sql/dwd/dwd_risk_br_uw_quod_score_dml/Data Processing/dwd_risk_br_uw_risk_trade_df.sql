insert
overwrite table risk.dwd_risk_br_uw_risk_trade_df partition(grass_date ='${grass_date}')
select md5(concat(trade_id, flow_no, flow_type))                                                       as source_pk
     , get_json_object(rsp, '$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].CPF') as cpf
     , trade_id                                                                                        as trade_id
     , flow_no                                                                                         as flow_no
     , flow_type                                                                                       as flow_type
     , ''                                                                                         as app_id
     , ''                                                                                        as scene_id
     , platform_user_id                                                                                as platform_user_id
     , rsp                                                                                             as rsp
     , UNIX_TIMESTAMP(create_time)                                                                                    as create_time
from (
         select t1.trace_id                                         as trade_id
              , get_json_object(t1.header_data, '$.FlowNo')         as flow_no
              , t1.data_source_name                                 as flow_type
              , get_json_object(t1.header_data, '$.PlatformUserId') as platform_user_id
              , t1.resp_raw_data                                    as rsp
              , t1.create_time                                      as create_time
              , row_number()                                           over(partition by t1.trace_id,get_json_object(t1.header_data, '$.FlowNo')  ,t1.data_source_name order by t1.create_time desc) rn
         from risk.ods__credit_risk_datafetch_br_db__identity_data_history_tab__df t1
         where t1.grass_date = '${grass_date}'
           and get_json_object(t1.header_data, '$.FlowNo') not like 'Replay%'
           and data_source_name in ('QuodReport', 'QuodPresumeIncome')
     ) tt1
where tt1.rn = 1
;
