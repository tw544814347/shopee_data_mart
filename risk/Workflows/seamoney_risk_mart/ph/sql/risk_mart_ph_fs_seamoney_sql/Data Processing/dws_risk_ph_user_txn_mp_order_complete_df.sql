--updated by wei.tao marketplace.shopee_checkout_v2_db__checkout_v2_tab__xx_df -> mp_order.dwd_checkout_all_ent_snapshot_df__xx_live

create temporary view return_tab as (
    select
        userid
        ,return_id
        ,orderid
    from marketplace.shopee_return_v2_db__return_v2_tab__reg_daily_s0_live
    where
        grass_region = upper('${region}')
        and status in (2, 5)
)
;

create temporary view orders_tab as (
    select
        op.order_id as orderid
        ,op.gmv
        ,op.gmv_usd
        ,op.buyer_id as userid
        ,from_unixtime(op.shipping_confirm_timestamp) as shipping_confirm_time
        ,cast(from_unixtime(op.shipping_confirm_timestamp) as date) shipping_confirm_date
        ,case
            when checkout.channelid = 40001 then 1
            when checkout.channelid in (40020, 40030) then 2
            when checkout.channelid in (
                40006
                ,40425
                ,40426
                ,40427
                ,40430
                ,40431
                ,40432
                ,40433
                ,40434
                ,40435
                ,40436
                ,40437
                ,40438
                ,40439
                ,40442
            )
                then 3
            when checkout.channelid in (40640, 40641, 40721) then 4
            when checkout.channelid in (
                41000
                ,40004
                ,40005
                ,40400
                ,40401
                ,40402
                ,40403
                ,40404
                ,40405
                ,40406
                ,40407
                ,40408
                ,40409
                ,40410
                ,40411
                ,40412
                ,40413
                ,40414
                ,40415
                ,40416
                ,40417
                ,40418
                ,40419
                ,40420
                ,40421
                ,40422
                ,40423
                ,40424
                ,40428
                ,40429
                ,40441
                ,40443
                ,40444
                ,49999
            )
                then 5
            when checkout.channelid = 49000 then 6
            when checkout.channelid in (45000, 45001, 45002, 45003, 45006, 45012) then 7
            else 8
        end as payment_method
        --1 credit card --2 shopee wallet --3 dragon pay online --4 wechat pay/touch pay --5 offline pay --6 COD --7 shopee SPL
    from
        mp_order.dwd_order_all_ent_df__reg_s0_live op
        inner join (
            select
                checkout_id as checkoutid
                ,get_json_object(checkout_info,'$.checkout_payment_info.channelid') as channelid
                ,get_json_object(checkout_info,'$.checkout_payment_info.spm_channel_id') as spm_channel_id
            -- from marketplace.shopee_checkout_v2_db__checkout_v2_tab__ph_df
            from mp_order.dwd_checkout_all_ent_snapshot_df__ph_live
            where grass_date = date('${grass_date}')
        ) checkout on op.checkout_id = checkout.checkoutid
    where
        op.grass_region = UPPER('${region}')
        and op.tz_type = 'local'
        and op.order_be_status_id in (4, 11, 12, 13, 14, 15)
        and op.shipping_confirm_timestamp > 0
        and op.is_bi_excluded = 0
        and checkout.channelid <> 49998 --PH: for free order need to exclude
        and checkout.channelid is not null
)
;

create temporary view user_info_tab as (
    select
        ot.userid
        --risk pctg 30 90 180 360 lifetime 
        ,cast(
            count(
                distinct (
                    case
                        when ot.payment_method = 6 then ot.orderid
                        else null
                    end
                )
            ) as double
        ) / cast(nullif(count(distinct ot.orderid), 0) as double) as pctg_of_cod__order_in_lifetime
        ,cast(
            count(
                distinct (
                    case
                        when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 360)
                            and ot.payment_method = 6
                            then ot.orderid
                        else null
                    end
                )
            ) as double
        ) / cast(
            nullif(
                count(
                    distinct (
                        case
                            when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 360) then ot.orderid
                            else null
                        end
                    )
                )
                ,0
            ) as double
        ) as pctg_of_cod__order_in_360d
        ,cast(
            count(
                distinct (
                    case
                        when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 180)
                            and ot.payment_method = 6
                            then ot.orderid
                        else null
                    end
                )
            ) as double
        ) / cast(
            nullif(
                count(
                    distinct (
                        case
                            when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 180) then ot.orderid
                            else null
                        end
                    )
                )
                ,0
            ) as double
        ) as pctg_of_cod__order_in_180d
        ,cast(
            count(
                distinct (
                    case
                        when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 90)
                            and ot.payment_method = 6
                            then ot.orderid
                        else null
                    end
                )
            ) as double
        ) / cast(
            nullif(
                count(
                    distinct (
                        case
                            when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 90) then ot.orderid
                            else null
                        end
                    )
                )
                ,0
            ) as double
        ) as pctg_of_cod__order_in_90d
        ,cast(
            count(
                distinct (
                    case
                        when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 30)
                            and ot.payment_method = 6
                            then ot.orderid
                        else null
                    end
                )
            ) as double
        ) / cast(
            nullif(
                count(
                    distinct (
                        case
                            when ot.shipping_confirm_date >= date_sub('${current_grass_date}', 30) then ot.orderid
                            else null
                        end
                    )
                )
                ,0
            ) as double
        ) as pctg_of_cod__order_in_30d
    from
        orders_tab ot
        left join return_tab rt on ot.orderid = rt.orderid
    where rt.return_id is null
    group by ot.userid
)
;

insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df partition (grass_date = '${grass_date}')
select
    userid as platform_user_id
    ,pctg_of_cod__order_in_30d
    ,pctg_of_cod__order_in_90d
    ,pctg_of_cod__order_in_180d
    ,pctg_of_cod__order_in_360d
    ,pctg_of_cod__order_in_lifetime
from user_info_tab
;