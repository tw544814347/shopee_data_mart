insert overwrite table ${SCHEMA}.ads_risk_user_device_login_language_channel_info_df partition (grass_region, type)
select
    concat_ws('_',substr(md5(cast(user_id as string)), 0, 2),cast(user_id as string),'spdf',shopee_df_plain,login_type) as rowkey
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_1d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_1d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_3d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_7d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_14d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_14d
    ,grass_region
    ,'device_language' as type
from
    (
        select
            cast(user_id as string) as user_id
            ,TRIM(REPLACE(shopee_df_plain, '_', '-'))  as shopee_df_plain
            ,case
                when is_auto_login = 'true' then 'auto'
                else 'manual'
            end as login_type
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 1)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_1d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 3)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_3d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 7)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_7d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 14)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_14d
            ,grass_region as grass_region
        from antifraud_dw.dwd_evt_shopee_login_di
        where grass_date > date_sub('${grass_date}',15) 
            and user_id > 0
            and char_length(shopee_df_plain) > 0
            and event_timestamp > 0
        group by user_id,shopee_df_plain,is_auto_login,grass_region
        union all
        select
            cast(user_id as string) as user_id
            ,TRIM(REPLACE(shopee_df_plain, '_', '-'))  as shopee_df_plain
            ,case
                when is_auto_login = 'true' then 'auto'
                else 'manual'
            end as login_type
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 1)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_1d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 3)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_3d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 7)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_7d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 14)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_14d
            ,grass_region as grass_region
        from antifraud_dw.dwd_evt_shopeepay_login_di
        where grass_date > date_sub('${grass_date}',15) 
            and user_id > 0
            and char_length(shopee_df_plain) > 0
            and event_timestamp > 0
        group by user_id,shopee_df_plain,is_auto_login,grass_region
    )

union all
select
    concat_ws('_',substr(md5(cast(user_id as string)), 0, 2),cast(user_id as string),'szdf',szdf_device_id,login_type) as rowkey
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_1d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_1d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_3d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_7d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(device_language_14d  as string), "\\[", ""), "\\]", ""), " ", ""), ',', '-')  as qf_14d
    ,grass_region
    ,'device_language' as type
from
    (
        select
            cast(user_id as string) as user_id
            ,TRIM(REPLACE(dfpinfosz__securitydeviceid, '_', '-'))  as szdf_device_id
            ,case
                when is_auto_login = 'true' then 'auto'
                else 'manual'
            end as login_type
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 1)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_1d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 3)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_3d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 7)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_7d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 14)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_14d
            ,grass_region as grass_region
        from antifraud_dw.dwd_evt_shopee_login_di
        where grass_date > date_sub('${grass_date}',15) 
            and user_id > 0
            and char_length(dfpinfosz__securitydeviceid) > 0
            and event_timestamp > 0
        group by user_id,dfpinfosz__securitydeviceid,is_auto_login,grass_region
        union all
        select
            cast(user_id as string) as user_id
            ,TRIM(REPLACE(dfpinfosz__security_device_id, '_', '-'))  as szdf_device_id
            ,case
                when is_auto_login = 'true' then 'auto'
                else 'manual'
            end as login_type
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 1)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_1d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 3)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_3d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 7)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_7d
            ,collect_set(case when  grass_date > date_sub('${grass_date}', 14)
            and grass_date <= '${grass_date}' then nvl(device_language, '') else null end) as device_language_14d
            ,grass_region as grass_region
        from antifraud_dw.dwd_evt_shopeepay_login_di
        where grass_date > date_sub('${grass_date}',15) 
            and user_id > 0
            and char_length(dfpinfosz__security_device_id) > 0
            and event_timestamp > 0
        group by user_id,dfpinfosz__security_device_id,is_auto_login,grass_region
    )
;