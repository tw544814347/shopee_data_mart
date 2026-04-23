-- drop table if exists ${SCHEMA}.ads_risk_vn_sfood_seller_info_df;
-- create table if not exists ${SCHEMA}.ads_risk_vn_sfood_seller_info_df
-- (
--     platform_user_id string	
--     ,credit_user_id string	
--     ,restaurant_id_list string
--     ,num_rid bigint
--     ,merchant_id_list string
--     ,num_mid bigint
--     ,store_id_list string
--     ,num_sid bigint
--     ,is_valid_food_merchant bigint
--     ,avg_merchant_ktp_change_cnt_7d decimal(30,10)
--     ,avg_merchant_ktp_change_cnt_30d decimal(30,10)
--     ,wl_merchant_id_list string
--     ,wl_restaurant_id_list string
--     ,wl_store_id_list string
-- )
-- partitioned by
-- (
--     grass_date string comment 'yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="zstd")
-- LOCATION '${HDFS_PATH}/ads/ads_risk_vn_sfood_seller_info_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_vn_sfood_seller_info_df;


----------------------- ShopeeFood User Base ------------------------- 
with shopeefood_base as (
    with new_system_info as (
        select store_id, merchant_id
        from shopeefood.shopeefood_mart_cdm_dim_vn_merchant_store_da_live 
        where date(dt) = (select max(dt) from shopeefood.shopeefood_mart_cdm_dim_vn_merchant_store_da_live)
    ) 
    ,old_system_mapping as (
        select  a.*
            ,b.restaurant_id -- 旧系统主键 
            ,b.delivery_id
        from new_system_info a left join shopeefood.shopeefood_mart_cdm_dwd_vn_restaurant_store_mapping_tab_da b 
            -- mapping 表每天刷新时删掉旧记录，因此不需申明 grass_date
            on a.store_id = b.store_id 
    ) 
    -- 注释：虽然字段名字是 merchant_id_crm，这个跟 merchant_id 有 1:N 关系，实际上对配的是 store_id
    ,delivery_mapping as (
        select  a.*, b.merchant_id as merchant_id_crm 
        from old_system_mapping a left join shopeefood.foody_mart__profile_merchant_master b
            on a.delivery_id = b.delivery_id
        where grass_region = 'VN' and grass_date = 'current'
    ) 
    select * 
    from delivery_mapping 
)

,vnfdbi as (
    select 
        mis_store_id as store_id_fdbi 
        ,mis_merchant_id as merchant_id_fdbi 
        ,merchant_id as restaurant_id_fdbi
        ,account_role, staff_status  
        ,cast(toc_uid as string) as shopee_uid 
        ,toc_phone, is_having_toc_uid  
    from vnfdbi_commercial.spf_dim_merchant_staff_mis_vn 
    where account_role = 'Super Admin' and staff_status = 'active' 
)

,foody_shopee_map as (
    select 
        a.store_id
        ,a.merchant_id
        ,a.restaurant_id
        ,a.delivery_id
        ,a.merchant_id_crm
        ,if(b.shopee_uid is null or b.shopee_uid = '0', concat('999_', cast(a.restaurant_id as string)), b.shopee_uid) as shopee_pk_uid 
    from shopeefood_base a 
        left join vnfdbi b 
        on a.restaurant_id = b.restaurant_id_fdbi 
) 

-- ------------------- Platform_uid Mapping -------------------

,uc_platform_uid as (
    select platform_user_id 
        ,credit_user_id 
        ,collect_list(product_id) product_id_arr 
        ,collect_list(product_name) product_name_arr 
    from (
        select platform_user_id
            ,credit_user_id 
            ,product_id
            ,case when product_id = 0 then 'Unknown' 
                when product_id = 1 then 'BCL' 
                when product_id = 2 then 'SCL' 
                when product_id = 3 then 'SPL' 
                when product_id = 4 then 'FES' 
                when product_id = 5 then 'credit score' 
                when product_id = 6 then 'MCL' 
                when product_id = 7 then 'Cicilan_hp' 
                when product_id = 8 then 'corporate loan' 
                when product_id = 10 then 'vehicle loan' 
                when product_id = 11 then 'term loan' 
            end as product_name
        from credit_uc.dws_all_prod_vn_uc_user_df 
        where date(grass_date) = current_date - interval '1' day 
            and product_id in (1, 2, 3, 4)
            and has_activated = 1
            and credit_user_id is not null 
            and credit_user_id <> '0'
    )
    group by 1, 2 
) 


------------------------- Merge ------------------------------------- 

,restaurant_raw as (
    select 
        a.restaurant_id  -- id mapping base表主键
        ,a.merchant_id_crm  -- 主键一对一
        ,a.delivery_id  -- 主键一对一
        ,a.store_id  -- 主键一对一
        ,a.merchant_id  -- 主键一对一
        ,case when substr(shopee_pk_uid, 1, 4) != '999_' and b.platform_user_id is not null then platform_user_id  -- foody有puid，UC有puid，用UC
            when substr(shopee_pk_uid, 1, 4) != '999_' and b.platform_user_id is null then concat('998_', shopee_pk_uid)  -- foody有puid，UC无puid，用foody处理后的'998_shopee_uid'
            when substr(shopee_pk_uid, 1, 4) = '999_' and b.platform_user_id is null then shopee_pk_uid  -- foody无puid，没法关联UC puid，用foody处理后的'999_restaurant_id'
        end as platform_user_id 
        ,case when substr(shopee_pk_uid, 1, 4) != '999_' and b.credit_user_id is not null then credit_user_id -- foody有puid，UC有关联的cuid，用UC
            when substr(shopee_pk_uid, 1, 4) != '999_' and b.credit_user_id is null then concat('997_', shopee_pk_uid)  -- foody有puid，UC无关联的cuid，用foody处理后的'997_shopee_uid'
            when substr(shopee_pk_uid, 1, 4) = '999_' and b.credit_user_id is null then shopee_pk_uid -- foody无puid，没法关联UC cuid，用foody处理后的'999_restaurant_id'
        end as credit_user_id 
    from foody_shopee_map a left join uc_platform_uid b 
        on a.shopee_pk_uid = b.platform_user_id  
) 

------------------------------------------------------------------------ 
------------------------- Aggregate -------------------------------- 
------------------------------------------------------------------------ 

,restaurant_agg as (
    select  platform_user_id
            ,credit_user_id
            ,array_join(array_sort(collect_set(restaurant_id)), ', ') as restaurant_id_list
            ,array_join(array_sort(collect_set(merchant_id)), ', ') as merchant_id_list
            ,array_join(array_sort(collect_set(store_id)), ', ') as store_id_list
            ,count(distinct restaurant_id) as num_rid
            ,count(distinct merchant_id) as num_mid
            ,count(distinct store_id) as num_sid
    from restaurant_raw
    group by 1,2
)

,vn_foody_merchant_platform_mapping as (
    select  platform_user_id
            ,credit_user_id
            ,merchant_id_list
            ,store_id_list
            ,restaurant_id_list  -- vn新增
    from smcdrisk_policy.vn_foody_merchant_platform_mapping -- 业务每月白名单表
    where grass_date = (select max(grass_date) from smcdrisk_policy.vn_foody_merchant_platform_mapping)
)


,user_merchant as (
    select  distinct coalesce(a.platform_user_id, b.platform_user_id) as platform_user_id
            ,a.credit_user_id
            ,a.restaurant_id_list
            ,a.num_rid
            ,a.merchant_id_list
            ,a.num_mid
            ,a.store_id_list
            ,a.num_sid
            ,case   when b.platform_user_id is null then 0
                    when 
                    (
                        a.credit_user_id = b.credit_user_id
                        and cardinality(array_except(split(a.merchant_id_list, ', '), split(b.merchant_id_list, ', '))) = 0
                        and cardinality(array_except(split(a.store_id_list, ', '), split(b.store_id_list, ', '))) = 0
                        and cardinality(array_except(split(a.restaurant_id_list, ', '), split(b.restaurant_id_list, ', '))) = 0  -- vn新增
                    ) then 2
                    else 1 end as is_valid_food_merchant
    from restaurant_agg a
    full outer join vn_foody_merchant_platform_mapping b
    on a.platform_user_id = b.platform_user_id
)

------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
,explode_view as 
(
    select 
            platform_user_id
            ,merchant_id_list
            ,restaurant_id_list
            ,store_id_list
            ,explode(split(merchant_id_list, ',')) AS wl_merchant_id
    from vn_foody_merchant_platform_mapping 
)


------------------------------------------------------------------------------------------------------------------------------------------


,id_card_no_change as (
    -- 反欺诈指标，merchant维度，7/30天是否改过身份证号
    SELECT 
        a.platform_user_id
        ,a.credit_user_id
        ,a.merchant_id_list
        ,a.restaurant_id_list
        ,a.store_id_list
        ,a.num_mid
        ,a.num_rid
        ,a.num_sid
        ,a.is_valid_food_merchant
        ,b.merchant_id_list as wl_merchant_id_list
        ,b.restaurant_id_list as wl_restaurant_id_list
        ,b.store_id_list as wl_store_id_list
        ,COUNT(c.id_7d) * 1.0 / cardinality(split(a.merchant_id_list, ',')) AS avg_merchant_ktp_change_cnt_7d
        ,COUNT(c.id_30d) * 1.0 / cardinality(split(a.merchant_id_list, ',')) AS avg_merchant_ktp_change_cnt_30d
    FROM user_merchant a
    left JOIN explode_view b
        ON a.platform_user_id = b.platform_user_id
    LEFT JOIN 
    (
        SELECT 
            case 
                when date(update_time) >= date_add(current_date, -7) then id 
                else null 
            end as id_7d
            ,id as id_30d
            ,case 
                when date(update_time) >= date_add(current_date, -7) then COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId'))
                else null
            end as old_id_7d
            ,case 
                when date(update_time) >= date_add(current_date, -7) then COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId'))
                else null
            end as new_id_7d
            ,COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) AS old_id_30d
            ,COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId')) AS new_id_30d
            ,update_time
        FROM merchantservice.mss_merchant_info_vn_db__operation_log_tab__reg_daily_s0_live
        WHERE operate_type = 2  -- update
        AND object_type = 12  -- Core info
        AND data_type = 18  -- merchant profile
        AND COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) IS NOT NULL
        AND COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId')) IS NOT NULL
        AND COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) <> COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId'))
        AND date(update_time) >= date_add(current_date, -30)
    ) c
    ON b.wl_merchant_id = cast(c.id_30d as string)
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
)
------------------------------------------------------------------------ 
-------------------------------Insert -------------------------------- 
------------------------------------------------------------------------ 

insert overwrite table ${SCHEMA}.ads_risk_vn_sfood_seller_info_df partition (grass_date = '${ds}')
select 
    platform_user_id
    ,credit_user_id
    ,restaurant_id_list
    ,num_rid
    ,merchant_id_list
    ,num_mid
    ,store_id_list
    ,num_sid
    ,is_valid_food_merchant
    ,avg_merchant_ktp_change_cnt_7d
    ,avg_merchant_ktp_change_cnt_30d
    ,wl_merchant_id_list
    ,wl_restaurant_id_list as wl_restaurant_id_list
    ,wl_store_id_list
    -- ,'${ds}' as grass_date
from id_card_no_change
;