--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-26T16:23:08.830Z
-- Description:    用户在指定商家list下支付的次数和金额
--********************************************************************--

--add JAR hdfs://R2/user/huangyue/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar;
DROP TEMPORARY FUNCTION IF EXISTS to_bitmap;
create TEMPORARY function to_bitmap as 'com.shopee.udf.UidToRoaring64Bitmap' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-uid-to-bitmap-1.0-SNAPSHOT.jar';

create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';

create or replace temporary view filter_view as 
select 
    cur_sceneid, scene_id, req_time, shopeepay_user_id, pay_id, shop_id, transaction_type, load_amount, decimal_base
from (
    select 
        app_id || '_' || scene_id as cur_sceneid,
        scene_id,
        req_time,
        shopeepay_user_id,
        pay_id,
        shop_id,
        transaction_type,
        load_amount,
        decimal_base,
        row_number() over (partition by app_id, scene_id, pay_id order by req_time desc) as rn
    from risk.dwd_request_log_payment_success_rt t1
    where grass_region = '${region_lower}'
        and dt >= '${begin_date}'
        and app_id = 'kredit'
        and scene_id in ('10035', '10045', '10055', '10075', '10185')
        and char_length(pay_id) > 0
        and char_length(shop_id) > 0
        and req_time > 0
) t where rn = 1
;

create or replace temporary view union_view as 
select 
    shopeepay_user_id, req_time, pay_id, cur_sceneid, shop_id, verify_type,

    case when decimal_base > 0
        then cast((cast(load_amount as DECIMAL(20, 6)) / decimal_base) as DECIMAL(20, 6))
        else cast(load_amount as DECIMAL(20, 6))
    end as amount
