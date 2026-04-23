--drop table if exists ${SCHEMA}.dws_risk_user_info_metrics_1_df;
create external table if not exists ${SCHEMA}.dws_risk_user_info_metrics_1_df
(
    user_id                              bigint               comment 'user_id'
    ,shop_id                             bigint               comment 'shop_id'
    ,shopee_registration_timestamp       bigint               comment 'shopee_registration_timestamp'
    ,shopee_loyalty                      string               comment 'shopee_loyalty'
    ,config_addr_list_td                 string               comment 'config_addr_list_td'
)
partitioned by
(
    grass_region   string   comment "grass_region"
    ,grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_info_metrics_1_df';
--msck repair table ${SCHEMA}.dws_risk_user_info_metrics_1_df;


create or replace temporary view user_table as
select
    t1.user_id
    ,t1.shop_id
    ,t1.shopee_registration_timestamp
    ,t2.shopee_loyalty
    ,t1.grass_region
from
(
    select
        user_id
        ,shop_id
        ,registration_timestamp as shopee_registration_timestamp
        ,grass_region
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date = date('${bizdate}')
) t1
left join
(
    select
        user_id
        ,case
            when loyalty_tier = 10 then 'classic'
            when loyalty_tier = 20 then 'silver'
            when loyalty_tier = 30 then 'gold'
            when loyalty_tier = 40 then 'platinum'
            when loyalty_tier = 0 then 'error'
            else 'classic'
        end as shopee_loyalty
        ,grass_region
    from mp_user.dim_user_ext__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date('${bizdate}')
) t2
on t1.grass_region = t2.grass_region
and t1.user_id = t2.user_id
;

create or replace temporary view config_address as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(trim(regexp_replace(config_address, ',', '')))) as config_addr_list_td
from ${SCHEMA}.dim_risk_user_address_df
where tz_type='local'
  and grass_region = upper('${region}')
  and grass_date = date('${bizdate}')
  and trim(regexp_replace(config_address, ',', '')) <> ''
  and (is_valid = 'Y'
    or (is_valid = 'N'
        and modified_time <= unix_timestamp(date('${bizdate}'))
        and modified_time > unix_timestamp(date('${bizdate}')- interval 90 day)
        )
    )
group by
    user_id
    ,grass_region
having config_addr_list_td <> ''
;

insert overwrite table ${SCHEMA}.dws_risk_user_info_metrics_1_df partition (grass_region, grass_date)
select
    t1.user_id
    ,t1.shop_id
    ,t1.shopee_registration_timestamp
    ,t1.shopee_loyalty
    ,t2.config_addr_list_td
    ,t1.grass_region
    ,'${bizdate}' as grass_date
from user_table t1
left join config_address t2
on t1.grass_region = t2.grass_region
and t1.user_id = t2.user_id
;

create or replace view ${SCHEMA}.dws_risk_${region}_user_info_metrics_1_df as
select
    *
from ${SCHEMA}.dws_risk_user_info_metrics_1_df
where
    grass_region = upper('${region}')
;