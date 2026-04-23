create or replace temporary view  shopee_acct_abnormal as 
    select 
        user_id
        ,status
        ,1 as shopee_acct_abnormal
    from mp_user.dim_user__reg_s0_live t1 
    join (
          select 
              max(grass_date) grass_date
          from mp_user.dim_user__reg_s0_live 
          where grass_region = 'ID'
        ) t2 on t1.grass_date = t2.grass_date 
    where status != 1
    and grass_region = 'ID'
;

create or replace temporary view fraud_tab_raw AS 
SELECT 
    userid
    ,tagid
    ,status
    ,ctime
FROM
    (
            -- SELECT 
        --     a.userid
        --     , a.tagid
        --     , a.status
        --     , a.ctime
        --     , ROW_NUMBER() OVER(PARTITION BY a.userid, a.tagid ORDER BY a.ctime DESC) rank
        -- FROM marketplace.shopee_fraud_backend_id_db__fraud_user_tag_tab__reg_daily_s0_live a 
        -- LEFT JOIN marketplace.shopee_fraud_backend_id_db__fraud_tag_tab__reg_daily_s0_live b 
        --     ON a.tagid = b.id
        -- WHERE b.status = 1
        --     AND b.type IN (1,2) 
        --     AND b.severity = 1 
        --     -- AND b.name NOT IN ('Internal test',
        --     --                     'Account Hacking - Victim',
        --     --                     'Scam - Victim',
        --     --                     'SPL Overdue',
        --     --                     'Requested By User',
        --     --                     'Requested by Legal',
        --     --                     'ATO - Reported Victim',
        --     --                     'ATO - Prevented Victim (offline)',
        --     --                     'ATO - Prevented Victim [System check]')
        select  
            user_id                as userid
            ,create_datetime       as ctime
            ,fraud_tag_id          as tagid
            ,fraud_tag_status      as status
            , ROW_NUMBER() OVER(PARTITION BY a.user_id, a.fraud_tag_id ORDER BY a.create_datetime DESC) rank
        from antifraud_dw.dim_user_fraud_tag_di a 
        where severity = 'SEVERE'
        and fraud_tag_status = 1
        and grass_region ='ID'
    )
WHERE rank = 1
;

create or replace temporary view fraud_tab AS 
SELECT 
    userid
    ,1 AS is_bad_user
FROM fraud_tab_raw
WHERE status = 1
GROUP BY userid
;

create or replace temporary view fraud_and_access_spl as
select
    a.user_id as userid
    ,c.is_bad_user
from
    (
        select
            user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'ID'
            and grass_date = '${grass_date}'
    ) a
    left join fraud_tab c on a.user_id = c.userid
;

create or replace temporary view  age AS 
select
    user_id as userid
    ,to_date(from_unixtime(registration_timestamp)) as register_date
    ,(
        case
            when registration_timestamp = 0 or registration_timestamp is null then null
            else (
                unix_timestamp(current_timestamp) + 3600 - registration_timestamp
            ) / 86400
        end
    ) as shopee_age
from mp_user.dim_user__reg_s0_live
where
    tz_type = 'local'
    and grass_region = 'ID'
    and grass_date = '${grass_date}'
    and unix_timestamp(current_timestamp) + 3600 >= registration_timestamp
group by
    user_id
    ,to_date(from_unixtime(registration_timestamp))
    ,(
        case
            when registration_timestamp = 0 or registration_timestamp is null then null
            else (
                unix_timestamp(current_timestamp) + 3600 - registration_timestamp
            ) / 86400
        end
    )
;

create or replace temporary view return_tab AS 
SELECT 
    buyer_id as userid
    , return_id
    , order_id
FROM mp_order.dwd_return_all_ent_snapshot_df__reg_live
WHERE grass_region = 'ID' AND return_status_id IN (2, 5) and grass_date=date('${ds}') 
;
-- 0: deleted, 1: requested, 2: accepted, 3: cancelled, 4: judging, 5: refund_paid, 6: closed, 7: return_processing (start reverse logistics), 8: return_seller_dispute (seller dispute after item is returned)

create or replace temporary view orders_tab  as 
SELECT 
    buyer_id AS user_id
    , order_id
    , gmv_usd
    , FROM_UNIXTIME(shipping_confirm_timestamp) AS shipping_confirm_time
    ,CAST(FROM_UNIXTIME(shipping_confirm_timestamp) AS DATE) shipping_confirm_date, order_be_status_id, order_be_status
