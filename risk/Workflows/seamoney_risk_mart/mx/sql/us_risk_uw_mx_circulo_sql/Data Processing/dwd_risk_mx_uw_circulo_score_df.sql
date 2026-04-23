insert overwrite ${SCHEMA}.dwd_risk_mx_uw_circulo_score_df partition (grass_date)
select flow_no
        ,user_id
        ,request_date
        ,request_datetime
        ,request_id
        ,message_type
        ,message_description
        ,get_json_object(score, '$.nombreScore') as score_name
        ,cast(get_json_object(score, '$.valor') as bigint) as score_value
        ,get_json_object(score, '$.razones') as score_reasons
        ,'${ds}' as grass_date
from  (
    select  flow_no
            ,user_id
            ,request_id
            ,request_datetime
            ,cast(date(request_datetime) as string) as request_date
            ,get_json_object(messages[0], '$.tipoMensaje') as message_type
            ,get_json_object(messages[0], '$.leyenda') as message_description 
            ,explode(scores) as score
    from (
        SELECT get_json_object(header_data, '$.FlowNo') as flow_no 
                ,get_json_object(header_data, '$.PlatformUserId') as user_id
                ,get_json_object(req_data, '$.RequestId') as request_id
                ,date_format(to_timestamp(create_time) - interval '6' hour, 'yyyy-MM-dd hh:mm:ss')as request_datetime
                ,from_json(get_json_object(resp_raw_data, '$.mensajes'), 'array<string>') as messages
                ,from_json(get_json_object(resp_raw_data, '$.scores'), 'array<string>') as scores

        FROM risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
        WHERE grass_date = '${ds}'
        AND data_source_name = 'RccFicoScore'
    )
)
