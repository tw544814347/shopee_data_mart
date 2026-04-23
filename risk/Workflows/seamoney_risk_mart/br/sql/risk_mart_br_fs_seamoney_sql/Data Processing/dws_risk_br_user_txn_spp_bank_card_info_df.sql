-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-30
-- Theme Domain:        User Txn SPM Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-30 - chengguo.liu - 初始化, FS迁移spp card相关feature, https://fs.idata.shopeemobile.com/job-management/job-edit/744
--               表迁移:shopeepay.shopee_payment_module_payment_br_db__payment_v2_tab__reg_daily_s2_live → shopeepay.ods__shopee_payment_module_payment_br_db__payment_v2_tab__df__sensitive → mart_dwd_pps_inbound_payment_tab_df__br
--                     mp_order.dwd_checkout_all_ent_snapshot_df__sg_live → mp_order.dwd_checkout_all_ent_snapshot_df__reg_live
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_info_df
(
    platform_user_id string comment 'shopee user id'
    ,freq_card_number_180d string comment 'frequency of card number in last 180 days'
    ,freq_card_bin_180d string comment 'frequency of card bin in last 180 days'
    ,freq_card_brand_180d string comment 'frequency of card brand in last 180 days'
    ,freq_card_type_180d string comment 'frequency of card type in last 180 days'
    ,freq_bank_name_180d string comment 'frequency of bank name in last 180 days'
    ,freq_bank_id_180d string comment 'frequency of bank id in last 180 days'
    ,freq_order_number_of_ccard_180d string comment 'frequency of order number of ccard in last 180 days'
    ,freq_total_amount_of_ccard_180d string comment 'frequency of total amount of ccard in last 180 days'
    ,freq_max_amount_of_ccard_180d string comment 'frequency of max amount of ccard in last 180 days'
    ,freq_min_amount_of_ccard_180d string comment 'frequency of min amount of ccard in last 180 days'
    ,freq_avg_amount_of_ccard_180d string comment 'frequency of avg amount of ccard in last 180 days'
    ,active_card_nums_180d string comment 'active card number in last 180 days'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_spp_bank_card_info_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_info_df;


CREATE OR REPLACE TEMPORARY VIEW return_tab AS
select
    buyer_id as userid
    ,return_id
    ,order_id as orderid
from mp_order.dwd_return_all_ent_df__reg_live
where
    tz_type = 'local'
    and grass_region = 'BR'
    and return_status in (2, 5)
;

create or replace temporary view card_fail as
select distinct
    pps_transaction_id as payment_transaction_id
    ,cast(get_json_object(extra_data,'$.pay_result.payment.transaction_status.description') as string) as reason_code_text
    ,update_time as mtime
from shopeepay.mart_dwd_pps_inbound_payment_tab_df__br
where
    cast(from_unixtime(update_time) as date) >= date_sub('${current_grass_date}', 180)
    and cast(from_unixtime(update_time) as date) <= date_sub('${current_grass_date}', 1)
    and payment_status = 22 -- 20 success, 22 fail
;

CREATE OR REPLACE TEMPORARY VIEW orders_raw_tab AS
SELECT t1.buyer_id AS userid, t1.payment_transaction_id, t1.order_id, t1.gmv_usd,
       to_date(from_unixtime(t1.shipping_confirm_timestamp)) AS shipping_confirm_date,
       CASE WHEN t1.payment_spm_channel_id in (10006201,10012801) THEN 1 --cc installment
            WHEN t1.payment_spm_channel_id = 10006200 THEN 2 --credit debit card
            WHEN t1.payment_spm_channel_id = 10006300 THEN 3 --ebank
            WHEN t1.payment_spm_channel_id in (10011800,10006100) THEN 4 --boleto
            WHEN t1.payment_spm_channel_id = 10013500 THEN 5 --pix
       ELSE 6 --other payment
       END AS payment_method,
       cast(get_json_object(get_json_object(t2.checkout_info, '$.checkout_payment_info.channel_item_option_info'), 
                       '$.credit_card_data.card_number') AS STRING) AS card_number,
       SUBSTR(CAST(get_json_object(get_json_object(t2.checkout_info, '$.checkout_payment_info.channel_item_option_info'), 
                                 '$.credit_card_data.card_number') AS STRING), 1, 6) AS card_bin, 
       SUBSTR(CAST(get_json_object(get_json_object(t2.checkout_info, '$.checkout_payment_info.channel_item_option_info'), 
                                 '$.credit_card_data.card_number') AS STRING), 5, 2) AS card_class,
       CAST(get_json_object(get_json_object(t2.checkout_info, '$.checkout_payment_info.channel_item_option_info'), 
                            '$.credit_card_data.bank_id') AS STRING) AS bank_id
FROM mp_order.dwd_order_all_ent_df__reg_s0_live t1
left join
(
  select
    checkout_id as checkoutid
    ,checkout_info
  from mp_order.dwd_checkout_all_ent_snapshot_df__reg_live
  where grass_region = 'BR'
  and grass_date = '${grass_date}'
) t2
ON t1.checkout_id = t2.checkoutid
WHERE t1.grass_region = 'BR'
  AND to_date(from_unixtime(t1.shipping_confirm_timestamp)) >= date_sub('${current_grass_date}', 180)
  AND t1.shipping_confirm_timestamp > 0  
  AND t1.tz_type = 'local'
  AND t1.is_bi_excluded = 0
  AND t1.order_be_status_id IN (4, 11, 12, 13, 14, 15)
;

CREATE OR REPLACE TEMPORARY VIEW card_type AS
SELECT CAST(bank_id AS STRING) AS bank_id, 
       CAST(bin AS STRING) AS card_bin,
       CASE
           WHEN type = 1 THEN 'credit card'
           WHEN type = 2 THEN 'debit card'
           WHEN type = 3 THEN 'prepaid card'
           WHEN type = 4 THEN 'BCA_SAKUKU' -- an e-wallet card used by BCA_ONE_KLIK
           ELSE 'else' END AS card_type,
       brand
FROM shopeepay.shopee_payment_module_br_db__bank_identification_number_tab__reg_daily_s0_live
WHERE status = 1;

-- DETAIL
CREATE OR REPLACE TEMPORARY VIEW user_info_tab_success_tb_raw AS
SELECT userid, credit_card_number, card_bin, bank_id, card_type, card_brand, bank_name,
       order_number_of_ccard_180d, total_amount_of_ccard_180d, avg_amount_of_ccard_180d,
       max_amount_of_ccard_180d, min_amount_of_ccard_180d
FROM
(SELECT t1.userid, t1.card_number as credit_card_number, t1.card_bin, t1.bank_id, 
        t2.card_type, t2.brand as card_brand, t3.bank_name,
        COUNT(DISTINCT (CASE WHEN t1.shipping_confirm_date >= date_sub('${current_grass_date}', 180) THEN t1.order_id ELSE NULL END)) AS order_number_of_ccard_180d,        
--         
        SUM(CASE WHEN t1.shipping_confirm_date >= date_sub('${current_grass_date}', 180) THEN t1.gmv_usd ELSE 0 END) AS total_amount_of_ccard_180d,
        
        SUM(CASE WHEN t1.shipping_confirm_date >= date_sub('${current_grass_date}', 180) THEN t1.gmv_usd ELSE 0 END)/
        COUNT(DISTINCT (CASE WHEN t1.shipping_confirm_date >= date_sub('${current_grass_date}', 180) THEN t1.order_id ELSE NULL END)) AS avg_amount_of_ccard_180d,

        MAX(CASE WHEN t1.shipping_confirm_date >= date_sub('${current_grass_date}', 180) THEN t1.gmv_usd ELSE 0 END) AS max_amount_of_ccard_180d,
        MIN(CASE WHEN t1.shipping_confirm_date >= date_sub('${current_grass_date}', 180) THEN t1.gmv_usd ELSE 0 END) AS min_amount_of_ccard_180d
FROM 
(SELECT t1.userid, t1.order_id, t1.gmv_usd, t1.shipping_confirm_date, t1.card_number, t1.card_bin, t1.bank_id
 FROM orders_raw_tab t1 
 LEFT JOIN return_tab t2 ON t1.order_id = t2.orderid
 LEFT JOIN card_fail t3 ON t1.payment_transaction_id = t3.payment_transaction_id
 WHERE t2.return_id IS NULL AND t3.payment_transaction_id is null AND t1.card_number is not null AND t1.bank_id is not null) t1
LEFT JOIN card_type t2
ON t1.card_bin = t2.card_bin AND t1.bank_id = t2.bank_id
LEFT JOIN shopeepay.mart_dim_issue_bank_df__br t3 
ON t1.bank_id = cast(t3.bank_id as STRING)
WHERE t1.card_number is not null AND t1.bank_id is not null
  AND t2.card_type = 'credit card' 
GROUP BY 1,2,3,4,5,6,7);

CREATE OR REPLACE TEMPORARY VIEW active_card_num_tb_raw AS
SELECT distinct userid, card_number, bank_id 
FROM
(SELECT t1.userid, t1.card_number, t1.bank_id
 FROM orders_raw_tab t1 
 LEFT JOIN return_tab t2 ON t1.order_id = t2.orderid
 LEFT JOIN card_fail t3 ON t1.payment_transaction_id = t3.payment_transaction_id
 WHERE t2.return_id IS NULL AND t3.payment_transaction_id is null)
WHERE card_number is not null AND bank_id is not null;

CREATE OR REPLACE TEMPORARY VIEW active_card_num_tb AS
SELECT userid, count(*) as active_card_num
FROM active_card_num_tb_raw
GROUP BY 1;

CREATE OR REPLACE TEMPORARY VIEW user_info_tab_success_tb AS
SELECT t1.userid, t1.credit_card_number, t1.card_bin, t1.bank_id, t1.card_type, t1.card_brand, t1.bank_name,
       t1.order_number_of_ccard_180d, t1.total_amount_of_ccard_180d, t1.avg_amount_of_ccard_180d,
       t1.max_amount_of_ccard_180d, t1.min_amount_of_ccard_180d,
       t2.active_card_num as active_card_nums_180d
FROM user_info_tab_success_tb_raw t1 
LEFT JOIN active_card_num_tb t2 
ON t1.userid = t2.userid;

CREATE OR REPLACE TEMPORARY VIEW br_spl_ccard_success_tb as
SELECT userid, credit_card_number, card_bin, bank_id, card_type, card_brand, bank_name,
       order_number_of_ccard_180d, total_amount_of_ccard_180d, avg_amount_of_ccard_180d,
       max_amount_of_ccard_180d, min_amount_of_ccard_180d, active_card_nums_180d,
       '${current_grass_date}' as grass_date
FROM user_info_tab_success_tb;

CREATE OR REPLACE TEMPORARY VIEW card_success_base_freq AS
SELECT userid, credit_card_number as freq_card_number_180d, card_bin as freq_card_bin_180d,
       card_brand as freq_card_brand_180d,
       bank_id as freq_bank_id_180d, card_type as freq_card_type_180d, order_number_of_ccard_180d as freq_order_number_of_ccard_180d,
       total_amount_of_ccard_180d as freq_total_amount_of_ccard_180d, max_amount_of_ccard_180d as freq_max_amount_of_ccard_180d,
       min_amount_of_ccard_180d as freq_min_amount_of_ccard_180d, bank_name as freq_bank_name_180d,
       avg_amount_of_ccard_180d as freq_avg_amount_of_ccard_180d, active_card_nums_180d
FROM
(SELECT t1.userid, t1.credit_card_number,
        t1.card_bin, t1.card_brand,
        t1.bank_id, t1.card_type,
        t1.order_number_of_ccard_180d, t1.total_amount_of_ccard_180d, t1.max_amount_of_ccard_180d, t1.min_amount_of_ccard_180d,
        t1.bank_name, t1.active_card_nums_180d, t1.avg_amount_of_ccard_180d,
        row_number() over(PARTITION BY t1.userid ORDER BY t1.order_number_of_ccard_180d desc, t1.total_amount_of_ccard_180d desc) as rank_num
 FROM br_spl_ccard_success_tb t1
)
WHERE rank_num = 1;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_info_df partition (grass_date = '${grass_date}')
SELECT t1.platform_user_id,
       CASE WHEN freq_card_number_180d is null or freq_card_number_180d in ('null','',' ') THEN '-9999' ELSE freq_card_number_180d END AS freq_card_number_180d,
       CASE WHEN freq_card_bin_180d is null or freq_card_bin_180d in ('null','',' ') THEN '-9999' ELSE freq_card_bin_180d END AS freq_card_bin_180d,
       CASE WHEN freq_card_brand_180d is null or freq_card_brand_180d in ('null','',' ') THEN '-9999' ELSE freq_card_brand_180d END AS freq_card_brand_180d,
       CASE WHEN freq_card_type_180d is null or freq_card_type_180d in ('null','',' ') THEN '-9999' ELSE freq_card_type_180d END AS freq_card_type_180d,
       CASE WHEN freq_bank_name_180d is null or freq_bank_name_180d in ('null','',' ') THEN '-9999' ELSE freq_bank_name_180d END AS freq_bank_name_180d,
       CASE WHEN freq_bank_id_180d is null or freq_bank_id_180d in ('null','',' ') THEN '-9999' ELSE freq_bank_id_180d END AS freq_bank_id_180d,
       CASE WHEN freq_order_number_of_ccard_180d is null THEN 0 ELSE freq_order_number_of_ccard_180d END AS freq_order_number_of_ccard_180d,
       CASE WHEN freq_total_amount_of_ccard_180d is null THEN 0 ELSE freq_total_amount_of_ccard_180d END AS freq_total_amount_of_ccard_180d,
       CASE WHEN freq_max_amount_of_ccard_180d is null THEN 0 ELSE freq_max_amount_of_ccard_180d END AS freq_max_amount_of_ccard_180d,
       CASE WHEN freq_min_amount_of_ccard_180d is null THEN 0 ELSE freq_min_amount_of_ccard_180d END AS freq_min_amount_of_ccard_180d,
       CASE WHEN freq_avg_amount_of_ccard_180d is null THEN 0 ELSE freq_avg_amount_of_ccard_180d END AS freq_avg_amount_of_ccard_180d,
       CASE WHEN active_card_nums_180d is null THEN 0 ELSE active_card_nums_180d END AS active_card_nums_180d
from
(
    select
        platform_user_id
    from ${SCHEMA}.dim_risk_${region}_user_info_df
    where grass_date = '${grass_date}'
) t1
left join card_success_base_freq t2
on t1.platform_user_id = t2.userid
;