from (
    select 
        shopeepay_user_id, req_time, pay_id, cur_sceneid,
        get_json_object(tbl.order_info, '$.SellerId') as shop_id,
        cast(get_json_object(tbl.order_info, '$.OrderAmount') as bigint) as load_amount,
        cast(get_json_object(tbl.order_info, '$.decimal_base') as bigint) as decimal_base,
        'shop_id' as verify_type
    from filter_view
    lateral view explode(json_to_array(shop_id)) tbl as order_info
    where scene_id = '10035'
    union all 
    select 
        shopeepay_user_id, req_time, pay_id, cur_sceneid, shop_id, load_amount, decimal_base,
        case when scene_id = '10075' then 'store_id' else 'unique_merchant_id' end as verify_type
    from filter_view
    where scene_id in ('10075', '10095')
    union all 
    -- 10045/10055 unique_merchant_id_string
    select 
        shopeepay_user_id, req_time, pay_id,
        case when scene_id = '10045' then cur_sceneid || '_' || lower(transaction_type) else cur_sceneid end as cur_sceneid,
        get_json_object(shop_id, '$.unique_merchant_id_string') as shop_id,
        load_amount, 
        decimal_base,
        'unique_merchant_id_string' as verify_type
    from filter_view
    where (scene_id = '10055') or (scene_id = '10045' and transaction_type in ('C2B', 'JUMPAPP'))
    union all 
    -- 10045/10055 mer_merchant_id_string
    select 
        shopeepay_user_id, req_time, pay_id,
        case when scene_id = '10045' then cur_sceneid || '_' || lower(transaction_type) else cur_sceneid end as cur_sceneid,
        get_json_object(shop_id, '$.mer_merchant_id_string') as shop_id,
        load_amount, 
        decimal_base,
        'mer_merchant_id_string' as verify_type
    from filter_view
    where (scene_id = '10055') or (scene_id = '10045' and transaction_type in ('C2B', 'JUMPAPP'))
    union all 
    -- 10185 card_acceptor_name
    select 
        shopeepay_user_id, req_time, pay_id, cur_sceneid,
        get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.cardAcceptorName') as shop_id,
        cast(cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) * ${default_decimal_base} as bigint) as loan_amount,
        ${default_decimal_base} as decimal_base,
        'card_acceptor_name' as verify_type
    from filter_view
    where scene_id = '10185'
        and char_length(get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.cardAcceptorName')) > 0
        and cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) is not null
    union all 
    -- 10185 card_acceptor_id
    select 
        shopeepay_user_id, req_time, pay_id, cur_sceneid,
        get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.cardAcceptorId') as shop_id,
        cast(cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) * ${default_decimal_base} as bigint) as loan_amount,
        ${default_decimal_base} as decimal_base,
        'card_acceptor_id' as verify_type
    from filter_view
    where scene_id = '10185'
        and char_length(get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.cardAcceptorId')) > 0
        and cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) is not null
    union all 
    -- 10185 acquiring_institution_id
    select 
        shopeepay_user_id, req_time, pay_id, cur_sceneid,
        get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.acquiringInstitutionId') as shop_id,
        cast(cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) * ${default_decimal_base} as bigint) as loan_amount,
        ${default_decimal_base} as decimal_base,
        'acquiring_institution_id' as verify_type
    from filter_view
    where scene_id = '10185'
        and char_length(get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.acquiringInstitutionId')) > 0
        and cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) is not null
    union all 
    -- 10185 card_unique_merchant_id
    select 
        shopeepay_user_id, req_time, pay_id, cur_sceneid,
        concat(get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.acquiringInstitutionId'), 
            get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.cardAcceptorId')) as shop_id,
        cast(cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) * ${default_decimal_base} as bigint) as loan_amount,
        ${default_decimal_base} as decimal_base,
        'card_unique_merchant_id' as verify_type
    from filter_view
    where scene_id = '10185'
        and char_length(get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.acquiringInstitutionId')) > 0
        and char_length(get_json_object(get_json_object(shop_id, '$.card_authorization_cis_req_params.payment_context'), '$.cardAcceptorId')) > 0
        and cast(get_json_object(shop_id, '$.card_authorization_cis_req_params.real_loan_amount') as DECIMAL(20, 6)) is not null

    union all
     -- 10045/10055 aplus_acquire_merchant_id
    select 
        shopeepay_user_id, req_time, pay_id,
        concat_ws('_', cur_sceneid, if(scene_id = '10045', 'csb_aplus', 'bsc_aplus')) as cur_sceneid,
        concat(get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_acquirer_id'), get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_merchant_id')) as shop_id,
        load_amount, 
        decimal_base,
        'aplus_acquire_merchant_id' as verify_type
    from filter_view
    where scene_id in ('10055', '10045')
        and char_length(get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_acquirer_id')) > 0
        and char_length(get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_merchant_id')) > 0
        and get_json_object(shop_id, '$.merchant_type') = 'aplus'

    union all
     -- 10045/10055 aplus_acquire_store_id
    select 
        shopeepay_user_id, req_time, pay_id,
        concat_ws('_', cur_sceneid, if(scene_id = '10045', 'csb_aplus', 'bsc_aplus')) as cur_sceneid,
        concat(get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_acquirer_id'), get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_store_id')) as shop_id,
        load_amount, 
        decimal_base,
        'aplus_acquire_store_id' as verify_type
    from filter_view
    where scene_id in ('10055', '10045')
        and char_length(get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_acquirer_id')) > 0
        and char_length(get_json_object(get_json_object(shop_id, '$.aplus_info'), '$.aplus_store_id')) > 0
        and get_json_object(shop_id, '$.merchant_type') = 'aplus'

    union all 
    -- 10045/10055 unique_merchant_id_string
    select 
        shopeepay_user_id, req_time, pay_id,
        case when scene_id = '10045' then cur_sceneid || '_' || lower(transaction_type) else cur_sceneid end as cur_sceneid,
        concat(get_json_object(shop_id, '$.unique_merchant_id_string'), get_json_object(shop_id, '$.promptpay_bill_reference1')) as shop_id,
        load_amount, 
        decimal_base,
        'promptpay_bill_reference1_merchant_id' as verify_type
    from filter_view
    where ((scene_id = '10055') or (scene_id = '10045' and transaction_type in ('C2B', 'JUMPAPP')))
        and char_length(get_json_object(shop_id, '$.unique_merchant_id_string')) > 0
        and char_length(get_json_object(shop_id, '$.promptpay_bill_reference1')) > 0
) t where char_length(shop_id) > 0
;

-- 关联维表并炸开
create or replace temporary view final_detail_view as 
select 
    t1.shopeepay_user_id
    ,floor(t1.req_time / 86400) * 86400 as req_time_d
    ,t1.pay_id
    ,t1.cur_sceneid
    ,t1.shop_id
    ,t1.verify_type
    ,t1.amount
    ,split(tbl.custom_list_info, '_')[0] as data_type
    ,split(tbl.custom_list_info, '_')[1] as custom_list_id
from (
    select 
        t.shopeepay_user_id
        ,t.req_time
        ,t.pay_id
        ,t.cur_sceneid
        ,t.shop_id
        ,t.verify_type
        ,t.amount
        ,split(sc.custom_list_infos, ',') as custom_list_infos_array
    from union_view t
    inner join 
    (
        select 
            shop_id, custom_list_infos
        from risk.dim_risk_af_shop_to_custom_list_df
        where grass_region = '${region_lower}' and grass_date = '${ds}'
    ) sc 
    on t.shop_id = sc.shop_id
    where sc.custom_list_infos is not null 
        and char_length(sc.custom_list_infos) > 0
    ) t1
    lateral view explode(custom_list_infos_array) tbl as custom_list_info
;

-- 获取聚合结果
create or replace temporary view final_aggregation_view as 
select 
    concat_ws('_', substr(md5(shopeepay_user_id), 0, 2), '2', shopeepay_user_id, data_type, custom_list_id, req_time_d) as rowkey
    ,cur_sceneid
    ,verify_type
    ,to_bitmap(concat_ws(',', collect_set(pay_id))) as agg_count
    ,cast(sum(amount) as string) as agg_amount
from final_detail_view 
where data_type is not null 
    and custom_list_id is not null
    and char_length(shopeepay_user_id) > 0
group by shopeepay_user_id, req_time_d, data_type, custom_list_id, cur_sceneid, verify_type
;

-- 数据插入
insert overwrite table risk.dws_risk_af_user_payment_in_shop_list_dfs_df partition (grass_region = '${region_lower}', grass_date = '${ds}')
select
    rowkey
    ,max(case when cur_sceneid = 'kredit_10035' and verify_type = 'shop_id' then agg_amount else null end) as kredit_10035_shop_id
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'mer_merchant_id_string' then agg_amount else null end) as kredit_10045_c2b_mer_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string_terminal_label
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string_store_label_terminal_label
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string_gcash' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string_gcash
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'mer_merchant_id_string' then agg_amount else null end) as kredit_10045_jumpapp_mer_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string_terminal_label
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string_store_label_terminal_label
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string_gcash' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string_gcash
    ,max(case when cur_sceneid = 'kredit_10045_p2p' and verify_type = 'p2p_bank_account_id' then agg_amount else null end) as kredit_10045_p2p_p2p_bank_account_id
    ,max(case when cur_sceneid = 'kredit_10045_p2p' and verify_type = 'p2p_bank_account_name' then agg_amount else null end) as kredit_10045_p2p_p2p_bank_account_name
    ,max(case when cur_sceneid = 'kredit_10045_p2p' and verify_type = 'acquirer_unique_merchant_id_string' then agg_amount else null end) as kredit_10045_p2p_acquirer_unique_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10045_VNPay' and verify_type = 'acquirer_unique_merchant_id_string' then agg_amount else null end) as kredit_10045_VNPay_acquirer_unique_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10045_VNPay' and verify_type = 'acquirer_unique_merchant_id_string_terminal_label' then agg_amount else null end) as kredit_10045_VNPay_acquirer_unique_merchant_id_string_terminal_label
    ,max(case when cur_sceneid = 'kredit_10045_csb_aplus' and verify_type = 'aplus_acquire_merchant_id' then agg_amount else null end) as kredit_10045_csb_aplus_aplus_acquire_merchant_id
    ,max(case when cur_sceneid = 'kredit_10045_csb_aplus' and verify_type = 'aplus_acquire_store_id' then agg_amount else null end) as kredit_10045_csb_aplus_aplus_acquire_store_id
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'promptpay_bill_reference1_merchant_id' then agg_amount else null end) as kredit_10045_c2b_promptpay_bill_reference1_merchant_id
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'promptpay_bill_reference1_merchant_id' then agg_amount else null end) as kredit_10045_jumpapp_promptpay_bill_reference1_merchant_id
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string' then agg_amount else null end) as kredit_10055_unique_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'mer_merchant_id_string' then agg_amount else null end) as kredit_10055_mer_merchant_id_string
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_amount else null end) as kredit_10055_unique_merchant_id_string_terminal_label
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_amount else null end) as kredit_10055_unique_merchant_id_string_store_label_terminal_label
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string_gcash' then agg_amount else null end) as kredit_10055_unique_merchant_id_string_gcash
    ,max(case when cur_sceneid = 'kredit_10055_bsc_aplus' and verify_type = 'aplus_acquire_merchant_id' then agg_amount else null end) as kredit_10055_bsc_aplus_aplus_acquire_merchant_id
    ,max(case when cur_sceneid = 'kredit_10055_bsc_aplus' and verify_type = 'aplus_acquire_store_id' then agg_amount else null end) as kredit_10055_bsc_aplus_aplus_acquire_store_id
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'promptpay_bill_reference1_merchant_id' then agg_amount else null end) as kredit_10055_promptpay_bill_reference1_merchant_id
    ,max(case when cur_sceneid = 'kredit_10075' and verify_type = 'store_id' then agg_amount else null end) as kredit_10075_store_id
    ,max(case when cur_sceneid = 'kredit_10095' and verify_type = 'unique_merchant_id' then agg_amount else null end) as kredit_10095_unique_merchant_id
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'card_acceptor_name' then agg_amount else null end) as kredit_10185_card_acceptor_name
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'card_acceptor_id' then agg_amount else null end) as kredit_10185_card_acceptor_id
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'acquiring_institution_id' then agg_amount else null end) as kredit_10185_acquiring_institution_id
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'card_unique_merchant_id' then agg_amount else null end) as kredit_10185_card_unique_merchant_id
    ,max(case when cur_sceneid = 'kredit_10035' and verify_type = 'shop_id' then agg_count else null end) as kredit_10035_shop_id_unq
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'mer_merchant_id_string' then agg_count else null end) as kredit_10045_c2b_mer_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_store_label_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'unique_merchant_id_string_gcash' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_gcash_unq
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'mer_merchant_id_string' then agg_count else null end) as kredit_10045_jumpapp_mer_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_store_label_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'unique_merchant_id_string_gcash' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_gcash_unq
    ,max(case when cur_sceneid = 'kredit_10045_p2p' and verify_type = 'p2p_bank_account_id' then agg_count else null end) as kredit_10045_p2p_p2p_bank_account_id_unq
    ,max(case when cur_sceneid = 'kredit_10045_p2p' and verify_type = 'p2p_bank_account_name' then agg_count else null end) as kredit_10045_p2p_p2p_bank_account_name_unq
    ,max(case when cur_sceneid = 'kredit_10045_p2p' and verify_type = 'acquirer_unique_merchant_id_string' then agg_count else null end) as kredit_10045_p2p_acquirer_unique_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10045_VNPay' and verify_type = 'acquirer_unique_merchant_id_string' then agg_count else null end) as kredit_10045_VNPay_acquirer_unique_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10045_VNPay' and verify_type = 'acquirer_unique_merchant_id_string_terminal_label' then agg_count else null end) as kredit_10045_VNPay_acquirer_unique_merchant_id_string_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10045_csb_aplus' and verify_type = 'aplus_acquire_merchant_id' then agg_count else null end) as kredit_10045_csb_aplus_aplus_acquire_merchant_id_unq
    ,max(case when cur_sceneid = 'kredit_10045_csb_aplus' and verify_type = 'aplus_acquire_store_id' then agg_count else null end) as kredit_10045_csb_aplus_aplus_acquire_store_id_unq
    ,max(case when cur_sceneid = 'kredit_10045_c2b' and verify_type = 'promptpay_bill_reference1_merchant_id' then agg_count else null end) as kredit_10045_c2b_promptpay_bill_reference1_merchant_id_unq
    ,max(case when cur_sceneid = 'kredit_10045_jumpapp' and verify_type = 'promptpay_bill_reference1_merchant_id' then agg_count else null end) as kredit_10045_jumpapp_promptpay_bill_reference1_merchant_id_unq
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string' then agg_count else null end) as kredit_10055_unique_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'mer_merchant_id_string' then agg_count else null end) as kredit_10055_mer_merchant_id_string_unq
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_count else null end) as kredit_10055_unique_merchant_id_string_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_count else null end) as kredit_10055_unique_merchant_id_string_store_label_terminal_label_unq
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'unique_merchant_id_string_gcash' then agg_count else null end) as kredit_10055_unique_merchant_id_string_gcash_unq
    ,max(case when cur_sceneid = 'kredit_10055_bsc_aplus' and verify_type = 'aplus_acquire_merchant_id' then agg_count else null end) as kredit_10055_bsc_aplus_aplus_acquire_merchant_id_unq
    ,max(case when cur_sceneid = 'kredit_10055_bsc_aplus' and verify_type = 'aplus_acquire_store_id' then agg_count else null end) as kredit_10055_bsc_aplus_aplus_acquire_store_id_unq
    ,max(case when cur_sceneid = 'kredit_10055' and verify_type = 'promptpay_bill_reference1_merchant_id' then agg_count else null end) as kredit_10055_promptpay_bill_reference1_merchant_id_unq
    ,max(case when cur_sceneid = 'kredit_10075' and verify_type = 'store_id' then agg_count else null end) as kredit_10075_store_id_unq
    ,max(case when cur_sceneid = 'kredit_10095' and verify_type = 'unique_merchant_id' then agg_count else null end) as kredit_10095_unique_merchant_id_unq
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'card_acceptor_name' then agg_count else null end) as kredit_10185_card_acceptor_name_unq
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'card_acceptor_id' then agg_count else null end) as kredit_10185_card_acceptor_id_unq
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'acquiring_institution_id' then agg_count else null end) as kredit_10185_acquiring_institution_id_unq
    ,max(case when cur_sceneid = 'kredit_10185' and verify_type = 'card_unique_merchant_id' then agg_count else null end) as kredit_10185_card_unique_merchant_id_unq
from final_aggregation_view
group by rowkey
;