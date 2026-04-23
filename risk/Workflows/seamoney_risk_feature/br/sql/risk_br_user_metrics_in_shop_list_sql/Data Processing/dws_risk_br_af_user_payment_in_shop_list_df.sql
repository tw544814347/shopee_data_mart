--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-26T16:23:08.830Z
-- Description:    用户在指定商家list下支付的次数和金额
--********************************************************************--

--add JAR hdfs://R2/user/huangyue/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar;
DROP TEMPORARY FUNCTION IF EXISTS to_bitmap;
create TEMPORARY function to_bitmap as 'com.shopee.udf.UidToRoaring64Bitmap' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-uid-to-bitmap-1.0-SNAPSHOT.jar';

create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';

-- kredit 10035 detail view
create or replace temporary view kredit_10035_detail_view as
select 
    t.app_id 
    ,t.scene_id
    ,t.req_time
    ,t.platform_user_id
    ,t.device_fingerprint
    ,t.app_type
    ,t.szdf
    ,t.order_id
    ,get_json_object(tbl.order_info, '$.SellerId') as shop_id
    ,cast(get_json_object(tbl.order_info, '$.OrderAmount') as bigint) as loan_amount
    ,cast(get_json_object(tbl.order_info, '$.decimal_base') as bigint) as decimal_base
from 
	(
	select 
	    get_json_object(value, '$.Req.RiskReqHeader.AppID') as app_id
	    ,get_json_object(value, '$.Req.RiskReqHeader.SceneID') as scene_id
        ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as req_time
	
	    ,get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id') as platform_user_id
	    ,trim(replace(get_json_object(value, '$.ReqParams.CommonHeader.device_fingerprint'), '_', '-')) as device_fingerprint
	    ,trim(replace(get_json_object(value, '$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id'), '_', '-')) as szdf
	
	    ,get_json_object(value, '$.ReqParams.CheckOutId') as order_id
        ,get_json_object(value, '$.ReqParams.OrderInfo') as order_info
        ,get_json_object(get_json_object(value, '$.ReqParams.CommonHeader.risk_device_info'), '$.app_type') as app_type
	from ${SCHEMA}.dwd_risk_af_payment_success_join_df t1
	where grass_region = '${region}'
	    and grass_date >= '${begin_date}'
	    and app_id = 'kredit'
	    and scene_id = '10035'
	    and get_json_object(value, '$.ReqParams.CheckOutId') is not null 
	    and char_length(get_json_object(value, '$.ReqParams.CheckOutId')) > 0
	    and char_length(get_json_object(value, '$.Req.RiskReqHeader.ReqTime')) >= 10
	    and get_json_object(value, '$.ReqParams.OrderInfo') is not null
	) t
	lateral view explode(json_to_array(t.order_info)) tbl as order_info
;

-- kredit 10045/10055 detail view
create or replace temporary view kredit_10045_10055_detail_view as
select 
    get_json_object(value, '$.Req.RiskReqHeader.AppID') as app_id
    ,get_json_object(value, '$.Req.RiskReqHeader.SceneID') as scene_id
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as req_time

    ,get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id') as platform_user_id
    ,trim(replace(get_json_object(value, '$.ReqParams.CommonHeader.device_fingerprint'), '_', '-')) as device_fingerprint
    ,trim(replace(get_json_object(value, '$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id'), '_', '-')) as szdf

    ,get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as order_id
    ,get_json_object(get_json_object(value, '$.ReqParams.CheckOutDetail'), '$.unique_merchant_id_string') as unique_merchant_id_string
    ,get_json_object(get_json_object(value, '$.ReqParams.CheckOutDetail'), '$.mer_merchant_id_string') as mer_merchant_id_string

    ,cast(get_json_object(value, '$.ReqParams.LoanAmount') as bigint) as loan_amount
    ,cast(get_json_object(value, '$.ReqParams.DecimalBase') as bigint) as decimal_base
    ,get_json_object(value, '$.ReqParams.TransactionType') as transaction_type
    ,get_json_object(get_json_object(value, '$.ReqParams.CommonHeader.risk_device_info'), '$.app_type') as app_type
from ${SCHEMA}.dwd_risk_af_payment_success_join_df t1
where grass_region = '${region}'
    and grass_date >= '${begin_date}'
    and app_id = 'kredit'
    and scene_id in ('10045', '10055')
    and get_json_object(value, '$.Req.RiskReqHeader.FlowNo') is not null 
    and char_length(get_json_object(value, '$.Req.RiskReqHeader.FlowNo')) > 0
    and char_length(get_json_object(value, '$.Req.RiskReqHeader.ReqTime')) >= 10
    and get_json_object(value, '$.ReqParams.CheckOutDetail') is not null
    and char_length(get_json_object(value, '$.ReqParams.CheckOutDetail')) >= 10
