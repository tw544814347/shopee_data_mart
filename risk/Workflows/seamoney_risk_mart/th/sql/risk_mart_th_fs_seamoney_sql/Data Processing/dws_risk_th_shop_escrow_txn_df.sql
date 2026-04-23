--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-10-29
-- Theme Domain：       transaction
-- Description:         escrow financial product transaction info
-- 开发要求:             https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=888264612#gid=888264612
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/262
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/284
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/286
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/287
-- Data Granularity:    shop_id
-- 变更历史：
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


drop table if exists ${SCHEMA}.dws_risk_th_shop_escrow_txn_df
;

create external table if not exists ${SCHEMA}.dws_risk_th_shop_escrow_txn_df (
    shop_id                             string comment 'shop id'
    ,is_seller_active                   bigint comment 'is active'
    ,is_eligible_12m                    bigint comment 'whether the customer is eligible for 12 month tenor'
    ,first_sales_date                   string comment 'first selling transaction happened date'
    ,txn_escrow_normal_pmt_30d          bigint comment ''
    ,txn_escrow_normal_pmt_31_60d       bigint comment ''
    ,txn_escrow_normal_pmt_61_90d       bigint comment ''
    ,txn_escrow_normal_pmt_91_120d      bigint comment ''
    ,txn_escrow_normal_pmt_121_150d     bigint comment ''
    ,txn_escrow_normal_pmt_151_180d     bigint comment ''
    ,txn_shipout_normal_pmt_30d         bigint comment ''
    ,txn_shipout_normal_pmt_31_60d      bigint comment ''
    ,txn_shipout_normal_pmt_61_90d      bigint comment ''
    ,txn_shipout_normal_pmt_91_120d     bigint comment ''
    ,txn_shipout_normal_pmt_121_150d    bigint comment ''
    ,txn_shipout_normal_pmt_151_180d    bigint comment ''
    ,days_has_txn_30days    bigint comment ''
    ,days_has_txn_90days    bigint comment ''
    ,days_has_txn_180days   bigint comment ''
    ,days_has_txn_360days   bigint comment ''
    ,daily_avg_escrow           decimal(30,10) comment ''
    ,daily_escrow_percentile50  decimal(30,10) comment ''
    ,daily_escrow_percentile75  decimal(30,10) comment ''
    ,daily_escrow_percentile90  decimal(30,10) comment ''
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_th_shop_escrow_txn_df/' 
comment 
'
Tag:risk summary table
mp_user.dim_shop__reg_s0_live
mp_order.dwd_order_all_ent_df__reg_s0_live
credit_mart.wide_scl_th_behavior_user_df -- no access
credit_mart.dws_spl_th_loan_repayment_df
credit_mart.dws_scl_th_loan_repayment_df
'
;
msck repair table ${SCHEMA}.dws_risk_th_shop_escrow_txn_df;

create or replace temporary view shop_info as (
    select  distinct shop_id
            --,user_id
            ,1  as is_seller_active
    from    mp_user.dim_shop__th_s0_live
    where   grass_date = date('${ds}')
    and     grass_region = 'TH'
)
;

create or replace temporary view fs_basic_order_info as (
    select  shop_id
            ,order_id
            ,payment_method
            ,is_net_order
            ,gmv_usd
            ,substring_index(shipping_confirm_datetime,' ', 1) as shipping_confirm_datetime
            ,escrow_to_seller_amt_usd
            ,grass_date
            ,tz_type
            ,order_be_status
            ,escrow_paid_datetime
    from    mp_order.dwd_order_all_ent_df__th_s0_live
    where   grass_region = 'TH'
    -- and     (grass_date >= current_date - interval  '390'  day or grass_date = date('9999-01-01'))
    -- and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
    -- and     cast(escrow_paid_datetime as date) between (current_date - interval  '390'  day) and current_date
    -- group by    shop_id
)
;

create or replace temporary view fs_first_sales_date as (
    select  shop_id
            ,min(case when is_net_order = 1 then grass_date else null end) as first_sales_date
    from    fs_basic_order_info
    where   tz_type = 'local'
    and     (grass_date >= current_date - interval  '390'  day or grass_date = date('9999-01-01'))
    and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
    and     cast(escrow_paid_datetime as date) between (current_date - interval  '390'  day) and current_date
    group by    shop_id
)
;

create or replace temporary view fs_order_info_180d as (
    select  shop_id
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime >= (current_date - interval '30' day)  and escrow_to_seller_amt_usd > 0 then order_id else null end)txn_escrow_normal_pmt_30d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '60' day) and (current_date - interval '31' day) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_31_60d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '90' day) and (current_date - interval '61' day) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_61_90d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '120' day) and (current_date - interval '91' day) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_91_120d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '150' day) and (current_date - interval '121' day) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_121_150d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '180' day) and (current_date - interval '151' day) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_151_180d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime >= current_date - interval '30' day then order_id else null end) as txn_shipout_normal_pmt_30d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '60' day) and (current_date - interval '31' day) then order_id else null end) as txn_shipout_normal_pmt_31_60d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '90' day) and (current_date - interval '61' day) then order_id else null end) as txn_shipout_normal_pmt_61_90d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '120' day) and (current_date - interval '91' day) then order_id else null end) as txn_shipout_normal_pmt_91_120d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '150' day) and (current_date - interval '121' day) then order_id else null end) as txn_shipout_normal_pmt_121_150d
            ,count(distinct case when is_cod = 0 and shipping_confirm_datetime between (current_date - interval '180' day) and (current_date - interval '151' day) then order_id else null end) as txn_shipout_normal_pmt_151_180d
    from (
        select  shop_id 
            ,cast(substring_index(shipping_confirm_datetime,' ', 0) as date) as shipping_confirm_datetime
            ,order_id
            ,gmv_usd
            ,escrow_to_seller_amt_usd
            ,case when payment_method = 'PAY_COD' then 1 else 0  end is_cod
        from    fs_basic_order_info
        where   (grass_date >= current_date - interval  '180'  day or grass_date = date('9999-01-01'))
        and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
        and     cast(escrow_paid_datetime as date) between (current_date - interval  '180'  day) and current_date
    )
    group by shop_id
)
;

