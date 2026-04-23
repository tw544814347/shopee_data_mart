create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
insert overwrite table ${SCHEMA}.ads_${product}_risk_${region_lower}_af_workflow_2fa_di partition(grass_date)
select 
    t1.shopeepay_userid
    , t1.flow_no as workflow_flow_no
    ,case when lower(get_json_object(t2.output, '$.RunStep')) like '%liveness_check_init%' then 'LC'
    when lower(get_json_object(t2.output, '$.RunStep')) like '%otp_init%' then 'OTP'
    when lower(get_json_object(t2.output, '$.RunStep')) like '%tap_secure%' then 'tap_secure'
    else null end as verify_method
    , case when lower(t2.output) like '%return_result_standard_reject%' then 0
           when lower(t2.output) like '%return_result_standard_pass%' then 1
           else null end as verify_result
    , case when lower(t2.output) like '%liveness_check_init%'
            and lower(t2.output) like '%return_result_standard_reject%'
            and lower(t2.output) not like '%antifraud_60001%'
        then 'lc_timeout'
            when lower(t2.output) like '%liveness_check_init%'
            and lower(t2.output) like '%return_result_standard_reject%'
            and lower(t2.output) like '%antifraud_60001%'
        then 'lc_model_reject'
      else null end as lc_fail_reason
    ,t1.device_fingerprint
    ,t1.szdf
    ,t1.create_time
    ,t1.update_time
    , date(t1.create_time) as grass_date
from (select 
    id
    ,flow_no
    , get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.CommonHeader.shopeepay_user_id') as shopeepay_userid
    , get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.CommonHeader.device_fingerprint') as device_fingerprint
    , get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    , output
    , create_time
    , update_time
from ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_di 
) t1 
inner join 
(
    select *
    from
    ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_step_di
    where (lower(output) like '%return_result_standard_reject%' or lower(output) like '%return_result_standard_pass%')
) t2 on t1.id=t2.wfid
;
