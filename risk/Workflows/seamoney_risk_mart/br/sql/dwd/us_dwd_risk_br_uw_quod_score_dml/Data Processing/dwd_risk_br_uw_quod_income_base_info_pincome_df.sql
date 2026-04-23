

insert overwrite table risk.dwd_risk_br_uw_quod_income_base_info_pincome_df partition(grass_date ='${grass_date}')
select
t1.platform_user_id                                                                                                                 as platform_user_id            
,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Header.TransactionId')                                                 as transaction_id             
,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].CPF')                                  as cpf                        
,concat(get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].ReferenceDate.Year'),'-'
       ,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].ReferenceDate.Month'),'-'
       ,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].ReferenceDate.Day'))            as update_date                
,cast(get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].PresumedIncome') as double )      as presumed_income            
,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].PositiveData')                         as positive_data              
,cast(get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].MinimumWageRangeValue')as int)    as min_wage_range             
,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].MinimumWageRangeDescription')          as min_wage_range_description 
,get_json_object(t1.rsp,'$.PresumedIncomeResponseEx.Response.Records.PresumedIncomeOutput[0].IncomeRangeValue')                     as income_range_value         
,source_pk                                                                                                                          as source_pk 
,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                                     as create_time 
from risk.dwd_risk_br_uw_risk_trade_df t1 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodPresumeIncome'
;

