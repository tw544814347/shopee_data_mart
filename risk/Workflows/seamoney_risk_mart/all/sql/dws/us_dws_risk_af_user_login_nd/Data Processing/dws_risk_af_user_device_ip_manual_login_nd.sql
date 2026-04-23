insert overwrite table ${SCHEMA}.dws_risk_af_user_device_ip_manual_login_nd partition(grass_region,grass_date)
select 
     user_id                                                                                                                                            as user_id
    ,md5_user_id                                                                                                                                        as md5_user_id
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_3d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")    as login_szdf_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_7d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")    as login_szdf_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_14d  as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")    as login_szdf_14d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_ip_3d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")      as login_ip_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_ip_7d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")      as login_ip_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_ip_14d  as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")      as login_ip_14d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_ipc_3d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")     as login_ipc_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_ipc_7d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")     as login_ipc_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_ipc_14d  as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")     as login_ipc_14d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_bssid_3d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")   as login_bssid_3d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_bssid_7d   as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")   as login_bssid_7d
    ,regexp_replace(regexp_replace(regexp_replace(regexp_replace(cast(login_bssid_14d  as string),"\\[",""),"\\]","")," ",""),"^\s*,\s*|\s*,\s*$","")   as login_bssid_14d
    ,grass_region                                                                                                                                       as grass_region
    ,grass_date                                                                                                                                         as grass_date
from(
      select 
            user_id                                                                                                                           as user_id
            ,md5(user_id)                                                                                                                     as md5_user_id
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then trim(szdf_device_id) else null end)                                                       as login_szdf_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)
                  and grass_date<='${bizdate}' then trim(szdf_device_id) else null end)                                                       as login_szdf_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)   
                  and grass_date<='${bizdate}' then trim(szdf_device_id) else null end)                                                       as login_szdf_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then trim(client_ip) else null end)                                                            as login_ip_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)
                  and grass_date<='${bizdate}' then trim(client_ip) else null end)                                                            as login_ip_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)   
                  and grass_date<='${bizdate}' then trim(client_ip) else null end)                                                            as login_ip_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then REGEXP_EXTRACT(trim(client_ip), '([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+', 1) else null end)     as login_ipc_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)
                  and grass_date<='${bizdate}' then REGEXP_EXTRACT(trim(client_ip), '([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+', 1) else null end)     as login_ipc_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)   
                  and grass_date<='${bizdate}' then REGEXP_EXTRACT(trim(client_ip), '([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+', 1) else null end)     as login_ipc_14d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',3)
                  and grass_date<='${bizdate}' then trim(dfpinfosz__bssid) end)                                                               as login_bssid_3d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',7)
                  and grass_date<='${bizdate}' then trim(dfpinfosz__bssid) else null end)                                                     as login_bssid_7d
            ,collect_set(case when  grass_date > date_sub('${bizdate}',14)   
                  and grass_date<='${bizdate}' then trim(dfpinfosz__bssid) else null end)                                                     as login_bssid_14d      
            ,grass_region                                                                                                                     as grass_region
            ,'${bizdate}'                                                                                                                     as grass_date
      from ${SCHEMA}.dwd_risk_af_user_device_login_di t1 
      where 
      grass_date > date_sub('${bizdate}',15)
    --   and grass_region='VN'
      and (length(szdf_device_id)>0 or length(client_ip)>0 or length(dfpinfosz__bssid)>0)
      and is_auto_login = 'false'
      group by 
      user_id
      ,md5(user_id)
      ,grass_region
) a 
;



