-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: ads_risk_spl_br_user_transactions_df
-- ** Create Author|创建人: chenyingying
-- ** Create time|创建日期: 2025-11-25
-- ** Modified log|修改日志:
-- **             修改日期: 2025-11-25  修改人:chenyingying  需求文档: https://docs.google.com/spreadsheets/d/1HvtmypV26djmILUlX_pnJq48hyH4pPV3eIzIQ_9jx2Y/edit?gid=1688131530#gid=1688131530
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- ** label_cc_installment         10013801 -- cci
-- ** label_spinpay_pix            10014600 -- pix
-- ** label_adyen_pix              10013500 -- pix
-- ** label_santander_pix          10014900 -- pix
-- ** label_shopee_wallet_v2       10001400 -- wallet
-- **************************************************************************

-- drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_transaction_df ;
create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_transaction_df 
(
    credit_user_id                              string comment 'unique credit user id',
    biz_type                                    bigint comment 'Dimension, 1:BCL;2:SCL;3:SPL;4:FES;7:SPLX;8:CPL;11:TL;12:SVL;13:SCF',
    combine_payment_cnt_td                      bigint comment 'history combined payment order cnt',
    combine_payment_amount_td                   decimal(30,10) comment 'history combined payment total amount',
    combine_payment_spl_amount_td               decimal(30,10) comment 'history combined payment spl amount',
    combine_payment_cci_amount_td               decimal(30,10) comment 'history combined payment cci amount',
    combine_payment_pix_amount_td               decimal(30,10) comment 'history combined payment pix amount',
    combine_payment_wallet_amount_td            decimal(30,10) comment 'history combined payment wallet amount',
    combine_payment_cnt_30d                    bigint comment 'last 30d combined payment order cnt',
    combine_payment_amount_30d                 decimal(30,10) comment 'last 30dcombined payment total amount',
    combine_payment_spl_amount_30d             decimal(30,10) comment 'last 30dcombined payment spl amount',
    combine_payment_cci_amount_30d             decimal(30,10) comment 'last 30d combined payment cci amount',
    combine_payment_pix_amount_30d             decimal(30,10) comment 'last 30dcombined payment pix amount',
    combine_payment_wallet_amount_30d          decimal(30,10) comment 'last 30dcombined payment wallet amount',
    combine_payment_cnt_90d                    bigint comment 'last 90d combined payment order cnt',
    combine_payment_amount_90d                 decimal(30,10) comment 'last 90d combined payment total amount',
    combine_payment_spl_amount_90d             decimal(30,10) comment 'last 90d combined payment spl amount',
    combine_payment_cci_amount_90d             decimal(30,10) comment 'last 90d combined payment cci amount', 
    combine_payment_pix_amount_90d             decimal(30,10) comment 'last 90d combined payment pix amount',
    combine_payment_wallet_amount_90d          decimal(30,10) comment 'last 90d combined payment wallet amount',
    combine_payment_cnt_180d                   bigint comment 'last 180d combined payment order cnt',
    combine_payment_amount_180d                decimal(30,10) comment 'last 180d combined payment total amount',
    combine_payment_spl_amount_180d            decimal(30,10) comment 'last 180d combined payment spl amount',    
    combine_payment_cci_amount_180d            decimal(30,10) comment 'last 180d combined payment cci amount',    
    combine_payment_pix_amount_180d            decimal(30,10) comment 'last 180d combined payment pix amount',
    combine_payment_wallet_amount_180d         decimal(30,10) comment 'last 180d combined payment wallet amount',
    combine_payment_cnt_360d                   bigint comment 'last 360d combined payment order cnt',
    combine_payment_amount_360d                decimal(30,10) comment 'last 360d combined payment total amount',
    combine_payment_spl_amount_360d            decimal(30,10) comment 'last 360d combined payment spl amount',
    combine_payment_cci_amount_360d            decimal(30,10) comment 'last 360d combined payment cci amount',
    combine_payment_pix_amount_360d            decimal(30,10) comment 'last 360d combined payment pix amount',
    combine_payment_wallet_amount_360d         decimal(30,10) comment 'last 360d combined payment wallet amount'
)
partitioned by
(
    grass_date string comment 'Full Daily Partition'
) 
comment 'credit mart summary table'
stored as orc tblproperties ("orc.compress" = "SNAPPY", "orc.stripe.size" = "64000000") 
location '${HDFS_PATH}/ads/ads_risk_${table_product}_${table_region}_user_transaction_df/grass_region=${region}'
;
with all_user_transaction_payemnt_feature as (
    select credit_user_id,
            biz_type,
            -- histoy feature
            sum(if(order_in_td = 1, 1, 0))     as combine_payment_cnt_td,
            sum(if(order_in_td = 1, total_amount,0))    as combine_payment_amount_td,
            sum(if(order_in_td = 1, spl_amount, 0))     as combine_payment_spl_amount_td,
            sum(if(downpay_channel_id = 10013801 and order_in_td = 1, downpay_amount, 0))                           as combine_payment_cci_amount_td,
            sum(if(downpay_channel_id in (10014600, 10013500, 10014900) and order_in_td = 1, downpay_amount, 0))    as combine_payment_pix_amount_td,
            sum(if(downpay_channel_id = 10001400 and order_in_td = 1, downpay_amount, 0))                           as combine_payment_wallet_amount_td,

            -- 30d feature
            sum(if(order_in_30d = 1, 1, 0))    as combine_payment_cnt_30d,
            sum(if(order_in_30d = 1,total_amount,0))           as combine_payment_amount_30d,
            sum(if(order_in_30d = 1,spl_amount, 0))             as combine_payment_spl_amount_30d,
            sum(if(downpay_channel_id = 10013801 and order_in_30d = 1, downpay_amount, 0))                           as combine_payment_cci_amount_30d,
            sum(if(downpay_channel_id in (10014600, 10013500, 10014900) and order_in_30d = 1, downpay_amount, 0))    as combine_payment_pix_amount_30d,
            sum(if(downpay_channel_id = 10001400 and order_in_30d = 1, downpay_amount, 0))                           as combine_payment_wallet_amount_30d,

            -- 90d feature
            sum(if(order_in_90d = 1, 1, 0))    as combine_payment_cnt_90d,
            sum(if(order_in_90d = 1,total_amount,0))           as combine_payment_amount_90d,
            sum(if(order_in_90d = 1,spl_amount, 0))             as combine_payment_spl_amount_90d,
            sum(if(downpay_channel_id = 10013801 and order_in_90d = 1, downpay_amount, 0))                           as combine_payment_cci_amount_90d,
            sum(if(downpay_channel_id in (10014600, 10013500, 10014900) and order_in_90d = 1, downpay_amount, 0))    as combine_payment_pix_amount_90d,
            sum(if(downpay_channel_id = 10001400 and order_in_90d = 1, downpay_amount, 0))                           as combine_payment_wallet_amount_90d,

            -- 180d feature
            sum(if(order_in_180d = 1, 1, 0))    as combine_payment_cnt_180d,
            sum(if(order_in_180d = 1,total_amount,0))           as combine_payment_amount_180d,
            sum(if(order_in_180d = 1,spl_amount, 0))             as combine_payment_spl_amount_180d,
            sum(if(downpay_channel_id = 10013801 and order_in_180d = 1, downpay_amount, 0))                           as combine_payment_cci_amount_180d,
            sum(if(downpay_channel_id in (10014600, 10013500, 10014900) and order_in_180d = 1, downpay_amount, 0))    as combine_payment_pix_amount_180d,
            sum(if(downpay_channel_id = 10001400 and order_in_180d = 1, downpay_amount, 0))                           as combine_payment_wallet_amount_180d,            

            -- 360d feature
            sum(if(order_in_360d = 1, 1, 0))    as combine_payment_cnt_360d,
            sum(if(order_in_360d = 1,total_amount,0))           as combine_payment_amount_360d,
            sum(if(order_in_360d = 1,spl_amount, 0))             as combine_payment_spl_amount_360d,
            sum(if(downpay_channel_id = 10013801 and order_in_360d = 1, downpay_amount, 0))                           as combine_payment_cci_amount_360d,
            sum(if(downpay_channel_id in (10014600, 10013500, 10014900) and order_in_360d = 1, downpay_amount, 0))    as combine_payment_pix_amount_360d,
            sum(if(downpay_channel_id = 10001400 and order_in_360d = 1, downpay_amount, 0))                           as combine_payment_wallet_amount_360d            

    from (
        select  credit_user_id,
            downpay_channel_id,
            if(date(create_time) between date('${ds}') - interval '30' day and date('${ds}'), 1, 0) order_in_30d,
            if(date(create_time) between date('${ds}') - interval '90' day and date('${ds}'), 1, 0) order_in_90d,
            if(date(create_time) between date('${ds}') - interval '180' day and date('${ds}'), 1, 0) order_in_180d,
            if(date(create_time) between date('${ds}') - interval '360' day and date('${ds}'), 1, 0) order_in_360d,
            if(order_id is not null, 1, 0)  order_in_td,
            downpay_amount as downpay_amount,
            total_amount as total_amount,
            total_amount - downpay_amount as spl_amount,
            create_time,
            biz_type
        from credit_mart.dwd_spl_br_order_df  
        where grass_date = '${ds}'
        and downpay_amount > 0 -- policy 确认口径
        and confirm_status = 3 -- 只统计有确认订单的用户
    )
    group by credit_user_id, biz_type
)

