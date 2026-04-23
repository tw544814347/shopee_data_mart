insert overwrite table ${SCHEMA}.ads_risk_user_device_auto_login_cnt_df partition(grass_region = 'sg')
SELECT user_id
       ,is_success
       ,login_time
       ,login_channel
       ,is_auto_login
       ,grass_date
FROM (
  SELECT user_id
         ,is_success
         ,grass_date
         ,floor(event_timestamp / 1000) as login_time
         ,grass_region
         ,login_channel
         ,is_auto_login
         ,ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY grass_date DESC) AS row_num
  FROM antifraud_dw.dwd_evt_shopee_login_di
  WHERE grass_date > date_sub('${grass_date}',15) 
    and grass_region in ('SG')
    and user_id > 0
) t1 
WHERE row_num <= 1000
;






-- 全量补充
-- insert overwrite table ${SCHEMA}.ads_risk_user_device_latest_login_time_df partition(grass_region = 'sg',grass_date = '${grass_date}')
-- SELECT user_id
--        ,is_success
--        ,login_time
--        ,login_channel
--        ,is_auto_login
-- FROM (
--   SELECT user_id
--          ,is_success
--          ,floor(event_timestamp / 1000) as login_time
--          ,grass_region
--          ,login_channel
--          ,is_auto_login
--          ,ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_timestamp DESC) AS row_num
--   FROM antifraud_dw.dwd_evt_shopee_login_di
--   WHERE  grass_region in ('SG')
--      and user_id > 0
-- ) t1 
-- WHERE row_num = 1
-- ;

-- 每日增量数据
insert overwrite table ${SCHEMA}.ads_risk_user_device_latest_login_time_df partition(grass_region = 'sg',grass_date = '${grass_date}')
select user_id
     , is_success
     , login_time
     , login_channel
     , is_auto_login
from (
         SELECT user_id
              , is_success
              , login_time
              , login_channel
              , is_auto_login
              , ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_time DESC) AS row_num
         FROM (
                  SELECT user_id
                       , cast(is_success as string) as is_success
                       , floor(event_timestamp / 1000) as login_time
                       , login_channel
                       , cast(is_auto_login as string) as is_auto_login
                  from antifraud_dw.dwd_evt_shopee_login_di
                  WHERE grass_date = '${grass_date}'
                    and grass_region in ('SG')
                    and user_id > 0
                  union all
                  select user_id
                       , is_success
                       , login_time
                       , login_channel
                       , is_auto_login
                  from risk.ads_risk_user_device_latest_login_time_df
                  where grass_region = 'sg'
                    and grass_date = date_sub('${grass_date}', 1)
              )
     )
where row_num = 1
;