--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-09-05
-- Theme Domain：        risk user_phone recycle
-- Description:          通过离线分析phone recycle的case，发现有些tag对于发现逾期风险有明显的相关性，希望可以在线上用这些tag标记出这些用户
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42340 逻辑: https://docs.google.com/document/d/1XeynmStAk4zQadsNlcMTCxN-XbB6g4QjaRWnzt8cBt8/edit
-- 变更历史：
--      update by zongyi.lu@shopee.com 2024-10-09 按照讨论的逻辑更新 https://docs.google.com/spreadsheets/d/1emcyI2D6mmhZBxZl_BRh5Q-cvpAyJ6iZRa8AHNbovA0/edit?gid=1985808598#gid=1985808598
--      update by zongyi.lu@shopee.com 2024-10-16 gps 以及 address 要限制最近三年的数据，防止后续数据越来越大(与用户达成一致)
--********************************************************************--

-- 存在沉默期的用户
create temporary view tmp_risk_user_login_period_tab as 
select 
user_id 
,login_timestamp
,next_login_timestamp -- 沉默期结束时间
,login_shopee_device_id
,next_login_shopee_device_id
,next_login_from
from (
    -- 1. silence date 在近一年内的, 且取最后一次silence date 
    -- 2.一年内只登录了一次的用户start date = 最后一次登录，end date = 今天;之后再算silence
    select  
    user_id 
    ,login_timestamp
    ,next_login_timestamp
    ,login_shopee_device_id
    ,next_login_shopee_device_id
    ,next_login_from
    from (
        select 
        user_id 
        ,login_timestamp
        ,nvl(next_login_timestamp,unix_timestamp('${grass_date} 23:59:59','yyyy-MM-dd HH:mm:ss')) as next_login_timestamp
        ,login_shopee_device_id
        ,next_login_shopee_device_id
        ,next_login_from
        ,row_number() over(partition by user_id order by login_timestamp desc ) rn 
        from risk.dws_risk_${region}_user_login_period_df 
        where grass_date ='${grass_date}'
        and nvl(next_login_date,'${grass_date}')>=date_sub('${grass_date}',366)
        and datediff(nvl(next_login_date,'${grass_date}'),login_date)>${cutoff_silence_days} 
    ) t 
    where rn =1 
    -- 超过一年没登陆的用户start date = 最后一次登录，end date = 今天;之后再算silence
    union all 
    select 
    user_id 
    ,login_timestamp
    ,unix_timestamp('${grass_date} 23:59:59','yyyy-MM-dd HH:mm:ss') as next_login_timestamp
    ,login_shopee_device_id
    ,next_login_shopee_device_id
    ,next_login_from
    from (
        select 
        t1.user_id 
        ,t1.login_timestamp
        ,t1.next_login_timestamp
        ,t1.login_shopee_device_id
        ,t1.next_login_date
        ,t1.next_login_shopee_device_id
        ,t1.login_date
        ,t1.next_login_from
        ,row_number() over(partition by t1.user_id order by t1.login_timestamp desc ) rn 
        from risk.dws_risk_${region}_user_login_period_df t1 
        join(
            select
            user_id 
            ,max(next_login_date) max_next_login_date
            from risk.dws_risk_${region}_user_login_period_df
            where grass_date ='${grass_date}' 
            group by user_id
        ) t2 on t1.user_id = t2.user_id 
        where t1.grass_date ='${grass_date}'and t2.max_next_login_date<date_sub('${grass_date}',366)
    ) t
    where datediff('${grass_date}',next_login_date)>180 -- 满足silence date
    and t.rn =1 
) t1 
;

-- 沉默期用户结束日期用的登录设备
create temporary view tmp_risk_user_silence_device_tab as 
select 
    tt1.user_id 
    ,max(case -- when tt1.next_login_from like '%web%' then 1 
              when tt2.user_id is not null and tt1.next_login_timestamp>tt2.login_timestamp then 0 
              when tt2.user_id is not null and tt1.next_login_timestamp<=tt2.login_timestamp then 1 
              when tt2.user_id is null then 1 else null end) new_device_reactive
