-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-20
-- Theme Domain:        MP User Txn Order Payment Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-20 - chengguo.liu - 按主题整合
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df (
    shopee_user_id                                    string     comment 'shopee user id'
    ,max_inactive_days_in_180d                        bigint     comment 'max inactive day in last 180 days'
)
partitioned by (
    grass_date                                        string     comment 'Partition, YYYY-MM-DD'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_aio_user_txn_mp_order_payment_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df;


create or replace temporary view order_escrow_paid_feature
as
select
    shopee_user_id
    ,max(diff) as max_inactive_days_in_180d
from
    (
        select
            shopee_user_id
            ,datediff(
                escrow_paid_date
                ,lag(escrow_paid_date, 1) over (
                    partition by shopee_user_id
                    order by escrow_paid_date
                )
            ) as diff
        from
            (
                select
                    seller_user_id as shopee_user_id
                    ,to_date(escrow_paid_datetime) as escrow_paid_date
                from ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df
                where
                    grass_date = '${grass_date}'
                    and to_date(escrow_paid_datetime) between date_sub('${current_grass_date}', 180) and date_sub('${current_grass_date}', 1)
                    and is_net_order = 1
                group by 1, 2
            )
    )
group by 1
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df partition(grass_date ='${grass_date}')
select
    t1.shopee_user_id
    ,t2.max_inactive_days_in_180d
from
(
    select
        user_id as shopee_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join order_escrow_paid_feature t2
on t1.shopee_user_id = t2.shopee_user_id
;
