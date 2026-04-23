--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-19
-- Theme Domain：       ph_screen
-- Description:         
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-11-20 screen_ops_tab 改成 ticket_ops_tab jira: https://jira.shopee.io/browse/SPFDT-46154 prd: https://docs.google.com/spreadsheets/d/1TWOGGIUbw8GZuARsBkzmz6A5PjTPu7X67-ZAra_O7yQ/edit?gid=0#gid=0
--********************************************************************--

drop table if exists ${SCHEMA}.dwd_credit_ph_risk_screen_df;
create external table if not exists ${SCHEMA}.dwd_credit_ph_risk_screen_df
(
        id string COMMENT '<comment><description>Application identifier</description><calculationLogic>t1.id</calculationLogic><enum>No enum</enum></comment>',
        apply_no string COMMENT '<comment><description>Application number</description><calculationLogic>t1.apply_no</calculationLogic><enum>No enum</enum></comment>',
        platform_type bigint COMMENT '<comment><description>Platform type identifier: 0-none;1-shopee;2-airpay;3-merchat</description><calculationLogic>t1.platform_type</calculationLogic><enum>0-none, 1-shopee, 2-airpay, 3-merchat</enum></comment>',
        platform_type_name string COMMENT '<comment><description>Platform type name</description><calculationLogic>e4.name</calculationLogic><enum>No enum</enum></comment>',
        platform_user_id string COMMENT '<comment><description>Platform user identifier</description><calculationLogic>t1.platform_user_id</calculationLogic><enum>No enum</enum></comment>',
        credit_user_id string COMMENT '<comment><description>Credit user identifier</description><calculationLogic>t1.credit_user_id</calculationLogic><enum>No enum</enum></comment>',
        apply_type bigint COMMENT '<comment><description>Application business type: 0-NONE; 1-ACTIVATION; 2-INCREASE_LIMIT; 3-UPDATE_KYC_INFO</description><calculationLogic>t1.apply_type</calculationLogic><enum>0-NONE, 1-ACTIVATION, 2-INCREASE_LIMIT, 3-UPDATE_KYC_INFO</enum></comment>',
        apply_type_name string COMMENT '<comment><description>Application business type name</description><calculationLogic>e1.name</calculationLogic><enum>No enum</enum></comment>',
        is_apply_type_activation bigint COMMENT '<comment><description>Flag indicating if application type is activation: 1:yes, 0:no</description><calculationLogic>if (t1.apply_type = 1, 1, 0)</calculationLogic><enum>0-no, 1-yes</enum></comment>',
        post_update_info string COMMENT '<comment><description>Post update information</description><calculationLogic>t1.post_update_info</calculationLogic><enum>No enum</enum></comment>',
        operator string COMMENT '<comment><description>Operator email</description><calculationLogic>t1.operator</calculationLogic><enum>No enum</enum></comment>',
        create_time string COMMENT '<comment><description>Create timestamp</description><calculationLogic>t1.create_time</calculationLogic><enum>No enum</enum></comment>',
        update_time string COMMENT '<comment><description>Update timestamp</description><calculationLogic>t1.update_time</calculationLogic><enum>No enum</enum></comment>',
        operator_start_time string COMMENT '<comment><description>Operator processing start timestamp</description><calculationLogic>t1.operator_start_time</calculationLogic><enum>No enum</enum></comment>',
        operator_end_time string COMMENT '<comment><description>Operator processing end timestamp</description><calculationLogic>t1.operator_end_time</calculationLogic><enum>No enum</enum></comment>',
        audit_extra_info string COMMENT '<comment><description>Audit extra information (BRScreenRejectType)</description><calculationLogic>t1.audit_extra_info</calculationLogic><enum>No enum</enum></comment>',
        maker_operator string COMMENT '<comment><description>Maker operator name</description><calculationLogic>t1.maker_operator</calculationLogic><enum>No enum</enum></comment>',
        maker_extra_info string COMMENT '<comment><description>Maker extra information</description><calculationLogic>t1.maker_extra_info</calculationLogic><enum>No enum</enum></comment>',
        maker_update_info string COMMENT '<comment><description>Maker update information</description><calculationLogic>t1.maker_update_info</calculationLogic><enum>No enum</enum></comment>',
        maker_submit_time string COMMENT '<comment><description>Maker submit timestamp</description><calculationLogic>t1.maker_submit_time</calculationLogic><enum>No enum</enum></comment>',
        audit_other string COMMENT '<comment><description>Other audit output content</description><calculationLogic>t1.audit_other</calculationLogic><enum>No enum</enum></comment>',
        maker_audit_other string COMMENT '<comment><description>Other maker audit output content</description><calculationLogic>t1.maker_audit_other</calculationLogic><enum>No enum</enum></comment>',
        context string COMMENT '<comment><description>Ticket rejection reason</description><calculationLogic>t1.context</calculationLogic><enum>No enum</enum></comment>',
        reject_code string COMMENT '<comment><description>Ticket rejection code</description><calculationLogic>t1.reject_code</calculationLogic><enum>No enum</enum></comment>',
        screen_platform bigint COMMENT '<comment><description>Screen platform identifier: 0=UC 1=Risk</description><calculationLogic>t1.screen_platform</calculationLogic><enum>0-UC, 1-Risk</enum></comment>',
        submission_time string COMMENT '<comment><description>Submission timestamp</description><calculationLogic>t1.submission_time</calculationLogic><enum>No enum</enum></comment>',
        screen_completed_time string COMMENT '<comment><description>Screen completed timestamp</description><calculationLogic>t1.screen_completed_time</calculationLogic><enum>No enum</enum></comment>',
        kyc_freeze_reasons string COMMENT '<comment><description>KYC freeze reasons</description><calculationLogic>t1.kyc_freeze_reasons</calculationLogic><enum>No enum</enum></comment>',
        fraud_freeze_reasons string COMMENT '<comment><description>Fraud freeze reasons</description><calculationLogic>t1.fraud_freeze_reasons</calculationLogic><enum>No enum</enum></comment>',
        is_skip_idwall bigint COMMENT '<comment><description>Flag indicating if IDWall is skipped</description><calculationLogic>t1.is_skip_idwall</calculationLogic><enum>No enum</enum></comment>',
        operator_map_no string COMMENT '<comment><description>Operator map number</description><calculationLogic>t1.operator_map_no</calculationLogic><enum>No enum</enum></comment>',
        broken_ektp_name bigint COMMENT '<comment><description>Broken eKTP name / audit output</description><calculationLogic>t1.broken_ektp_name</calculationLogic><enum>No enum</enum></comment>',
        screen_type string COMMENT '<comment><description>Screen type field</description><calculationLogic>t1.screen_type</calculationLogic><enum>No enum</enum></comment>'
        )