from (
    select 
    t1.user_id
    ,t.new_login_shopee_device_id -- silence_end_date 的登录设备
    ,t1.next_login_timestamp -- silence_end_date 
    ,t1.next_login_from -- silence_end_date 登录来源
    from tmp_risk_user_login_period_tab t1 
    lateral view explode(next_login_shopee_device_id) t AS new_login_shopee_device_id
) tt1 
left join (
    select 
    user_id 
    ,grass_date 
    ,login_timestamp as login_timestamp
    ,login_from      as login_from
    ,shopee_device_id as shopee_device_id
    from risk.dwd_risk_login_di
    where grass_region = upper('${region}')  
    and grass_date<'${grass_date}'
) tt2 on tt1.user_id = tt2.user_id and tt1.new_login_shopee_device_id = tt2.shopee_device_id
group by tt1.user_id
;

-- 冷静期前后下单地址是否一致& 是否沉默期前就设置了地址(并且沉默期后下了单)&用户下单地址city_list
create temporary view tmp_risk_user_silence_address_tab as 
select 
    tttt1.user_id 
    ,max(tttt1.is_same_address) as is_same_address
    ,max(tttt1.is_old_mp_address) as is_old_mp_address
    ,cast(collect_set(tttt1.gps_city ) as string) as gps_city_list
    ,cast(collect_set(tttt1.gps_province)as string) as gps_province_list
    ,cast(collect_set(tttt1.gps_city_list_slice)as string) as gps_city_list_slice
from (
    select 
    ttt1.user_id 
    ,max(ttt1.is_same_address) as is_same_address
    ,max(ttt1.is_old_mp_address) as is_old_mp_address
    ,ttt1.gps_city
    ,ttt1.gps_province
    ,concat(nvl(split(ttt1.gps_city,' ')[1],' '),' ',nvl(split(ttt1.gps_city,' ')[2],' ')) as gps_city_list_slice
    -- ,cast(collect_set(case when ttt1.pos >= 1 and ttt1.pos < 4 then replace(ttt1.val,'"') else null end ) as string) as gps_city_list_slice -- 用户的net订单的地址切片 取city按照空格分割,第2,3个元素
    from(
        select 
        tt1.user_id 
        ,tt1.is_same_address as is_same_address
        ,tt1.is_old_mp_address as is_old_mp_address
        ,split(tt1.user_address,'_')[1] as gps_city
        ,split(tt1.user_address,'_')[0]as  gps_province
        -- ,posexplode(split(split(user_address,'_')[1],' ')) AS (pos, val)
        from (
            select 
            t1.user_id 
            ,t2.user_address 
            ,max(case when from_unixtime(t1.next_login_timestamp) < t2.max_order_create_date_item and from_unixtime(t1.next_login_timestamp) >min_order_create_date then 1 else 0 end ) is_same_address
            ,max(case when from_unixtime(t1.next_login_timestamp)<= t2.min_order_create_date_item and t3.modify_dt<=t1.next_login_timestamp then 1 else 0 end ) is_old_mp_address
            from tmp_risk_user_login_period_tab t1 
            left join (
                select user_id
                , user_address
                , min(order_create_date) as min_order_create_date
                , max(case when net_order_def_item_tag =1 then order_create_date else null end) as max_order_create_date_item
                , min(case when net_order_def_item_tag =1 then order_create_date else null end) as min_order_create_date_item
                from (
                    select 
                    buyer_id as user_id
                    ,checkout_id
                    ,buyer_shipping_address_state
                    ,buyer_shipping_address_city
                    ,concat(buyer_shipping_address_state,'_',buyer_shipping_address_city,'_',buyer_shipping_address_district) as  user_address
                    ,FROM_UNIXTIME(create_timestamp) as order_create_date
                    ,max(case when order_item_status in ('OITEM_UNRATED', 'OITEM_RATED') then 1 else 0 end) as net_order_def_item_tag
                    from mp_order.dwd_order_item_all_ent_df__reg_s0_live
                    where grass_region = upper('${region}')
                    and grass_date !=date'9999-01-01'
                    and is_bi_excluded = 0
                    and shop_id > 0
                    and to_date(FROM_UNIXTIME(create_timestamp))>=date_sub('${grass_date}',370*3)
                    group by buyer_id
                    ,checkout_id
                    ,concat(buyer_shipping_address_state,'_',buyer_shipping_address_city,'_',buyer_shipping_address_district)
                    ,FROM_UNIXTIME(create_timestamp)
                    ,buyer_shipping_address_state
                    ,buyer_shipping_address_city
                ) t1 
                group by user_id,user_address
            ) t2 on t1.user_id = t2.user_id 
            left join (
                select
                user_id
                ,concat(address_level1.value,'_',address_level2.value,'_',address_level3.value) as user_address 
                ,min(create_timestamp) as modify_dt
                from mp_user.dim_user_address__reg_s1_live
                where grass_region = upper('${region}')
                and grass_date = '${grass_date}'
                and status > 0
                and to_date(from_unixtime(create_timestamp)) >=date_sub('${grass_date}',370*3)
                group by user_id
                ,concat(address_level1.value,'_',address_level2.value,'_',address_level3.value) 
            ) t3 on t2.user_id = t3.user_id and t2.user_address = t3.user_address
            group by t1.user_id 
            ,t2.user_address 
        ) tt1 
    ) ttt1 
    group by ttt1.user_id 
    ,ttt1.gps_city
    ,ttt1.gps_province
    ,concat(nvl(split(ttt1.gps_city,' ')[1],' '),' ',nvl(split(ttt1.gps_city,' ')[2],' '))
) tttt1
group by tttt1.user_id 
;

