insert overwrite table ${SCHEMA}.dws_risk_id_phone_multiloan_df partition (grass_region, grass_date)
select  phone
        ,min(mh_consecutive_query_day_min_1d) as mh_consecutive_query_day_min_1d
        ,min(mh_consecutive_query_day_min_3d) as mh_consecutive_query_day_min_3d
        ,min(mh_consecutive_query_day_min_7d) as mh_consecutive_query_day_min_7d
        ,min(mh_consecutive_query_day_min_14d) as mh_consecutive_query_day_min_14d
        ,min(mh_consecutive_query_day_min_30d) as mh_consecutive_query_day_min_30d
        ,min(mh_consecutive_query_day_min_90d) as mh_consecutive_query_day_min_90d
        ,min(mh_consecutive_query_day_min_180d) as mh_consecutive_query_day_min_180d
        ,min(mh_consecutive_query_day_min_360d) as mh_consecutive_query_day_min_360d
        ,min(mh_consecutive_query_day_min_720d) as mh_consecutive_query_day_min_720d
        ,min(mh_consecutive_query_day_min_ever) as mh_consecutive_query_day_min_ever
        ,max(mh_attempted_institutions_month_max_90d) as mh_attempted_institutions_month_max_90d
        ,max(mh_attempted_institutions_month_max_180d) as mh_attempted_institutions_month_max_180d
        ,max(mh_attempted_institutions_month_max_360d) as mh_attempted_institutions_month_max_360d
        ,max(mh_attempted_institutions_month_max_720d) as mh_attempted_institutions_month_max_720d
        ,max(mh_attempted_institutions_month_max_ever) as mh_attempted_institutions_month_max_ever
        ,grass_region
        ,grass_date
from    ${SCHEMA}.dws_risk_id_ktp_phone_multiloan_df
where   grass_region = 'ID'
  and   grass_date = '${grass_date}'
group by phone, grass_region, grass_date
;

