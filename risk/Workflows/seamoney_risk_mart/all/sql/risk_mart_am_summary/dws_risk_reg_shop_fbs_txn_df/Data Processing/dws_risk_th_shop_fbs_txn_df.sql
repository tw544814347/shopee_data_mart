-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-06
-- Theme Domain:        MP Shop Full-filled-by-Shopee Txn
-- Data Granularity:    shop_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-06 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_shop_fbs_txn_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_shop_fbs_txn_df
(
    shop_id                                                 string         comment 'shop id'
    ,fbs_ado_m_1                                            double         comment 'fbs average daily orders in current month'
    ,fbs_ado_m_2                                            double         comment 'fbs average daily orders in previous month'
    ,fbs_ado_m_3                                            double         comment 'fbs average daily orders in 2 months ago'
    ,shop_ado_m_1                                           double         comment 'shop average daily orders in current month'
    ,shop_ado_m_2                                           double         comment 'shop average daily orders in previous month'
    ,shop_ado_m_3                                           double         comment 'shop average daily orders in 2 months ago'
    ,fbs_pen_m_1                                            double         comment 'fbs penetration rate in current month'
    ,fbs_pen_m_2                                            double         comment 'fbs penetration rate in previous month'
    ,fbs_pen_m_3                                            double         comment 'fbs penetration rate in 2 months ago'
    ,m_1_month                                              string         comment 'current month label'
    ,m_2_month                                              string         comment 'previous month label'
    ,m_3_month                                              string         comment '2 months ago month label'
    ,fbs_program_tier_m_1                                   string         comment 'fbs program tier in current month'
    ,fbs_program_tier_m_2                                   string         comment 'fbs program tier in previous month'
    ,fbs_program_tier_m_3                                   string         comment 'fbs program tier in 2 months ago'
)
comment 'fbs program tier summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_shop_fbs_txn_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_shop_fbs_txn_df;


create or replace temporary view tmp_fbs_ado as
select
    shop_id
    ,sum(
        case
            when date_trunc('month', to_date(create_datetime)) = date_trunc(
                'month'
                ,add_months(to_date('${grass_date}'), -2)
            )
                then order_fraction
        end
    ) as shop_total_gross_orders_m_3
    ,sum(
        case
            when date_trunc('month', to_date(create_datetime)) = date_trunc(
                'month'
                ,add_months(to_date('${grass_date}'), -1)
            )
                then order_fraction
        end
    ) as shop_total_gross_orders_m_2
    ,sum(
        case
            when date_trunc('month', to_date(create_datetime)) = date_trunc('month', to_date('${grass_date}'))
                then order_fraction
        end
    ) as shop_total_gross_orders_m_1
    ,sum(
        case
            when date_trunc('month', to_date(create_datetime)) = date_trunc(
                'month'
                ,add_months(to_date('${grass_date}'), -2)
            )
                and fulfilment_source = 'FULFILLED_BY_SHOPEE'
                then order_fraction
        end
    ) as shop_fbs_gross_orders_m_3
    ,sum(
        case
            when date_trunc('month', to_date(create_datetime)) = date_trunc(
                'month'
                ,add_months(to_date('${grass_date}'), -1)
            )
                and fulfilment_source = 'FULFILLED_BY_SHOPEE'
                then order_fraction
        end
    ) as shop_fbs_gross_orders_m_2
    ,sum(
        case
            when date_trunc('month', to_date(create_datetime)) = date_trunc('month', to_date('${grass_date}'))
                and fulfilment_source = 'FULFILLED_BY_SHOPEE'
                then order_fraction
        end
    ) as shop_fbs_gross_orders_m_1
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where
    tz_type = 'local'
    and grass_region = '${grass_region}'
    and is_bi_excluded = 0
    and grass_date >= cast(
        date_trunc(
            'month'
            ,add_months(to_date('${grass_date}'), -2)
        ) as date
    )
    and to_date(from_unixtime(create_timestamp)) >= cast(
        date_trunc(
            'month'
            ,add_months(to_date('${grass_date}'), -2)
        ) as date
    )
group by shop_id
;


