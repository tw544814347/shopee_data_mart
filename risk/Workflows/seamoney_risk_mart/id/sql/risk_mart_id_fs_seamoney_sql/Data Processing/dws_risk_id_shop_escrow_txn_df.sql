--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-10-10
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


--drop table if exists ${SCHEMA}.dws_risk_id_shop_escrow_txn_df;

create external table if not exists ${SCHEMA}.dws_risk_id_shop_escrow_txn_df (
    shop_id                             string comment 'shop id'
    ,is_eligible_12m                    bigint comment 'whether the customer is eligible for 12 month tenor'
    ,first_sales_date                   string comment 'first selling transaction happened date'
    ,escrow_normal_pmt_30d              decimal(30,10) comment 'escrow amount of non-cod order in 30 days'
    ,escrow_normal_pmt_31_60d           decimal(30,10) comment 'escrow amount of non-cod order in 31-60 days'
    ,escrow_normal_pmt_61_90d           decimal(30,10) comment 'escrow amount of non-cod order in 61-90 days'
    ,escrow_normal_pmt_91_120d          decimal(30,10) comment 'escrow amount of non-cod order in 91-120 days'
    ,escrow_normal_pmt_121_150d         decimal(30,10) comment 'escrow amount of non-cod order in 121-150 days'
    ,escrow_normal_pmt_151_180d         decimal(30,10) comment 'escrow amount of non-cod order in 151-180 days'
    ,txn_escrow_normal_pmt_30d          bigint comment 'non-cod & escrow amount > 0 order in last 30 days'
    ,txn_escrow_normal_pmt_31_60d       bigint comment 'non-cod & escrow amount > 0 order in last 31-60 days'
    ,txn_escrow_normal_pmt_61_90d       bigint comment 'non-cod & escrow amount > 0 order in last 61-90 days'
    ,txn_escrow_normal_pmt_91_120d      bigint comment 'non-cod & escrow amount > 0 order in last 91-120 days'
    ,txn_escrow_normal_pmt_121_150d     bigint comment 'non-cod & escrow amount > 0 order in last 121-150 days'
    ,txn_escrow_normal_pmt_151_180d     bigint comment 'non-cod & escrow amount > 0 order in last 151-180 days'
    ,txn_shipout_normal_pmt_30d         bigint comment 'non-cod order in last 30 days'
    ,txn_shipout_normal_pmt_31_60d      bigint comment 'non-cod order in last 31-60 days'
    ,txn_shipout_normal_pmt_61_90d      bigint comment 'non-cod order in last 61-90 days'
    ,txn_shipout_normal_pmt_91_120d     bigint comment 'non-cod order in last 91-120 days'
    ,txn_shipout_normal_pmt_121_150d    bigint comment 'non-cod order in last 121-150 days'
    ,txn_shipout_normal_pmt_151_180d    bigint comment 'non-cod order in last 151-180 days'
    ,escrow_cod_pmt_30d                 bigint comment 'cod & escrow amount > 0 order in last 30 days'
    ,escrow_cod_pmt_31_60d              bigint comment 'cod & escrow amount > 0 order in last 31-60 days'
    ,escrow_cod_pmt_61_90d              bigint comment 'cod & escrow amount > 0 order in last 61-90 days'
    ,escrow_cod_pmt_91_120d             bigint comment 'cod & escrow amount > 0 order in last 91-120 days'
    ,escrow_cod_pmt_121_150d            bigint comment 'cod & escrow amount > 0 order in last 121-150 days'
    ,escrow_cod_pmt_151_180d            bigint comment 'cod & escrow amount > 0 order in last 151-180 days'
    ,gmv_shipout_cod_pmt_30d            decimal(30,10) comment 'gmv of cod order in last 30 days'
    ,gmv_shipout_cod_pmt_31_60d         decimal(30,10) comment 'gmv of cod order in last 31-60 days'
    ,gmv_shipout_cod_pmt_61_90d         decimal(30,10) comment 'gmv of cod order in last 61-90 days'
    ,gmv_shipout_cod_pmt_91_120d        decimal(30,10) comment 'gmv of cod order in last 91-120 days'
    ,gmv_shipout_cod_pmt_121_150d       decimal(30,10) comment 'gmv of cod order in last 121-150 days'
    ,gmv_shipout_cod_pmt_151_180d       decimal(30,10) comment 'gmv of cod order in last 151-180 days'
    ,gmv_shipout_normal_pmt_30d         decimal(30,10) comment 'gmv of non-cod order in last 30 days'
    ,gmv_shipout_normal_pmt_31_60d      decimal(30,10) comment 'gmv of non-cod order in last 31-60 days'
    ,gmv_shipout_normal_pmt_61_90d      decimal(30,10) comment 'gmv of non-cod order in last 61-90 days'
    ,gmv_shipout_normal_pmt_91_120d     decimal(30,10) comment 'gmv of non-cod order in last 91-120 days'
    ,gmv_shipout_normal_pmt_121_150d    decimal(30,10) comment 'gmv of non-cod order in last 121-150 days'
    ,gmv_shipout_normal_pmt_151_180d    decimal(30,10) comment 'gmv of non-cod order in last 151-180 days'
    ,txn_escrow_cod_pmt_30d             bigint comment 'cod & escrow amount > 0 order in last 30 days'
    ,txn_escrow_cod_pmt_31_60d          bigint comment 'cod & escrow amount > 0 order in last 31-60 days'
    ,txn_escrow_cod_pmt_61_90d          bigint comment 'cod & escrow amount > 0 order in last 61-90 days'
    ,txn_escrow_cod_pmt_91_120d         bigint comment 'cod & escrow amount > 0 order in last 91-120 days'
    ,txn_escrow_cod_pmt_121_150d        bigint comment 'cod & escrow amount > 0 order in last 121-150 days'
    ,txn_escrow_cod_pmt_151_180d        bigint comment 'cod & escrow amount > 0 order in last 151-180 days'
    ,txn_shipout_cod_pmt_30d            bigint comment 'cod order in last 30 days'
    ,txn_shipout_cod_pmt_31_60d         bigint comment 'cod order in last 31-60 days'
    ,txn_shipout_cod_pmt_61_90d         bigint comment 'cod order in last 61-90 days'
    ,txn_shipout_cod_pmt_91_120d        bigint comment 'cod order in last 91-120 days'
    ,txn_shipout_cod_pmt_121_150d       bigint comment 'cod order in last 121-150 days'
    ,txn_shipout_cod_pmt_151_180d       bigint comment 'cod order in last 151-180 days'
    ,days_has_txn_30days                bigint comment 'days has txn in last 30days'
    ,days_has_txn_90days                bigint comment 'days has txn in last 90days'
    ,days_has_txn_180days               bigint comment 'days has txn in last 180days'
    ,days_has_txn_360days               bigint comment 'days has txn in last 360days'
    ,daily_avg_escrow                   decimal(30,10) comment 'average daily escrow amount'
    ,daily_escrow_percentile50          decimal(30,10) comment '50 percentile of daily escrow amount'
    ,daily_escrow_percentile75          decimal(30,10) comment '75 percentile of daily escrow amount'
    ,daily_escrow_percentile90          decimal(30,10) comment '90 percentile of daily escrow amount'
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_id_shop_escrow_txn_df/' 
comment 
'
Tag:risk summary table
table description: record the shop escrow transaction
table source: 
mp_user.dim_shop__reg_s0_live
mp_order.dwd_order_all_ent_df__reg_s0_live
'
;

--msck repair table ${SCHEMA}.dws_risk_id_shop_escrow_txn_df;

create or replace temporary view shop_info as (
    select  shop_id
    from    mp_user.dim_shop__id_s0_live 
    where   grass_date = '${ds}'
    and     grass_region = 'ID'
)
;

-- 独立
create or replace temporary view tmp_fs_262 as (
    select  shop_id
            ,first_sales_date
            ,case when first_sales_date < current_date - interval '1' year then 1 else 0 end  as is_eligible_12m
    from    (
        select  shop_id
                ,min(case when is_net_order = 1 then grass_date else null end) as first_sales_date
        from    mp_order.dwd_order_all_ent_df__id_s0_live
        where   grass_region = 'ID'
        and     tz_type = 'local'
        and (grass_date >= current_date - interval '390' day  or grass_date = date('9999-01-01'))
        and (grass_date <> date('9999-01-01') or (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
        and cast(escrow_paid_datetime as date) between current_date - interval '390' day and current_date
        group by shop_id    
    )
)
;

create or replace temporary view order_info as (
    select  date(shipping_confirm_datetime) as shipping_confirm_date -- make sure
            ,shop_id
            ,order_id
            ,gmv_usd
            ,escrow_to_seller_amt_usd,
            case    when payment_method = 'PAY_COD' then 1
                    else 0  
                    end as is_cod
            ,grass_date
            ,escrow_paid_datetime
            ,order_be_status
            ,shipping_confirm_timestamp
            ,escrow_to_seller_amt
    from    mp_order.dwd_order_all_ent_df__id_s0_live
    where   grass_region = 'ID' 
    -- and     shipping_confirm_timestamp is not null -- 退化到tmp_fs_284 / tmp_fs_287
)
;

create or replace temporary view tmp_fs_284 as (
    SELECT  shop_id
            --Normal & amount
            ,sum(case when is_cod = 0 and shipping_confirm_date >= current_date - interval '30' day then gmv_usd else null end) as gmv_shipout_normal_pmt_30d
            ,sum(case when is_cod = 0 and shipping_confirm_date >= current_date - interval '30' day then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_30d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day then gmv_usd else null end) as gmv_shipout_normal_pmt_31_60d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_31_60d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day then gmv_usd else null end) as gmv_shipout_normal_pmt_61_90d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_61_90d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day then gmv_usd else null end) as gmv_shipout_normal_pmt_91_120d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_91_120d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day then gmv_usd else null end) as gmv_shipout_normal_pmt_121_150d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_121_150d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day then gmv_usd else null end) as gmv_shipout_normal_pmt_151_180d
            ,sum(case when is_cod = 0 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day then escrow_to_seller_amt_usd else null end) AS escrow_normal_pmt_151_180d   
            --COD & amount     
            ,sum(case when is_cod = 1 and shipping_confirm_date >= current_date - interval '30' day then gmv_usd else null end) as gmv_shipout_cod_pmt_30d
            ,sum(case when is_cod = 1 and shipping_confirm_date >= current_date - interval '30' day then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_30d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day then gmv_usd else null end) as gmv_shipout_cod_pmt_31_60d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_31_60d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day then gmv_usd else null end) as gmv_shipout_cod_pmt_61_90d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_61_90d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day then gmv_usd else null end) as gmv_shipout_cod_pmt_91_120d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_91_120d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day then gmv_usd else null end) as gmv_shipout_cod_pmt_121_150d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_121_150d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day then gmv_usd else null end) as gmv_shipout_cod_pmt_151_180d
            ,sum(case when is_cod = 1 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_151_180d
            --Normal & TxN
            ,count(distinct case when is_cod = 0 and shipping_confirm_date >= current_date - interval '30' day then order_id else null end) as txn_shipout_normal_pmt_30d
            ,count(distinct case when is_cod = 0 and shipping_confirm_date >= current_date - interval '30' day and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_30d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day then order_id else null end) AS txn_shipout_normal_pmt_31_60d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day and escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_normal_pmt_31_60d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day then order_id else null end) AS txn_shipout_normal_pmt_61_90d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_normal_pmt_61_90d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day then order_id else null end) AS txn_shipout_normal_pmt_91_120d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_normal_pmt_91_120d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day then order_id else null end) AS txn_shipout_normal_pmt_121_150d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_normal_pmt_121_150d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day then order_id else null end) AS txn_shipout_normal_pmt_151_180d
            ,COUNT(DISTINCT case when is_cod = 0 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_normal_pmt_151_180d
            --COD & TxN
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date >= current_date - interval '30' day then order_id else null end) AS txn_shipout_cod_pmt_30d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date >= current_date - interval '30' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_cod_pmt_30d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day then order_id else null end) AS txn_shipout_cod_pmt_31_60d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '60' day and current_date - interval '31' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_cod_pmt_31_60d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day then order_id else null end) AS txn_shipout_cod_pmt_61_90d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '90' day and current_date - interval '61' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_cod_pmt_61_90d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day then order_id else null end) AS txn_shipout_cod_pmt_91_120d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '120' day and current_date - interval '91' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_cod_pmt_91_120d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day then order_id else null end) AS txn_shipout_cod_pmt_121_150d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '150' day and current_date - interval '121' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_cod_pmt_121_150d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day  then order_id else null end) AS txn_shipout_cod_pmt_151_180d
            ,COUNT(DISTINCT case when is_cod = 1 and shipping_confirm_date between current_date - interval '180' day and current_date - interval '151' day AND escrow_to_seller_amt_usd > 0 then order_id else null end) AS txn_escrow_cod_pmt_151_180d
    FROM    order_info
    where   shipping_confirm_timestamp is not null
    and     ((grass_date between current_date - interval '180' day and current_date - interval '1' day)
            or (grass_date = DATE '9999-01-01' 
                and order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID') 
                and (CAST(escrow_paid_datetime as date) between (CURRENT_DATE - interval  '180'  day) and current_date)
            )
    )
    GROUP BY shop_id
)
;


