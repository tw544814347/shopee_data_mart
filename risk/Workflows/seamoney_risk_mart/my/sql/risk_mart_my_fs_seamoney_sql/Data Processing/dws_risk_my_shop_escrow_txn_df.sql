--********************************************************************--
-- Author:              xiukai.yu@seamoney.com
-- Created Time:        2024-11-20
-- Description:         https://docs.google.com/spreadsheets/d/1Q0kBoljyNJ_bep2f0rZ8ZIRs1JdiErZ8Z2b0zTjK53M/edit?pli=1&gid=1148389135#gid=1148389135
--********************************************************************--

--drop table if exists ${SCHEMA}.dws_risk_my_shop_escrow_txn_df;
create table if not exists ${SCHEMA}.dws_risk_my_shop_escrow_txn_df
(
    shop_id                                 string,
    gmv_shipout_normal_pmt_30d              double,
    escrow_normal_pmt_30d                   double,
    gmv_shipout_normal_pmt_31_60d           double,
    escrow_normal_pmt_31_60d                double,
    gmv_shipout_normal_pmt_61_90d           double,
    escrow_normal_pmt_61_90d                double,
    gmv_shipout_normal_pmt_91_120d          double,
    escrow_normal_pmt_91_120d               double,
    gmv_shipout_normal_pmt_121_150d         double,
    escrow_normal_pmt_121_150d              double,
    gmv_shipout_normal_pmt_151_180d         double,
    escrow_normal_pmt_151_180d              double,
    gmv_shipout_cod_pmt_30d                 double,
    escrow_cod_pmt_30d                      double,
    gmv_shipout_cod_pmt_31_60d              double,
    escrow_cod_pmt_31_60d                   double,
    gmv_shipout_cod_pmt_61_90d              double,
    escrow_cod_pmt_61_90d                   double,
    gmv_shipout_cod_pmt_91_120d             double,
    escrow_cod_pmt_91_120d                  double,
    gmv_shipout_cod_pmt_121_150d            double,
    escrow_cod_pmt_121_150d                 double,
    gmv_shipout_cod_pmt_151_180d            double,
    escrow_cod_pmt_151_180d                 double,
    txn_shipout_normal_pmt_30d              bigint,
    txn_escrow_normal_pmt_30d               bigint,
    txn_shipout_normal_pmt_31_60d           bigint,
    txn_escrow_normal_pmt_31_60d            bigint,
    txn_shipout_normal_pmt_61_90d           bigint,
    txn_escrow_normal_pmt_61_90d            bigint,
    txn_shipout_normal_pmt_91_120d          bigint,
    txn_escrow_normal_pmt_91_120d           bigint,
    txn_shipout_normal_pmt_121_150d         bigint,
    txn_escrow_normal_pmt_121_150d          bigint,
    txn_shipout_normal_pmt_151_180d         bigint,
    txn_escrow_normal_pmt_151_180d          bigint,
    txn_shipout_cod_pmt_30d                 bigint,
    txn_escrow_cod_pmt_30d                  bigint,
    txn_shipout_cod_pmt_31_60d              bigint,
    txn_escrow_cod_pmt_31_60d               bigint,
    txn_shipout_cod_pmt_61_90d              bigint,
    txn_escrow_cod_pmt_61_90d               bigint,
    txn_shipout_cod_pmt_91_120d             bigint,
    txn_escrow_cod_pmt_91_120d              bigint,
    txn_shipout_cod_pmt_121_150d            bigint,
    txn_escrow_cod_pmt_121_150d             bigint,
    txn_shipout_cod_pmt_151_180d            bigint,
    txn_escrow_cod_pmt_151_180d             bigint,
    first_sales_date                        string,
    is_eligible_12m                         int,
    days_has_txn_30days                     bigint,
    days_has_txn_90days                     bigint,
    days_has_txn_180days                    bigint,
    days_has_txn_360days                    bigint,
    daily_avg_escrow                        double,
    daily_escrow_percentile50               double,
    daily_escrow_percentile75               double,
    daily_escrow_percentile90               double
)  
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_my_shop_escrow_txn_df/grass_region=MY';
--msck repair table ${SCHEMA}.dws_risk_my_shop_escrow_txn_df;


