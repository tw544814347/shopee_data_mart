insert overwrite table ${SCHEMA}.dws_risk_af_device_login_nd partition (grass_region, grass_date, device_type)
select  szdf_device_id as devive_fingerprint
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_3d   as string), "\\[", ""), "\\]", ""), " ", "") as login_country_3d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_7d   as string), "\\[", ""), "\\]", ""), " ", "") as login_country_7d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_14d  as string), "\\[", ""), "\\]", ""), " ", "") as login_country_14d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_30d  as string), "\\[", ""), "\\]", ""), " ", "") as login_country_30d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_60d  as string), "\\[", ""), "\\]", ""), " ", "") as login_country_60d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_3d   as string), "\\[", ""), "\\]", ""), " ", "") as login_city_3d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_7d   as string), "\\[", ""), "\\]", ""), " ", "") as login_city_7d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_14d  as string), "\\[", ""), "\\]", ""), " ", "") as login_city_14d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_30d  as string), "\\[", ""), "\\]", ""), " ", "") as login_city_30d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_60d  as string), "\\[", ""), "\\]", ""), " ", "") as login_city_60d
        ,grass_region as grass_region
        ,grass_date as grass_date
        ,'szdf' as device_type
from    (
    select  szdf_device_id
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 3)
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 7)                                         
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 14)                                            
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 30)                                            
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 60)                                            
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_60d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 3)
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 7)                                         
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 14)                                            
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 30)                                            
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 60)                                            
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_60d
            ,grass_region as grass_region
            ,'${bizdate}' as grass_date
    from    ${SCHEMA}.dwd_risk_af_user_device_login_di t1
    left join risk.dim_risk_ip_country_mapping t2
    on      t1.ipinfo_country_ip = t2.ipinfo_country_ip
    where   grass_date > date_sub('${bizdate}', 60)
      and   length(szdf_device_id) > 0
    group by szdf_device_id, grass_region
) a
;

insert overwrite table ${SCHEMA}.dws_risk_af_device_login_nd partition (grass_region, grass_date, device_type)
select  shopee_df_plain as devive_fingerprint
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_3d   as string), "\\[", ""), "\\]", ""), " ", "") as login_country_3d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_7d   as string), "\\[", ""), "\\]", ""), " ", "") as login_country_7d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_14d  as string), "\\[", ""), "\\]", ""), " ", "") as login_country_14d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_30d  as string), "\\[", ""), "\\]", ""), " ", "") as login_country_30d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_60d  as string), "\\[", ""), "\\]", ""), " ", "") as login_country_60d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_3d   as string), "\\[", ""), "\\]", ""), " ", "") as login_city_3d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_7d   as string), "\\[", ""), "\\]", ""), " ", "") as login_city_7d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_14d  as string), "\\[", ""), "\\]", ""), " ", "") as login_city_14d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_30d  as string), "\\[", ""), "\\]", ""), " ", "") as login_city_30d
        ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_60d  as string), "\\[", ""), "\\]", ""), " ", "") as login_city_60d
        ,grass_region as grass_region
        ,grass_date as grass_date
        ,'spdf' as device_type
from    (
    select  shopee_df_plain
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 3)
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 7)                                         
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 14)                                            
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 30)                                            
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 60)                                            
                  and grass_date <= '${bizdate}' then nvl(t2.country_name, '') else null end) as login_country_60d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 3)
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 7)                                         
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 14)                                            
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 30)                                            
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}', 60)                                            
                  and grass_date <= '${bizdate}' then nvl(ipinfo__city_ip, '') else null end) as login_city_60d
            ,grass_region as grass_region
            ,'${bizdate}' as grass_date
    from    ${SCHEMA}.dwd_risk_af_user_device_login_di t1
    left join risk.dim_risk_ip_country_mapping t2
    on      t1.ipinfo_country_ip = t2.ipinfo_country_ip
    where   grass_date > date_sub('${bizdate}', 60)
      and   length(shopee_df_plain) > 0
    group by shopee_df_plain, grass_region
) a
;

