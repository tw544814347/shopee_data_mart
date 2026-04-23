insert overwrite ${SCHEMA}.dwd_risk_mx_uw_circulo_address_df partition (grass_date = '${ds}')
select flow_no
        ,user_id
        ,request_date
        ,request_datetime
        ,request_id
        ,message_type
        ,message_description
        ,get_json_object(address, '$.direccion') as                 address
        ,get_json_object(address, '$.coloniaPoblacion') as          town
        ,get_json_object(address, '$.delegacionMunicipio') as       district
        ,get_json_object(address, '$.ciudad') as                    city
        ,get_json_object(address, '$.estado') as                    state
        ,get_json_object(address, '$.CP') as                        zipcode
        ,get_json_object(address, '$.fechaResidencia') as           residence_date
        ,get_json_object(address, '$.numeroTelefono') as            telephone_number
        ,get_json_object(address, '$.tipoDomicilio') as             address_type
        ,get_json_object(address, '$.tipoAsentamiento') as          establishment_type
        ,get_json_object(address, '$.fechaRegistroDomicilio') as    address_registration_date
        ,get_json_object(address, '$.tipoAltaDomicilio') as         address_registration_type
        ,get_json_object(address, '$.numeroOtorgantesCarga') as     no_of_grantor_in_loan_registration
        ,get_json_object(address, '$.numeroOtorgantesConsulta') as  no_of_grantor_in_request
        ,get_json_object(address, '$.idDomicilio') as               address_id
from  (
    select  flow_no
            ,user_id
            ,request_id
            ,request_datetime
            ,cast(date(request_datetime) as string) as request_date
            ,get_json_object(messages[0], '$.tipoMensaje') as message_type
            ,get_json_object(messages[0], '$.leyenda') as message_description 
            ,explode(addresses) as address
    from (
        SELECT get_json_object(header_data, '$.FlowNo') as flow_no 
                ,get_json_object(header_data, '$.PlatformUserId') as user_id
                ,get_json_object(req_data, '$.RequestId') as request_id
                ,date_format(to_timestamp(create_time) - interval '6' hour, 'yyyy-MM-dd hh:mm:ss')as request_datetime
                ,from_json(get_json_object(resp_raw_data, '$.mensajes'), 'array<string>') as messages
                ,from_json(get_json_object(resp_raw_data, '$.domicilios'), 'array<string>') as addresses

        FROM risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
        WHERE grass_date = '${ds}'
        AND data_source_name = 'RccFicoScore'
    )
)
