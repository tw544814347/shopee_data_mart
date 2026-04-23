-- PRD: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=277316402#gid=277316402

--********************************************************************--
-- Author:              jialiang.nie@shopee.com
-- Created Time:        2024-09-09
-- Theme Domain：        risk shopee food feature
-- Description:          
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42557 逻辑: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=277316402#gid=277316402
-- 变更历史：
--     修改日期: 2024-10-02  修改人:jialiang.nie  修改内容: 这张表 smcdrisk_policy.id_foody_merchant_platform_mapping 每个月15号才会更新，去掉这张表的依赖（逻辑有考虑到，取了max partition）
--     修改日期: 2024-10-25  修改人:jialiang.nie  修改内容: 替换 ods__credit_usercenter_member_id_db__user_base_info_tab__df 为UC Mart表
--     修改日期: 2025-06-20  修改人:jialiang.nie  修改内容: 解决puid:cuid 1:2的问题数据，最终结果按照uc_update_time倒序取第一条
--********************************************************************--

-- ^core ID mapping base table logic as shows below (SCL口径全量platform user id):
-- 实现思路：取全量merchant ID，关联有效的nationID，匹配credit UID，检查UC侧用户冻结状态，再在用户维度聚合merchant和Store ID，最终完成全量用户在几个ID实体间的关联逻辑。

-- 卖家的一些基础信息和指标
-- 用户范围
--      merchantservice.mss_merchant_info_id_db__customer_entity_info_relation_tab__reg_daily_s0_live对应的所有未冻结或最新更新的platform_user_id
-- 字段含义
--      national_id: 身份证号
--      merchant_id_list: 卖家名下的所有merchant
--      is_valid_food_merchant: 是否是好卖家, when platform_user_id为null then 0 else when 卖家信息与白名单一致 then 2 else 1
--      avg_merhcant_ktp_change_cnt_7d: 用户身份证号的更改指标(7天内)


with merchant_base as (
    -- key: merchant_id
    select merchant_id
    from shopeefood.shopeefood_mart_cdm_dim_id_merchant_merchant_da 
    where date(dt) = date('${ds}')
    
)

,national_id_tab as (
    -- key: merchant_id
    -- merchant_id:national_id n:1
    select  a.entity_id as merchant_id
            ,case when (national_id is null or national_id = '') then 0 else 1 end as has_valid_national_id
            ,coalesce(national_id, '0') as national_id
    from (
        select  entity_id
                ,customer_entity_id
        from merchantservice.mss_merchant_info_id_db__customer_entity_info_relation_tab__reg_daily_s0_live 
        where entity_type = 2
            and relation_status = 1
    ) a 
    left join (
        select  id
                ,national_id
                ,info_status
        from merchantservice.mss_merchant_info_id_db__customer_entity_info_tab__reg_daily_s0_live
        where info_status = 1
    ) b
    on a.customer_entity_id = b.id
    where a.entity_id in (select merchant_id from merchant_base)
)
-- 这里可能出现 national_id:uc_id 1:n 的情况，是旧记录造成的。下面 freeze_tab 会排掉这些旧记录
,uc_id_tab as (
    -- key: merchant_id + national_id + credit_user_id
    -- merchant_id:national_id n:1
    select  a.*
            ,case when b.user_id is null then 0 else 1 end as has_matching_ucid
            ,cast(b.user_id as string) as credit_user_id 
            ,b.update_time as uc_update_time
    from national_id_tab a
    left join 
    (
        select
            user_id 
            ,update_time
            ,id_card_no
        from credit_uc.dwd_credit_id_uc_base_info_tab_df
        where grass_date = '${ds}'
    ) b
    on a.national_id = b.id_card_no
    and a.has_valid_national_id = 1
)

-------------------- Freeze --------------------
,user_freeze_1 as (
    select  cast(user_id as string) as credit_user_id
            ,array_join(collect_list(lock_type), ',') as user_freeze_type_1
    from credit_uc.dwd_uc_id_user_lock_info_df
    where date(grass_date) = date('${ds}')
        and lock_status = 1
        and lock_type != 23
        and cast(user_id as string) in (select credit_user_id from uc_id_tab where has_matching_ucid = 1)
    group by 1
)

,product_freeze_1 as (
    select  cast(user_id as string) as credit_user_id
            ,array_join(collect_list(biz_type), ',') as product_freeze_type_1
    from credit_uc.dwd_uc_id_user_lock_product_info_df
    where date(grass_date) = date('${ds}')
        and lock_status = 1
        and lock_type != 23
        and cast(user_id as string) in (select credit_user_id from uc_id_tab where has_matching_ucid = 1)
    group by 1
)

