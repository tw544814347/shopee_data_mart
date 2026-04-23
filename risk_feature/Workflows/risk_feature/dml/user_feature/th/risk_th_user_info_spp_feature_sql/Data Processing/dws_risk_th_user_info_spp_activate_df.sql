-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-01-22
-- Theme Domain:        User Base Info SPP Activate Feature
-- Data Granularity:    shopeepay_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-19 - chenyingying - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_spp_activate_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_spp_activate_df
(
    shopeepay_user_id                           string comment 'shopeepay user id'
    ,latest_spl_th_activation_till_now_days     bigint comment 'latest spl activation time'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_spp_activate_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_spp_activate_df;


insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_spp_activate_df partition(grass_date='${ds}')
select t1.shopeepay_user_id
        ,coalesce(t2.latest_spl_th_activation_till_now_days, -9999) as latest_spl_th_activation_till_now_days
from (
    select  shopeepay_user_id
    from    shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where   grass_date = '${ds}'
) t1
left join (
    select  shopeepay_user_id
            ,max(
                case    when reactivate_time is not null then datediff('${ds}',to_date(reactivate_time))
                        else datediff('${ds}',to_date(activation_time)) end
            )   as latest_spl_th_activation_till_now_days
    from (
        select  spp_user_id as shopeepay_user_id
                ,reactivate_time
                ,activation_time
        from    credit_uc.dws_spl_${region}_uc_user_df
        where   grass_date = '${ds}'
    ) tt2
    group   by shopeepay_user_id
) t2
on t1.shopeepay_user_id = t2.shopeepay_user_id
