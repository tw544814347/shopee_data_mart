--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df (
    platform_user_id string comment 'platform_user_id'
    ,latest_days_to_bind_bankcard_among_active_cards bigint comment ''
    ,earliest_days_to_bind_bankcard_among_active_cards bigint comment ''
    ,latest_months_to_bind_bankcard_among_active_cards bigint comment ''
    ,earliest_months_to_bind_bankcard_among_active_cards bigint comment ''
    ,latest_binded_bankcard_type_among_active_card bigint comment ''
    ,latest_months_to_unbind_bankcards bigint comment ''
    ,num_of_unbind_bankcards_in_the_past_one_month bigint comment ''
    ,num_of_unbind_bankcards_in_the_past_three_months bigint comment ''
    ,is_only_have_non_sg_card bigint comment ''
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_spp_bank_card_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df;

create
or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

create or replace temporary view user_card_list as (
    select
        a.user_id as platform_user_id
        ,a.status
        ,datediff(
            '${smd_grass_date}'
            ,format_time (a.ctime, '${grass_region}')
        ) as create_date
        ,datediff(
            '${smd_grass_date}'
            ,format_time (a.mtime, '${grass_region}')
        ) as update_date
        ,substr(a.card_number, 1, 6) card_number_head
        ,b.card_type as card_type
        ,case
            when c.bank_region = 'SG' then 1
            else 0
        end as tag
    from
        (
                select 
                    shopeepay_user_id as user_id
                    ,linkage_status as status
                    ,create_time as ctime
                    ,update_time as mtime
                    ,card_number as card_number
                from shopeepay.mart_dim_payment_channel_item_df__sg
                where item_ref is not NULL
        ) a
        left join shopeepay.mart_dim_card_bin_df__sg b on substr(a.card_number, 1, 6) = b.card_bin --仅SG有
        left join shopeepay.mart_dim_issue_bank_df__sg c on b.bank_id = c.bank_id
)
;

--user bind card
create or replace temporary view user_card_list_1 as (
    select
        platform_user_id
        ,status
        ,create_date
        ,card_number_head
        ,card_type
        ,tag
    from user_card_list
    where
        status = 0
        and card_type in (1, 2)
)
;

create or replace temporary view user_card_list_2 as (
    select
        a.platform_user_id
        ,min(create_date) as latest_days_to_bind_bankcard_among_active_cards
        ,max(create_date) as earliest_days_to_bind_bankcard_among_active_cards
        ,min(create_date) / 30 as latest_months_to_bind_bankcard_among_active_cards
        ,max(create_date) / 30 as earliest_months_to_bind_bankcard_among_active_cards
        ,case
            when max(tag) = 1 then 0
            else 1
        end as is_only_have_non_sg_card
    from user_card_list_1 a
    group by a.platform_user_id
)
;

create or replace temporary view user_card_list_3 as (
    select
        a.platform_user_id
        ,max(a.card_type) as latest_binded_bankcard_type_among_active_card
    from user_card_list_1 a
    where
        create_date = (
            select
                min(create_date)
            from user_card_list_1
        )
    group by a.platform_user_id
)
;

--user unbind card
create or replace temporary view unbinded_card as (
    select
        platform_user_id
        ,status
        ,create_date
        ,update_date
        ,card_number_head
        ,card_type
    from user_card_list
    where status = 1
)
;

create or replace temporary view unbinded_card_1 as (
    select
        platform_user_id
        ,min(update_date) / 30 as latest_months_to_unbind_bankcards
    from unbinded_card
    group by platform_user_id
)
;

create or replace temporary view unbinded_card_2 as (
    select
        a.platform_user_id
        ,sum(
            distinct (
                case
                    when update_date between 0 and 30 then 1
                    else 0
                end
            )
        ) as num_of_unbind_bankcards_in_the_past_one_month
        ,sum(
            distinct (
                case
                    when update_date between 0 and 90 then 1
                    else 0
                end
            )
        ) as num_of_unbind_bankcards_in_the_past_three_months
    from unbinded_card a
    group by a.platform_user_id
)
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df partition (grass_date)
select
    t1.platform_user_id as platform_user_id
    ,coalesce(t2.latest_days_to_bind_bankcard_among_active_cards, -999) as latest_days_to_bind_bankcard_among_active_cards
    ,coalesce(t2.earliest_days_to_bind_bankcard_among_active_cards, -999) as earliest_days_to_bind_bankcard_among_active_cards
    ,coalesce(t2.latest_months_to_bind_bankcard_among_active_cards, -999) as latest_months_to_bind_bankcard_among_active_cards
    ,coalesce(
        t2.earliest_months_to_bind_bankcard_among_active_cards
        ,-999
    ) as earliest_months_to_bind_bankcard_among_active_cards
    ,coalesce(t3.latest_binded_bankcard_type_among_active_card, -999) as latest_binded_bankcard_type_among_active_card
    ,coalesce(t4.latest_months_to_unbind_bankcards, -999) as latest_months_to_unbind_bankcards
    ,coalesce(t5.num_of_unbind_bankcards_in_the_past_one_month, -999) as num_of_unbind_bankcards_in_the_past_one_month
    ,coalesce(t5.num_of_unbind_bankcards_in_the_past_three_months, -999) as num_of_unbind_bankcards_in_the_past_three_months
    ,coalesce(t2.is_only_have_non_sg_card, 0) as is_only_have_non_sg_card
    ,'${ds}' as grass_date
from
    (
        select distinct
            platform_user_id
        from risk.dim_risk_${region}_user_info_df
        where grass_date = '${ds}'
    ) t1
    left join user_card_list_2 t2 on t1.platform_user_id = t2.platform_user_id
    left join user_card_list_3 t3 on t1.platform_user_id = t3.platform_user_id
    left join unbinded_card_1 t4 on t1.platform_user_id = t4.platform_user_id
    left join unbinded_card_2 t5 on t1.platform_user_id = t5.platform_user_id
;