create or replace temporary view shop_info as
select 
    shop_id
from mp_user.dim_shop__reg_s0_live 
where grass_date = cast('${grass_date}' as date)
    and grass_region = '${upper_region}'
;


create or replace temporary view order_info AS
select
    cast(split(shipping_confirm_datetime,' ')[0] AS date) AS shipping_confirm_datetime, 
    shop_id, 
    order_id, 
    gmv_usd, 
    escrow_to_seller_amt_usd,
    case 
        when payment_method = 'PAY_COD' then 1
        else 0  
    end is_cod
from mp_order.dwd_order_all_ent_df__reg_s0_live
where grass_region = '${upper_region}' 
    and shipping_confirm_timestamp is not null
    and (
        (grass_date between cast(date_sub('${cur_date}', 180) as date) and cast('${grass_date}' as date))
        or
        (grass_date = cast('9999-01-01' as date) and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID') 
            and (cast(escrow_paid_datetime as date) between cast(date_sub('${cur_date}', 180) as date) and cast('${cur_date}' as date))
        )
    )
;


create or replace temporary view basic_order_info AS
select
    shop_id, 
    min(case when is_net_order = 1 then grass_date else null end) AS first_sales_date
from mp_order.dwd_order_all_ent_df__reg_s0_live
where grass_region = '${upper_region}' 
    and tz_type = 'local'
    and (grass_date >= cast(date_sub('${cur_date}', 390) as date) OR grass_date = cast('9999-01-01' as date))
    and (grass_date <> cast('9999-01-01' as date) or (grass_date = cast('9999-01-01' as date) and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
    and cast(escrow_paid_datetime as date) between cast(date_sub('${cur_date}', 390) as date) and cast('${cur_date}' as date)
group by shop_id;
;


create or replace temporary view txn_frequency_info AS
select
    shop_id, 
    count(distinct case when cast(split(shipping_confirm_datetime,' ')[0] as date) >= date_sub('${cur_date}', 30) then cast(split(shipping_confirm_datetime,' ')[0] as date) else null end) as days_has_txn_30days,
    count(distinct case when cast(split(shipping_confirm_datetime,' ')[0] as date) >= date_sub('${cur_date}', 90) then cast(split(shipping_confirm_datetime,' ')[0] as date) else null end) as days_has_txn_90days,
    count(distinct case when cast(split(shipping_confirm_datetime,' ')[0] as date) >= date_sub('${cur_date}', 180) then cast(split(shipping_confirm_datetime,' ')[0] as date) else null end) as days_has_txn_180days,
    count(distinct case when cast(split(shipping_confirm_datetime,' ')[0] as date) >= date_sub('${cur_date}', 360) then cast(split(shipping_confirm_datetime,' ')[0] as date) else null end) as days_has_txn_360days
from mp_order.dwd_order_all_ent_df__reg_s0_live
where grass_region = '${upper_region}' 
    and (
        (grass_date between cast(date_sub('${cur_date}', 360) as date) and cast(date_sub('${cur_date}', 1) as date))
        or
        (grass_date = cast('9999-01-01' as date)
            AND order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID') 
            AND (cast(escrow_paid_datetime as date) between cast(date_sub('${cur_date}', 360) as date) and cast('${cur_date}' as date))
        )
    )
group by shop_id;
;


create or replace temporary view escrow_percentile_info AS
select 
    shop_id,
    avg(daily_escrow_to_seller_usd) as daily_avg_escrow,
    approx_percentile(daily_escrow_to_seller_usd , 0.5, 10000) as daily_escrow_percentile50,
    approx_percentile(daily_escrow_to_seller_usd, 0.75, 10000) as daily_escrow_percentile75,
    approx_percentile(daily_escrow_to_seller_usd, 0.9, 10000) as daily_escrow_percentile90
from (
    select
        shop_id,
        cast(split(shipping_confirm_datetime,' ')[0] as date) as shipping_confirm_date,
        sum(escrow_to_seller_amt_usd) as daily_escrow_to_seller_usd
    from mp_order.dwd_order_all_ent_df__reg_s0_live
    where grass_region = '${upper_region}' 
        and shipping_confirm_timestamp is not null
        and escrow_to_seller_amt > 0
        and ( (grass_date between cast(date_sub('${cur_date}', 181) as date) and cast(date_sub('${cur_date}', 1) as date))
            or
            (grass_date = cast('9999-01-01' as date)
                and order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID') 
                and (cast(escrow_paid_datetime as date) between cast(date_sub('${cur_date}', 181) as date) and cast('${cur_date}' as date))
            )
        )
    group by shop_id, split(shipping_confirm_datetime,' ')[0]
) as t
group by shop_id
;

create or replace temporary view fs_feature_info as
select 
    shop_id,
    --normal & amount
    sum(case when is_cod = 0 and shipping_confirm_datetime >= date_sub('${cur_date}', 30) then gmv_usd else null end) as gmv_shipout_normal_pmt_30d,
    sum(case when is_cod = 0 and shipping_confirm_datetime >= date_sub('${cur_date}', 30) then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_30d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 60) and date_sub('${cur_date}', 31) then gmv_usd else null end) as gmv_shipout_normal_pmt_31_60d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 60) and date_sub('${cur_date}', 31) then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_31_60d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 90) and date_sub('${cur_date}', 61) then gmv_usd else null end) as gmv_shipout_normal_pmt_61_90d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 90) and date_sub('${cur_date}', 61) then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_61_90d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 120) and date_sub('${cur_date}',91) then gmv_usd else null end) as gmv_shipout_normal_pmt_91_120d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 120) and date_sub('${cur_date}',91) then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_91_120d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 150) and date_sub('${cur_date}',121) then gmv_usd else null end) as gmv_shipout_normal_pmt_121_150d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 150) and date_sub('${cur_date}',121) then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_121_150d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 180) and date_sub('${cur_date}',151) then gmv_usd else null end) as gmv_shipout_normal_pmt_151_180d,
    sum(case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}', 180) and date_sub('${cur_date}',151) then escrow_to_seller_amt_usd else null end) as escrow_normal_pmt_151_180d,    
    --cod & amount     
    sum(case when is_cod = 1 and shipping_confirm_datetime >= date_sub('${cur_date}',30) then gmv_usd else null end) as gmv_shipout_cod_pmt_30d,
    sum(case when is_cod = 1 and shipping_confirm_datetime >= date_sub('${cur_date}',30) then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_30d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',60) and date_sub('${cur_date}',31) then gmv_usd else null end) as gmv_shipout_cod_pmt_31_60d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',60) and date_sub('${cur_date}',31) then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_31_60d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',90) and date_sub('${cur_date}',61) then gmv_usd else null end) as gmv_shipout_cod_pmt_61_90d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',90) and date_sub('${cur_date}',61) then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_61_90d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',120) and date_sub('${cur_date}',91) then gmv_usd else null end) as gmv_shipout_cod_pmt_91_120d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',120) and date_sub('${cur_date}',91) then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_91_120d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',150) and date_sub('${cur_date}',121) then gmv_usd else null end) as gmv_shipout_cod_pmt_121_150d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',150) and date_sub('${cur_date}',121) then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_121_150d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',180) and date_sub('${cur_date}',151) then gmv_usd else null end) as gmv_shipout_cod_pmt_151_180d,
    sum(case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',180) and date_sub('${cur_date}',151) then escrow_to_seller_amt_usd else null end) as escrow_cod_pmt_151_180d, 
    --normal & txn
    count(distinct case when is_cod = 0 and shipping_confirm_datetime >= date_sub('${cur_date}',30) then order_id else null end) as txn_shipout_normal_pmt_30d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime >= date_sub('${cur_date}',30) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_30d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',60) and date_sub('${cur_date}',31) then order_id else null end) as txn_shipout_normal_pmt_31_60d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',60) and date_sub('${cur_date}',31) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_31_60d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',90) and date_sub('${cur_date}',61) then order_id else null end) as txn_shipout_normal_pmt_61_90d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',90) and date_sub('${cur_date}',61) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_61_90d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',120) and date_sub('${cur_date}',91) then order_id else null end) as txn_shipout_normal_pmt_91_120d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',120) and date_sub('${cur_date}',91) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_91_120d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',150) and date_sub('${cur_date}',121) then order_id else null end) as txn_shipout_normal_pmt_121_150d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',150) and date_sub('${cur_date}',121) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_121_150d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',180) and date_sub('${cur_date}',151) then order_id else null end) as txn_shipout_normal_pmt_151_180d,
    count(distinct case when is_cod = 0 and shipping_confirm_datetime between date_sub('${cur_date}',180) and date_sub('${cur_date}',151) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_normal_pmt_151_180d,
    --cod & txn
    count(distinct case when is_cod = 1 and shipping_confirm_datetime >= date_sub('${cur_date}',30) then order_id else null end) as txn_shipout_cod_pmt_30d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime >= date_sub('${cur_date}',30) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_cod_pmt_30d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',60) and date_sub('${cur_date}',31) then order_id else null end) as txn_shipout_cod_pmt_31_60d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',60) and date_sub('${cur_date}',31) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_cod_pmt_31_60d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',90) and date_sub('${cur_date}',61) then order_id else null end) as txn_shipout_cod_pmt_61_90d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',90) and date_sub('${cur_date}',61) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_cod_pmt_61_90d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',120) and date_sub('${cur_date}',91) then order_id else null end) as txn_shipout_cod_pmt_91_120d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',120) and date_sub('${cur_date}',91) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_cod_pmt_91_120d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',150) and date_sub('${cur_date}',121) then order_id else null end) as txn_shipout_cod_pmt_121_150d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',150) and date_sub('${cur_date}',121) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_cod_pmt_121_150d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',180) and date_sub('${cur_date}',151) then order_id else null end) as txn_shipout_cod_pmt_151_180d,
    count(distinct case when is_cod = 1 and shipping_confirm_datetime between date_sub('${cur_date}',180) and date_sub('${cur_date}',151) and escrow_to_seller_amt_usd > 0 then order_id else null end) as txn_escrow_cod_pmt_151_180d
