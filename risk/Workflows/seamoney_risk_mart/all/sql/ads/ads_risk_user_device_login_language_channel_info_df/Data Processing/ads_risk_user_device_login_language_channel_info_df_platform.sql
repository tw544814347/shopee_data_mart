insert overwrite table ${SCHEMA}.ads_risk_user_device_login_language_channel_info_df partition (grass_region, type)
select
    concat_ws('_',substr(md5(cast(user_id as string)), 0, 2),cast(user_id as string)) as rowkey
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(platform_id_1d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_1d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(platform_id_3d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(platform_id_7d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(platform_id_14d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_14d
    ,grass_region
    ,'platform' as type
from
    (
        select
            cast(user_id as string) as user_id
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 1)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_1d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 3)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_3d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 7)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_7d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 14)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_14d
            ,grass_region as grass_region
        from antifraud_dw.dwd_evt_shopee_login_di
        where grass_date > date_sub('${grass_date}',15) 
            and user_id > 0
            and event_timestamp > 0
            and is_auto_login = 'false'
        group by user_id,grass_region
        union all
        select
            cast(user_id as string) as user_id
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 1)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_1d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 3)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_3d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 7)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_7d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 14)
            and grass_date <= '${grass_date}' then nvl(platform_id, '') else null end) as platform_id_14d
            ,grass_region as grass_region
        from antifraud_dw.dwd_evt_shopeepay_login_di
        where grass_date > date_sub('${grass_date}',15) 
            and user_id > 0
            and event_timestamp > 0
            and is_auto_login = 'false'
        group by user_id,grass_region
    )
;