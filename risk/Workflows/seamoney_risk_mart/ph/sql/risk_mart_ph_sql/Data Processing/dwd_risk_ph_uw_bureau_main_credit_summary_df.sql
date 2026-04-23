
insert overwrite table risk.dwd_risk_ph_uw_bureau_main_credit_summary_df partition(grass_date)
select
cast(get_json_object(header_data,'$.PlatformUserId') as string )  as platform_user_id
,cast(get_json_object(header_data,'$.FlowNo') as string )         as flow_no
,create_time                                                      as request_time
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.AgeAtLoanTermination') as string) as age_at_loan_termination
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.ReportingProvidersNumber') as string) as reporting_providers_number
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContract') as string) as number_of_contract
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractRQ') as string) as number_of_contract_rq
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractRF') as string) as number_of_contract_rf
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractRN') as string) as number_of_contract_rn
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractAC') as string) as number_of_contract_ac
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractCLCA') as string) as number_of_contract_clca
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractOther') as string) as number_of_contract__other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractACOther') as string) as number_of_contract_ac_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractCLCAOther') as string) as number_of_contract_clca_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractRFOther') as string) as number_of_contract_rf_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractRNOther') as string) as number_of_contract_rn_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NumberOfContractRQOther') as string) as number_of_contract_rq_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.TotalOutstanding') as string) as total_outstanding
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.MonthsOfBooks') as string) as months_of_books
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilizationRateNonInstallment') as string) as utilization_rate_noninstallment
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilizationRateCreditCard') as string) as utilization_rate_credit_card
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.OverlimitFlag') as string) as overlimit_flag
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.Accounts30Days') as string) as accounts_30days
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.Accounts60Days') as string) as accounts_60days
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.Accounts90Days') as string) as accounts_90days
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.Accounts30DaysOther') as string) as accounts_30days_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.Accounts60DaysOther') as string) as accounts_60days_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.Accounts90DaysOther') as string) as accounts_90days_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstTotalMonthlyPaymentsAmount') as string) as inst_total_monthly_payments_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstTotalOutstandingBalanceAmount') as string) as inst_total_outstanding_balance_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstTotalOverdueAmount') as string) as inst_total_overdue_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstNumberOfContracts') as string) as inst_number_of_contracts
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstMaxOverdueAmount') as string) as inst_max_overdue_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstMaxOverdueAmountDate') as string) as inst_max_overdue_amountdate
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstMaxOverdueDays') as string) as inst_max_overduedays
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.InstMaxOverdueDaysDate') as string) as inst_max_overduedays_date
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NonInstTotalCreditLimit') as string) as noninst_total_credit_limit
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NonInstTotalUtilization') as string) as noninst_total_utilization
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NonInstTotalOverdraftAmount') as string) as noninst_total_overdraft_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NonInstNumberOfContracts') as string) as noninst_number_of_contracts
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NonInstHighestCreditLimit') as string) as noninst_highest_credit_limit
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.NonInstAvgCreditLimit') as string) as noninst_avg_credit_limit
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditTotalCreditLimit') as string) as credit_total_credit_limit
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditTotalOutstandingBalanceAmount') as string) as credit_total_outstanding_balance_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditTotalOverdueAmount') as string) as credit_total_overdue_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditNumberOfContracts') as string) as credit_number_of_contracts
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditHighestCreditLimit') as string) as credit_highest_credit_limit
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditAvgCreditLimit') as string) as credit_avg_credit_limit
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditMaxOverdueAmount') as string) as credit_max_overdue_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditMaxOverdueAmountDate') as string) as credit_max_overdue_amountdate
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditMaxOverdueDays') as string) as credit_max_overduedays
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditMaxOverdueDaysDate') as string) as credit_max_overduedays_date
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditMaxOutstandingBalance') as string) as credit_max_outstanding_balance
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.CreditMaxOutstandingBalanceDate') as string) as credit_max_outstanding_balancedate
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityTotalBilledAmount') as string) as utility_total_billed_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityTotalOutstandingBalanceAmount') as string) as utility_total_outstandingbalance_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityTotalOverdueAmount') as string) as utility_total_overdue_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityNumberOfContracts') as string) as utility_number_of_contracts
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxOverdueAmount') as string) as utility_max_overdue_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxOverdueAmountDate') as string) as utility_max_overdue_amountdate
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxOverdueDays') as string) as utility_max_overdue_days
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxOverdueDaysDate') as string) as utility_max_overdue_days_date
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxOutstandingBalance') as string) as utility_max_outstanding_balance
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxOutstandingBalanceDate') as string) as utility_max_outstanding_balance_date
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxBilledAmount') as string) as utility_max_billed_amount
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilityMaxBilledAmountDate') as string) as utility_max_billed_amount_date
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.LoanToValue') as string) as loan_to_value
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.SubjectInfoTypeCodeDesc') as string) as subject_info_type_code_desc
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.AgeAtLoanTerminationMax') as string) as age_at_loan_termination_max
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.MonthsOfBooksOther') as string) as months_of_books_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.OverlimitFlagOther') as string) as over_limit_flag_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.ReportingProvidersNumberOther') as string) as reporting_providers_number_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.TotalOutstandingOther') as string) as total_outstanding_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilizationRateNonInstallmentOther') as string) as utilization_rate_noninstallment_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.AggregateData.UtilizationRateCreditCardOther') as string) as utilization_rate_credit_card_other
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.Decision.Value') as string) as decision_value
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBConfigurationData.ExclusionRuleLabel.Description') as string) as exclusionrulelabel_description
,cast(get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBConfigurationData.ExclusionRuleLabel.Value') as string) as exclusionrulelabel_value
,grass_date
from risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
where grass_date = '${grass_date}'
and data_source_name = 'CrifData'
and data_source_code = 2;