create or replace temporary view tmp_fbs_final as
select
    a.shop_id
    ,shop_fbs_gross_orders_m_1 / dayofmonth(to_date('${grass_date}')) as fbs_ado_m_1
    ,shop_fbs_gross_orders_m_2 / dayofmonth(
        date_sub(
            date_trunc('month', to_date('${grass_date}'))
            ,1
        )
    ) as fbs_ado_m_2
    ,shop_fbs_gross_orders_m_3 / dayofmonth(
        date_sub(
            date_trunc(
                'month'
                ,add_months(to_date('${grass_date}'), -1)
            )
            ,1
        )
    ) as fbs_ado_m_3
    ,shop_total_gross_orders_m_1 / dayofmonth(to_date('${grass_date}')) as shop_ado_m_1
    ,shop_total_gross_orders_m_2 / dayofmonth(
        date_sub(
            date_trunc('month', to_date('${grass_date}'))
            ,1
        )
    ) as shop_ado_m_2
    ,shop_total_gross_orders_m_3 / dayofmonth(
        date_sub(
            date_trunc(
                'month'
                ,add_months(to_date('${grass_date}'), -1)
            )
            ,1
        )
    ) as shop_ado_m_3
    ,case
        when shop_total_gross_orders_m_1 = 0 then 0
        else cast(shop_fbs_gross_orders_m_1 as double) / cast(shop_total_gross_orders_m_1 as double)
    end as fbs_pen_m_1
    ,case
        when shop_total_gross_orders_m_2 = 0 then 0
        else cast(shop_fbs_gross_orders_m_2 as double) / cast(shop_total_gross_orders_m_2 as double)
    end as fbs_pen_m_2
    ,case
        when shop_total_gross_orders_m_3 = 0 then 0
        else cast(shop_fbs_gross_orders_m_3 as double) / cast(shop_total_gross_orders_m_3 as double)
    end as fbs_pen_m_3
    ,date_format(
        add_months(to_date('${grass_date}'), 0)
        ,'MMM'
    ) as m_1_month
    ,date_format(
        add_months(to_date('${grass_date}'), -1)
        ,'MMM'
    ) as m_2_month
    ,date_format(
        add_months(to_date('${grass_date}'), -2)
        ,'MMM'
    ) as m_3_month
from tmp_fbs_ado a
;


create or replace temporary view tmp_fbs_formatting as
select
    *
    ,case
        when shop_ado_m_1 > 500 and fbs_pen_m_1 >= 0.7 then 'Platinum'
        when fbs_pen_m_1 >= 0.7 then 'Gold'
        when fbs_pen_m_1 >= 0.5 and fbs_pen_m_1 < 0.7 then 'Silver'
        when fbs_pen_m_1 >= 0.3 and fbs_pen_m_1 < 0.5 then 'Bronze'
        when fbs_pen_m_1 < 0.3 then 'Others'
    end as fbs_program_tier_m_1
    ,case
        when shop_ado_m_2 > 500 and fbs_pen_m_2 >= 0.7 then 'Platinum'
        when fbs_pen_m_2 >= 0.7 then 'Gold'
        when fbs_pen_m_2 >= 0.5 and fbs_pen_m_2 < 0.7 then 'Silver'
        when fbs_pen_m_2 >= 0.3 and fbs_pen_m_2 < 0.5 then 'Bronze'
        when fbs_pen_m_2 < 0.3 then 'Others'
    end as fbs_program_tier_m_2
    ,case
        when shop_ado_m_3 > 500 and fbs_pen_m_3 >= 0.7 then 'Platinum'
        when fbs_pen_m_3 >= 0.7 then 'Gold'
        when fbs_pen_m_3 >= 0.5 and fbs_pen_m_3 < 0.7 then 'Silver'
        when fbs_pen_m_3 >= 0.3 and fbs_pen_m_3 < 0.5 then 'Bronze'
        when fbs_pen_m_3 < 0.3 then 'Others'
    end as fbs_program_tier_m_3
from tmp_fbs_final
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_shop_fbs_txn_df partition (grass_date = '${grass_date}')
select
    t1.shop_id
    ,t2.fbs_ado_m_1
    ,t2.fbs_ado_m_2
    ,t2.fbs_ado_m_3
    ,t2.shop_ado_m_1
    ,t2.shop_ado_m_2
    ,t2.shop_ado_m_3
    ,t2.fbs_pen_m_1
    ,t2.fbs_pen_m_2
    ,t2.fbs_pen_m_3
    ,t2.m_1_month
    ,t2.m_2_month
    ,t2.m_3_month
    ,t2.fbs_program_tier_m_1
    ,t2.fbs_program_tier_m_2
    ,t2.fbs_program_tier_m_3
from
(
    select
        shop_id
    from
    ${SCHEMA}.dim_risk_shop_df
    where tz_type = 'local'
    and grass_region = '${grass_region}'
    and grass_date = date '${grass_date}'
) t1
left join
(
    select
        shop_id
        ,cast(fbs_ado_m_1 as double) as fbs_ado_m_1
        ,cast(fbs_ado_m_2 as double) as fbs_ado_m_2
        ,cast(fbs_ado_m_3 as double) as fbs_ado_m_3
        ,cast(shop_ado_m_1 as double) as shop_ado_m_1
        ,cast(shop_ado_m_2 as double) as shop_ado_m_2
        ,cast(shop_ado_m_3 as double) as shop_ado_m_3
        ,cast(fbs_pen_m_1 as double) as fbs_pen_m_1
        ,cast(fbs_pen_m_2 as double) as fbs_pen_m_2
        ,cast(fbs_pen_m_3 as double) as fbs_pen_m_3
        ,m_1_month
        ,m_2_month
        ,m_3_month
        ,fbs_program_tier_m_1
        ,fbs_program_tier_m_2
        ,fbs_program_tier_m_3
    from tmp_fbs_formatting
) t2
on t1.shop_id = t2.shop_id
;
