drop table if exists ${SCHEMA}.dwd_risk_a30_user_df
;

create table  ${SCHEMA}.dwd_risk_a30_user_df
stored as orc
as
select  user_id
        ,grass_region
from    mp_user.ads_activeness_user_activity_td__reg_s0_live
where   tz_type = 'local'
  and   grass_region in ('ID', 'PH')
  and   date(from_unixtime(last_login_timestamp_td)) between date(date_sub('${bizTimeFormatter(SCHEDULED_TIME,"yyyy-MM-dd","-1d")}',30))
  and   date '${bizTimeFormatter(SCHEDULED_TIME,"yyyy-MM-dd","-1d")}'
  and   grass_date = date '${bizTimeFormatter(SCHEDULED_TIME,"yyyy-MM-dd","-1d")}'
group by user_id, grass_region
;