from order_info
group by shop_id
;

insert overwrite table ${SCHEMA}.dws_risk_my_shop_escrow_txn_df partition(grass_date)
select 
    a.shop_id as shop_id,
    b.gmv_shipout_normal_pmt_30d as gmv_shipout_normal_pmt_30d,
    b.escrow_normal_pmt_30d as escrow_normal_pmt_30d,
    b.gmv_shipout_normal_pmt_31_60d as gmv_shipout_normal_pmt_31_60d,
    b.escrow_normal_pmt_31_60d as escrow_normal_pmt_31_60d,
    b.gmv_shipout_normal_pmt_61_90d as gmv_shipout_normal_pmt_61_90d,
    b.escrow_normal_pmt_61_90d as escrow_normal_pmt_61_90d,
    b.gmv_shipout_normal_pmt_91_120d as gmv_shipout_normal_pmt_91_120d,
    b.escrow_normal_pmt_91_120d as escrow_normal_pmt_91_120d,
    b.gmv_shipout_normal_pmt_121_150d as gmv_shipout_normal_pmt_121_150d,
    b.escrow_normal_pmt_121_150d as escrow_normal_pmt_121_150d,
    b.gmv_shipout_normal_pmt_151_180d as gmv_shipout_normal_pmt_151_180d,
    b.escrow_normal_pmt_151_180d as escrow_normal_pmt_151_180d,
    b.gmv_shipout_cod_pmt_30d as gmv_shipout_cod_pmt_30d,
    b.escrow_cod_pmt_30d as escrow_cod_pmt_30d,
    b.gmv_shipout_cod_pmt_31_60d as gmv_shipout_cod_pmt_31_60d,
    b.escrow_cod_pmt_31_60d as escrow_cod_pmt_31_60d,
    b.gmv_shipout_cod_pmt_61_90d as gmv_shipout_cod_pmt_61_90d,
    b.escrow_cod_pmt_61_90d as escrow_cod_pmt_61_90d,
    b.gmv_shipout_cod_pmt_91_120d as gmv_shipout_cod_pmt_91_120d,
    b.escrow_cod_pmt_91_120d as escrow_cod_pmt_91_120d,
    b.gmv_shipout_cod_pmt_121_150d as gmv_shipout_cod_pmt_121_150d,
    b.escrow_cod_pmt_121_150d as escrow_cod_pmt_121_150d,
    b.gmv_shipout_cod_pmt_151_180d as gmv_shipout_cod_pmt_151_180d,
    b.escrow_cod_pmt_151_180d as escrow_cod_pmt_151_180d,
    b.txn_shipout_normal_pmt_30d as txn_shipout_normal_pmt_30d,
    b.txn_escrow_normal_pmt_30d as txn_escrow_normal_pmt_30d,
    b.txn_shipout_normal_pmt_31_60d as txn_shipout_normal_pmt_31_60d,
    b.txn_escrow_normal_pmt_31_60d as txn_escrow_normal_pmt_31_60d,
    b.txn_shipout_normal_pmt_61_90d as txn_shipout_normal_pmt_61_90d,
    b.txn_escrow_normal_pmt_61_90d as txn_escrow_normal_pmt_61_90d,
    b.txn_shipout_normal_pmt_91_120d as txn_shipout_normal_pmt_91_120d,
    b.txn_escrow_normal_pmt_91_120d as txn_escrow_normal_pmt_91_120d,
    b.txn_shipout_normal_pmt_121_150d as txn_shipout_normal_pmt_121_150d,
    b.txn_escrow_normal_pmt_121_150d as txn_escrow_normal_pmt_121_150d,
    b.txn_shipout_normal_pmt_151_180d as txn_shipout_normal_pmt_151_180d,
    b.txn_escrow_normal_pmt_151_180d as txn_escrow_normal_pmt_151_180d,
    b.txn_shipout_cod_pmt_30d as txn_shipout_cod_pmt_30d,
    b.txn_escrow_cod_pmt_30d as txn_escrow_cod_pmt_30d,
    b.txn_shipout_cod_pmt_31_60d as txn_shipout_cod_pmt_31_60d,
    b.txn_escrow_cod_pmt_31_60d as txn_escrow_cod_pmt_31_60d,
    b.txn_shipout_cod_pmt_61_90d as txn_shipout_cod_pmt_61_90d,
    b.txn_escrow_cod_pmt_61_90d as txn_escrow_cod_pmt_61_90d,
    b.txn_shipout_cod_pmt_91_120d as txn_shipout_cod_pmt_91_120d,
    b.txn_escrow_cod_pmt_91_120d as txn_escrow_cod_pmt_91_120d,
    b.txn_shipout_cod_pmt_121_150d as txn_shipout_cod_pmt_121_150d,
    b.txn_escrow_cod_pmt_121_150d as txn_escrow_cod_pmt_121_150d,
    b.txn_shipout_cod_pmt_151_180d as txn_shipout_cod_pmt_151_180d,
    b.txn_escrow_cod_pmt_151_180d as txn_escrow_cod_pmt_151_180d,
    -- 只使用原来feature station中的部份逻辑
    c.first_sales_date as first_sales_date,
    -- 原来是减去 1 year  
    case when c.first_sales_date < cast(date_sub('${cur_date}', 365) as date) then 1 else 0 end as is_eligible_12m,
    d.days_has_txn_30days as days_has_txn_30days,
    d.days_has_txn_90days as days_has_txn_90days,
    d.days_has_txn_180days as days_has_txn_180days,
    d.days_has_txn_360days as days_has_txn_360days,
    e.daily_avg_escrow as daily_avg_escrow,
    e.daily_escrow_percentile50 as daily_escrow_percentile50,
    e.daily_escrow_percentile75 as daily_escrow_percentile75,
    e.daily_escrow_percentile90 as daily_escrow_percentile90,
    '${grass_date}'  as grass_date
from shop_info a
left join fs_feature_info b
    on a.shop_id = b.shop_id
left join basic_order_info c
    on a.shop_id = c.shop_id
left join txn_frequency_info d
    on a.shop_id = d.shop_id
left join escrow_percentile_info e
    on a.shop_id = e.shop_id  
;