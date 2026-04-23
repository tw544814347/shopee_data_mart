insert overwrite ${SCHEMA}.dwd_risk_mx_uw_aai_multi_platform_df partition (grass_date = '${ds}')
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
        ,cast(get_json_object(data, '$.GD_X_1')  as decimal(30, 10)) as gd_x_1
        ,cast(get_json_object(data, '$.GD_X_2')  as decimal(30, 10)) as gd_x_2
        ,cast(get_json_object(data, '$.GD_X_3')  as decimal(30, 10)) as gd_x_3
        ,cast(get_json_object(data, '$.GD_X_4')  as decimal(30, 10)) as gd_x_4
        ,cast(get_json_object(data, '$.GD_X_5')  as decimal(30, 10)) as gd_x_5
        ,cast(get_json_object(data, '$.GD_X_6')  as decimal(30, 10)) as gd_x_6
        ,cast(get_json_object(data, '$.GD_X_7')  as decimal(30, 10)) as gd_x_7
        ,cast(get_json_object(data, '$.GD_X_8')  as decimal(30, 10)) as gd_x_8
        ,cast(get_json_object(data, '$.GD_X_9')  as decimal(30, 10)) as gd_x_9
        ,cast(get_json_object(data, '$.GD_X_10') as decimal(30, 10))  as gd_x_10

        ,cast(get_json_object(data, '$.GD_X_11') as decimal(30, 10)) as gd_x_11
        ,cast(get_json_object(data, '$.GD_X_12') as decimal(30, 10)) as gd_x_12
        ,cast(get_json_object(data, '$.GD_X_13') as decimal(30, 10)) as gd_x_13
        ,cast(get_json_object(data, '$.GD_X_14') as decimal(30, 10)) as gd_x_14
        ,cast(get_json_object(data, '$.GD_X_15') as decimal(30, 10)) as gd_x_15
        ,cast(get_json_object(data, '$.GD_X_16') as decimal(30, 10)) as gd_x_16
        ,cast(get_json_object(data, '$.GD_X_17') as decimal(30, 10)) as gd_x_17
        ,cast(get_json_object(data, '$.GD_X_18') as decimal(30, 10)) as gd_x_18
        ,cast(get_json_object(data, '$.GD_X_19') as decimal(30, 10)) as gd_x_19
        ,cast(get_json_object(data, '$.GD_X_20') as decimal(30, 10)) as gd_x_20

        ,cast(get_json_object(data, '$.GD_X_21') as decimal(30,10)) as gd_x_21
        ,cast(get_json_object(data, '$.GD_X_22') as decimal(30,10)) as gd_x_22
        ,cast(get_json_object(data, '$.GD_X_23') as decimal(30,10)) as gd_x_23
        ,cast(get_json_object(data, '$.GD_X_24') as decimal(30,10)) as gd_x_24
        ,cast(get_json_object(data, '$.GD_X_25') as decimal(30,10)) as gd_x_25
        ,cast(get_json_object(data, '$.GD_X_26') as decimal(30,10)) as gd_x_26
        ,cast(get_json_object(data, '$.GD_X_27') as decimal(30,10)) as gd_x_27
        ,cast(get_json_object(data, '$.GD_X_28') as decimal(30,10)) as gd_x_28
        ,cast(get_json_object(data, '$.GD_X_29') as decimal(30,10)) as gd_x_29
        ,cast(get_json_object(data, '$.GD_X_30') as decimal(30,10)) as gd_x_30

        ,cast(get_json_object(data, '$.GD_X_31') as decimal(30,10)) as gd_x_31
        ,cast(get_json_object(data, '$.GD_X_32') as decimal(30,10)) as gd_x_32
        ,cast(get_json_object(data, '$.GD_X_33') as decimal(30,10)) as gd_x_33
        ,cast(get_json_object(data, '$.GD_X_34') as decimal(30,10)) as gd_x_34
        ,cast(get_json_object(data, '$.GD_X_35') as decimal(30,10)) as gd_x_35
        ,cast(get_json_object(data, '$.GD_X_36') as decimal(30,10)) as gd_x_36
        ,cast(get_json_object(data, '$.GD_X_37') as decimal(30,10)) as gd_x_37
        ,cast(get_json_object(data, '$.GD_X_38') as decimal(30,10)) as gd_x_38
        ,cast(get_json_object(data, '$.GD_X_39') as decimal(30,10)) as gd_x_39
        ,cast(get_json_object(data, '$.GD_X_40') as decimal(30,10)) as gd_x_40

        ,cast(get_json_object(data, '$.GD_X_41') as decimal(30,10)) as gd_x_41
        ,cast(get_json_object(data, '$.GD_X_42') as decimal(30,10)) as gd_x_42
        ,cast(get_json_object(data, '$.GD_X_43') as decimal(30,10)) as gd_x_43
        ,cast(get_json_object(data, '$.GD_X_44') as decimal(30,10)) as gd_x_44
        ,cast(get_json_object(data, '$.GD_X_45') as decimal(30,10)) as gd_x_45
        ,cast(get_json_object(data, '$.GD_X_46') as decimal(30,10)) as gd_x_46
        ,cast(get_json_object(data, '$.GD_X_47') as decimal(30,10)) as gd_x_47
        ,cast(get_json_object(data, '$.GD_X_48') as decimal(30,10)) as gd_x_48
        ,cast(get_json_object(data, '$.GD_X_49') as decimal(30,10)) as gd_x_49
        ,cast(get_json_object(data, '$.GD_X_50') as decimal(30,10)) as gd_x_50

        ,cast(get_json_object(data, '$.GD_X_51') as decimal(30,10)) as gd_x_51
        ,cast(get_json_object(data, '$.GD_X_52') as decimal(30,10)) as gd_x_52
        ,cast(get_json_object(data, '$.GD_X_53') as decimal(30,10)) as gd_x_53
        ,cast(get_json_object(data, '$.GD_X_54') as decimal(30,10)) as gd_x_54
        ,cast(get_json_object(data, '$.GD_X_55') as decimal(30,10)) as gd_x_55
        ,cast(get_json_object(data, '$.GD_X_56') as decimal(30,10)) as gd_x_56
        ,cast(get_json_object(data, '$.GD_X_57') as decimal(30,10)) as gd_x_57
        ,cast(get_json_object(data, '$.GD_X_58') as decimal(30,10)) as gd_x_58

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
    AND data_source_name = 'AaiMultiPlatform'
)