create or replace temporary view tmp_fs_286 as (
    select  shop_id
            ,COUNT(DISTINCT CASE WHEN shipping_confirm_date >= (CURRENT_DATE - interval  '30'  day) THEN shipping_confirm_date ELSE NULL END) days_has_txn_30days
            ,COUNT(DISTINCT CASE WHEN shipping_confirm_date >= (CURRENT_DATE - interval  '90'  day) THEN shipping_confirm_date ELSE NULL END) days_has_txn_90days
            ,COUNT(DISTINCT CASE WHEN shipping_confirm_date >= (CURRENT_DATE - interval  '180'  day) THEN shipping_confirm_date ELSE NULL END) days_has_txn_180days
            ,COUNT(DISTINCT CASE WHEN shipping_confirm_date >= (CURRENT_DATE - interval  '360'  day) THEN shipping_confirm_date ELSE NULL END) days_has_txn_360days
    from    order_info
    where   ((grass_date between current_date - interval '360' day and current_date - interval '1' day)
            or (grass_date = DATE '9999-01-01' 
                and order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID') 
                and (cast(escrow_paid_datetime as date) between (current_date - interval  '360'  day) and current_date)
            )
    )
    group by shop_id
)
;

create or replace temporary view tmp_fs_287 as (
    SELECT  shop_id,
            avg(daily_escrow_to_seller_usd) as daily_avg_escrow,
            approx_percentile(daily_escrow_to_seller_usd , 0.5, 10000) as daily_escrow_percentile50,
            approx_percentile(daily_escrow_to_seller_usd, 0.75, 10000) as daily_escrow_percentile75,
            approx_percentile(daily_escrow_to_seller_usd, 0.9, 10000) as daily_escrow_percentile90
    FROM    (
        SELECT  shop_id
                ,shipping_confirm_date,
                SUM(escrow_to_seller_amt_usd) daily_escrow_to_seller_usd
        FROM    order_info
        WHERE   shipping_confirm_timestamp is not null
        AND     escrow_to_seller_amt > 0
        AND     ((grass_date BETWEEN (CURRENT_DATE - interval '181' day) AND (CURRENT_DATE - interval '1' day))
                OR  (grass_date = DATE '9999-01-01' 
                    AND order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID') 
                    AND (CAST(escrow_paid_datetime as date) BETWEEN (CURRENT_DATE - interval  '181'  day) AND CURRENT_DATE)
                    )
                )
        GROUP BY shop_id, shipping_confirm_date
    )
    GROUP BY shop_id
)
;

