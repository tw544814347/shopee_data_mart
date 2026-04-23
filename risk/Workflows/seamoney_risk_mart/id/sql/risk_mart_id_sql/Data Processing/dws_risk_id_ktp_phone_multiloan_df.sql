create or replace temporary view multiloan_query_base as
select  ktp_no
        ,phone
        ,from_unixtime(req_time, 'yyyy-MM-dd') as req_date
        ,from_unixtime(pre_req_time, 'yyyy-MM-dd') as pre_req_date
        ,app_id
from    (
    select  ktp_no
            ,phone
            ,req_time
            ,lag(req_time) over (partition by ktp_no, phone order by req_time) as pre_req_time
            ,app_id
    from    (
        select
                ktp_no
                ,phone
                ,req_time
                ,app_id
        from risk.dwd_risk_multiloan_history_df
        union all
        select  ktp_no
                ,msisdn as phone
                ,req_time/1000 as req_time
                ,app_id
        from    risk.dwd_risk_id_tob_service_di
        where   grass_date <= '${grass_date}'
        and     biz_code in ('200000', '300006', '300007')
    )
)
;

--计算 mh_consecutive_query_day_min_{offset} = -1 的情况
--case when区间内，只有1次查询值则为-1
create or replace temporary view multiloan_cnt_query_metrics as
select  ktp_no
        ,phone
        ,count(case when req_date='${grass_date}' then req_date else null end) as mh_query_cnt_day_1d
        ,count(case when req_date>=date_sub('${grass_date}', 3) then req_date else null end) as mh_query_cnt_day_3d
        ,count(case when req_date>=date_sub('${grass_date}', 7) then req_date else null end) as mh_query_cnt_day_7d
        ,count(case when req_date>=date_sub('${grass_date}', 14) then req_date else null end) as mh_query_cnt_day_14d
        ,count(case when req_date>=date_sub('${grass_date}', 30) then req_date else null end) as mh_query_cnt_day_30d
        ,count(case when req_date>=date_sub('${grass_date}', 90) then req_date else null end) as mh_query_cnt_day_90d
        ,count(case when req_date>=date_sub('${grass_date}', 180) then req_date else null end) as mh_query_cnt_day_180d
        ,count(case when req_date>=date_sub('${grass_date}', 360) then req_date else null end) as mh_query_cnt_day_360d
        ,count(case when req_date>=date_sub('${grass_date}', 720) then req_date else null end) as mh_query_cnt_day_720d
        ,count(case when req_date is not null then req_date else null end) as mh_query_cnt_day_ever
        ,'ID' as grass_region
from    multiloan_query_base
group by ktp_no, phone
;

create or replace temporary view multiloan_consecutive_query_metrics_1 as
select  ktp_no
        ,phone
        ,case when mh_query_cnt_day_1d = 1 then -1 else null end as mh_consecutive_query_day_min_1d
        ,case when mh_query_cnt_day_3d = 1 then -1 else null end as mh_consecutive_query_day_min_3d
        ,case when mh_query_cnt_day_7d = 1 then -1 else null end as mh_consecutive_query_day_min_7d
        ,case when mh_query_cnt_day_14d = 1 then -1 else null end as mh_consecutive_query_day_min_14d
        ,case when mh_query_cnt_day_30d = 1 then -1 else null end as mh_consecutive_query_day_min_30d
        ,case when mh_query_cnt_day_90d = 1 then -1 else null end as mh_consecutive_query_day_min_90d
        ,case when mh_query_cnt_day_180d = 1 then -1 else null end as mh_consecutive_query_day_min_180d
        ,case when mh_query_cnt_day_360d = 1 then -1 else null end as mh_consecutive_query_day_min_360d
        ,case when mh_query_cnt_day_720d = 1 then -1 else null end as mh_consecutive_query_day_min_720d
        ,case when mh_query_cnt_day_ever = 1 then -1 else null end as mh_consecutive_query_day_min_ever
from    multiloan_cnt_query_metrics
;

