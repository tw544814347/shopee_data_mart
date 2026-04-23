insert overwrite table ${SCHEMA}.dws_risk_af_user_szdf_device_login_nd partition(grass_region,grass_date)
select 
      user_id
      ,szdf_device_id
      ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_tags_3d as string),"\\[",""),"\\]",""),'"','')  as login_szdf_tags_3d  
      ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_tags_7d as string),"\\[",""),"\\]",""),'"','')  as login_szdf_tags_7d  
      ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_tags_14d as string),"\\[",""),"\\]",""),'"','') as login_szdf_tags_14d 
      ,regexp_replace(regexp_replace(regexp_replace(cast(login_szdf_tags_30d as string),"\\[",""),"\\]",""),'"','') as login_szdf_tags_30d 
      ,grass_region  as grass_region 
      ,'${ds}'       as grass_date 
from (
      select 
            user_id
            ,szdf_device_id 
            ,collect_set(case when grass_date > date_sub('${ds}',3) and grass_date<='${ds}' then tags else null end ) as login_szdf_tags_3d  
            ,collect_set(case when grass_date > date_sub('${ds}',7) and grass_date<='${ds}' then tags else null end ) as login_szdf_tags_7d  
            ,collect_set(case when grass_date > date_sub('${ds}',14) and grass_date<='${ds}' then tags else null end ) as login_szdf_tags_14d 
            ,collect_set(case when grass_date > date_sub('${ds}',30) and grass_date<='${ds}' then tags else null end ) as login_szdf_tags_30d 
            ,grass_region 
      from(
      select 
            a.user_id                      as user_id
            ,a.szdf_device_id              as szdf_device_id
            ,regexp_replace(nvl(t.tags,''),'"','') as tags
            ,a.grass_date                  as grass_date
            ,a.grass_region                as grass_region
      from risk.dwd_risk_af_user_device_login_di a 
      lateral view explode(split(regexp_replace(regexp_replace(dfpinfosz__tags,"\\[",""),"\\]","") ,',')) t as tags
      where grass_date >=date_sub('${ds}',30)
      and grass_date <='${ds}'
      and a.grass_region in('ID','MY','TH','PH','SG','VN')
      ) a 
      group by user_id,szdf_device_id,grass_region
) a 
;