-- 沉默期中修改了手机号的用户 
create temporary view tmp_risk_user_change_phone_tab as
select 
t1.user_id 
,max(case when to_date(from_unixtime(t2.create_timestamp))>=to_date(from_unixtime(t1.login_timestamp)) and to_date(from_unixtime(t2.create_timestamp))<to_date(from_unixtime(t1.next_login_timestamp)) then 1 else 0 end)  as edge_data_issue
from  tmp_risk_user_login_period_tab t1 
left join (
    select 
    user_id
    ,create_timestamp
    from mp_user.dwd_account_audit_changelog_di__reg_s1_live
    where grass_region = upper('${region}')
    and account_change_type = 'phone'
    and action = 'add'
) t2 on t1.user_id =t2.user_id 
group by t1.user_id
;

-- -- 用户的net订单的地址切片
-- create temporary view tmp_risk_user_city_slice_tab as
-- select
-- t1.user_id
-- ,collect_set(replace(t1.val,'"')) as gps_city_list_slice
-- from (
-- select 
-- buyer_id as user_id 
-- ,buyer_shipping_address_city
-- ,posexplode(split(buyer_shipping_address_city,' ')) AS (pos, val)
-- from mp_order.dwd_order_item_all_ent_df__reg_s0_live
-- where grass_region = upper('${region}')
-- and grass_date !=date'9999-01-01'
-- and is_bi_excluded = 0
-- and shop_id > 0
-- ) t1 
-- where pos >= 1 and pos < 4
-- group by t1.user_id
-- ;

insert overwrite table ${SCHEMA}.ads_risk_${region}_user_login_phone_recycle_df partition(grass_date='${grass_date}')
select 
t1.user_id 
,case when t2.user_id is not null then 1 else 0 end  as login_1y
,case when t3.user_id is not null then 1 else 0 end  as gross_order
,case when t4.user_id is not null then 1 else 0 end  as credit_user
,${cutoff_silence_days}                              as cutoff_silence_days
,case when t5.user_id is not null then 1 else 0 end  as flag_silence_user
,case when t5.user_id is not null then t5.login_timestamp else null end      as silence_start_timestamp
,case when t5.user_id is not null then t5.next_login_timestamp else null end as silence_end_timestamp
,case when t5.user_id is null then -1 
      when t5.user_id is not null and t6.user_id is not null and to_date(from_unixtime(t6.first_add_phone_timestamp))<= to_date(from_unixtime(t5.login_timestamp)) then 1 
      -- 不满足第二个case when 则走第三个,注意2,3 的case when 位置不能改
      when t5.user_id is not null then 0  else 0 end as phone_added_bef_silence 
