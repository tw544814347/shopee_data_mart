add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

create or replace temporary function geo_to_h3 as 'com.shopee.udf.Geo2H3UDF' using jar 'hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_sample;
create table ${SCHEMA}.dws_risk_mx_user_gps_sample as
select
    user_id
from mp_user.dwd_login_ent_di__reg_s0_live
where tz_type = 'local'
    and grass_region = 'MX'
    and grass_date >= date_sub('${ds}', 360)
    and grass_date <= date('${ds}')
group by user_id
;

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_base;
create table ${SCHEMA}.dws_risk_mx_user_gps_base as
select
    user_id
    ,date_format(format_time(location_timestamp, 'MX'), 'yyyy-MM-dd') as location_date
    ,location_timestamp
    ,hour(format_time(location_timestamp, 'MX')) as locate_hr
    ,latitude
    ,longitude
    ,geo_to_h3(latitude, longitude, 6) as hex
from
(
    select
        user_id
        ,report_timestamp
        ,longitude/base as longitude
        ,latitude/base as latitude
        ,location_timestamp
    from ${SCHEMA}.dwd_risk_data_point_gps_di
    where tz_type = 'local'
        and grass_region = 'MX'
        and grass_date >= date_sub('${ds}', 360)
        and grass_date <= date('${ds}')
        and user_id is not null
) a
where latitude >=-35
    and latitude <= 5
    and longitude >= -74
    and longitude <= -35
    and location_timestamp > 0
    and format_time(location_timestamp, 'MX') >= date_sub('${ds}', 360)
    and format_time(location_timestamp, 'MX') <= date('${ds}')
;

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_no_record;
create table ${SCHEMA}.dws_risk_mx_user_gps_no_record as
select
    t1.user_id
    ,count(t2.hex) as hex_cnt
    ,if(count(t2.hex)>0, 1, 0) as has_gps_record
from ${SCHEMA}.dws_risk_mx_user_gps_sample t1
left join ${SCHEMA}.dws_risk_mx_user_gps_base t2
on t1.user_id = t2.user_id
where t2.hex is not null
    and t2.location_date <= date_sub('${ds}', 7)
group by t1.user_id
;

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_sample_feature;
create table ${SCHEMA}.dws_risk_mx_user_gps_sample_feature as
select
    t1.user_id
    ,t2.user_gps_cnt
    ,t2.user_days_with_gps
    ,t2.user_months_with_gps
from ${SCHEMA}.dws_risk_mx_user_gps_sample t1
left join
    (
        select
            user_id
            ,count(location_timestamp) as user_gps_cnt
            ,approx_count_distinct(location_date) as user_days_with_gps
            ,approx_count_distinct(month(location_date)) as user_months_with_gps
            ,min(location_date) as user_earliest_location_date
        from ${SCHEMA}.dws_risk_mx_user_gps_base
        group by user_id
    ) t2
on t1.user_id = t2.user_id
;


drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_hex_feature_pre;
create table ${SCHEMA}.dws_risk_mx_user_gps_hex_feature_pre as
select
    user_id
    ,hex
    ,gps_record_cnt
    ,days_with_gps
    ,months_with_gps
    ,row_number() over(partition by user_id order by days_with_gps desc, gps_record_cnt desc) as rank
from
(
    select
        user_id
        ,hex
        ,count(location_timestamp) as gps_record_cnt
        ,approx_count_distinct(location_date) as days_with_gps
        ,approx_count_distinct(month(location_date)) as months_with_gps
    from ${SCHEMA}.dws_risk_mx_user_gps_base
    group by user_id, hex
) t
where days_with_gps >= 15
;

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_hex_feature;
create table ${SCHEMA}.dws_risk_mx_user_gps_hex_feature as
select
    t1.user_id
    ,a1.hex as hex1
    ,a1.days_with_gps as days_with_gps_1
    ,a1.months_with_gps as months_with_gps_1
    ,a1.gps_record_cnt as gps_record_cnt_1
    ,a2.hex as hex2
    ,a2.days_with_gps as days_with_gps_2
    ,a2.months_with_gps as months_with_gps_2
    ,a2.gps_record_cnt as gps_record_cnt_2
    ,a3.hex as hex3
    ,a3.days_with_gps as days_with_gps_3
    ,a3.months_with_gps as months_with_gps_3
    ,a3.gps_record_cnt as gps_record_cnt_3