-- 为了解决以上描述的 national_id:uc_id 1:n 的问题，我们优先保留没有冻结状态的用户账号，其次再保留最近更新的用户账号，重新搭建 1:1 的关系
,freeze_tab as (
    -- key: merchant_id
    -- merchant_id:national_id n:1
    select * 
    from (
        select  a.*
                ,row_number() over (partition by a.merchant_id order by case    when (b.user_freeze_type_1 is null and d.product_freeze_type_1 is null) then cast(to_unix_timestamp(a.uc_update_time) as bigint) * 4
                                                                                when (b.user_freeze_type_1 is null) then cast(to_unix_timestamp(a.uc_update_time) as bigint) * 3
                                                                                when (d.product_freeze_type_1 is null) then cast(to_unix_timestamp(a.uc_update_time) as bigint) * 2
                                                                                else cast(to_unix_timestamp(a.uc_update_time) as bigint) end
                                    desc) as row_num
        from uc_id_tab a
        left join user_freeze_1 b
        on a.credit_user_id = b.credit_user_id
        and a.has_matching_ucid = 1
        left join product_freeze_1 d
        on a.credit_user_id = d.credit_user_id
        and a.has_matching_ucid = 1

    )
    where row_num = 1
)


-------------------- Platform UID --------------------
,pid_tab as (
    select  
        a.*
        ,i.last_loan_disburse_time
        ,case 
            when coalesce(to_unix_timestamp(i.last_loan_disburse_time),0) = 0 then coalesce(e.platform_user_id, '-1')
            else coalesce(i.platform_user_id, '-1')
        end as platform_user_id
        ,array_union(coalesce(e.all_known_pid, array()), coalesce(i.all_known_pid,array())) as all_known_pid
    from freeze_tab a
    left join 
    (
        select  credit_user_id
                ,max_by(platform_user_id, last_application_time) as platform_user_id
                ,array_distinct(filter(collect_list(platform_user_id), x -> x is not null)) as all_known_pid
        from credit_uc.dws_all_prod_id_uc_user_df
        where date(grass_date) = date('${ds}')
            and credit_user_id in (select distinct credit_user_id from freeze_tab)
            and product_id in (1,2,3,6)
            and has_activated = 1
        group by 1
    ) e
    on a.credit_user_id = e.credit_user_id
    left join (
        select 
            credit_user_id
            ,max(last_loan_disburse_time) as last_loan_disburse_time
            ,max_by(platform_user_id, last_loan_disburse_time) as platform_user_id
            ,array_distinct(filter(collect_list(platform_user_id), x -> x is not null)) as all_known_pid
        from 
        (
            select  credit_user_id
                    ,platform_user_id
                    ,last_loan_disburse_time
            from credit_mart.wide_bcl_id_behavior_user_df
            where date(grass_date) = date('${ds}')
                and credit_user_id in (select distinct credit_user_id from freeze_tab)
            union all 
            select  credit_user_id
                    ,platform_user_id
                    ,last_loan_disburse_time
            from credit_mart.wide_scl_id_behavior_user_df
            where date(grass_date) = date('${ds}')
                and credit_user_id in (select distinct credit_user_id from freeze_tab)
            union all 
            select  credit_user_id
                    ,platform_user_id
                    ,last_loan_disburse_time
            from credit_mart.wide_mcl_id_behavior_user_df
            where date(grass_date) = date('${ds}')
                and credit_user_id in (select distinct credit_user_id from freeze_tab)
            union all 
            select  credit_user_id
                    ,platform_user_id
                    ,last_spl_disburse_time as last_loan_disburse_time
            from credit_mart.wide_spl_id_behavior_user_df
            where date(grass_date) = date('${ds}')
                and credit_user_id in (select distinct credit_user_id from freeze_tab)
        )
        group by 1
    ) i
    on a.credit_user_id = i.credit_user_id
    where a.has_matching_ucid = 1 
)

,pid_check_tab as (
    select  *
            ,case   when platform_user_id = '-1' then ''
                    when cardinality(all_known_pid) = 1 then ''
                    else array_join(filter(all_known_pid, x -> x != platform_user_id), ',') end as other_platform_user_id -- 目前用户最多只有两个 platform_user_id，所以这字段应该只有最多一个 platform_user_id
    from pid_tab
    where platform_user_id != '-1' 
)

-------------------- Aggregate --------------------
,store_raw as (
    select  a.*
            ,b.store_id
    from pid_check_tab a
    left join (
        select  store_id
                ,merchant_id
        from shopeefood.shopeefood_mart_cdm_dim_id_merchant_store_da
        where date(dt) = current_date - interval '1' day
    ) b
    on a.merchant_id = b.merchant_id
)

,store_agg as (
    select  platform_user_id
            ,array_join(array_sort(collect_set(store_id)), ', ') as store_id_list
            ,count(distinct store_id) as num_sid
    from store_raw
    group by 1
)

