insert overwrite table ${SCHEMA}.ads_2bscore_sg_user_phone_info_df partition (grass_date = '${ds}')
select  tt1.phone_number as phone_no
        ,case when tt2.score is null then tt4.platform_user_id else tt1.user_id end as platform_user_id
        ,1 as is_phone_matched
        ,coalesce(tt2.score,tt4.score) as score
        ,coalesce(tt3.is_blacklist_hit, 0) as is_blacklist_hit
        ,tt3.list_type
        ,cast(tt3.reason_code as int) as reason_code
        ,coalesce(tt2_1.score_v3,tt4.score_v3) as score_v3
        ,tt3.reason_code_list
from    (
    select  user_id
            ,phone_number
    from    (
        select  user_id
                ,phone_number
                ,row_number() over(partition by phone_number order by registration_datetime desc, user_id desc) as rn
        from    (
            select  user_id
                    ,phone_number
                    ,registration_datetime
            from    mp_user.dim_user__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = 'SG'
              and   grass_date = '${ds}'
              and   is_phone_verified = 1
        ) t1
    )
    where   rn = 1
) tt1
left join (
    select  a.userid as user_id
            ,round(a.score) score
    from    rescbds_credit.sg_spl_acard_credit_score a
    where   a.model_version = 'v3.0'
    and     a.grass_date = (select max(grass_date) max_grass_date from rescbds_credit.sg_spl_acard_credit_score where grass_date <= '${ds}' and model_version = 'v3.0')
) tt2
on      tt1.user_id = tt2.user_id
left join (
    select  userid
            ,round(score) as score_v3
    from    rescbds_credit.sg_tob_credit_score
    where grass_date = (select max(grass_date) from rescbds_credit.sg_tob_credit_score where grass_date <= '${ds}' and model_version = 'v3.0')
    and model_version = 'v3.0'
) tt2_1
on tt1.user_id = tt2_1.userid
left join (
    select  a.userid
            ,a.ifmatched as is_blacklist_hit
            ,a.list_type
            ,a.reason_code
            ,a.reason_code_list
    from    rescbds_credit.rescbds_credit_prod_sg__das_user_blacklist a
    where   grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_sg__das_user_blacklist where grass_date <= '${ds}')
) tt3
on      tt1.user_id = tt3.userid
left join
(
    select  t1.phone_no
            ,t2.platform_user_id
            ,t2.score
            ,t2.score_v3
            ,t1.grass_date
    from (
        select
            phone_no
            ,max(grass_date) as grass_date
        from risk.ads_2bscore_sg_user_phone_info_df
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
            ,score_v3
            ,grass_date
        from risk.ads_2bscore_sg_user_phone_info_df
        where grass_date >= date_sub('${grass_date}', 30)
        and grass_date <= '${grass_date}'
    ) t2 on t1.phone_no = t2.phone_no
    and t1.grass_date = t2.grass_date
) tt4
on tt1.phone_number = tt4.phone_no
;