from ${SCHEMA}.dws_risk_mx_user_gps_sample_feature t1
left join
(select * from ${SCHEMA}.dws_risk_mx_user_gps_hex_feature_pre where rank = 1) a1
on t1.user_id = a1.user_id
left join
(select * from ${SCHEMA}.dws_risk_mx_user_gps_hex_feature_pre where rank = 2) a2
on t1.user_id = a2.user_id
left join
(select * from ${SCHEMA}.dws_risk_mx_user_gps_hex_feature_pre where rank = 3) a3
on t1.user_id = a3.user_id
;

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_feature_detail;
create table ${SCHEMA}.dws_risk_mx_user_gps_feature_detail as
select
    user_id
    ,user_gps_cnt
    ,user_days_with_gps
    ,user_months_with_gps
    ,case when user_days_with_gps < 10 then -992001 else hex1 end as hex1
    ,case when user_days_with_gps < 10 then -992001 else days_with_gps_1 end as days_with_gps_1
    ,case when user_days_with_gps < 10 then -992001 else months_with_gps_1 end as months_with_gps_1
    ,case when user_days_with_gps < 10 then -992001 else gps_record_cnt_1 end as gps_record_cnt_1
    ,case when user_days_with_gps < 10 then -992001 else hex2 end as hex2
    ,case when user_days_with_gps < 10 then -992001 else days_with_gps_2 end as days_with_gps_2
    ,case when user_days_with_gps < 10 then -992001 else months_with_gps_2 end as months_with_gps_2
    ,case when user_days_with_gps < 10 then -992001 else gps_record_cnt_2 end as gps_record_cnt_2
    ,case when user_days_with_gps < 10 then -992001 else hex3 end as hex3
    ,case when user_days_with_gps < 10 then -992001 else days_with_gps_3 end as days_with_gps_3
    ,case when user_days_with_gps < 10 then -992001 else months_with_gps_3 end as months_with_gps_3
    ,case when user_days_with_gps < 10 then -992001 else gps_record_cnt_3 end as gps_record_cnt_3
    ,has_gps_record
    ,'MX' as grass_region
    ,date'${ds}' as grass_date
from
(
    select
        t1.user_id
        ,case when t3.has_gps_record = 1 then t1.user_gps_cnt else -991001 end as user_gps_cnt
        ,case when t3.has_gps_record = 1 then t1.user_days_with_gps else -991001 end as user_days_with_gps
        ,case when t3.has_gps_record = 1 then t1.user_months_with_gps else -991001 end as user_months_with_gps
        ,case when t3.has_gps_record = 1 then t2.hex1 else -991001 end as hex1
        ,case when t3.has_gps_record = 1 then t2.days_with_gps_1 else -991001 end as days_with_gps_1
        ,case when t3.has_gps_record = 1 then t2.months_with_gps_1 else -991001 end as months_with_gps_1
        ,case when t3.has_gps_record = 1 then t2.gps_record_cnt_1 else -991001 end as gps_record_cnt_1
        ,case when t3.has_gps_record = 1 then t2.hex2 else -991001 end as hex2
        ,case when t3.has_gps_record = 1 then t2.days_with_gps_2 else -991001 end as days_with_gps_2
        ,case when t3.has_gps_record = 1 then t2.months_with_gps_2 else -991001 end as months_with_gps_2
        ,case when t3.has_gps_record = 1 then t2.gps_record_cnt_2 else -991001 end as gps_record_cnt_2
        ,case when t3.has_gps_record = 1 then t2.hex3 else -991001 end as hex3
        ,case when t3.has_gps_record = 1 then t2.days_with_gps_3 else -991001 end as days_with_gps_3
        ,case when t3.has_gps_record = 1 then t2.months_with_gps_3 else -991001 end as months_with_gps_3
        ,case when t3.has_gps_record = 1 then t2.gps_record_cnt_3 else -991001 end as gps_record_cnt_3
        ,t3.has_gps_record
    from ${SCHEMA}.dws_risk_mx_user_gps_sample_feature t1
    left join ${SCHEMA}.dws_risk_mx_user_gps_hex_feature t2
        on t1.user_id = t2.user_id
    left join ${SCHEMA}.dws_risk_mx_user_gps_no_record t3
        on t1.user_id = t3.user_id
) t
;

drop table if exists ${SCHEMA}.dws_risk_mx_user_gps_feature_summary;
create table ${SCHEMA}.dws_risk_mx_user_gps_feature_summary as
select
    user_id
    ,if(hex_list = '' or hex_list is null, 'None',hex_list) as hex_list
from
    (
    select
        user_id
        ,concat_ws(',', if(hex1=-992001,null,hex1), if(hex2=-992001,null,hex2), if(hex3=-992001,null,hex3)) as hex_list
    from ${SCHEMA}.dws_risk_mx_user_gps_feature_detail
    ) t
;

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_user_frequency_gps_df PARTITION(tz_type='local', grass_region, grass_date)
select
    t1.user_id
    ,t1.user_gps_cnt
    ,t1.user_days_with_gps
    ,t1.user_months_with_gps
    ,t1.hex1
    ,t1.days_with_gps_1
    ,t1.months_with_gps_1
    ,t1.gps_record_cnt_1
    ,t1.hex2
    ,t1.days_with_gps_2
    ,t1.months_with_gps_2
    ,t1.gps_record_cnt_2
    ,t1.hex3
    ,t1.days_with_gps_3
    ,t1.months_with_gps_3
    ,t1.gps_record_cnt_3
    ,t1.has_gps_record
    ,t2.hex_list
    ,grass_region
    ,date'${ds}' as grass_date
from ${SCHEMA}.dws_risk_mx_user_gps_feature_detail t1
left join ${SCHEMA}.dws_risk_mx_user_gps_feature_summary t2
on t1.user_id = t2.user_id
;

create or replace view ${SCHEMA}.dws_risk_mx_user_frequency_gps_df as
select
    *
from ${SCHEMA}.dws_risk_user_frequency_gps_df
where
    grass_region = 'MX'
    and grass_date = '${grass_date}'
;