;

-- kredit 10075 detail view
create or replace temporary view kredit_10075_detail_view as
select 
    get_json_object(value, '$.Req.RiskReqHeader.AppID') as app_id
    ,get_json_object(value, '$.Req.RiskReqHeader.SceneID') as scene_id
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as req_time

    ,get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id') as platform_user_id
    ,trim(replace(get_json_object(value, '$.ReqParams.CommonHeader.device_fingerprint'), '_', '-')) as device_fingerprint
    ,trim(replace(get_json_object(value, '$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id'), '_', '-')) as szdf

    ,get_json_object(value, '$.ReqParams.PayId') as order_id
    ,get_json_object(value, '$.ReqParams.FoodPayInfoDetail.store_id') as shop_id

    ,cast(get_json_object(value, '$.ReqParams.LoanAmount') as bigint) as loan_amount
    ,cast(get_json_object(value, '$.ReqParams.DecimalBase') as bigint) as decimal_base
    ,get_json_object(get_json_object(value, '$.ReqParams.CommonHeader.risk_device_info'), '$.app_type') as app_type
from ${SCHEMA}.dwd_risk_af_payment_success_join_df t1
where grass_region = '${region}'
    and grass_date >= '${begin_date}'
    and app_id = 'kredit'
    and scene_id = '10075'
    and get_json_object(value, '$.ReqParams.PayId') is not null 
    and char_length(get_json_object(value, '$.ReqParams.PayId')) > 0
    and char_length(get_json_object(value, '$.Req.RiskReqHeader.ReqTime')) >= 10
    and get_json_object(value, '$.ReqParams.FoodPayInfoDetail.store_id') is not null
    and char_length(get_json_object(value, '$.ReqParams.FoodPayInfoDetail.store_id')) > 0
;

-- 数据源整合
create or replace temporary view combine_view as 
select 
    'shop_id' as verify_type

    ,app_id
    ,scene_id
    ,req_time
    ,platform_user_id
    ,device_fingerprint
    ,app_type
    ,szdf
    ,order_id
    
    ,shop_id
    ,case when decimal_base > 0
        then cast((cast(loan_amount as DECIMAL(20, 6)) / decimal_base) as DECIMAL(20, 6))
        else cast(loan_amount as DECIMAL(20, 6))
    end as amount
    ,null as transaction_type
from kredit_10035_detail_view
group by app_id, scene_id, req_time, platform_user_id, device_fingerprint, app_type, szdf, order_id, shop_id, loan_amount, decimal_base, transaction_type
union all
select 
    'unique_merchant_id_string' as verify_type

    ,app_id
    ,scene_id
    ,req_time
    ,platform_user_id
    ,device_fingerprint
    ,app_type
    ,szdf
    ,order_id
    
    ,unique_merchant_id_string as shop_id
    ,case when decimal_base > 0
        then cast((cast(loan_amount as DECIMAL(20, 6)) / decimal_base) as DECIMAL(20, 6))
        else cast(loan_amount as DECIMAL(20, 6))
    end as amount
    ,transaction_type
from kredit_10045_10055_detail_view where unique_merchant_id_string is not null and char_length(unique_merchant_id_string) > 0
group by app_id, scene_id, req_time, platform_user_id, device_fingerprint, app_type, szdf, order_id, unique_merchant_id_string, loan_amount, decimal_base, transaction_type
union all 
select 
    'mer_merchant_id_string' as verify_type

    ,app_id
    ,scene_id
    ,req_time
    ,platform_user_id
    ,device_fingerprint
    ,app_type
    ,szdf
    ,order_id
    
    ,mer_merchant_id_string as shop_id
    ,case when decimal_base > 0
        then cast((cast(loan_amount as DECIMAL(20, 6)) / decimal_base) as DECIMAL(20, 6))
        else cast(loan_amount as DECIMAL(20, 6))
    end as amount
    ,transaction_type
