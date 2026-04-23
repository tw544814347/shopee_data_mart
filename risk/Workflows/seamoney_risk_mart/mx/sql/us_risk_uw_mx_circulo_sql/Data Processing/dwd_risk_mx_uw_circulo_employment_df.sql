insert overwrite ${SCHEMA}.dwd_risk_mx_uw_circulo_employment_df partition (grass_date)
select flow_no
        ,user_id
        ,request_datetime
        ,cast(date(request_datetime) as string) as request_date
        ,request_id
        ,message_type
        ,message_description
        ,get_json_object(employment, '$.nombreEmpresa') as  company_name   
        ,get_json_object(employment, '$.direccion') as  address        
        ,get_json_object(employment, '$.coloniaPoblacion') as  town           
        ,get_json_object(employment, '$.delegacionMunicipio') as  district       
        ,get_json_object(employment, '$.ciudad') as  city           
        ,get_json_object(employment, '$.estado') as  state          
        ,get_json_object(employment, '$.CP') as  zipcode  
        ,get_json_object(employment, '$.numeroTelefono') as  telephone_number    
        ,get_json_object(employment, '$.extension') as  telephone_extension 
        ,get_json_object(employment, '$.fax') as  fax_number          
        ,get_json_object(employment, '$.puesto') as  position            
        ,get_json_object(employment, '$.fechaContratacion') as  hiring_date         
        ,get_json_object(employment, '$.claveMoneda') as  currency            
        ,get_json_object(employment, '$.salarioMensual') as  monthly_salary      
        ,get_json_object(employment, '$.fechaUltimoDiaEmpleo') as  last_employment_date
        ,get_json_object(employment, '$.fechaVerificacionEmpleo') as  verification_date  
        ,'${ds}' as grass_date
from(

    select flow_no
            ,user_id
            ,request_id
            ,request_datetime
            ,get_json_object(messages[0], '$.tipoMensaje') as message_type
            ,get_json_object(messages[0], '$.leyenda') as message_description
            ,explode(employments) as employment
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
                        get_json_object(resp_raw_data, '$.empleos')
                        ,'array<string>'
                    ) as employments
            from risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
            where   grass_date = '${ds}'
            and data_source_name = 'RccFicoScore'
    )   
)