----------------------------------------------------------------PH----------------------------------------------------------------
create or replace temporary view filter_view as 
select 
    get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as flow_no
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as req_time
    
    ,case when (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10025', '10035'))
            or (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'spj' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10025')
            or (get_json_object(value, '$.Req.RiskReqHeader.AppID') in ('spjup', 'mcl') and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005') then cast(get_json_object(value, '$.ReqParams.LoadAmount') as bigint)
        when (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10045', '10055', '10075', '10095', '30001', '30002', '30003', '30005'))
            or (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'chp' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10045') then cast(get_json_object(value, '$.ReqParams.LoanAmount') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'fes' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005' then cast(get_json_object(value, '$.ReqParams.account_receivable') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10084' then cast(get_json_object(value, '$.ReqParams.load_amount') as bigint)
        when (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '30006'
            or get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'corploan' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005') then cast(get_json_object(value, '$.ReqParams.loan_amount') as bigint)
    end as loan_amount

    ,case when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'fes' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005' then cast(get_json_object(value, '$.ReqParams.real_account_receivable') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '30003' then cast(get_json_object(value, '$.ReqParams.RealLoanAmount') as bigint)
        else cast(get_json_object(value, '$.ReqParams.real_loan_amount') as bigint)
    end as real_loan_amount

    ,case when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10025', '10035', '10045', '10055', '10084')
        then cast(get_json_object(value, '$.ReqParams.combine_payment_amount') as bigint)
    end as combine_payment_amount

    ,case when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10025', '10035', '10045', '10055', '10084')
        then cast(get_json_object(value, '$.ReqParams.real_combine_payment_amount') as bigint)
    end as real_combine_payment_amount

    ,case when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10025', '30002') then cast(get_json_object(value, '$.ReqParams.OrderAmount') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10084', '30006') then cast(get_json_object(value, '$.ReqParams.order_amount') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'fes' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005' then cast(get_json_object(value, '$.ReqParams.outstanding_balance') as bigint)
    end as order_amount

    ,case when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10025', '10084', '30002', '30006') 
            then cast(get_json_object(value, '$.ReqParams.real_order_amount') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'fes' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005' then cast(get_json_object(value, '$.ReqParams.real_outstanding_balance') as bigint)
    end as real_order_amount

    ,get_json_object(value, '$.ReqParams.TransactionType') as transaction_type

    ,case when (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10025', '10035', '10084', '10095', '30001', '30002'))
            or (get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'spj' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10025')
            or (get_json_object(value, '$.Req.RiskReqHeader.AppID') in ('spjup', 'mcl', 'corploan') and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005') then cast(get_json_object(value, '$.ReqParams.decimal_base') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'kredit' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') in ('10045', '10055', '10075', '30003', '30005', '30006') 
            then cast(get_json_object(value, '$.ReqParams.DecimalBase') as bigint)
        when get_json_object(value, '$.Req.RiskReqHeader.AppID') = 'fes' and get_json_object(value, '$.Req.RiskReqHeader.SceneID') = '10005' then cast(get_json_object(value, '$.ReqParams.magnification') as bigint)
    end as decimal_base

    -- partition key
    ,get_json_object(value, '$.Req.RiskReqHeader.AppID') as app_id
    ,get_json_object(value, '$.Req.RiskReqHeader.SceneID') as scene_id
    ,dt
from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2 
where grass_region = '${REGION}'
    --and dt >= '${ds_t_3}'
    and dt = '${ds}'
    and (
        (tn = '${region}_live_credit_risk_gateway_req_rsp_kredit' and scene_id in ('10025', '10035', '10045', '10055', '10084', '30001', '30002', '30003', '30006'))
        or (tn = '${region}_live_credit_risk_gateway_req_rsp_spj' and scene_id = '10025')
        or (tn in ('${region}_live_credit_risk_gateway_req_rsp_spjup', '${region}_live_credit_risk_gateway_req_rsp_fes', '${region}_live_credit_risk_gateway_req_rsp_corploan') and scene_id = '10005')
    )
    and char_length(get_json_object(value, '$.Req.RiskReqHeader.FlowNo')) > 0
;

insert overwrite ${SCHEMA}.check_real_loan_amount_history partition(grass_region='${region}', app_id, scene_id, dt)
select 
    flow_no,
    req_time,

    loan_amount,
    real_loan_amount,
    combine_payment_amount,
    real_combine_payment_amount,
    order_amount,
    real_order_amount,

    transaction_type,
    decimal_base,

    -- compare
    -- 1. loan_amount vs real_loan_amount
    case when app_id = 'kredit' and scene_id in ('10045', '10055')
        then (case when abs(loan_amount - real_loan_amount) > 0 then 1 else 0 end)
        when ((app_id = 'kredit' and scene_id in ('10025', '10035', '10084', '30001', '30002')) or (app_id in ('spjup', 'fes', 'corploan') and scene_id = '10005') or (app_id = 'spj' and scene_id = '10025')) then (
            case when (decimal_base is null or decimal_base <= 0) and abs(loan_amount - real_loan_amount) > 0 then 1
                when (decimal_base is null or decimal_base <= 0) and abs(loan_amount - real_loan_amount) <= 0 then 0
                when decimal_base > 0 and abs(loan_amount / decimal_base - real_loan_amount) > 0 then 1
                when decimal_base > 0 and abs(loan_amount / decimal_base - real_loan_amount) <= 0 then 0
            end
        )
        when app_id = 'kredit' and scene_id in ('30003', '30006') then (case when abs(loan_amount / 1000000 - real_loan_amount) > 0 then 1 else 0 end)
    end as loan_amount_diff,

    -- 2. combine_payment_amount vs real_combine_payment_amount
    case when app_id = 'kredit' and scene_id in ('10045', '10055') and combine_payment_amount is not null and real_combine_payment_amount is not null then (
            case when abs(loan_amount - real_loan_amount) > 0 then 1 else 0 end
        )
        when app_id = 'kredit' and scene_id in ('10025', '10035', '10084') and combine_payment_amount is not null and real_combine_payment_amount is not null then (
            case when (decimal_base is null or decimal_base <= 0) and abs(combine_payment_amount - real_combine_payment_amount) > 0 then 1
                when (decimal_base is null or decimal_base <= 0) and abs(combine_payment_amount - real_combine_payment_amount) <= 0 then 0
                when decimal_base > 0 and abs(combine_payment_amount / decimal_base - real_combine_payment_amount) > 0 then 1
                when decimal_base > 0 and abs(combine_payment_amount / decimal_base - real_combine_payment_amount) <= 0 then 0
            end
        )
    end as combine_payment_amount_diff,

    -- 3. order_amount vs real_order_amount
    case when (((app_id = 'kredit' and scene_id in ('10025', '10084', '30002')) or (app_id = 'fes' and scene_id = '10005')) and order_amount is not null and real_order_amount is not null) then (
            case when (decimal_base is null or decimal_base <= 0) and abs(order_amount - real_order_amount) > 0 then 1
                when (decimal_base is null or decimal_base <= 0) and abs(order_amount - real_order_amount) <= 0 then 0
                when decimal_base > 0 and abs(order_amount / decimal_base - real_order_amount) > 0 then 1
                when decimal_base > 0 and abs(order_amount / decimal_base - real_order_amount) <= 0 then 0
            end
        )
        when app_id = 'kredit' and scene_id = '30006' and order_amount is not null and real_order_amount is not null 
            then (case when abs(order_amount / 1000000 - real_order_amount) > 0 then 1 else 0 end)
    end as order_amount_diff,

    app_id,
    scene_id,
    dt
from filter_view
;