insert overwrite ${SCHEMA}.dws_risk_id_shop_escrow_txn_df partition (grass_date = '${ds}')
select  t1.shop_id
        ,t2.is_eligible_12m
        ,t2.first_sales_date
        ,t3.escrow_normal_pmt_30d
        ,t3.escrow_normal_pmt_31_60d
        ,t3.escrow_normal_pmt_61_90d
        ,t3.escrow_normal_pmt_91_120d
        ,t3.escrow_normal_pmt_121_150d
        ,t3.escrow_normal_pmt_151_180d
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
        ,t3.escrow_cod_pmt_30d
        ,t3.escrow_cod_pmt_31_60d
        ,t3.escrow_cod_pmt_61_90d
        ,t3.escrow_cod_pmt_91_120d
        ,t3.escrow_cod_pmt_121_150d
        ,t3.escrow_cod_pmt_151_180d
        ,t3.gmv_shipout_cod_pmt_30d
        ,t3.gmv_shipout_cod_pmt_31_60d
        ,t3.gmv_shipout_cod_pmt_61_90d
        ,t3.gmv_shipout_cod_pmt_91_120d
        ,t3.gmv_shipout_cod_pmt_121_150d
        ,t3.gmv_shipout_cod_pmt_151_180d
        ,t3.gmv_shipout_normal_pmt_30d
        ,t3.gmv_shipout_normal_pmt_31_60d
        ,t3.gmv_shipout_normal_pmt_61_90d
        ,t3.gmv_shipout_normal_pmt_91_120d
        ,t3.gmv_shipout_normal_pmt_121_150d
        ,t3.gmv_shipout_normal_pmt_151_180d
        ,t3.txn_escrow_cod_pmt_30d
        ,t3.txn_escrow_cod_pmt_31_60d
        ,t3.txn_escrow_cod_pmt_61_90d
        ,t3.txn_escrow_cod_pmt_91_120d
        ,t3.txn_escrow_cod_pmt_121_150d
        ,t3.txn_escrow_cod_pmt_151_180d
        ,t3.txn_shipout_cod_pmt_30d
        ,t3.txn_shipout_cod_pmt_31_60d
        ,t3.txn_shipout_cod_pmt_61_90d
        ,t3.txn_shipout_cod_pmt_91_120d
        ,t3.txn_shipout_cod_pmt_121_150d
        ,t3.txn_shipout_cod_pmt_151_180d
        ,t4.days_has_txn_30days
        ,t4.days_has_txn_90days
        ,t4.days_has_txn_180days
        ,t4.days_has_txn_360days
        ,t5.daily_avg_escrow
        ,t5.daily_escrow_percentile50
        ,t5.daily_escrow_percentile75
        ,t5.daily_escrow_percentile90
from    shop_info as t1 
left join tmp_fs_262 as t2
on t1.shop_id = t2.shop_id
left join tmp_fs_284 as t3
on t1.shop_id = t3.shop_id
left join tmp_fs_286 as t4 
on t1.shop_id = t4.shop_id 
left join tmp_fs_287 as t5 
on t1.shop_id = t5.shop_id
;

