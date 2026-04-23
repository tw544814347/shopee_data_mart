create
or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table
    ${SCHEMA}.ads_2cscore_id_user_mission_result_df partition (grass_date = '${ds}')
    --mp
select
    tt1.platform_user_id
    ,tt1.platform_type
    ,tt1.mission_id
    ,tt1.mission_type
    ,tt1.start_time
    ,tt1.completion_time
    ,tt1.start_time_local
    ,tt1.completion_time_local
    ,count(
        distinct case
            when tt1.start_time_local <= tt2.create_datetime
                and tt1.completion_time_local >= tt2.create_datetime
                and tt2.gmv >= tt3.mission_value
                then tt2.order_id
            else null
        end
    ) mission_result
from
    (
        select
            platform_user_id
            ,platform_type
            ,mission_id
            ,mission_type
            ,start_time
            ,completion_time
            ,start_time_local
            ,completion_time_local
        from ${SCHEMA}.dwd_2cscore_id_user_mission_df
        where
            grass_date = '${ds}'
            and (
                mission_progress in (1, 2)
                or (
                    mission_progress = 3
                    and completion_time_local >= date_sub('${ds}', 3)
                )
            )
            and mission_type = 1
    ) tt1
    left join (
        select
            t1.buyer_id shopee_user_id
            ,t1.order_id
            ,t1.create_datetime
            ,t1.gmv
        from
            mp_order.dwd_order_all_ent_df__reg_s0_live t1
            join (
                select
                    to_date(min(start_time_local)) min_date
                from ${SCHEMA}.dwd_2cscore_id_user_mission_df
                where
                    grass_date = '${ds}'
                    and (
                        mission_progress in (1, 2)
                        or (
                            mission_progress = 3
                            and completion_time_local >= date_sub('${ds}', 3)
                        )
                    )
                    and mission_type = 1
            ) t3 on 1 = 1
        where
            t1.tz_type = 'local'
            and t1.grass_region = 'ID'
            and t1.order_fe_status_id = 3
            and t1.create_datetime is not null
            and t1.grass_date >= t3.min_date
            and date_format(t1.create_datetime, 'yyyy-MM-dd') >= t3.min_date
    ) tt2 on tt1.platform_user_id = tt2.shopee_user_id
    join (
        select
            mission_id
            ,mission_value
        from ${SCHEMA}.dim_2cscore_id_complete_condition_df
        where
            grass_date = '${ds}'
            and mission_type = 1
            and mission_variable = 'shopee_order_amount'
    ) tt3 on tt1.mission_id = tt3.mission_id
group by
    tt1.platform_user_id
    ,tt1.platform_type
    ,tt1.mission_id
    ,tt1.mission_type
    ,tt1.start_time
    ,tt1.completion_time
    ,tt1.start_time_local
    ,tt1.completion_time_local
union all
--dp
select
    a.platform_user_id
    ,a.platform_type
    ,a.mission_id mission_id
    ,a.mission_type
    ,a.start_time
    ,a.completion_time
    ,a.start_time_local
    ,a.completion_time_local
    ,count(
        distinct case
            when a.start_time_local <= b.create_datetime and a.completion_time_local >= b.create_datetime then b.order_id
            else null
        end
    ) mission_result
from
    (
        select
            platform_user_id
            ,platform_type
            ,mission_id
            ,mission_type
            ,start_time
            ,completion_time
            ,start_time_local
            ,completion_time_local
        from ${SCHEMA}.dwd_2cscore_id_user_mission_df
        where
            grass_date = '${ds}'
            and (
                mission_progress in (1, 2)
                or (
                    mission_progress = 3
                    and completion_time_local >= date_sub('${ds}', 3)
                )
            )
            and mission_type in (2, 3, 4)
    ) a
    left join (
        select
            user_id shopee_user_id
            ,order_id
            ,format_time (create_time, '${region}') create_datetime
            ,case
                when category_id = '20102' then 2
                when category_id = '20103' then 3
                when category_id = '20101' then 4
                else null
            end mission_type
        from digitalpurchase.id_order_dwd_dp_trd_ord_df_s0_live
        where
            grass_date = '${ds}'
            and order_status in ('OR3', 'OR5', 'OR6')
            and category_id in ('20102', '20103', '20101')
    ) b on a.platform_user_id = b.shopee_user_id
    and a.mission_type = b.mission_type
group by
    a.platform_user_id
    ,a.platform_type
    ,a.mission_id
    ,a.mission_type
    ,a.start_time
    ,a.completion_time
    ,a.start_time_local
    ,a.completion_time_local
union all
--spp
select
    tt1.platform_user_id
    ,tt1.platform_type
    ,tt1.mission_id
    ,tt1.mission_type
    ,tt1.start_time
    ,tt1.completion_time
    ,tt1.start_time_local
    ,tt1.completion_time_local
    ,count(
        distinct case
            when tt1.start_time_local <= tt2.create_datetime
                and tt1.completion_time_local >= tt2.create_datetime
                and tt2.amount >= tt3.mission_value
                then tt2.transaction_sn
            else null
        end
    ) mission_result
from
    (
        select
            platform_user_id
            ,platform_type
            ,mission_id
            ,mission_type
            ,start_time
            ,completion_time
            ,start_time_local
            ,completion_time_local
        from ${SCHEMA}.dwd_2cscore_id_user_mission_df
        where
            grass_date = '${ds}'
            and (
                mission_progress in (1, 2)
                or (
                    mission_progress = 3
                    and completion_time_local >= date_sub('${ds}', 3)
                )
            )
            and mission_type = 5
    ) tt1
    left join (
        select
            t1.user_id shopee_user_id
            ,transaction_sn
            ,format_time (t1.create_time, '${region}') create_datetime
            ,t1.amount
        from shopeepay.dwd_wallet_id_transaction_tab_df t1
        where
            t1.transaction_type = 1
            and t1.status = 3
        union
        select
            shopee_user_id
            ,uws_order_sn
            ,format_time (create_time, '${region}') create_datetime
            ,net_amount
        from shopeepay.mart_dwd_wide_user_order_wallet_all_ent_df__id
        where
            order_type_name = 'Topup'
            and order_status_name = 'SUCCESS'
    ) tt2 on tt1.platform_user_id = tt2.shopee_user_id
    join (
        select
            mission_id
            ,mission_value
        from ${SCHEMA}.dim_2cscore_id_complete_condition_df
        where
            grass_date = '${ds}'
            and mission_type = 5
            and mission_variable = 'shopee_pay_top_up_amount'
    ) tt3 on tt1.mission_id = tt3.mission_id
group by
    tt1.platform_user_id
    ,tt1.platform_type
    ,tt1.mission_id
    ,tt1.mission_type
    ,tt1.start_time
    ,tt1.completion_time
    ,tt1.start_time_local
    ,tt1.completion_time_local
;