,merchant_agg as (
    select  platform_user_id
            ,array_join(array_sort(collect_set(merchant_id)), ', ') as merchant_id_list
            ,count(distinct merchant_id) as num_mid
    from pid_check_tab
    group by 1
)
,id_foody_merchant_platform_mapping as (
    select  platform_user_id
            ,credit_user_id
            ,national_id
            ,merchant_id_list
            ,store_id_list
    from smcdrisk_policy.id_foody_merchant_platform_mapping -- 业务每月白名单表
    where grass_date = (select max(grass_date) from smcdrisk_policy.id_foody_merchant_platform_mapping)
)
,user_merchant as (
    select  distinct a.platform_user_id
            ,a.credit_user_id
            ,a.national_id
            ,a.other_platform_user_id
            ,a.uc_update_time
            ,b.merchant_id_list
            ,b.num_mid
            ,c.store_id_list
            ,c.num_sid
            ,case   when d.platform_user_id is null then 0
                    when 
                    (
                        a.credit_user_id = d.credit_user_id
                        and a.national_id = d.national_id
                        and cardinality(array_except(split(d.merchant_id_list, ', '), split(b.merchant_id_list, ', '))) = 0
                        and cardinality(array_except(split(d.store_id_list, ', '), split(c.store_id_list, ', '))) = 0
                    ) then 2
                    else 1 end as is_valid_food_merchant
    from pid_check_tab a
    left join merchant_agg b
    on a.platform_user_id = b.platform_user_id
    left join store_agg c
    on a.platform_user_id = c.platform_user_id
    left join id_foody_merchant_platform_mapping d
    on a.platform_user_id = d.platform_user_id
)

,id_card_no_change as (
    -- 反欺诈指标，7/30天是否改过身份证号
    SELECT 
        a.platform_user_id
        ,a.credit_user_id
        ,a.national_id
        ,a.other_platform_user_id
        ,a.uc_update_time
        ,a.merchant_id_list
        ,a.num_mid
        ,a.store_id_list
        ,a.num_sid
        ,a.is_valid_food_merchant
        ,b.merchant_id_list as wl_merchant_id_list
        ,COUNT(c.id_7d) * 1.0 / cardinality(split(a.merchant_id_list, ',')) AS avg_merhcant_ktp_change_cnt_7d
        ,COUNT(c.id_30d) * 1.0 / cardinality(split(a.merchant_id_list, ',')) AS avg_merhcant_ktp_change_cnt_30d
    FROM user_merchant a
    left JOIN 
    (
        select 
            platform_user_id
            ,merchant_id_list
            ,explode(split(merchant_id_list, ',')) AS wl_merchant_id
        from id_foody_merchant_platform_mapping 
    ) b
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
        FROM merchantservice.mss_merchant_info_id_db__operation_log_tab__reg_daily_s0_live
        WHERE operate_type = 2  -- update
        AND object_type = 12  -- Core info
        AND data_type = 18  -- merchant profile
        AND COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) IS NOT NULL
        AND COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId')) IS NOT NULL
        AND COALESCE(get_json_object(old_data, '$.NationalId'), get_json_object(old_data, '$.nationalId')) <> COALESCE(get_json_object(new_data, '$.NationalId'), get_json_object(new_data, '$.nationalId'))
        AND date(update_time) >= date_add(current_date, -30)
    ) c
    ON b.wl_merchant_id = cast(c.id_30d as string)
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11
)


insert overwrite table ${SCHEMA}.ads_risk_${table_region}_sfood_seller_info_df partition (grass_date)
select 
    platform_user_id
    ,credit_user_id
    ,national_id
    ,other_platform_user_id
    ,uc_update_time
    ,merchant_id_list
    ,num_mid
    ,store_id_list
    ,num_sid
    ,is_valid_food_merchant
    ,avg_merhcant_ktp_change_cnt_7d
    ,avg_merhcant_ktp_change_cnt_30d
    ,wl_merchant_id_list
    ,grass_date
from 
(
    select 
        platform_user_id
        ,credit_user_id
        ,national_id
        ,other_platform_user_id
        ,uc_update_time
        ,merchant_id_list
        ,num_mid
        ,store_id_list
        ,num_sid
        ,is_valid_food_merchant
        ,avg_merhcant_ktp_change_cnt_7d
        ,avg_merhcant_ktp_change_cnt_30d
        ,wl_merchant_id_list
        ,'${ds}' as grass_date
        ,row_number() over(partition by platform_user_id,merchant_id_list,store_id_list,num_mid,num_sid,is_valid_food_merchant order by uc_update_time desc) as rn
    from id_card_no_change
) t1 
where rn = 1

;