--计算 mh_consecutive_query_day_min_{offset} >=0 的情况
--case when区间内，req_time和pre_req_time都不为空时，再计算最近n天连续两次查询距离最短天数
create or replace temporary view multiloan_consecutive_query_metrics_2 as
select  ktp_no
        ,phone
        ,min(case when req_date='${grass_date}' and pre_req_date='${grass_date}' then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_1d
        ,min(case when req_date>=date_sub('${grass_date}', 3) and pre_req_date>= date_sub('${grass_date}', 3) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_3d
        ,min(case when req_date>=date_sub('${grass_date}', 7) and pre_req_date>= date_sub('${grass_date}', 7) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_7d
        ,min(case when req_date>=date_sub('${grass_date}', 14) and pre_req_date>= date_sub('${grass_date}', 14) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_14d
        ,min(case when req_date>=date_sub('${grass_date}', 30) and pre_req_date>= date_sub('${grass_date}', 30) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_30d
        ,min(case when req_date>=date_sub('${grass_date}', 90) and pre_req_date>= date_sub('${grass_date}', 90) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_90d
        ,min(case when req_date>=date_sub('${grass_date}', 180) and pre_req_date>= date_sub('${grass_date}', 180) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_180d
        ,min(case when req_date>=date_sub('${grass_date}', 360) and pre_req_date>= date_sub('${grass_date}', 360) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_360d
        ,min(case when req_date>=date_sub('${grass_date}', 720) and pre_req_date>= date_sub('${grass_date}', 720) then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_720d
        ,min(case when req_date is not null and pre_req_date is not null then datediff(req_date, pre_req_date) else null end) as mh_consecutive_query_day_min_ever
        ,'ID' as grass_region
from    multiloan_query_base
group by ktp_no, phone
;

create or replace temporary view multiloan_institutions_query_metrics as
select  ktp_no
        ,phone
        ,max(case when req_date >= date_sub('${grass_date}', 90) then query_institutions_cnt else null end) as mh_attempted_institutions_month_max_90d
        ,max(case when req_date >= date_sub('${grass_date}', 180) then query_institutions_cnt else null end) as mh_attempted_institutions_month_max_180d
        ,max(case when req_date >= date_sub('${grass_date}', 360) then query_institutions_cnt else null end) as mh_attempted_institutions_month_max_360d
        ,max(case when req_date >= date_sub('${grass_date}', 720) then query_institutions_cnt else null end) as mh_attempted_institutions_month_max_720d
        ,max(query_institutions_cnt) as mh_attempted_institutions_month_max_ever
from    (
    select  ktp_no
            ,phone
            ,req_date
            ,count(distinct app_id) AS query_institutions_cnt
    from    multiloan_query_base
    group by ktp_no, phone, req_date
) t
group by ktp_no, phone
;

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_id_ktp_phone_multiloan_df PARTITION (grass_region, grass_date)
select  t1.ktp_no
        ,t1.phone
        ,coalesce(t1.mh_consecutive_query_day_min_1d, t2.mh_consecutive_query_day_min_1d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_3d, t2.mh_consecutive_query_day_min_3d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_7d, t2.mh_consecutive_query_day_min_7d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_14d, t2.mh_consecutive_query_day_min_14d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_30d, t2.mh_consecutive_query_day_min_30d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_90d, t2.mh_consecutive_query_day_min_90d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_180d, t2.mh_consecutive_query_day_min_180d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_360d, t2.mh_consecutive_query_day_min_360d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_720d, t2.mh_consecutive_query_day_min_720d, -9999)
        ,coalesce(t1.mh_consecutive_query_day_min_ever, t2.mh_consecutive_query_day_min_ever, -9999)
        ,coalesce(t3.mh_attempted_institutions_month_max_90d, -9999)
        ,coalesce(t3.mh_attempted_institutions_month_max_180d, -9999)
        ,coalesce(t3.mh_attempted_institutions_month_max_360d, -9999)
        ,coalesce(t3.mh_attempted_institutions_month_max_720d, -9999)
        ,coalesce(t3.mh_attempted_institutions_month_max_ever, -9999)
        ,'ID' as grass_region
        ,'${grass_date}' as grass_date
from    multiloan_consecutive_query_metrics_1 t1
left outer join multiloan_consecutive_query_metrics_2 t2
on      t1.ktp_no = t2.ktp_no
  and   t1.phone = t2.phone
left outer join multiloan_institutions_query_metrics t3
on      t1.ktp_no = t3.ktp_no
  and   t1.phone = t3.phone
;