,case when t5.user_id is null then -1 
      when t5.user_id is not null and t3.user_id is not null and t3.buyer_first_purchase_timestamp_td < t5.login_timestamp then 1 
      -- 不满足第二个case when 则走第三个,注意2,3 的case when 位置不能改
      when t5.user_id is not null then 0  else 0 end as gross_order_bef_silence 
,case when t5.user_id is null then -1  
       when t5.user_id is not null and t7.user_id is not null and t7.new_device_reactive =1 then 1
       -- 此处无需考虑网页端的数据
       -- when t5.user_id is not null and t5.next_login_from like '%web%' then 1 
       when t5.user_id is not null then 0 else 0 end as new_device_reactive
,case when t5.user_id is null then -1  
       when t5.user_id is not null and t7.user_id is not null and t7.new_device_reactive =0 then 1
       -- 此处无需考虑网页端的数据
       -- when t5.user_id is not null and t5.next_login_from like '%web%' then 0
       when t5.user_id is not null then 0 else 0 end as old_device_appear
,case when t5.user_id is null then -1 
      when t5.user_id is not null and t8.is_same_address =1 then 1 
      when t5.user_id is not null then 0 else 0 end as consistent_mp_address
,case when t5.user_id is null then -1 
      when t5.user_id is not null and t8.is_old_mp_address =1 then 1 
      when t5.user_id is not null then 0 else 0 end as old_added_mp_address
,case when t9.user_id is not null then t9.edge_data_issue else 0 end  as edge_data_issue
,replace(cast(case when t8.user_id is not null then t8.gps_city_list else null end as string),'"') as gps_city_list
,replace(cast(case when t8.user_id is not null then t8.gps_city_list_slice else null end as string),'"') as gps_city_list_slice
,replace(cast(case when t8.user_id is not null then t8.gps_province_list else null end as string),'"') as gps_province_list
from (
    select 
     user_id
    from mp_user.dim_user__reg_s0_live
    where grass_region = upper('${region}') 
    and grass_date = '${grass_date}'
    and status = 1
    -- and is_phone_verified = 1 只是跑数据测试加了这个条件
) t1 
left join (
    select
        user_id
       from risk.dwd_risk_login_di 
    where  grass_region = upper('${region}') 
    and grass_date >= date_sub('${grass_date}',366)
    group by user_id
) t2 on t1.user_id = t2.user_id 
left join(
    select 
    buyer_id as user_id
    ,min(buyer_first_purchase_timestamp_td) as buyer_first_purchase_timestamp_td
    from mp_order.dws_buyer_gmv_td__reg_s0_live
    where grass_region = upper('${region}') 
    and grass_date = '${grass_date}'
    and buyer_first_purchase_timestamp_td is not null 
    group by buyer_id
) t3 on t1.user_id = t3.user_id 
left join (
    select 
    platform_user_id as user_id 
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where grass_date >= '${grass_date}' 
    and has_valid_activated = 1
    group by platform_user_id
) t4 on t1.user_id = t4.user_id  
left join (
    select 
    user_id 
    ,login_timestamp
    ,next_login_timestamp
    ,next_login_from
    from tmp_risk_user_login_period_tab
) t5 on t1.user_id = t5.user_id 
left join(
    select   
    user_id
    ,min(modified_timestamp) first_add_phone_timestamp
    from mp_user.dwd_account_audit_changelog_di__reg_s1_live mq
    where grass_region =  upper('${region}') 
    and account_change_type = 'phone'
    and action = 'add'
    and grass_date <= '${grass_date}' 
    group by user_id
) t6 on t1.user_id =t6.user_id 
left join (
    select 
    user_id 
    ,new_device_reactive
    from tmp_risk_user_silence_device_tab
) t7 on t1.user_id = t7.user_id 
left join tmp_risk_user_silence_address_tab t8 on t1.user_id = t8.user_id 
left join tmp_risk_user_change_phone_tab t9 on t1.user_id = t9.user_id 

;

