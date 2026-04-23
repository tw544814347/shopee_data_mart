------------------------------------------------------------------------
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-02-03
-- Description:         用户行为主题域，SPP User Login主题
-- Data Granularity:    shopeepay user id 
-- PRD:                 
------------------------------------------------------------------------
set spark.sql.hive.convertMetastoreParquet=false;

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_ever_login_info_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_ever_login_info_df
(
    shopeepay_user_id string comment 'shopeepay_user_id' ,
    szdf_ever_login_1y string comment 'szdf_ever_login_1y' 
) 
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_spp_login_ever_login_info_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_ever_login_info_df;

-- ========== tmp4: 加盐去盐版本（物化表）==========
with tmp4 as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as szdf_ever_login_1y
    from (
        select 
            user_id
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
        from (
            select 
                regexp_replace(salted_user_id, '_salt_\\d+$', '') as user_id
                ,sz_dfp_device_id
            from (
                select 
                    concat(user_id, '_salt_', cast(floor(rand() * 100) as int)) as salted_user_id
                    ,sz_dfp_device_id
                from (
                    select
                        shopeepay_user_id as user_id
                        ,sz_dfp_device_id
                    from risk.dws_risk_user_sz_device_login_di 
                    where tz_type = 'local'
                        and grass_region = upper('${region}')
                        and grass_date >= date_sub(date('${grass_date}'), 365)
                        and grass_date <= date('${grass_date}')
                        and shopeepay_user_id is not null
                ) tmp_base
                distribute by cast(floor(rand() * 2000) as int)  -- 额外的数据打散
            ) tmp_salted
            group by salted_user_id, sz_dfp_device_id
        ) tmp_unsalt
        group by user_id
    ) t1
)

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_ever_login_info_df partition (grass_date = '${grass_date}')
select 
    a.user_id as shopeepay_user_id
    ,tmp4.szdf_ever_login_1y
from (
    select cast(shopeepay_user_id as string) as user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where grass_date = '${grass_date}'
) as a
left join tmp4 on a.user_id = tmp4.user_id
distribute by a.user_id