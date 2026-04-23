------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-05-27
-- Description:         user_txn_bank_cap
-- Data Granularity:    platform_user_id
-- PRD:                    
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.dws_risk_vn_user_txn_bank_cap_df;
create external table if not exists ${SCHEMA}.dws_risk_vn_user_txn_bank_cap_df (
    platform_user_id string comment 'platform_user_id'
    ,spl_bank_cap bigint
    ,bcl_bank_cap bigint
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/dws/dws_risk_vn_user_txn_bank_cap_df'
;

--msck repair table ${SCHEMA}.dws_risk_vn_user_txn_bank_cap_df;
insert overwrite table ${SCHEMA}.dws_risk_vn_user_txn_bank_cap_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.spl_bank_cap
    ,t3.bcl_bank_cap
from
    (
        select
            user_id as platform_user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'VN'
            and grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,bank_cap as spl_bank_cap
        from smcdrisk_policy.vn_spl_bank_cap_df
        where
            grass_date = (
                select
                    max(grass_date)
                from smcdrisk_policy.vn_spl_bank_cap_df
            )
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,bank_cap as bcl_bank_cap
        from smcdrisk_policy.vn_bcl_bank_cap_df
        where
            grass_date = (
                select
                    max(grass_date)
                from smcdrisk_policy.vn_bcl_bank_cap_df
            )
    ) t3 on t1.platform_user_id = t3.platform_user_id
;