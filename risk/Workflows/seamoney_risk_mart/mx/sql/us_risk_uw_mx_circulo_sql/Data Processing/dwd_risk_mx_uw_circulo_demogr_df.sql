insert overwrite ${SCHEMA}.dwd_risk_mx_uw_circulo_demogr_df partition (grass_date)
select  flow_no
        ,user_id
        ,request_date
        ,request_datetime
        ,request_id
        ,message_type
        ,message_description
        ,paternal_last_name
        ,maternal_last_name
        ,additional_last_name
        ,name
        ,date_of_birth
        ,rfc
        ,curp
        ,social_security_no
        ,nationality
        ,residence
        ,martial_status
        ,sex
        ,ife
        ,cast(dependent_no as bigint) as dependent_no
        ,date_of_death
        ,'${ds}' as grass_date
from
    (
        select
            flow_no
            ,user_id
            ,request_id
            ,request_datetime
            ,cast(date(request_datetime) as string) as request_date
            ,get_json_object(messages[0], '$.tipoMensaje') as message_type
            ,get_json_object(messages[0], '$.leyenda') as message_description
            ,get_json_object(persona, '$.apellidoPaterno') as           paternal_last_name
            ,get_json_object(persona, '$.apellidoMaterno') as           maternal_last_name
            ,get_json_object(persona, '$.apellidoAdicional') as         additional_last_name
            ,get_json_object(persona, '$.nombres') as                   name
            ,get_json_object(persona, '$.fechaNacimiento') as           date_of_birth
            ,get_json_object(persona, '$.RFC') as                       rfc
            ,get_json_object(persona, '$.CURP') as                      curp
            ,get_json_object(persona, '$.numeroSeguridadSocial') as     social_security_no
            ,get_json_object(persona, '$.nacionalidad') as              nationality
            ,get_json_object(persona, '$.residencia') as                residence
            ,get_json_object(persona, '$.estadoCivil') as               martial_status
            ,get_json_object(persona, '$.sexo') as                      sex
            ,get_json_object(persona, '$.claveElectorIFE') as           ife
            ,get_json_object(persona, '$.numeroDependientes') as        dependent_no
            ,get_json_object(persona, '$.fechaDefuncion') as            date_of_death
        from
            (
                select
                    get_json_object(header_data, '$.FlowNo') as flow_no
                    ,get_json_object(header_data, '$.PlatformUserId') as user_id
                    ,get_json_object(req_data, '$.RequestId') as request_id
                    ,date_format(to_timestamp(create_time) - interval '6' hour ,'yyyy-MM-dd hh:mm:ss') as request_datetime
                    ,from_json(get_json_object(resp_raw_data, '$.mensajes'),'array<string>') as messages
                    ,get_json_object(resp_raw_data, '$.persona') as persona
                from risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
                where
                    grass_date = '${ds}'
                    and data_source_name = 'RccFicoScore'
            )
    )