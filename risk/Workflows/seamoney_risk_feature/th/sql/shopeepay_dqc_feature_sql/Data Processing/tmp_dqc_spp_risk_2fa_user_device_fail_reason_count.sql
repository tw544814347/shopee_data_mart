insert into table ${SCHEMA}.tmp_dqc_spp_risk_2fa_user_device_fail_reason_count_${region}
select  user_id as shopeepay_userid
        , szdf
        , fail_reason
        , count(distinct id) as result
        , min(verify_time) as beginTime
        , max(verify_time) as endTime
from    (
    select  cast(id as string) as id
            ,user_id
            ,szdf
            ,create_time as verify_time
            , case when lower(output) like '%liveness_check_init%' then 'LC'
                when lower(output) like '%otp_init%' then 'OTP'
                else '' end as verify_type
            , case when lower(output) like '%return_result_standard_reject%' then 'failed'
                when lower(output) like '%return_result_standard_pass%' then 'success'
                else 'init' end as verify_status
            , case when lower(output) like '%return_result_standard_reject%' and lower(output) like '%antifraud_60001%' then 'LC_model_reject'
                when lower(output) like '%return_result_standard_reject%' and lower(output) not like '%antifraud_60001%' then 'LC_timeout'
                else 'unknow' end as fail_reason
            ,update_time
    from    (
        select  id
                ,user_id
                ,szdf
        from    (
            select  id
                    ,get_json_object(decode(unbase64(cast(get_json_object(input, '$.Params') as string)), 'UTF-8'), '$.CommonHeader.shopeepay_user_id') as user_id
                    ,get_json_object(decode(unbase64(cast(get_json_object(input, '$.Params') as string)), 'UTF-8'), '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
            from    risk.ods__shopeepay_risk_control_${region}_db__workflow_tab
            where   create_time >= to_unix_timestamp(date_add(from_unixtime(to_unix_timestamp(cast(${SCHEDULED_DATE} as string), 'yyyyMMdd'), 'yyyy-MM-dd'), -2), 'yyyy-MM-dd')
        ) as t1
        where   user_id is not null
          and   user_id != ''
          and   szdf is not null
          and   szdf != ''
    ) as flow_tab
    join    (
        select  wfid
                ,output
                ,create_time
                ,update_time
        from    risk.ods__shopeepay_risk_control_${region}_db__workflow_steps_tab
        where   create_time >= to_unix_timestamp(date_add(from_unixtime(to_unix_timestamp(cast(${SCHEDULED_DATE} as string), 'yyyyMMdd'), 'yyyy-MM-dd'), -2), 'yyyy-MM-dd')
                and (lower(output) like '%liveness_check_init%') -- verify type
    ) as step_tab
    on      flow_tab.id = step_tab.wfid
) as tf
where   verify_type = 'LC'
  and   verify_status = 'failed'
  and   fail_reason in ('LC_timeout', 'LC_model_reject')
  and   user_id is not null
  and   user_id <> ''
  and   szdf is not null
  and   szdf <> ''
group by user_id, szdf, fail_reason
;