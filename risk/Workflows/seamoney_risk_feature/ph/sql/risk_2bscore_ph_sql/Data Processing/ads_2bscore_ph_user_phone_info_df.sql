------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-04-25
-- Description:         PH 2bscore
-- Data Granularity:    phone_no
--Notes:                phone_no维度的表，关联user_id或者其它维度的表，一定要保证关联健唯一，避免数据发散
-- PRD:                 

--变更历史：
--v1  2024-04-25, 修复phone维度，user_id映射和score不一致的问题；PRD：https://jira.shopee.io/browse/SPFDT-33714
------------------------------------------------------------------------

add jar hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-sha-256.jar;
create or replace temporary function sha256 as 'com.shopee.udf.RiskSha256';

create or replace temporary view tmp_2bscore_ph_user_address_info_nd as
select user_id
        ,to_json(collect_list(map(
                            'address', case when lat_long = 'NA' or lat_long = 'ERROR' then ''
                                        else lat_long
                                        end,
                            'confidence_level', case when is_self_addr = 1 and order_cnt >= 10 then 'High'
                                                        when is_self_addr = 1 and order_cnt < 10 then 'Medium'
                                                        when is_self_addr = 0 and order_cnt >= 10 then 'Medium'
                                                        when is_self_addr = 0 and order_cnt < 10 then 'Low'
                                                else ''
                                                end 
        ))) AS address_info
from (
    select t1.user_id
        ,t1.zipcode
        ,t1.state
        ,t1.city
        ,t1.district
        ,t1.town
        ,t1.address
        ,t1.is_self_addr
        ,t1.order_cnt
        ,t2.lat_long
    from risk.ads_2bscore_ph_user_address_info_nd t1
    left join (
        select  zipcode
                ,state
                ,city
                ,district
                ,town
                ,address
                ,lat_long
                ,grass_date
        from    risk.dim_2bscore_ph_user_address_lat_long_df
        where   grass_date = '${ds_t_2}'
        and     lat_long <> 'ERROR'
        and     lat_long <> 'NA'
    ) t2
    on  t1.address = t2.address
    and t1.state = t2.state
    and t1.city = t2.city
    and t1.district = t2.district
    and t1.town = t2.town
    and t1.zipcode = t2.zipcode
    where t1.grass_date = '${grass_date}'
    group by t1.user_id, t1.zipcode, t1.state, t1.city, t1.district, t1.town, t1.address, t1.is_self_addr, t1.order_cnt, t2.lat_long
)
group by user_id
;

insert overwrite table ${SCHEMA}.ads_2bscore_ph_user_phone_info_df partition (grass_date = '${ds}')
select  tt1.phone_number as phone_no
        ,case when tt2.score is null then tt4.platform_user_id else tt1.userid end as platform_user_id
        ,1 is_ktp_matched
        ,coalesce(tt2.score,tt4.score) as score
        ,coalesce(tt3.is_blacklist_hit, 0)
        ,tt3.list_type
        ,cast(tt3.reason_code as int)
        ,sha256(phone_number) as phone_no_sha256
        ,base64(tt1.phone_number) as phone_no_base64
        ,coalesce(t5.address_info, '') as address_info
from    (
    select  t1.user_id AS userid
            ,t2.phone_number AS phone_number
            ,row_number() over(partition by t2.phone_number order by t1.registration_datetime desc, t1.user_id desc) as latest_phone_number
    from    (
        select  s0.*
        from    mp_user.dim_user__reg_s0_live s0
        where   s0.tz_type = 'local'
          and   s0.grass_region = 'PH'
          and   s0.grass_date = '${ds}'
          and   s0.is_phone_verified = 1
    ) t1
    inner join (
        select  s1.user_id
                ,s1.phone_number
                ,s1.grass_date
        from    mp_user.dim_user__reg_s1_live s1
        where   s1.tz_type = 'local'
          and   s1.grass_region = 'PH'
          and   s1.grass_date = '${ds}'
    ) t2
    on      t1.user_id = t2.user_id
      and   t1.grass_date = t2.grass_date
) tt1
left join (
    select  a.userid
            ,round(a.score) score
    from    rescbds_credit.ph_tob_credit_score a
    where   grass_date = (select max(grass_date) from rescbds_credit.ph_tob_credit_score where grass_date<='${ds}')
) tt2
on      tt1.userid = tt2.userid
left join (
    select  a.userid
            ,a.ifmatched as is_blacklist_hit
            ,a.list_type
            ,a.reason_code
    from    rescbds_credit.ph_tob_blacklist a
    where   grass_date = (select max(grass_date) from rescbds_credit.ph_tob_blacklist where grass_date<='${ds}')
) tt3
on      tt1.userid = tt3.userid
left join
(
    select  t1.phone_no
            ,t2.platform_user_id
            ,t2.score
            ,t1.grass_date
    from (
        select
            phone_no
            ,max(grass_date) as grass_date
        from risk.ads_2bscore_ph_user_phone_info_df
        where
            grass_date >= date_sub('${grass_date}', 30)
            and grass_date <= '${grass_date}'
            and score is not null
        group by phone_no
    ) t1
    left join
    (
        select
            phone_no
            ,platform_user_id
            ,score
            ,grass_date
        from risk.ads_2bscore_ph_user_phone_info_df
        where grass_date >= date_sub('${grass_date}', 30)
        and grass_date <= '${grass_date}'
    ) t2 on t1.phone_no = t2.phone_no
    and t1.grass_date = t2.grass_date
) tt4
on tt1.phone_number = tt4.phone_no
left join tmp_2bscore_ph_user_address_info_nd t5
on      tt1.userid = t5.user_id
where   tt1.latest_phone_number = 1
;

