--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_login_szdf_device_user_agg_df (
    sz_dfp_device_id                       STRING         COMMENT 'sz_dfp_device_id',

    cnt_user_l3m                           BIGINT         COMMENT 'cnt distinct users in last 3 months',
    cnt_user_l1m                           BIGINT         COMMENT 'cnt distinct users in last 1 month',
    cnt_user_l10d                          BIGINT         COMMENT 'cnt distinct users in last 10 days',
    cnt_user_login_3d                      BIGINT         COMMENT 'cnt users with login days <=3 in last 3 months',
    cnt_user_login_2d                      BIGINT         COMMENT 'cnt users with login days <=2 in last 3 months',
    cnt_user_login_1d                      BIGINT         COMMENT 'cnt users with login days <=1 in last 3 months'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_${reg}_aio_login_szdf_device_user_agg_df/product_id = ${biz_type_code}'
;


create or replace temp view szdf_base_data as (
    select  distinct 
            user_id
            ,sz_dfp_device_id
            ,grass_date
    from    risk.dwd_risk_szdf_login_di
    where   grass_region = upper('${reg}')
      and   tz_type = 'local'
      and   grass_date >= '${ds_t_720}' and grass_date <= '${ds}'
      and   sz_dfp_device_id <> '' and   sz_dfp_device_id is not null
);
create or replace temp view df as (
    select  sz_dfp_device_id
            ,count(distinct case when grass_date >= '${ds_t_90}' then user_id end) as cnt_user_l3m
            ,count(distinct case when grass_date >= '${ds_t_30}' then user_id end) as cnt_user_l1m
            ,count(distinct case when grass_date >= '${ds_t_10}' then user_id end) as cnt_user_l10d
    from    szdf_base_data
    where   grass_date >= '${ds_t_90}'
    group by sz_dfp_device_id
);
create or replace temp view df_uid as (
    select  user_id
            ,sz_dfp_device_id
            ,count(distinct grass_date) as cnt_login_days_l3m
    from    szdf_base_data
    where   grass_date >= '${ds_t_90}'
    group by user_id, sz_dfp_device_id
    having count(distinct grass_date) <= 3
);
create or replace temp view df_agg as (
    select  sz_dfp_device_id
            ,count(distinct user_id) as cnt_user_login_3d
            ,count(distinct case when cnt_login_days_l3m <= 2 then user_id end) as cnt_user_login_2d
            ,count(distinct case when cnt_login_days_l3m <= 1 then user_id end) as cnt_user_login_1d
    from    df_uid
    group by sz_dfp_device_id
);
create or replace temp view df_uid_login_agg as (
    select  df.sz_dfp_device_id
            ,df.cnt_user_l3m as cnt_user_l3m
            ,df.cnt_user_l1m as cnt_user_l1m
            ,df.cnt_user_l10d as cnt_user_l10d
            ,agg.cnt_user_login_3d as cnt_user_login_3d
            ,agg.cnt_user_login_2d as cnt_user_login_2d
            ,agg.cnt_user_login_1d as cnt_user_login_1d
    from    df 
    left join df_agg agg 
        on df.sz_dfp_device_id = agg.sz_dfp_device_id
);

 
insert overwrite table ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_login_szdf_device_user_agg_df partition(grass_date = '${ds}')
select 
  df_uid_login_agg.sz_dfp_device_id as sz_dfp_device_id
  ,cnt_user_l3m
  ,cnt_user_l1m
  ,cnt_user_l10d
  ,cnt_user_login_3d
  ,cnt_user_login_2d
  ,cnt_user_login_1d
from df_uid_login_agg
DISTRIBUTE BY df_uid_login_agg.sz_dfp_device_id
;
