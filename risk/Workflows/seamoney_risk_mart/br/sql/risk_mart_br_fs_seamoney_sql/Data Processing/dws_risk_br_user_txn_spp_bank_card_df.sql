-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-30
-- Theme Domain:        User Txn SPM Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-30 - chengguo.liu - 初始化, 原始需求逻辑 https://fs.idata.shopeemobile.com/job-management/job-edit/750
--               表迁移:shopeepay.shopee_payment_module_payment_br_db__payment_v2_tab__reg_daily_s2_live → shopeepay.ods__shopee_payment_module_payment_br_db__payment_v2_tab__df__sensitive → mart_dwd_pps_inbound_payment_tab_df__br
--                     mp_order.dwd_checkout_all_ent_snapshot_df__sg_live → mp_order.dwd_checkout_all_ent_snapshot_df__reg_live
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df
(
    shopee_user_id                                      string         comment 'shopee user id'
    ,user_total_fail_nums_180d                          bigint         comment 'user total fail nums in 180d'
    ,user_recent_fail_day                               bigint         comment 'user recent fail day'
    ,user_recent_fail_reason                            string         comment 'user recent fail reason'
    ,high_risk_latest_day                               bigint         comment 'high risk latest day'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_spp_bank_card_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df;

create or replace temporary view card_fail as
select distinct
    pps_transaction_id as payment_transaction_id
    ,cast(get_json_object(extra_data,'$.pay_result.payment.transaction_status.description') as string) as fail_reason
    ,update_time as mtime
from shopeepay.mart_dwd_pps_inbound_payment_tab_df__br
where
    cast(from_unixtime(update_time) as date) >= date_sub('${current_grass_date}', 180)
    and cast(from_unixtime(update_time) as date) <= date_sub('${current_grass_date}', 1)
    and payment_status = 22 -- 20 success, 22 fail
;

CREATE OR REPLACE temporary VIEW card_fail_full_info AS
SELECT
    cf.fail_reason,
    cf.mtime,
    get_json_object(ch.checkout_info, '$.checkout_payment_info.transaction_id') AS payment_transaction_id,
    ch.user_id as userid,
    coalesce(CAST(get_json_object(get_json_object(ch.checkout_info, '$.checkout_payment_info.channel_item_option_info'), '$.credit_card_data.card_number') AS STRING), '-9999') AS card_number,
    coalesce(CAST(get_json_object(get_json_object(ch.checkout_info, '$.checkout_payment_info.channel_item_option_info'), '$.credit_card_data.bank_id') AS STRING), '-99') AS bank_id
FROM card_fail cf
LEFT JOIN (
    SELECT *
    FROM mp_order.dwd_checkout_all_ent_snapshot_df__reg_live
    WHERE tz_type = 'local'
    and grass_region = 'BR'
    and grass_date = '${grass_date}'
) ch
ON cf.payment_transaction_id = get_json_object(ch.checkout_info, '$.checkout_payment_info.transaction_id')
WHERE ch.user_id IS NOT NULL
;

CREATE OR REPLACE temporary VIEW card_fail_times_all AS
SELECT
    userid,
    count(DISTINCT mtime) AS user_total_fail_nums_180d
FROM card_fail_full_info
GROUP BY userid
;

CREATE OR REPLACE temporary VIEW card_fail_recent_all AS
SELECT
    userid,
    datediff(current_date(), CAST(FROM_UNIXTIME(mtime) AS DATE)) AS user_recent_fail_day,
    fail_reason AS user_recent_fail_reason
FROM (
    SELECT
        userid,
        mtime,
        fail_reason,
        row_number() OVER (PARTITION BY userid ORDER BY mtime DESC) AS rank_num
    FROM card_fail_full_info
)
WHERE rank_num = 1
;

CREATE OR REPLACE temporary VIEW card_high_risk AS
SELECT
    userid,
    datediff(current_date(), CAST(FROM_UNIXTIME(mtime) AS DATE)) AS high_risk_latest_day,
    fail_reason AS reason
FROM (
    SELECT
        userid,
        mtime,
        fail_reason,
        row_number() OVER (PARTITION BY userid ORDER BY mtime DESC) AS rank_num
    FROM card_fail_full_info
    WHERE fail_reason = 'High risk transaction'
)
WHERE rank_num = 1
;

create or replace temporary view card_fail_summary as
SELECT
    a.userid AS user_id,
    CASE WHEN a.user_total_fail_nums_180d IS NULL OR CAST(a.user_total_fail_nums_180d AS STRING) IN ('null', '', ' ') THEN -9999 ELSE a.user_total_fail_nums_180d END AS user_total_fail_nums_180d,
    CASE WHEN b.user_recent_fail_day IS NULL OR CAST(b.user_recent_fail_day AS STRING) IN ('null', '', ' ') THEN -9999 ELSE b.user_recent_fail_day END AS user_recent_fail_day,
    CASE WHEN b.user_recent_fail_reason IS NULL OR b.user_recent_fail_reason IN ('null', '', ' ') THEN '-9999' ELSE b.user_recent_fail_reason END AS user_recent_fail_reason,
    CASE WHEN c.high_risk_latest_day IS NULL OR CAST(c.high_risk_latest_day AS STRING) IN ('null', '', ' ') THEN -9999 ELSE c.high_risk_latest_day END AS high_risk_latest_day
FROM card_fail_times_all a
LEFT JOIN card_fail_recent_all b ON a.userid = b.userid
LEFT JOIN card_high_risk c ON a.userid = c.userid
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id as shopee_user_id
    ,t2.user_total_fail_nums_180d
    ,t2.user_recent_fail_day
    ,t2.user_recent_fail_reason
    ,t2.high_risk_latest_day
from
(
    select
        platform_user_id
    from ${SCHEMA}.dim_risk_${region}_user_info_df
    where grass_date = '${grass_date}'
) t1
left join card_fail_summary t2
on t1.platform_user_id = t2.user_id
;