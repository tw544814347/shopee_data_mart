--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-12T17:43:38.310Z
-- Description:    查询用户最近登录天数
--********************************************************************--

-- 查询用户最近登录天数
insert overwrite table ${SCHEMA}.dws_risk_user_login_info_df partition (tz_type='local', grass_region, grass_date)
select
    user_id
    ,login_day_cnt_14d as buyer_login_days_in_14d
    ,login_day_cnt_30d as buyer_login_days_in_30d
    ,login_day_cnt_60d as buyer_login_days_in_60d
    ,login_day_cnt_180d as buyer_login_days_in_180d
    ,grass_region
    ,grass_date
from mp_user.dws_user_login_nd__reg_s0_live
where tz_type = 'local'
    and grass_region in ${batch_region_am}
    and grass_date = '${bizdate}'
;
