

insert overwrite table ${SCHEMA}.dws_risk_af_user_device_login_nd partition(grass_region,grass_date)
select 
     user_id                                                                                                                               as user_id
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_3d   as string),"\\[",""),"\\]","")," ","")                              as login_szdf_3d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_7d   as string),"\\[",""),"\\]","")," ","")                              as login_szdf_7d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_14d  as string),"\\[",""),"\\]","")," ","")                              as login_szdf_14d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_30d  as string),"\\[",""),"\\]","")," ","")                              as login_szdf_30d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_60d  as string),"\\[",""),"\\]","")," ","")                              as login_szdf_60d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_bad_szdf_3d   as string),"\\[",""),"\\]","")," ","")                          as login_bad_szdf_3d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_bad_szdf_7d   as string),"\\[",""),"\\]","")," ","")                          as login_bad_szdf_7d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_bad_szdf_14d  as string),"\\[",""),"\\]","")," ","")                          as login_bad_szdf_14d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_bad_szdf_30d  as string),"\\[",""),"\\]","")," ","")                          as login_bad_szdf_30d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_bad_szdf_60d  as string),"\\[",""),"\\]","")," ","")                          as login_bad_szdf_60d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_spdf_3d   as string),"\\[",""),"\\]","")," ","")                              as login_spdf_3d    
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_spdf_7d   as string),"\\[",""),"\\]","")," ","")                              as login_spdf_7d    
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_spdf_14d  as string),"\\[",""),"\\]","")," ","")                              as login_spdf_14d   
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_spdf_30d  as string),"\\[",""),"\\]","")," ","")                              as login_spdf_30d   
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_spdf_60d  as string),"\\[",""),"\\]","")," ","")                              as login_spdf_60d   
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_3d   as string),"\\[",""),"\\]","")," ","")                           as login_country_3d 
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_7d   as string),"\\[",""),"\\]","")," ","")                           as login_country_7d 
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_14d  as string),"\\[",""),"\\]","")," ","")                           as login_country_14d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_30d  as string),"\\[",""),"\\]","")," ","")                           as login_country_30d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_country_60d  as string),"\\[",""),"\\]","")," ","")                           as login_country_60d
    ,md5_user_id                                                                                                                           as md5_user_id
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_3d   as string),"\\[",""),"\\]","")," ","")                              as login_city_3d 
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_7d   as string),"\\[",""),"\\]","")," ","")                              as login_city_7d 
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_14d  as string),"\\[",""),"\\]","")," ","")                              as login_city_14d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_30d  as string),"\\[",""),"\\]","")," ","")                              as login_city_30d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_city_60d  as string),"\\[",""),"\\]","")," ","")                              as login_city_60d
    ,grass_region                                                                                                                          as grass_region
    ,grass_date                                                                                                                            as grass_date
from(
      select
            user_id                                                                                        as user_id
            ,md5(user_id)                                                                                  as md5_user_id
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_szdf_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_szdf_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_szdf_14d      
            ,collect_set(case when  grass_date > date_sub('${bizdate}',30)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_szdf_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',60)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_szdf_60d
            ,collect_set(case when is_bad_tag='1' and grass_date > date_sub('${bizdate}',3)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_bad_szdf_3d
            ,collect_set(case when is_bad_tag='1' and grass_date > date_sub('${bizdate}',7)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_bad_szdf_7d
            ,collect_set(case when is_bad_tag='1' and grass_date > date_sub('${bizdate}',14)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_bad_szdf_14d
            ,collect_set(case when is_bad_tag='1' and grass_date > date_sub('${bizdate}',30)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_bad_szdf_30d
            ,collect_set(case when is_bad_tag='1' and grass_date > date_sub('${bizdate}',60)   
                  and grass_date<='${bizdate}' then szdf_device_id else null end)                          as login_bad_szdf_60d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then regexp_replace(shopee_df_plain,'_','-') else null end) as login_spdf_3d    
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)                         
                  and grass_date<='${bizdate}' then regexp_replace(shopee_df_plain,'_','-') else null end) as login_spdf_7d    
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)                            
                  and grass_date<='${bizdate}' then regexp_replace(shopee_df_plain,'_','-') else null end) as login_spdf_14d   
            ,collect_set(case when  grass_date > date_sub('${bizdate}',30)                            
                  and grass_date<='${bizdate}' then regexp_replace(shopee_df_plain,'_','-') else null end) as login_spdf_30d   
            ,collect_set(case when  grass_date > date_sub('${bizdate}',60)                            
                  and grass_date<='${bizdate}' then regexp_replace(shopee_df_plain,'_','-') else null end) as login_spdf_60d   
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then nvl(t2.country_name,'') else null end)                 as login_country_3d 
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)                                         
                  and grass_date<='${bizdate}' then nvl(t2.country_name,'') else null end)                 as login_country_7d 
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)                                            
                  and grass_date<='${bizdate}' then nvl(t2.country_name,'') else null end)                 as login_country_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',30)                                            
                  and grass_date<='${bizdate}' then nvl(t2.country_name,'') else null end)                 as login_country_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',60)                                            
                  and grass_date<='${bizdate}' then nvl(t2.country_name,'') else null end)                 as login_country_60d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then nvl(ipinfo__city_ip,'') else null end)                 as login_city_3d 
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)                                         
                  and grass_date<='${bizdate}' then nvl(ipinfo__city_ip,'') else null end)                 as login_city_7d 
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)                                            
                  and grass_date<='${bizdate}' then nvl(ipinfo__city_ip,'') else null end)                 as login_city_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',30)                                            
                  and grass_date<='${bizdate}' then nvl(ipinfo__city_ip,'') else null end)                 as login_city_30d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',60)                                            
                  and grass_date<='${bizdate}' then nvl(ipinfo__city_ip,'') else null end)                 as login_city_60d
            ,grass_region                                                                                  as grass_region
            ,'${bizdate}'                                                                                  as grass_date
      from ${SCHEMA}.dwd_risk_af_user_device_login_di t1 
      left join risk.dim_risk_ip_country_mapping t2 on t1.ipinfo_country_ip = t2.ipinfo_country_ip
      where 
      grass_date >date_sub('${bizdate}',60)
    --   and grass_region='VN'
      and (length(szdf_device_id)>0 or length(shopee_df_plain)>0)
      group by 
      user_id
      ,md5(user_id)
      ,grass_region
) a 
;