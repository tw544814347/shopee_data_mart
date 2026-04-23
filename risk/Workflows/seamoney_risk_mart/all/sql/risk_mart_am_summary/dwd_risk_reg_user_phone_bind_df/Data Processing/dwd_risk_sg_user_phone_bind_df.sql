insert overwrite table ${SCHEMA}.dwd_risk_user_phone_bind_df partition (tz_type='local', grass_region, grass_date)
select
    user_id
    ,bind_phone
    ,bind_timestamp
    ,grass_region
    ,grass_date
from (
    (
        select
            user_id
            ,bind_phone
            ,bind_timestamp
            ,grass_region
            ,'${bizdate}' as grass_date
        from ${SCHEMA}.dwd_risk_user_phone_bind_df
        where grass_region = '${grass_region}'
            and grass_date = date_sub(date('${bizdate}'), 1)
    )
    union all
    (
        select
            user_id
            ,new_value as bind_phone
            ,create_timestamp as bind_timestamp
            ,grass_region
            ,grass_date
        from mp_user.dwd_account_audit_changelog_di__reg_s1_live
        where account_change_type = 'phone'
            and action in ('add', 'change')
            and grass_region = '${grass_region}'
            and grass_date = date('${bizdate}')
            and new_value is not null
    )
);