insert overwrite ${SCHEMA}.dwd_risk_mx_uw_aai_blacklist_df partition (grass_date = '${ds}')
select flow_no
        ,user_id
        ,request_id
        ,request_datetime
        ,get_json_object(data, '$.isHit')  as is_hit
        ,extra
        ,pricing_strategy
        ,code
        ,transaction_id
        ,message
from (
    SELECT get_json_object(header_data, '$.FlowNo') as flow_no 
            ,get_json_object(header_data, '$.PlatformUserId') as user_id
            ,get_json_object(req_data, '$.RequestId') as request_id
            ,date_format(to_timestamp(create_time) - interval '6' hour, 'yyyy-MM-dd hh:mm:ss')as request_datetime
            ,get_json_object(resp_raw_data, '$.data') as data
            ,get_json_object(resp_raw_data, '$.extra') as extra
            ,get_json_object(resp_raw_data, '$.pricingStrategy') as pricing_strategy
            ,get_json_object(resp_raw_data, '$.code') as code
            ,get_json_object(resp_raw_data, '$.transactionId') as transaction_id
            ,get_json_object(resp_raw_data, '$.message') as message
    FROM risk.ods__credit_risk_datafetch_mx_db__identity_data_history_tab__df
    WHERE grass_date = '${ds}'
    AND data_source_name = 'AaiBlacklist'
)