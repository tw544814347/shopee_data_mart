-- update: 2023-10-23
-- comment: update by user https://jira.shopee.io/browse/SPFDT-23835

-- -- 因为数据量较小,新产品近期上线, 先跑全量的数据 from 2023-05-09
-- insert overwrite  table risk.ads_risk_id_af_imei_price_df partition(grass_date ='${grass_date}')
-- select
-- substr(imei,1,8)                  as imei_sub
-- ,max(loanamount)                   as max_loanamount
-- ,approx_percentile(loanamount,0.5) as medium_loanamount
-- ,min(loanamount)                   as min_loanamount
-- ,sum(1)                            as cnt_req 
-- from 
-- (
--     select  
--         flow_no
--         ,get_json_object(get_json_object(extension, '$.CheckOutDetail'), '$.handphone_loan_info.imei') as imei
--         ,cast(get_json_object(extension, '$.LoanAmount') as bigint) as loanamount
--         ,grass_date
--     from risk.dwd_risk_id_strategy_final_result_merge_di a
--     where  topic_name ='id_live_credit_risk_gateway_req_rsp_chp'
--     -- and grass_date>='${grass_date}'
--     and grass_date>='2023-05-09'
--     and scene_id  in (10044)
--     and app_id in ('chp')
-- )
-- group by substr(imei,1,8) 
-- ;


-- create or replace temporary view flag_split_payment as
--     select  
--         order_sn 
--     from smcdrisk_antifraud.f_id_hpl_sentraponsel_case
--     where flag_split_payment = 'Yes';

-- -- down
-- create or replace temporary view merchant_info as 
-- -- mer as 
--     select  
--          t1.user_id as sid
--         ,t1.transaction_sn
--         ,t1.amount/100000 as amount
--         ,t1.extinfo.buyer_id
--         ,t1.extinfo.completed_time
--     from shopeepay.wallet_id_merchant_db__transaction_tab__reg_daily_s0_live t1 
--     join (
--         select  
--             order_sn 
--         from smcdrisk_antifraud.f_id_hpl_sentraponsel_case
--         where flag_split_payment = 'Yes'
--         group by order_sn 
--     ) t2 on t1.transaction_sn = t2.order_sn 
--     where  t1.transaction_type = 13
--     and  t1.extinfo.payment_channel_setting.payment_method_name = 'Cicilan HP'
-- ;

-- create or replace temporary view buyer_info as 
-- -- ,buyer as 
--     select  
--         platform_user_id
--         ,seller_id
--         ,ref_id
--         ,cast(get_json_object(_event, '$.ts') as bigint) as ts
--     -- from credit.ods__credit_spl_transaction_id_db__order_info_tab
--     from credit.ods__credit_spl_transaction_id_db__order_info_tab__df
--     where grass_date ='${grass_date}' 
--     and channel_id = 8
--     and  seller_name <> 'Loan Test Store'
--     ;

-- create or replace temporary view merchant_buyer_info as 
-- -- ,link as 
--     select 
--         distinct ref_id
--     from merchant_info mer
--     join buyer_info buyer on cast(mer.sid as bigint) = cast(buyer.seller_id as bigint)
--       and cast(buyer.platform_user_id as bigint) = cast(mer.buyer_id as bigint)
--       and mer.completed_time between buyer.ts and buyer.ts + 10
-- ;
-- insert overwrite  table risk.ads_risk_id_af_imei_price_df partition(grass_date ='${grass_date}')
-- select  
--     substr(imei, 1, 8) as imei_sub
--     ,max(loanamount) as max_loanamount
--     ,approx_percentile(loanamount, 0.5) as medium_loanamount
--     ,min(loanamount) as min_loanamount
--     ,count(distinct flow_no) as cnt_req
-- from(     
--         select  
--             flow_no
--             ,get_json_object(extension, '$.ReferenceID') as referenceid
--             ,get_json_object(get_json_object(extension, '$.CheckOutDetail'), '$.handphone_loan_info.imei') as imei
--             ,cast(get_json_object(extension, '$.LoanAmount') as bigint) as loanamount
--             ,grass_date
--         from risk.dwd_risk_id_strategy_final_result_merge_di a
--         where grass_date >= '2023-05-09'
--         and topic_name ='id_live_credit_risk_gateway_req_rsp_chp'
--         and scene_id  in (10044)
--         and app_id in ('chp')
--         group by 
--         flow_no
--         ,get_json_object(extension, '$.ReferenceID') 
--         ,get_json_object(get_json_object(extension, '$.CheckOutDetail'), '$.handphone_loan_info.imei') 
--         ,cast(get_json_object(extension, '$.LoanAmount') as bigint)
--         ,grass_date
-- ) t1 
-- left join merchant_buyer_info t2 on t1.referenceid = t2.ref_id
-- -- where referenceid not in (select ref_id from link)
-- where t2.ref_id is null
-- group by substr(imei, 1, 8)
-- ;

-- 直接读
insert overwrite  table risk.ads_risk_id_af_imei_price_df partition(grass_date ='${grass_date}')
select  
    imei_sub           as imei_sub
    ,max_loanamount    as max_loanamount
    ,medium_loanamount as medium_loanamount
    ,min_loanamount    as min_loanamount
    ,cnt_req            as cnt_req
from Smcdrisk_antifraud.f_id_cicilan_imei_price_agg_df
where grass_date ='${grass_date}'