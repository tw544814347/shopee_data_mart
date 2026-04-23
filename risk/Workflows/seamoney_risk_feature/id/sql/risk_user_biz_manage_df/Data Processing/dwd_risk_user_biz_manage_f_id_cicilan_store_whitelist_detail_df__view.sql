-- =============================================================================
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-12-08
-- Theme Domain:        Anti-Fraud
-- Data Granularity:    
-- Description:         业务侧透传表，落切片并保留历史所有数据 
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-12 - chengguo.liu - 初始化
--  2025-12-08 - wei.tao 保留所有历史切片
-- =============================================================================

/*
CREATE OR REPLACE VIEW risk.dwd_risk_user_biz_manage_f_id_cicilan_store_whitelist_detail_tmp_df as 
SELECT
    grass_date,
    CAST(get_json_object(json_data, '$.store_id') AS int) AS store_id,
    CAST(get_json_object(json_data, '$.open_date') AS date) AS open_date,
    CAST(get_json_object(json_data, '$.close_date') AS date) AS close_date,
    CAST(get_json_object(json_data, '$.status') AS int) AS status,
    get_json_object(json_data, '$.remark') AS remark,
    get_json_object(json_data, '$.merchant_type') AS merchant_type,
    CAST(get_json_object(json_data, '$.merchant_id') AS decimal(20,0)) AS merchant_id,
    get_json_object(json_data, '$.merchant_name') AS merchant_name,
    get_json_object(json_data, '$.store_name') AS store_name,
    CAST(get_json_object(json_data, '$.cnt_outlet') AS bigint) AS cnt_outlet,
    get_json_object(json_data, '$.merchant_entity_type') AS merchant_entity_type,
    get_json_object(json_data, '$.settle_to') AS settle_to,
    CAST(get_json_object(json_data, '$.cnt_ba_merchant') AS bigint) AS cnt_ba_merchant,
    get_json_object(json_data, '$.brand_group') AS brand_group,
    get_json_object(json_data, '$.tag') AS tag,
    get_json_object(json_data, '$.merchant_type_bi') AS merchant_type_bi,
    get_json_object(json_data, '$.merchant_cate') AS merchant_cate,
    CAST(get_json_object(json_data, '$.flag_in_constrain') AS int) AS flag_in_constrain,
    get_json_object(json_data, '$.merchant_type_mis') AS merchant_type_mis,
    get_json_object(json_data, '$.merchant_cate_backfill') AS merchant_cate_backfill,
    get_json_object(json_data, '$.merchant_cate_layer') AS merchant_cate_layer,
    CAST(get_json_object(json_data, '$.open_week') AS date) AS open_week,
    get_json_object(json_data, '$.wl_status') AS wl_status,
    get_json_object(json_data, '$.store_city') AS store_city,
    get_json_object(json_data, '$.store_state') AS store_state,
    get_json_object(json_data, '$.store_district') AS store_district,
    get_json_object(json_data, '$.store_sub_district') AS store_sub_district,
    CAST(get_json_object(json_data, '$.gps_latitude') AS decimal(11,8)) AS gps_latitude,
    CAST(get_json_object(json_data, '$.gps_longitude') AS decimal(11,8)) AS gps_longitude,
    get_json_object(json_data, '$.store_postal_code') AS store_postal_code,
    get_json_object(json_data, '$.store_detail_address') AS store_detail_address,
    CAST(get_json_object(json_data, '$.store_create_date') AS date) AS store_create_date,
    CAST(get_json_object(json_data, '$.payout_account_id') AS decimal(20,0)) AS payout_account_id,
    get_json_object(json_data, '$.settlement_cycle') AS settlement_cycle,
    get_json_object(json_data, '$.payout_mode') AS payout_mode,
    get_json_object(json_data, '$.store_bd_tag') AS store_bd_tag,
    get_json_object(json_data, '$.store_account_type') AS store_account_type,
    get_json_object(json_data, '$.store_status') AS store_status,
    CAST(get_json_object(json_data, '$.manager_merchant_id') AS decimal(20,0)) AS manager_merchant_id,
    get_json_object(json_data, '$.merchant_city') AS merchant_city,
    get_json_object(json_data, '$.merchant_contact_phone') AS merchant_contact_phone,
    CAST(get_json_object(json_data, '$.merchant_create_date') AS date) AS merchant_create_date,
    get_json_object(json_data, '$.customer_entity_type') AS customer_entity_type,
    get_json_object(json_data, '$.national_id_type') AS national_id_type,
    get_json_object(json_data, '$.national_id') AS national_id,
    get_json_object(json_data, '$.merchant_bd_tag') AS merchant_bd_tag,
    get_json_object(json_data, '$.merchant_account_type') AS merchant_account_type,
    get_json_object(json_data, '$.handphone_loan_merchant') AS handphone_loan_merchant,
    get_json_object(json_data, '$.brand_report') AS brand_report,
    get_json_object(json_data, '$.merchant_brand_report') AS merchant_brand_report,
    get_json_object(json_data, '$.merchant_status') AS merchant_status,
    CAST(get_json_object(json_data, '$.bank_id') AS decimal(20,0)) AS bank_id,
    get_json_object(json_data, '$.account_no') AS account_no,
    CAST(get_json_object(json_data, '$.mer_merchant_id') AS decimal(20,0)) AS mer_merchant_id,
    CAST(get_json_object(json_data, '$.spl_transaction') AS bigint) AS spl_transaction,
    CAST(get_json_object(json_data, '$.spp_transaction') AS bigint) AS spp_transaction,
    CAST(get_json_object(json_data, '$.cnt_spp_buyer') AS bigint) AS cnt_spp_buyer,
    CAST(get_json_object(json_data, '$.cnt_spl_buyer') AS bigint) AS cnt_spl_buyer,
    CAST(get_json_object(json_data, '$.cnt_spl_buyer_agr30') AS bigint) AS cnt_spl_buyer_agr30,
    CAST(get_json_object(json_data, '$.sum_fpd30_amt') AS decimal(38,10)) AS sum_fpd30_amt,
    CAST(get_json_object(json_data, '$.spl_transaction_agr30') AS bigint) AS spl_transaction_agr30,
    CAST(get_json_object(json_data, '$.sum_amount') AS decimal(38,10)) AS sum_amount,
    CAST(get_json_object(json_data, '$.sum_spl_amount') AS decimal(38,10)) AS sum_spl_amount,
    CAST(get_json_object(json_data, '$.spl_penetration_rate') AS decimal(38,14)) AS spl_penetration_rate,
    CAST(get_json_object(json_data, '$.spl_amount_overdue_rate') AS decimal(38,10)) AS spl_amount_overdue_rate,
    CAST(get_json_object(json_data, '$.spl_user_overdue_rate') AS decimal(24,4)) AS spl_user_overdue_rate
FROM risk.dwd_risk_user_biz_manage_f_id_cicilan_store_whitelist_detail_df;
*/