partitioned by(
    product_id bigint
    ,grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties (
    "orc.compress" = "zstd"
)
LOCATION '${HDFS_PATH}/risk_mart/dws/dwd_risk_credit_screen_df/grass_region=${region_upper}'
COMMENT 'Data warehouse detail table for risk credit screen information.'
;

msck repair table ${SCHEMA}.dwd_credit_ph_risk_screen_df;

create
or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

create
or replace temporary function json_to_array as 'com.shopee.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar'
;

insert overwrite table ${SCHEMA}.dwd_credit_ph_risk_screen_df partition (product_id, grass_date)
select
    t1.id
    ,t1.apply_no
    ,t1.platform_type
    ,e4.name as platform_type_name
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.apply_type
    ,e1.name as apply_type_name
    ,if (t1.apply_type = 1, 1, 0) as is_apply_type_activation
    ,t1.post_update_info
    ,t1.operator
    ,t1.create_time
    ,t1.update_time
    ,t1.operator_start_time
    ,t1.operator_end_time
    ,t1.audit_extra_info
    ,t1.maker_operator
    ,t1.maker_extra_info
    ,t1.maker_update_info
    ,t1.maker_submit_time
    ,t1.audit_other
    ,t1.maker_audit_other
    ,t1.context
    ,t1.reject_code
    ,t1.screen_platform
    ,t1.submission_time
    ,t1.screen_completed_time
    ,t1.kyc_freeze_reasons
    ,t1.fraud_freeze_reasons
    ,t1.is_skip_idwall
    ,t1.operator_map_no
    ,t1.broken_ektp_name
    ,t1.screen_type
    ,t1.biz_type as product_id
    ,'${ds}' as grass_date
from
    (
        select
            id
            ,tt1.apply_no
            ,platform_type
            ,platform_user_id
            ,user_id as credit_user_id
            ,apply_type
            ,'' as post_update_info
            ,operator
            ,format_time(create_time, '${region_upper}') as create_time
            ,format_time(update_time, '${region_upper}') as update_time
            ,format_time(operator_start_time, '${region_upper}') as operator_start_time
            ,format_time(operator_end_time, '${region_upper}') as operator_end_time
            ,audit_extra_info
            ,maker_operator
            ,maker_extra_info
            ,maker_update_info
            ,format_time(maker_submit_time, '${region_upper}') as maker_submit_time
            ,audit_other
            ,maker_audit_other
            ,context
            ,null as reject_code
            ,0 as screen_platform
            ,tt2.submission_time
            ,tt2.screen_completed_time
            ,kyc_freeze_reasons
            ,fraud_freeze_reasons
            ,is_skip_idwall
            ,operator_map_no
            ,broken_ektp_name
            ,null as screen_type
            ,biz_type
        from
            credit.ods__credit_usercenter_apply_${region_lower}_db__apply_activation_order_audit_tab__df tt1
            left join (
                select
                    apply_no
                    ,submission_time
                    ,screen_completed_time
                from credit_uc.dwd_uc_${region_lower}_apply_uc_screen_df
                where grass_date = '${ds}'
            ) tt2 on tt1.apply_no = tt2.apply_no
        where tt1.grass_date = '${ds}'
        union all
        select
            tt1.id
            ,tt1.req_no as apply_no
            ,tt1.platform_type
            ,tt1.platform_user_id
            ,tt1.credit_user_id
            ,case
                when tt1.apply_type = 'Activation' then 1
                when tt1.apply_type = 'UpdateInfo' then 3
            end as apply_type
            ,tt3.content as post_update_info
            ,tt3.operator
            ,format_time(tt1.create_time, '${region_upper}') as create_time
            ,format_time(tt1.update_time, '${region_upper}') as update_time
            ,format_time(tt1.maker_start_time, '${region_upper}') as operator_start_time
            ,format_time(tt1.maker_submit_time, '${region_upper}') as operator_end_time
            ,tt2.uc_reject_code as audit_extra_info
            ,tt1.maker as maker_operator
            ,tt2.uc_reject_code as maker_extra_info
            ,tt3.content as maker_update_info
            ,format_time(tt1.maker_submit_time, '${region_upper}') as maker_submit_time
            ,tt2.reject_message as audit_other
            ,tt2.reject_message as maker_audit_other
            ,tt2.reject_message as context
            ,tt1.reject_code
            ,1 as screen_platform
            ,format_time(tt1.create_time, '${region_upper}') as submission_time
            ,format_time(tt1.maker_submit_time, '${region_upper}') as screen_completed_time
            ,null as kyc_freeze_reasons
            ,null as fraud_freeze_reasons
            ,null as is_skip_idwall
            ,null as operator_map_no
            ,null as broken_ektp_name
            ,tt1.screen_type
            ,cast(e.biz_type as bigint) as biz_type
        from
            (
                select
                    *
                from risk.ods__credit_risk_control_ph_db__screen_tab__df
                where grass_date = '${ds}'
            ) tt1
            left join (
                select 
                    risk_kafka_app_id
                    ,biz_type
                from risk.dim_risk_prod_enum_df
            ) e
            on tt1.product_code = e.risk_kafka_app_id
            left join (
                select
                    screen_id
                    ,concat_ws(',', collect_set(ttt2.name)) as uc_reject_code
                    ,concat_ws(' ', collect_set(ttt1.reject_message)) as reject_message
                from
                    (
                        select
                            screen_id
                            ,get_json_object(reject_code, '$.code') as reject_code
                            ,get_json_object(reject_code, '$.message') as reject_message
                        from
                            (
                                select
                                    screen_id
                                    ,json_to_array (reject_code) as reject_code_list
                                from risk.ods__credit_risk_control_ph_db__screen_tab__df
                                where grass_date = '${ds}'
                            ) t lateral view explode (reject_code_list) a as reject_code
                    ) ttt1
                    left join (
                        select
                            name
                            ,value
                        from risk.dim_risk_uc_enum_df
                        where enum_name = 'reject_code'
                    ) ttt2 on ttt1.reject_code = ttt2.value
                group by screen_id
            ) tt2 on tt1.screen_id = tt2.screen_id
            left join (
                select
                    *
                from
                    (
                        select
                            ticket_id as screen_id
                            ,create_time
                            ,update_time
                            ,operator
                            ,content
                            ,row_number() over (
                                partition by ticket_id
                                order by update_time desc
                            ) as rn
                        -- from risk.ods__credit_risk_control_ph_db__screen_ops_tab__df
                        from risk.ods__credit_risk_control_ph_db__ticket_ops_tab__df
                        where grass_date = '${ds}'
                    )
                where rn = 1
            ) tt3 on tt1.screen_id = tt3.screen_id
    ) t1
    left join (
        select
            name
            ,value
        from risk.dim_risk_uc_enum_df
        where enum_name = 'apply_type'
    ) e1 on t1.apply_type = e1.value
    left join (
        select
            name
            ,value
        from risk.dim_risk_uc_enum_df
        where enum_name = 'platform_type'
    ) e4 on t1.platform_type = e4.value
;



