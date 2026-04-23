insert overwrite ${SCHEMA}.dwd_risk_mx_uw_circulo_loan_df partition (grass_date)
select
    flow_no
    ,user_id
    ,request_date
    ,request_datetime
    ,request_id
    ,message_type
    ,message_description
    ,update_date
    ,cast(contested_record as decimal(30, 10)) as contested_record
    ,grantor_code
    ,grantor_name
    ,account_number
    ,liability_type
    ,account_type
    ,loan_type
    ,currency
    ,cast(asset_value as decimal(30, 10)) as asset_value
    ,cast(number_of_payments as bigint) as number_of_payments
    ,payment_frequency
    ,cast(amount_due as decimal(30, 10)) as amount_due
    ,account_opening_date
    ,last_payment_date
    ,last_purchase_date
    ,account_closing_date
    ,report_date
    ,last_zero_balance_date
    ,collateral
    ,cast(maximum_loan as decimal(30, 10)) as maximum_loan
    ,cast(current_balance as decimal(30, 10)) as current_balance
    ,cast(credit_limit as decimal(30, 10)) as credit_limit
    ,cast(balance_due as decimal(30, 10)) as balance_due
    ,cast(number_of_payments_due as bigint) as number_of_payments_due
    ,current_payment
    ,payment_history
    ,last_payment_history_date
    ,first_payment_history_date
    ,observation_code
    ,cast(total_payment_reported as bigint) as total_payment_reported
    ,cast(worst_arrears as decimal(30,10)) as worst_arrears
    ,worst_arrears_date
    ,cast(balance_due_of_worst_arrears as decimal(30,10)) as balance_due_of_worst_arrears
    ,cast(last_payment_amount as decimal(30,10))    as last_payment_amount
    ,address_id
    ,services
    ,can_id
    ,initial_priority
    ,current_priority
    ,can_opening_date
    ,can_cancellation_date
    ,can_history
    ,last_can_date
    ,first_can_date
    ,'${ds}' as grass_date
from
    (
        select
            flow_no
            ,user_id
            ,request_date
            ,request_datetime
            ,request_id
            ,message_type
            ,message_description
            ,get_json_object(loan, '$.fechaActualizacion') as update_date
            ,get_json_object(loan, '$.registroImpugnado') as contested_record
            ,get_json_object(loan, '$.claveOtorgante') as grantor_code
            ,get_json_object(loan, '$.nombreOtorgante') as grantor_name
            ,get_json_object(loan, '$.cuentaActual') as account_number
            ,get_json_object(loan, '$.tipoResponsabilidad') as liability_type
            ,get_json_object(loan, '$.tipoCuenta') as account_type
            ,get_json_object(loan, '$.tipoCredito') as loan_type
            ,get_json_object(loan, '$.claveUnidadMonetaria') as currency
            ,get_json_object(loan, '$.valorActivoValuacion') as asset_value
            ,get_json_object(loan, '$.numeroPagos') as number_of_payments
            ,get_json_object(loan, '$.frecuenciaPagos') as payment_frequency
            ,get_json_object(loan, '$.montoPagar') as amount_due
            ,get_json_object(loan, '$.fechaAperturaCuenta') as account_opening_date
            ,get_json_object(loan, '$.fechaUltimoPago') as last_payment_date
            ,get_json_object(loan, '$.fechaUltimaCompra') as last_purchase_date
            ,get_json_object(loan, '$.fechaCierreCuenta') as account_closing_date
            ,get_json_object(loan, '$.fechaReporte') as report_date
            ,get_json_object(loan, '$.ultimaFechaSaldoCero') as last_zero_balance_date
            ,get_json_object(loan, '$.garantia') as collateral
            ,get_json_object(loan, '$.creditoMaximo') as maximum_loan
            ,get_json_object(loan, '$.saldoActual') as current_balance
            ,get_json_object(loan, '$.limiteCredito') as credit_limit
            ,get_json_object(loan, '$.saldoVencido') as balance_due
            ,get_json_object(loan, '$.numeroPagosVencidos') as number_of_payments_due
            ,get_json_object(loan, '$.pagoActual') as current_payment
            ,get_json_object(loan, '$.historicoPagos') as payment_history
            ,get_json_object(loan, '$.fechaRecienteHistoricoPagos') as last_payment_history_date
            ,get_json_object(loan, '$.fechaAntiguaHistoricoPagos') as first_payment_history_date
            ,get_json_object(loan, '$.clavePrevencion') as observation_code
            ,get_json_object(loan, '$.totalPagosReportados') as total_payment_reported
            ,get_json_object(loan, '$.peorAtraso') as worst_arrears
            ,get_json_object(loan, '$.fechaPeorAtraso') as worst_arrears_date
            ,get_json_object(loan, '$.saldoVencidoPeorAtraso') as balance_due_of_worst_arrears
            ,get_json_object(loan, '$.montoUltimoPago') as last_payment_amount
            ,get_json_object(loan, '$.idDomicilio') as address_id
            ,get_json_object(loan, '$.servicios') as services
            ,get_json_object(loan, '$.CAN.identificadorCAN') as can_id
            ,get_json_object(loan, '$.CAN.prelacionOrigen') as initial_priority
            ,get_json_object(loan, '$.CAN.prelacionActual') as current_priority
            ,get_json_object(loan, '$.CAN.fechaAperturaCAN') as can_opening_date
            ,get_json_object(loan, '$.CAN.fechaCancelacionCAN') as can_cancellation_date
            ,get_json_object(loan, '$.CAN.historicoCAN') as can_history
            ,get_json_object(loan, '$.CAN.fechaMRCAN') as last_can_date
            ,get_json_object(loan, '$.CAN.fechaMACAN') as first_can_date
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
                    ,explode (loans) as loan
                from
                    (
                        select
                            get_json_object(header_data, '$.FlowNo') as flow_no
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
                                get_json_object(resp_raw_data, '$.creditos')
                                ,'array<string>'
                            ) as loans
                        from risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
                        where
                            grass_date = '${ds}'
                            and data_source_name = 'RccFicoScore'
                    )
            )
    )