create or replace temporary view fs_order_info_360d as (
    select  shop_id 
            ,count(distinct case when cast(shipping_confirm_datetime as date) >= (current_date - interval  '30'  day) then cast(substring_index(shipping_confirm_datetime,' ', 0) as date) else null end)  as days_has_txn_30days
            ,count(distinct case when cast(shipping_confirm_datetime as date) >= (current_date - interval  '90'  day) then cast(substring_index(shipping_confirm_datetime,' ', 0) as date) else null end)  as days_has_txn_90days
            ,count(distinct case when cast(shipping_confirm_datetime as date) >= (current_date - interval  '180'  day) then cast(substring_index(shipping_confirm_datetime,' ', 0) as date) else null end)  as days_has_txn_180days
            ,count(distinct case when cast(shipping_confirm_datetime as date) >= (current_date - interval  '360'  day) then cast(substring_index(shipping_confirm_datetime,' ', 0) as date) else null end)  as days_has_txn_360days            
    from    fs_basic_order_info
    where   (grass_date >= current_date - interval  '360'  day or grass_date = date('9999-01-01'))
    and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
    and     cast(escrow_paid_datetime as date) between (current_date - interval  '360'  day) and current_date
    group by shop_id
)
;

create or replace temporary view fs_order_info_181d as (
    select  shop_id
            ,avg(daily_escrow_to_seller_usd) as daily_avg_escrow
            ,approx_percentile(daily_escrow_to_seller_usd , 0.5, 10000) as daily_escrow_percentile50
            ,approx_percentile(daily_escrow_to_seller_usd, 0.75, 10000) as daily_escrow_percentile75
            ,approx_percentile(daily_escrow_to_seller_usd, 0.9, 10000) as daily_escrow_percentile90
    from (
        select  shop_id
                ,cast(shipping_confirm_datetime as date) as shipping_confirm_date
                ,sum(escrow_to_seller_amt_usd) daily_escrow_to_seller_usd
        from    fs_basic_order_info
        where   (grass_date >= current_date - interval  '181'  day or grass_date = date('9999-01-01'))
        and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
        and     cast(escrow_paid_datetime as date) between (current_date - interval  '181'  day) and current_date
        group by shop_id, cast(shipping_confirm_datetime as date)
    )
    group by shop_id
)
;

insert overwrite ${SCHEMA}.dws_risk_th_shop_escrow_txn_df partition (grass_date='${ds}')
select  t1.shop_id              as shop_id
        ,t1.is_seller_active    as is_seller_active
        ,case when t2.first_sales_date < (current_date - interval '1' year) then 1 else 0 end as is_eligible_12m
        ,t2.first_sales_date    as first_sales_date
        ,t3.txn_escrow_normal_pmt_30d
        ,t3.txn_escrow_normal_pmt_31_60d
        ,t3.txn_escrow_normal_pmt_61_90d
        ,t3.txn_escrow_normal_pmt_91_120d
        ,t3.txn_escrow_normal_pmt_121_150d
        ,t3.txn_escrow_normal_pmt_151_180d
        ,t3.txn_shipout_normal_pmt_30d
        ,t3.txn_shipout_normal_pmt_31_60d
        ,t3.txn_shipout_normal_pmt_61_90d
        ,t3.txn_shipout_normal_pmt_91_120d
        ,t3.txn_shipout_normal_pmt_121_150d
        ,t3.txn_shipout_normal_pmt_151_180d
        ,t4.days_has_txn_30days
        ,t4.days_has_txn_90days
        ,t4.days_has_txn_180days
        ,t4.days_has_txn_360days
        ,t5.daily_avg_escrow
        ,t5.daily_escrow_percentile50
        ,t5.daily_escrow_percentile75
        ,t5.daily_escrow_percentile90
from    shop_info as t1
left join fs_first_sales_date as t2
on t1.shop_id = t2.shop_id
left join fs_order_info_180d as t3 
on t1.shop_id = t3.shop_id 
left join fs_order_info_360d as t4 
on t1.shop_id = t4.shop_id 
left join fs_order_info_181d as t5
on t1.shop_id = t5.shop_id