from kredit_10045_10055_detail_view where unique_merchant_id_string is not null and char_length(mer_merchant_id_string) > 0
group by app_id, scene_id, req_time, platform_user_id, device_fingerprint, app_type, szdf, order_id, mer_merchant_id_string, loan_amount, decimal_base, transaction_type
union all 
select 
    'store_id' as verify_type

    ,app_id
    ,scene_id
    ,req_time
    ,platform_user_id
    ,device_fingerprint
    ,app_type
    ,szdf
    ,order_id
    
    ,shop_id
    ,case when decimal_base > 0
        then cast((cast(loan_amount as DECIMAL(20, 6)) / decimal_base) as DECIMAL(20, 6))
        else cast(loan_amount as DECIMAL(20, 6))
    end as amount
    ,null as transaction_type
from kredit_10075_detail_view
group by app_id, scene_id, req_time, platform_user_id, device_fingerprint, app_type, szdf, order_id, shop_id, loan_amount, decimal_base, transaction_type
;

-- 关联维表并炸开
create or replace temporary view final_detail_view as 
select 
    t1.verify_type
    ,t1.app_id
    ,t1.scene_id
    ,t1.req_time
    ,t1.platform_user_id
    ,t1.device_fingerprint
    ,t1.app_type
    ,t1.szdf
    ,t1.order_id
    ,t1.shop_id
    ,t1.amount
    ,t1.transaction_type
    ,split(tbl.custom_list_info, '_')[0] as data_type
    ,split(tbl.custom_list_info, '_')[1] as custom_list_id
