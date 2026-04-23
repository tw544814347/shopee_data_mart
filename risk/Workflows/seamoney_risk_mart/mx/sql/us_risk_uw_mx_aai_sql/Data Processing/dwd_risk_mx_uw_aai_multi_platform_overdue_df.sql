insert overwrite ${SCHEMA}.dwd_risk_mx_uw_aai_multi_platform_overdue_df partition(grass_date = '${ds}')
select flow_no
        ,user_id
        ,request_id
        ,request_datetime
        ,date(request_datetime) as request_date
        ,extra
        ,pricing_strategy
        ,code
        ,transaction_id
        ,message
        ,cast(get_json_object(data, '$.MPOD_1')  as decimal(30,10)) as mpod_1
        ,cast(get_json_object(data, '$.MPOD_2')  as decimal(30,10)) as mpod_2
        ,cast(get_json_object(data, '$.MPOD_3')  as decimal(30,10)) as mpod_3
        ,cast(get_json_object(data, '$.MPOD_4')  as decimal(30,10)) as mpod_4
        ,cast(get_json_object(data, '$.MPOD_5')  as decimal(30,10)) as mpod_5
        ,cast(get_json_object(data, '$.MPOD_6')  as decimal(30,10)) as mpod_6
        ,cast(get_json_object(data, '$.MPOD_7')  as decimal(30,10)) as mpod_7
        ,cast(get_json_object(data, '$.MPOD_8')  as decimal(30,10)) as mpod_8
        ,cast(get_json_object(data, '$.MPOD_9')  as decimal(30,10)) as mpod_9
        ,cast(get_json_object(data, '$.MPOD_10') as decimal(30,10))  as mpod_10


        ,cast(get_json_object(data, '$.MPOD_11') as decimal(30,10)) as mpod_11
        ,cast(get_json_object(data, '$.MPOD_12') as decimal(30,10)) as mpod_12
        ,cast(get_json_object(data, '$.MPOD_13') as decimal(30,10)) as mpod_13
        ,cast(get_json_object(data, '$.MPOD_14') as decimal(30,10)) as mpod_14
        ,cast(get_json_object(data, '$.MPOD_15') as decimal(30,10)) as mpod_15
        ,cast(get_json_object(data, '$.MPOD_16') as decimal(30,10)) as mpod_16
        ,cast(get_json_object(data, '$.MPOD_17') as decimal(30,10)) as mpod_17
        ,cast(get_json_object(data, '$.MPOD_18') as decimal(30,10)) as mpod_18
        ,cast(get_json_object(data, '$.MPOD_19') as decimal(30,10)) as mpod_19
        ,cast(get_json_object(data, '$.MPOD_20') as decimal(30,10)) as mpod_20

        ,cast(get_json_object(data, '$.MPOD_21') as decimal(30,10)) as mpod_21
        ,cast(get_json_object(data, '$.MPOD_22') as decimal(30,10)) as mpod_22
        ,cast(get_json_object(data, '$.MPOD_23') as decimal(30,10)) as mpod_23
        ,cast(get_json_object(data, '$.MPOD_24') as decimal(30,10)) as mpod_24
        ,cast(get_json_object(data, '$.MPOD_25') as decimal(30,10)) as mpod_25
        ,cast(get_json_object(data, '$.MPOD_26') as decimal(30,10)) as mpod_26
        ,cast(get_json_object(data, '$.MPOD_27') as decimal(30,10)) as mpod_27
        ,cast(get_json_object(data, '$.MPOD_28') as decimal(30,10)) as mpod_28
        ,cast(get_json_object(data, '$.MPOD_29') as decimal(30,10)) as mpod_29
        ,cast(get_json_object(data, '$.MPOD_30') as decimal(30,10)) as mpod_30

        ,cast(get_json_object(data, '$.MPOD_31') as decimal(30,10)) as mpod_31
        ,cast(get_json_object(data, '$.MPOD_32') as decimal(30,10)) as mpod_32
        ,cast(get_json_object(data, '$.MPOD_33') as decimal(30,10)) as mpod_33
        ,cast(get_json_object(data, '$.MPOD_34') as decimal(30,10)) as mpod_34
        ,cast(get_json_object(data, '$.MPOD_35') as decimal(30,10)) as mpod_35
        ,cast(get_json_object(data, '$.MPOD_36') as decimal(30,10)) as mpod_36
        ,cast(get_json_object(data, '$.MPOD_37') as decimal(30,10)) as mpod_37
        ,cast(get_json_object(data, '$.MPOD_38') as decimal(30,10)) as mpod_38
        ,cast(get_json_object(data, '$.MPOD_39') as decimal(30,10)) as mpod_39
        ,cast(get_json_object(data, '$.MPOD_40') as decimal(30,10)) as mpod_40

        ,cast(get_json_object(data, '$.MPOD_41') as decimal(30,10)) as mpod_41
        ,cast(get_json_object(data, '$.MPOD_42') as decimal(30,10)) as mpod_42
        ,cast(get_json_object(data, '$.MPOD_43') as decimal(30,10)) as mpod_43
        ,cast(get_json_object(data, '$.MPOD_44') as decimal(30,10)) as mpod_44
        ,cast(get_json_object(data, '$.MPOD_45') as decimal(30,10)) as mpod_45
        ,cast(get_json_object(data, '$.MPOD_46') as decimal(30,10)) as mpod_46
        ,cast(get_json_object(data, '$.MPOD_47') as decimal(30,10)) as mpod_47
        ,cast(get_json_object(data, '$.MPOD_48') as decimal(30,10)) as mpod_48
        ,cast(get_json_object(data, '$.MPOD_49') as decimal(30,10)) as mpod_49
        ,cast(get_json_object(data, '$.MPOD_50') as decimal(30,10)) as mpod_50

        ,cast(get_json_object(data, '$.MPOD_51') as decimal(30,10)) as mpod_51
        ,cast(get_json_object(data, '$.MPOD_52') as decimal(30,10)) as mpod_52
        ,cast(get_json_object(data, '$.MPOD_53') as decimal(30,10)) as mpod_53
        ,cast(get_json_object(data, '$.MPOD_54') as decimal(30,10)) as mpod_54
        ,cast(get_json_object(data, '$.MPOD_55') as decimal(30,10)) as mpod_55
        ,cast(get_json_object(data, '$.MPOD_56') as decimal(30,10)) as mpod_56
        ,cast(get_json_object(data, '$.MPOD_57') as decimal(30,10)) as mpod_57
        ,cast(get_json_object(data, '$.MPOD_58') as decimal(30,10)) as mpod_58
        ,cast(get_json_object(data, '$.MPOD_59') as decimal(30,10)) as mpod_59



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
    AND data_source_name = 'AaiMultiPlatformOverdue'
)