insert overwrite ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_transaction_df partition (grass_date = '${ds}')
select  t1.credit_user_id,
        t1.biz_type,
        nvl(t1.combine_payment_cnt_td, 0),
        nvl(t1.combine_payment_amount_td, 0) ,
        nvl(t1.combine_payment_spl_amount_td, 0),
        nvl(t1.combine_payment_cci_amount_td, 0),
        nvl(t1.combine_payment_pix_amount_td, 0),
        nvl(t1.combine_payment_wallet_amount_td, 0),
        nvl(t1.combine_payment_cnt_30d, 0),
        nvl(t1.combine_payment_amount_30d, 0),
        nvl(t1.combine_payment_spl_amount_30d, 0),
        nvl(t1.combine_payment_cci_amount_30d, 0),
        nvl(t1.combine_payment_pix_amount_30d, 0),
        nvl(t1.combine_payment_wallet_amount_30d, 0),
        nvl(t1.combine_payment_cnt_90d, 0),
        nvl(t1.combine_payment_amount_90d, 0),
        nvl(t1.combine_payment_spl_amount_90d, 0),
        nvl(t1.combine_payment_cci_amount_90d, 0),
        nvl(t1.combine_payment_pix_amount_90d, 0),
        nvl(t1.combine_payment_wallet_amount_90d, 0),
        nvl(t1.combine_payment_cnt_180d, 0),
        nvl(t1.combine_payment_amount_180d, 0),
        nvl(t1.combine_payment_spl_amount_180d, 0),
        nvl(t1.combine_payment_cci_amount_180d, 0),
        nvl(t1.combine_payment_pix_amount_180d , 0),
        nvl(t1.combine_payment_wallet_amount_180d, 0),
        nvl(t1.combine_payment_cnt_360d, 0),
        nvl(t1.combine_payment_amount_360d, 0),
        nvl(t1.combine_payment_spl_amount_360d, 0),
        nvl(t1.combine_payment_cci_amount_360d, 0),
        nvl(t1.combine_payment_pix_amount_360d, 0),
        nvl(t1.combine_payment_wallet_amount_360d, 0)
from (
    select *
    from all_user_transaction_payemnt_feature
) t1
;