from (
    select 
        t.verify_type
        ,t.app_id
        ,t.scene_id
        ,t.req_time
        ,t.platform_user_id
        ,t.device_fingerprint
        ,t.app_type
        ,t.szdf
        ,t.order_id
        ,t.shop_id
        ,t.amount
        ,t.transaction_type
        ,split(sc.custom_list_infos, ',') as custom_list_infos_array
    from combine_view t
    inner join 
    (
        select 
            shop_id, custom_list_infos
        from ${SCHEMA}.dim_risk_af_shop_to_custom_list_df
        where grass_region = '${region}' and grass_date = '${ds}'
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
    concat_ws('_', substr(md5(platform_user_id), 0, 2), '1', platform_user_id, data_type, custom_list_id, floor(req_time/86400) * 86400) as rowkey
    ,app_id
    ,scene_id
    ,verify_type
    ,transaction_type
    ,to_bitmap(concat_ws(',', collect_set(order_id))) as agg_count
    ,cast(sum(amount) as string) as agg_amount
from final_detail_view 
where data_type is not null 
    and custom_list_id is not null
    and platform_user_id is not null
    and char_length(platform_user_id) > 0
group by platform_user_id, floor(req_time/86400) * 86400, data_type, custom_list_id, app_id, scene_id, verify_type, transaction_type
union all 
select 
    concat_ws('_', substr(md5(device_fingerprint), 0, 2), '2', device_fingerprint, data_type, custom_list_id, floor(req_time/86400) * 86400) as rowkey
    ,app_id
    ,scene_id
    ,verify_type
    ,transaction_type
    ,to_bitmap(concat_ws(',', collect_set(order_id))) as agg_count
    ,cast(sum(amount) as string) as agg_amount
from final_detail_view 
where data_type is not null 
    and custom_list_id is not null
    and device_fingerprint is not null
    and char_length(device_fingerprint) > 0
    --and (app_type is null or app_type <> '5')
group by device_fingerprint, floor(req_time/86400) * 86400, data_type, custom_list_id, app_id, scene_id, verify_type, transaction_type
union all
select 
    concat_ws('_', substr(md5(szdf), 0, 2), '3', szdf, data_type, custom_list_id, floor(req_time/86400) * 86400) as rowkey
    ,app_id
    ,scene_id
    ,verify_type
    ,transaction_type
    ,to_bitmap(concat_ws(',', collect_set(order_id))) as agg_count
    ,cast(sum(amount) as string) as agg_amount
from final_detail_view 
where data_type is not null 
    and custom_list_id is not null
    and szdf is not null
    and char_length(szdf) > 0
group by szdf, floor(req_time/86400) * 86400, data_type, custom_list_id, app_id, scene_id, verify_type, transaction_type
;

-- 数据插入
insert overwrite table ${SCHEMA}.dws_risk_af_user_payment_in_shop_list_df partition (grass_region = '${region}', grass_date = '${ds}')
select 
    rowkey 
    ,max(case when app_id = 'kredit' and scene_id = '10035' and verify_type = 'shop_id' then agg_amount else null end) as kredit_10035_shop_id 
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string' and transaction_type = 'C2B' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string 
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'mer_merchant_id_string' and transaction_type = 'C2B' then agg_amount else null end) as kredit_10045_c2b_mer_merchant_id_string
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_terminal_label' and transaction_type = 'C2B' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string_terminal_label
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' and transaction_type = 'C2B' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string_store_label_terminal_label
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_gcash' and transaction_type = 'C2B' then agg_amount else null end) as kredit_10045_c2b_unique_merchant_id_string_gcash
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string' and transaction_type = 'JUMPAPP' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'mer_merchant_id_string' and transaction_type = 'JUMPAPP' then agg_amount else null end) as kredit_10045_jumpapp_mer_merchant_id_string
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_terminal_label' and transaction_type = 'JUMPAPP' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string_terminal_label
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' and transaction_type = 'JUMPAPP' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string_store_label_terminal_label
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_gcash' and transaction_type = 'JUMPAPP' then agg_amount else null end) as kredit_10045_jumpapp_unique_merchant_id_string_gcash
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string' then agg_amount else null end) as kredit_10055_unique_merchant_id_string
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'mer_merchant_id_string' then agg_amount else null end) as kredit_10055_mer_merchant_id_string
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_amount else null end) as kredit_10055_unique_merchant_id_string_terminal_label
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_amount else null end) as kredit_10055_unique_merchant_id_string_store_label_terminal_label
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string_gcash' then agg_amount else null end) as kredit_10055_unique_merchant_id_string_gcash
    ,max(case when app_id = 'kredit' and scene_id = '10075' and verify_type = 'store_id' then agg_amount else null end) as kredit_10075_store_id
    ,max(case when app_id = 'kredit' and scene_id = '10095' and verify_type = 'unique_merchant_id' then agg_amount else null end) as kredit_10095_unique_merchant_id
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'acquirer_unique_merchant_id_string' and transaction_type = 'C2BP2P' then agg_amount else null end) as kredit_10045_p2p_acquirer_unique_merchant_id_string
    ,max(case when app_id = 'kredit' and scene_id = '10035' and verify_type = 'shop_id' then agg_count else null end) as kredit_10035_shop_id_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string' and transaction_type = 'C2B' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_unq 
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'mer_merchant_id_string' and transaction_type = 'C2B' then agg_count else null end) as kredit_10045_c2b_mer_merchant_id_string_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_terminal_label' and transaction_type = 'C2B' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_terminal_label_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' and transaction_type = 'C2B' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_store_label_terminal_label_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_gcash' and transaction_type = 'C2B' then agg_count else null end) as kredit_10045_c2b_unique_merchant_id_string_gcash_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string' and transaction_type = 'JUMPAPP' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'mer_merchant_id_string' and transaction_type = 'JUMPAPP' then agg_count else null end) as kredit_10045_jumpapp_mer_merchant_id_string_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_terminal_label' and transaction_type = 'JUMPAPP' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_terminal_label_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' and transaction_type = 'JUMPAPP' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_store_label_terminal_label_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'unique_merchant_id_string_gcash' and transaction_type = 'JUMPAPP' then agg_count else null end) as kredit_10045_jumpapp_unique_merchant_id_string_gcash_unq
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string' then agg_count else null end) as kredit_10055_unique_merchant_id_string_unq
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'mer_merchant_id_string' then agg_count else null end) as kredit_10055_mer_merchant_id_string_unq
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string_terminal_label' then agg_count else null end) as kredit_10055_unique_merchant_id_string_terminal_label_unq
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string_store_label_terminal_label' then agg_count else null end) as kredit_10055_unique_merchant_id_string_store_label_terminal_label_unq
    ,max(case when app_id = 'kredit' and scene_id = '10055' and verify_type = 'unique_merchant_id_string_gcash' then agg_count else null end) as kredit_10055_unique_merchant_id_string_gcash_unq
    ,max(case when app_id = 'kredit' and scene_id = '10075' and verify_type = 'store_id' then agg_count else null end) as kredit_10075_store_id_unq
    ,max(case when app_id = 'kredit' and scene_id = '10095' and verify_type = 'unique_merchant_id' then agg_count else null end) as kredit_10095_unique_merchant_id_unq
    ,max(case when app_id = 'kredit' and scene_id = '10045' and verify_type = 'acquirer_unique_merchant_id_string' and transaction_type = 'C2BP2P' then agg_count else null end) as kredit_10045_p2p_acquirer_unique_merchant_id_string_unq

from final_aggregation_view 
group by rowkey
;
