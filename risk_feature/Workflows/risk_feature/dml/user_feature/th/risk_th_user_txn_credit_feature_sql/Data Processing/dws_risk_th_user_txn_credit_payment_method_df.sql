-- =============================================================================
-- Author:              chenyingying
-- Created Time:        2026-01-16
-- Theme Domain:        User Txn Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-04 - chenyingying - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_payment_method_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_payment_method_df
(
    credit_user_id                                  string  comment 'credit user id'
    ,mp_buyer_id_array                              string  comment 'buyer id list of CsB user used SPL as payment method for MP COD order'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_payment_method_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_payment_method_df;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_payment_method_df partition (grass_date = '${ds}')
select  t1.credit_user_id
        ,coalesce(cast(t2.mp_buyer_id_array as string), '-9999') as mp_buyer_id_array
from (
    select
        credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${ds}'
        and credit_user_id <> ''
        and credit_user_id is not null
        and credit_user_id <> '0'
    group by credit_user_id
) t1
left join (
    select cast(cod_payer_credit_uid as string) as cod_payer_credit_uid
        ,collect_set(mp_buyer_id) mp_buyer_id_array
from smcdrisk_antifraud.monitor_cod_payment_th raw
where req_date <= '${ds}'
and mp_buyer_id is not null
group by 1
) t2
on t1.credit_user_id = t2.cod_payer_credit_uid
;