FROM mp_order.dwd_order_all_ent_df__reg_s0_live
WHERE grass_region = 'ID'
    AND tz_type = 'local'    -- for DWD table, tz_type only has 'local'
    AND order_be_status_id IN (4, 11, 12, 13, 14, 15)
    AND shipping_confirm_timestamp > 0
    AND is_bi_excluded = 0
;
        
create or replace temporary view user_order_info_tab as 
select 
    ot.user_id
    ,count(distinct ot.order_id) as confirmed_order_in_lifetime
from orders_tab ot 
left join return_tab rt 
on ot.order_id = rt.order_id
where ot.shipping_confirm_date < current_date
and rt.return_id is null
group by 1
;

-- create or replace temporary view  ascore_v33_max_grass_date as 
-- SELECT MAX(grass_date) max_grass_date
-- FROM rescbds_credit.rescbds_credit_prod_id__application_credit_score_mega
-- WHERE model_type = '2_terms_dpd30'
--     AND model_version = 'v3.3'
-- ;

create or replace temporary view ascore_tab_v33 as 
select 
    a.userid       as userid 
    , b.score      as ascore_v33
    , b.model_type as ascore_v33_model_type
    , b.grass_date as ascore_v33_grass_date
from fraud_and_access_spl a 
left join (
    select 
        a.userid
        , a.score
        , a.model_type
        , a.grass_date
    from rescbds_credit.rescbds_credit_prod_id__application_credit_score_mega a 
    join (
        select 
            max(grass_date) max_grass_date
        from rescbds_credit.rescbds_credit_prod_id__application_credit_score_mega
        where model_type = '2_terms_dpd30'
        and model_version = 'v3.3'
    ) b on a.grass_date = b.max_grass_date
    where a.model_type = '2_terms_dpd30'
        and a.model_version = 'v3.3'
) b on a.userid = b.userid
;

create or replace temporary view prefilter_process AS 
select 
        f.userid                               as userid
    ,coalesce(f.is_bad_user, 0)                as is_bad_user
    ,coalesce(a.shopee_age, 0)                 as shopee_age
    ,coalesce(ac.user_status_max, 0)           as credit_user_status
    ,coalesce(o.confirmed_order_in_lifetime,0) as confirmed_order_in_lifetime
from fraud_and_access_spl f 
left join age as a 
on f.userid = a.userid
left join (
            select platform_user_id
                    , cast(user_id as bigint) as user_id
                    , max(user_status)            as user_status_max
            from credit.ods__credit_usercenter_member_id_db__user_admin_map_tab__df
            where grass_date ='${grass_date}'
            group by platform_user_id,cast(user_id as bigint)) as ac 
on cast(f.userid as string) = ac.platform_user_id
left join user_order_info_tab o 
on f.userid = o.user_id
;


create or replace temporary view blacklist_users AS 
select 
    a.userid
    ,a.is_bad_user
    ,a.shopee_age
    ,a.credit_user_status
    ,as33.ascore_v33
    ,a.confirmed_order_in_lifetime
from prefilter_process a 
left join (
    select platform_user_id
    from risk.ods__credit_risk_control_id_db__credit_sp_tab__df
    where grass_date='${grass_date}'
    and status = 1
    group by platform_user_id
) p_user 
on a.userid = p_user.platform_user_id
left join ascore_tab_v33 as33
on a.userid = as33.userid
where p_user.platform_user_id is null  
-- cast(a.userid as varchar) not in
--     (select distinct platform_user_id
--     from credit.credit_risk_control_id_db__credit_sp_tab
--     where status = 1)
;

insert overwrite table risk.ads_risk_id_spl_ota_user_blacklist_df partition(grass_date ='${grass_date}')
select 
userid  as user_id 
,1      as status
from blacklist_users
where (shopee_age > 360 and ascore_v33 <= 500 AND confirmed_order_in_lifetime > 20)
or is_bad_user = 1 
or credit_user_status > 2
group by userid
-- 手动维护的表,支持手工添加黑名单userid
-- status=1表示添加黑名单生效
union all 
select 
user_id  as user_id 
,1      as status
from risk.ads_risk_id_spl_ota_user_blacklist_df_manual
where status='1'
;
;

