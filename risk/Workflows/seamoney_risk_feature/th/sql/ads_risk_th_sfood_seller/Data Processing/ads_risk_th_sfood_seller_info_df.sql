-- drop table if exists ${SCHEMA}.ads_risk_th_sfood_seller_info_df;
create table if not exists ${SCHEMA}.ads_risk_th_sfood_seller_info_df
(
    national_id string
    ,nation_id_encrypt string
    ,platform_user_id string
    ,credit_user_id string
    ,spp_user_id string
    ,has_activated_scl bigint
    ,merchant_id_list string
    ,num_mid bigint
    ,store_id_list string
    ,num_sid bigint
    ,avg_merchant_ktp_chg_7d decimal(30,10)
    ,avg_merchant_ktp_chg_30d decimal(30,10)
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
comment 'tag: risk feature summary table'
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_th_sfood_seller_info_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_sfood_seller_info_df;

-- ******************************************* 1. Foody-side Merchant Info ******************************************* 
with merchant_base as (
    select merchant_id 
    from shopeefood.shopeefood_mart_cdm_dim_th_merchant_merchant_da 
    where date(dt) = current_date - interval '1' day
)

,national_id_tab as (
    select a.entity_id as merchant_id
        ,case when (national_id is null or national_id = '') then 0 else 1 end as has_valid_national_id
        ,coalesce(national_id, '0') as national_id
        ,national_id_type 
    from (
        select entity_id, customer_entity_id
        from merchantservice.mss_merchant_info_th_db__customer_entity_info_relation_tab__reg_daily_s0_live 
        where entity_type = 2 and relation_status = 1
    ) a inner join merchant_base mb on a.entity_id = mb.merchant_id --已修改 使用inner join 
    left join (
        select id, national_id, national_id_type
        from merchantservice.mss_merchant_info_th_db__customer_entity_info_tab__reg_daily_s0_live
        where info_status = 1
    ) b on a.customer_entity_id = b.id 
)

-- ******************************************* 2. Credit-side Info *******************************************
,uc_id_tab as (
    -- 已修改 避免select *
    select a.merchant_id
        ,a.national_id
        ,a.has_valid_national_id
        ,b.credit_user_id
        ,if(b.credit_user_id is not null, 1, 0) as has_matching_ucid 
        ,date(b.update_time) as uc_update_time
        --已修改 增加nation_id_encrypt
        ,b.id_card_no_encrypt_data as nation_id_encrypt
    from national_id_tab a left join (
        select credit_user_id, id_card_no, update_time, id_card_no_encrypt_data
        from (
            select distinct credit_user_id, id_card_no, update_time, id_card_no_encrypt_data
                ,row_number() over(partition by id_card_no order by update_time desc) as rank_no 
            from credit_uc.dwd_uc_th_user_id_card_info_df
            where date(grass_date) = current_date - interval '1' day
        ) 
        where rank_no = 1 
    ) b on a.national_id = b.id_card_no and a.has_valid_national_id = 1 
)

-------------------- Platform UID --------------------
--已修改 增加ssp_user_id
,pid_tab as ( 
    with temp as (
        select credit_user_id, platform_user_id, product_id 
            ,last_application_time as last_operation_time, 'activation' as stage
            ,spp_user_id as spp_user_id
        from credit_uc.dws_all_prod_th_uc_user_df
        where date(grass_date) = current_date - interval '1' day 
            and has_activated = 1 

        union all 
        select credit_user_id, platform_user_id, 1 as product_id  
            ,last_loan_disburse_time as last_operation_time, 'disbursement' as stage
            ,cast(shopeepay_user_id as string) as spp_user_id
        from credit_mart.wide_bcl_th_behavior_user_df 
        where date(grass_date) = current_date - interval '1' day 

        union all 
        select credit_user_id, platform_user_id, 2 as product_id  
            ,last_loan_disburse_time as last_operation_time, 'disbursement' as stage
            ,cast(shopeepay_user_id as string) as spp_user_id
        from credit_mart.wide_scl_th_behavior_user_df 
        where date(grass_date) = current_date - interval '1' day 

        union all 
        select credit_user_id, platform_user_id, 3 as product_id  
            ,last_order_time as last_operation_time, 'disbursement' as stage
            ,cast(shopeepay_user_id as string) as spp_user_id
        from credit_mart.wide_spl_th_behavior_user_df 
        where date(grass_date) = current_date - interval '1' day 

        union all 
        select credit_user_id, platform_user_id, 4 as product_id 
            ,max(actual_disbursed_time) as last_operation_time, 'disbursement' as stage
            ,cast(null as string) as spp_user_id
        from credit_mart.dwd_fes_th_group_info_df
        where date(grass_date) = current_date - interval '1' day
        group by credit_user_id, platform_user_id, product_id
    ) 

    -- 已修改 避免select *
    select a.merchant_id
        ,a.national_id
        ,a.credit_user_id
        ,a.has_matching_ucid
        ,a.uc_update_time
        ,a.nation_id_encrypt
        ,b.platform_user_id
        ,b.all_known_pid 
        ,case when b.platform_user_id is null then '' 
            when size(b.all_known_pid) = 1 then '' 
            else array_join(filter(b.all_known_pid, x -> x != b.platform_user_id), ',') 
        end as other_platform_user_id 
        ,if(c.credit_user_id is not null, 1, 0) has_activated_scl 
        ,b.spp_user_id
    from uc_id_tab a 
        left join (
            select t1.credit_user_id 
                ,t2.platform_user_id 
                ,t1.all_known_pid 
                ,t3.spp_user_id
            from (
                select credit_user_id 
                    ,collect_set(platform_user_id) as all_known_pid 
                from temp 
                group by 1
            ) t1
            left join (
                select credit_user_id, platform_user_id
                from (
                    select credit_user_id, platform_user_id
                        ,row_number() over (partition by credit_user_id order by last_operation_time desc) as rn
                    from temp
                ) where rn = 1
            ) t2 on t1.credit_user_id = t2.credit_user_id
            left join (
                -- 获取spp_user_id（按last_operation_time取最新的）
                select credit_user_id, spp_user_id
                from (
                    select credit_user_id, spp_user_id
                        ,row_number() over (partition by credit_user_id order by last_operation_time desc) as rn
                    from temp
                    where spp_user_id is not null
                ) where rn = 1
            ) t3 on t1.credit_user_id = t3.credit_user_id
        ) b on a.credit_user_id = b.credit_user_id 
        left join (
            -- 已修改 避免select *
            select credit_user_id
            from temp 
            where product_id = 2 and stage = 'disbursement'
        ) c on a.credit_user_id = c.credit_user_id
)

-- ******************************************* 3. Add Foody Stores' Info *******************************************
,store_tab as ( 
    -- 已修改 避免select *
    select a.national_id
        ,b.store_id
    from pid_tab a
    left join (
        select store_id, merchant_id
        from shopeefood.shopeefood_mart_cdm_dim_th_merchant_store_da
        where date(dt) = current_date - interval '1' day
    ) b on a.merchant_id = b.merchant_id
)

-- ******************************************* 4. Aggregate & Merge *******************************************
,store_agg as (
    select national_id 
        ,array_join(array_sort(collect_set(store_id)), ', ') as store_id_list  -- 店铺ID列表（逗号分隔，按store_id排序）
        ,count(distinct store_id) as num_sid  -- 店铺数量
    from store_tab
    group by national_id
)

-- 按national_id聚合商户信息：将同一身份证号下的所有商户ID聚合成列表，并统计商户数量
,merchant_agg as (
    select national_id
        ,array_join(array_sort(collect_set(merchant_id)), ', ') as merchant_id_list  -- 商户ID列表（逗号分隔，按merchant_id排序）
        ,count(distinct merchant_id) as num_mid  -- 商户数量
    from pid_tab
    group by national_id
)

-- ******************************************* 5. KTP 变更特征（近 7/30 天商户身份证号变更） *******************************************
-- 1. 抽取近 30 天内有 KTP 变更的商户日志
,ktp_log AS (
    SELECT
        id AS merchant_id,
        update_time,
        COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) AS old_ktp,
        COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId')) AS new_ktp
    FROM merchantservice.mss_merchant_info_th_db__operation_log_tab__reg_daily_s0_live
    WHERE operate_type = 2
      AND object_type = 12
      AND data_type = 18
      AND COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) IS NOT NULL
      AND COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId')) IS NOT NULL
      AND COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) <> COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId'))
      AND to_date(update_time) >= date_sub(current_date(), 30)
)
-- 2. 先展开 merchant_id_list，再与 ktp_log 关联
,seller_merchant_expand AS (
    SELECT
        if(a.platform_user_id is null, concat('998_', a.national_id), a.platform_user_id) AS platform_user_id,
        if(a.credit_user_id is null, concat('999_', a.national_id), a.credit_user_id) AS credit_user_id,
        b.merchant_id_list,
        c.store_id_list,
        b.num_mid,
        c.num_sid,
        trim(t.merchant_id) AS merchant_id
    FROM pid_tab a
    LEFT JOIN merchant_agg b ON a.national_id = b.national_id
    LEFT JOIN store_agg c ON a.national_id = c.national_id
    LATERAL VIEW explode(split(coalesce(b.merchant_id_list, ''), ',')) t AS merchant_id
    WHERE coalesce(b.merchant_id_list, '') != ''
)
-- 3. 按 user 维度统计：商户列表中，有多少商户在 7/30 天内改过 KTP
,user_ktp_change AS (
    SELECT
        a.platform_user_id,
        a.credit_user_id,
        a.merchant_id_list,
        a.store_id_list,
        a.num_mid,
        a.num_sid,
        COUNT(DISTINCT CASE WHEN to_date(b.update_time) >= date_sub(current_date(), 7) THEN b.merchant_id END) * 1.0 / nullif(size(split(a.merchant_id_list, ',')), 0) AS avg_merchant_ktp_chg_7d,
        COUNT(DISTINCT b.merchant_id) * 1.0 / nullif(size(split(a.merchant_id_list, ',')), 0) AS avg_merchant_ktp_chg_30d
    FROM seller_merchant_expand a
    LEFT JOIN ktp_log b ON a.merchant_id = cast(b.merchant_id AS string)
    GROUP BY a.platform_user_id, a.credit_user_id, a.merchant_id_list, a.store_id_list, a.num_mid, a.num_sid
)

insert overwrite table ${SCHEMA}.ads_risk_th_sfood_seller_info_df partition (grass_date = '${ds}')
select distinct 
    a.national_id 
    ,a.nation_id_encrypt
    ,if(a.platform_user_id is null, concat('998_', a.national_id), a.platform_user_id) as platform_user_id 
    ,if(a.credit_user_id is null, concat('999_', a.national_id), a.credit_user_id) as credit_user_id 
    ,a.spp_user_id
    ,a.has_activated_scl
    ,b.merchant_id_list 
    ,b.num_mid 
    ,c.store_id_list 
    ,c.num_sid
    ,d.avg_merchant_ktp_chg_7d
    ,d.avg_merchant_ktp_chg_30d 
from pid_tab a 
    left join merchant_agg b 
        on a.national_id = b.national_id
    left join store_agg c 
        on a.national_id = c.national_id
    left join user_ktp_change d
        on if(a.platform_user_id is null, concat('998_', a.national_id), a.platform_user_id) = d.platform_user_id
        and if(a.credit_user_id is null, concat('999_', a.national_id), a.credit_user_id) = d.credit_user_id
        and coalesce(b.merchant_id_list, '') = coalesce(d.merchant_id_list, '')
;