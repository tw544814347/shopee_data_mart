insert overwrite table ${SCHEMA}.ads_risk_br_user_device_first_login partition(grass_date = '${grass_date}',key = 'szdf')
select szdf_rowkey
     , u_szdf_rowkey_1
     , t1.loginTime
     , t1.ts
     , szdf_device_id
     , t1.grass_region
     , t1.login_channel
     , t1.login_type
     , t1.user_id
from (select concat(substr(md5(szdf_device_id), 0, 2), '_', szdf_device_id, '_szdf_', user_id) as szdf_rowkey,
             concat(substr(md5(user_id), 0, 2), '_', user_id, '_szdf_',
                    szdf_device_id)                                                            as u_szdf_rowkey_1,
             floor(event_timestamp / 1000)                                                     as loginTime,
             9223372036854775807 - event_timestamp                                             as ts,
             szdf_device_id,
             grass_region,
             login_channel,
             login_type,
             user_id
      from (select cast(user_id as string)                                as user_id,
                   dfpinfosz__securitydeviceid                            as szdf_device_id,
                   case when is_auto_login = 'true' then '1' else '2' end as login_type,
                   event_timestamp                                        as event_timestamp,
                   grass_region                                           as grass_region,
                   login_channel                                          as login_channel,
                   row_number()                                              over(partition by user_id, dfpinfosz__securitydeviceid, grass_region order by event_timestamp asc) asc_rn
            from antifraud_dw.dwd_evt_shopee_login_di
            where grass_date = '${ds}'
              and is_success = 'true'
              and char_length(dfpinfosz__securitydeviceid) > 0
              and grass_region in ('BR'))
      where asc_rn = 1
     ) t1
         left join (select * from risk.ads_risk_br_user_device_first_login 
                        where grass_date < '${grass_date}'
                            and key = 'szdf') t2
                   on t1.user_id = t2.user_id
                       and t1.szdf_device_id = t2.device
where (t2.user_id is null or t2.device is null or length(t2.device) < 1)
;


insert overwrite table ${SCHEMA}.ads_risk_br_user_device_first_login partition(grass_date = '${grass_date}',key = 'spdf')
select hash_spdf_rowkey
     , u_spdf_rowkey_1
     , t1.loginTime
     , t1.ts
     , hashed_shopee_df
     , t1.grass_region
     , t1.login_channel
     , t1.login_type
     , t1.user_id
from (select concat(substr(md5(hashed_shopee_df), 0, 2), '_', hashed_shopee_df, '_hashsp_',
                    user_id)                       as hash_spdf_rowkey,
             concat(substr(md5(user_id), 0, 2), '_', user_id, '_hashsp_',
                    hashed_shopee_df)              as u_spdf_rowkey_1,
             floor(event_timestamp / 1000)         as loginTime,
             9223372036854775807 - event_timestamp as ts,
             hashed_shopee_df,
             grass_region,
             login_channel,
             login_type,
             user_id
      from (select cast(user_id as string)                                as user_id,
                   hashed_shopee_df                                       as hashed_shopee_df,
                   case when is_auto_login = 'true' then '1' else '2' end as login_type,
                   event_timestamp                                        as event_timestamp,
                   grass_region                                           as grass_region,
                   login_channel                                          as login_channel,
                   row_number()                                              over(partition by user_id, hashed_shopee_df, grass_region order by event_timestamp asc) asc_rn
            from antifraud_dw.dwd_evt_shopee_login_di
            where grass_date = '${ds}'
              and is_success = 'true'
              and char_length(hashed_shopee_df) > 0
              and grass_region in ('BR'))
      where asc_rn = 1
     ) t1
         left join (select * from risk.ads_risk_br_user_device_first_login 
                        where grass_date < '${grass_date}'
                            and key = 'spdf') t2
                   on t1.user_id = t2.user_id
                       and t1.hashed_shopee_df = t2.device
where (t2.user_id is null or t2.device is null or length(t2.device) < 1)
;


insert overwrite table ${SCHEMA}.ads_risk_br_user_device_first_login partition(grass_date = '${grass_date}',key = 'unhash_spdf')
select spdf_rowkey
     , user_spdf_rowkey
     , t1.loginTime
     , t1.ts
     , shopee_df_plain
     , t1.grass_region
     , t1.login_channel
     , t1.login_type
     , t1.user_id
from (select concat(substr(md5(TRIM(REPLACE(shopee_df_plain, '_', '-'))), 0, 2), '_',
                    TRIM(REPLACE(shopee_df_plain, '_', '-')), '_spdf_', user_id)                                  as spdf_rowkey,
             concat(substr(md5(user_id), 0, 2), '_', user_id, '_spdf_',
                    TRIM(REPLACE(shopee_df_plain, '_', '-')))                                                     as user_spdf_rowkey,
             floor(event_timestamp / 1000)                                                                        as loginTime,
             9223372036854775807 - event_timestamp                                                                as ts,
             shopee_df_plain,
             grass_region,
             login_channel,
             login_type,
             user_id
      from (select cast(user_id as string)                                as user_id,
                   shopee_df_plain                                        as shopee_df_plain,
                   case when is_auto_login = 'true' then '1' else '2' end as login_type,
                   event_timestamp                                        as event_timestamp,
                   grass_region                                           as grass_region,
                   login_channel                                          as login_channel,
                   row_number()                                              over(partition by user_id, shopee_df_plain, grass_region order by event_timestamp asc) asc_rn
            from antifraud_dw.dwd_evt_shopee_login_di
            where grass_date = '${ds}'
              and is_success = 'true'
              and char_length(shopee_df_plain) > 0
              and grass_region in ('BR'))
      where asc_rn = 1
     ) t1
         left join (select * from risk.ads_risk_br_user_device_first_login 
                        where grass_date < '${grass_date}'
                            and key = 'unhash_spdf') t2
                   on t1.user_id = t2.user_id
                       and t1.shopee_df_plain = t2.device
where (t2.user_id is null or t2.device is null or length(t2.device) < 1)
;