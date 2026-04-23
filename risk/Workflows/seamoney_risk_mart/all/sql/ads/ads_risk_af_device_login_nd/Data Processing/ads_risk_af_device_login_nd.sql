DROP TEMPORARY FUNCTION IF EXISTS uid_to_bitmap;
create TEMPORARY function uid_to_bitmap as 'com.shopee.udf.UidToRoaringBitmap' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-uid-to-bitmap-1.0-SNAPSHOT.jar';

DROP TEMPORARY FUNCTION IF EXISTS uid_to_bitmap64;
create TEMPORARY function uid_to_bitmap64 as 'com.shopee.udf.UidToRoaring64Bitmap' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-uid-to-bitmap-1.0-SNAPSHOT.jar';


insert overwrite table ${SCHEMA}.ads_risk_af_device_login_nd partition(grass_region,grass_date)
select 
     szdf_device_id                                                                                                                        as szdf_device_id
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_3d as string),"\\[",""),"\\]",""))                                        as login_user_3d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_7d as string),"\\[",""),"\\]",""))                                        as login_user_7d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_30d as string),"\\[",""),"\\]",""))                                       as login_user_30d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_60d as string),"\\[",""),"\\]",""))                                       as login_user_60d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_90d as string),"\\[",""),"\\]",""))                                       as login_user_90d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_120d as string),"\\[",""),"\\]",""))                                      as login_user_120d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_150d as string),"\\[",""),"\\]",""))                                      as login_user_150d
    ,uid_to_bitmap(regexp_replace(regexp_replace(cast(login_user_180d as string),"\\[",""),"\\]",""))                                      as login_user_180d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_3d   as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_3d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_7d   as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_7d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_30d  as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_30d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_60d  as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_60d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_90d  as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_90d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_120d as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_120d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_150d as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_150d
    ,regexp_replace(regexp_replace(regexp_replace(cast(login_fraud_tag_user_180d as string),"\\[",""),"\\]","")," ","")                    as login_fraud_tag_user_180d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_3d as string),"\\[",""),"\\]",""))                                      as login_user_bitmap64_3d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_7d as string),"\\[",""),"\\]",""))                                      as login_user_bitmap64_7d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_30d as string),"\\[",""),"\\]",""))                                     as login_user_bitmap64_30d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_60d as string),"\\[",""),"\\]",""))                                     as login_user_bitmap64_60d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_90d as string),"\\[",""),"\\]",""))                                     as login_user_bitmap64_90d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_120d as string),"\\[",""),"\\]",""))                                    as login_user_bitmap64_120d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_150d as string),"\\[",""),"\\]",""))                                    as login_user_bitmap64_150d
    ,uid_to_bitmap64(regexp_replace(regexp_replace(cast(login_user_180d as string),"\\[",""),"\\]",""))                                    as login_user_bitmap64_180d
    ,grass_region                                                                                                                          as grass_region
    ,grass_date                                                                                                                            as grass_date
from(
      select 
            szdf_device_id                                                                          as szdf_device_id
            ,collect_set(case when grass_date > date_sub('${grass_date}',3)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_3d
            ,collect_set(case when grass_date > date_sub('${grass_date}',7)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_7d
            ,collect_set(case when grass_date > date_sub('${grass_date}',30)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_30d
            ,collect_set(case when grass_date > date_sub('${grass_date}',60)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_60d
            ,collect_set(case when grass_date > date_sub('${grass_date}',90)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_90d
            ,collect_set(case when grass_date > date_sub('${grass_date}',120)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_120d
            ,collect_set(case when grass_date > date_sub('${grass_date}',150)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_150d
            ,collect_set(case when grass_date > date_sub('${grass_date}',180)                     
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_user_180d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',3)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_3d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',7)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_7d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',30)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_30d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',60)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_60d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',90)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_90d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',120)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_120d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',150)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_150d
            ,collect_set(case when is_fraud_tag='1' and grass_date > date_sub('${grass_date}',180)
                  and grass_date<='${grass_date}' then user_id else null end)                       as login_fraud_tag_user_180d
            ,grass_region                                                                           as grass_region
            ,'${grass_date}'                                                                        as grass_date
      from ${SCHEMA}.dwd_risk_af_user_device_login_di
      where grass_date >date_sub('${grass_date}',180)
      and length(szdf_device_id)>0
      group by 
      szdf_device_id
      ,grass_region
) a 
;