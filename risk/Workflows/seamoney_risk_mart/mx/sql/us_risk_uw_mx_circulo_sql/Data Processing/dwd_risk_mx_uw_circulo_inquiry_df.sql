insert overwrite ${SCHEMA}.dwd_risk_mx_uw_circulo_inquiry_df partition (grass_date)
select flow_no
        ,user_id
        ,request_id
        ,cast(date(request_datetime) as string) request_date
        ,request_datetime
        ,message_type
        ,message_description
        ,get_json_object(inquiry, '$.fechaConsulta')  as inquiry_date            
        ,get_json_object(inquiry, '$.claveOtorgante')  as grantor_code            
        ,get_json_object(inquiry, '$.nombreOtorgante')  as grantor_name            
        ,get_json_object(inquiry, '$.direccionOtorgante')  as grantor_address         
        ,get_json_object(inquiry, '$.telefonoOtorgante')  as grantor_telephone_number
        ,get_json_object(inquiry, '$.tipoCredito')  as loan_type               
        ,get_json_object(inquiry, '$.claveUnidadMonetaria')  as currency                
        ,cast(get_json_object(inquiry, '$.importeCredito') as decimal(30,10))  as loan_amount  
        ,get_json_object(inquiry, '$.tipoResponsabilidad')  as liability_type           
        ,get_json_object(inquiry, '$.idDomicilio')  as address_id              
        ,get_json_object(inquiry, '$.servicios')  as service           
        ,'${ds}' as grass_date      
from(

    select flow_no
            ,user_id
            ,request_id
            ,request_datetime
            ,get_json_object(messages[0], '$.tipoMensaje') as message_type
            ,get_json_object(messages[0], '$.leyenda') as message_description
            ,explode(inquiries) as inquiry
    from (
            select  get_json_object(header_data, '$.FlowNo') as flow_no
                    ,get_json_object(header_data, '$.PlatformUserId') as user_id
                    ,get_json_object(req_data, '$.RequestId') as request_id
                    ,date_format(
                        to_timestamp(create_time) - interval '6' hour
                        ,'yyyy-MM-dd hh:mm:ss'
                    ) as request_datetime
                    ,from_json(
                        get_json_object(resp_raw_data, '$.mensajes')
                        ,'array<string>'
                    ) as messages
                    ,from_json(
                        get_json_object(resp_raw_data, '$.consultas')
                        ,'array<string>'
                    ) as inquiries
            from risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
            where   grass_date = '${ds}'
            and data_source_name = 'RccFicoScore'
    )   
)