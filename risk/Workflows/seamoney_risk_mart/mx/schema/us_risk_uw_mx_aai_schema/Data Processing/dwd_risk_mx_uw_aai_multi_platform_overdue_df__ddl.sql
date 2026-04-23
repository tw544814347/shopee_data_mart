drop table if exists ${SCHEMA}.dwd_risk_mx_uw_aai_multi_platform_overdue_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_aai_multi_platform_overdue_df(
    flow_no string comment 'flow_no'
    ,user_id    string comment 'platform_user_id'
    ,request_id string comment ''
    ,request_datetime   string comment 'request_datetime'
    ,request_date   string comment 'request_date'
    ,extra  string  comment 'extra'
    ,pricing_strategy   string comment 'pricing strategy'
    ,code   string comment 'code'
    ,transaction_id string comment 'transaction_id'
    ,message    string comment 'message'
    ,mpod_1 decimal(30,10) comment 'mpod'
    ,mpod_2 decimal(30,10) comment 'mpod'
    ,mpod_3 decimal(30,10) comment 'mpod'
    ,mpod_4 decimal(30,10) comment 'mpod'
    ,mpod_5 decimal(30,10) comment 'mpod'
    ,mpod_6 decimal(30,10) comment 'mpod'
    ,mpod_7 decimal(30,10) comment 'mpod'
    ,mpod_8 decimal(30,10) comment 'mpod'
    ,mpod_9 decimal(30,10) comment 'mpod'
    ,mpod_10 decimal(30,10) comment 'mpod'
    ,mpod_11 decimal(30,10) comment 'mpod'
    ,mpod_12 decimal(30,10) comment 'mpod'
    ,mpod_13 decimal(30,10) comment 'mpod'
    ,mpod_14 decimal(30,10) comment 'mpod'
    ,mpod_15 decimal(30,10) comment 'mpod'
    ,mpod_16 decimal(30,10) comment 'mpod'
    ,mpod_17 decimal(30,10) comment 'mpod'
    ,mpod_18 decimal(30,10) comment 'mpod'
    ,mpod_19 decimal(30,10) comment 'mpod'
    ,mpod_20 decimal(30,10) comment 'mpod'
    ,mpod_21 decimal(30,10) comment 'mpod'
    ,mpod_22 decimal(30,10) comment 'mpod'
    ,mpod_23 decimal(30,10) comment 'mpod'
    ,mpod_24 decimal(30,10) comment 'mpod'
    ,mpod_25 decimal(30,10) comment 'mpod'
    ,mpod_26 decimal(30,10) comment 'mpod'
    ,mpod_27 decimal(30,10) comment 'mpod'
    ,mpod_28 decimal(30,10) comment 'mpod'
    ,mpod_29 decimal(30,10) comment 'mpod'
    ,mpod_30 decimal(30,10) comment 'mpod'
    ,mpod_31 decimal(30,10) comment 'mpod'
    ,mpod_32 decimal(30,10) comment 'mpod'
    ,mpod_33 decimal(30,10) comment 'mpod'
    ,mpod_34 decimal(30,10) comment 'mpod'
    ,mpod_35 decimal(30,10) comment 'mpod'
    ,mpod_36 decimal(30,10) comment 'mpod'
    ,mpod_37 decimal(30,10) comment 'mpod'
    ,mpod_38 decimal(30,10) comment 'mpod'
    ,mpod_39 decimal(30,10) comment 'mpod'
    ,mpod_40 decimal(30,10) comment 'mpod'
    ,mpod_41 decimal(30,10) comment 'mpod'
    ,mpod_42 decimal(30,10) comment 'mpod'
    ,mpod_43 decimal(30,10) comment 'mpod'
    ,mpod_44 decimal(30,10) comment 'mpod'
    ,mpod_45 decimal(30,10) comment 'mpod'
    ,mpod_46 decimal(30,10) comment 'mpod'
    ,mpod_47 decimal(30,10) comment 'mpod'
    ,mpod_48 decimal(30,10) comment 'mpod'
    ,mpod_49 decimal(30,10) comment 'mpod'
    ,mpod_50 decimal(30,10) comment 'mpod'
    ,mpod_51 decimal(30,10) comment 'mpod'
    ,mpod_52 decimal(30,10) comment 'mpod'
    ,mpod_53 decimal(30,10) comment 'mpod'
    ,mpod_54 decimal(30,10) comment 'mpod'
    ,mpod_55 decimal(30,10) comment 'mpod'
    ,mpod_56 decimal(30,10) comment 'mpod'
    ,mpod_57 decimal(30,10) comment 'mpod'
    ,mpod_58 decimal(30,10) comment 'mpod'
    ,mpod_59 decimal(30,10) comment 'mpod'

)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_aai_multi_platform_overdue_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_aai_multi_platform_overdue_df;


