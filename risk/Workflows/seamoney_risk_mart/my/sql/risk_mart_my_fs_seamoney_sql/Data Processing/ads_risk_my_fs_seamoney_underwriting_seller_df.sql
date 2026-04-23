--drop table if exists ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_seller_df;
create external table if not exists ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_seller_df (
    shop_id string
    ,platform_user_id string
    ,is_seller_active bigint
    ,gmv_shipout_normal_pmt_30d double
    ,escrow_normal_pmt_30d double
    ,gmv_shipout_normal_pmt_31_60d double
    ,escrow_normal_pmt_31_60d double
    ,gmv_shipout_normal_pmt_61_90d double
    ,escrow_normal_pmt_61_90d double
    ,gmv_shipout_normal_pmt_91_120d double
    ,escrow_normal_pmt_91_120d double
    ,gmv_shipout_normal_pmt_121_150d double
    ,escrow_normal_pmt_121_150d double
    ,gmv_shipout_normal_pmt_151_180d double
    ,escrow_normal_pmt_151_180d double
    ,gmv_shipout_cod_pmt_30d double
    ,escrow_cod_pmt_30d double
    ,gmv_shipout_cod_pmt_31_60d double
    ,escrow_cod_pmt_31_60d double
    ,gmv_shipout_cod_pmt_61_90d double
    ,escrow_cod_pmt_61_90d double
    ,gmv_shipout_cod_pmt_91_120d double
    ,escrow_cod_pmt_91_120d double
    ,gmv_shipout_cod_pmt_121_150d double
    ,escrow_cod_pmt_121_150d double
    ,gmv_shipout_cod_pmt_151_180d double
    ,escrow_cod_pmt_151_180d double
    ,txn_shipout_normal_pmt_30d bigint
    ,txn_escrow_normal_pmt_30d bigint
    ,txn_shipout_normal_pmt_31_60d bigint
    ,txn_escrow_normal_pmt_31_60d bigint
    ,txn_shipout_normal_pmt_61_90d bigint
    ,txn_escrow_normal_pmt_61_90d bigint
    ,txn_shipout_normal_pmt_91_120d bigint
    ,txn_escrow_normal_pmt_91_120d bigint
    ,txn_shipout_normal_pmt_121_150d bigint
    ,txn_escrow_normal_pmt_121_150d bigint
    ,txn_shipout_normal_pmt_151_180d bigint
    ,txn_escrow_normal_pmt_151_180d bigint
    ,txn_shipout_cod_pmt_30d bigint
    ,txn_escrow_cod_pmt_30d bigint
    ,txn_shipout_cod_pmt_31_60d bigint
    ,txn_escrow_cod_pmt_31_60d bigint
    ,txn_shipout_cod_pmt_61_90d bigint
    ,txn_escrow_cod_pmt_61_90d bigint
    ,txn_shipout_cod_pmt_91_120d bigint
    ,txn_escrow_cod_pmt_91_120d bigint
    ,txn_shipout_cod_pmt_121_150d bigint
    ,txn_escrow_cod_pmt_121_150d bigint
    ,txn_shipout_cod_pmt_151_180d bigint
    ,txn_escrow_cod_pmt_151_180d bigint
    ,first_sales_date string
    ,is_eligible_12m int
    ,days_has_txn_30days bigint
    ,days_has_txn_90days bigint
    ,days_has_txn_180days bigint
    ,days_has_txn_360days bigint
    ,daily_avg_escrow double
    ,daily_escrow_percentile50 double
    ,daily_escrow_percentile75 double
    ,daily_escrow_percentile90 double
    ,spl_max_dpd_l1m bigint comment 'last 1 months spl max dpd'
    ,spl_max_dpd_l2m bigint comment 'last 2 months spl max dpd'
    ,spl_max_dpd_l3m bigint comment 'last 3 months spl max dpd'
    ,spl_max_dpd_l6m bigint comment 'last 6 months spl max dpd'
    ,spl_max_dpd_l12m bigint comment 'last 12 months spl max dpd'
    ,sl_max_dpd_l1m bigint comment 'last 1 months sl max dpd'
    ,sl_max_dpd_l2m bigint comment 'last 2 months sl max dpd'
    ,sl_max_dpd_l3m bigint comment 'last 3 months sl max dpd'
    ,sl_max_dpd_l6m bigint comment 'last 6 months sl max dpd'
    ,sl_max_dpd_l12m bigint comment 'last 12 months sl max dpd'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_underwriting_seller_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_seller_df;

insert overwrite table
    ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_seller_df partition (grass_date = '${grass_date}')
select
    t1.shop_id
    ,t1.platform_user_id
    ,t1.is_seller_active
    ,t2.gmv_shipout_normal_pmt_30d
    ,t2.escrow_normal_pmt_30d
    ,t2.gmv_shipout_normal_pmt_31_60d
    ,t2.escrow_normal_pmt_31_60d
    ,t2.gmv_shipout_normal_pmt_61_90d
    ,t2.escrow_normal_pmt_61_90d
    ,t2.gmv_shipout_normal_pmt_91_120d
    ,t2.escrow_normal_pmt_91_120d
    ,t2.gmv_shipout_normal_pmt_121_150d
    ,t2.escrow_normal_pmt_121_150d
    ,t2.gmv_shipout_normal_pmt_151_180d
    ,t2.escrow_normal_pmt_151_180d
    ,t2.gmv_shipout_cod_pmt_30d
    ,t2.escrow_cod_pmt_30d
    ,t2.gmv_shipout_cod_pmt_31_60d
    ,t2.escrow_cod_pmt_31_60d
    ,t2.gmv_shipout_cod_pmt_61_90d
    ,t2.escrow_cod_pmt_61_90d
    ,t2.gmv_shipout_cod_pmt_91_120d
    ,t2.escrow_cod_pmt_91_120d
    ,t2.gmv_shipout_cod_pmt_121_150d
    ,t2.escrow_cod_pmt_121_150d
    ,t2.gmv_shipout_cod_pmt_151_180d
    ,t2.escrow_cod_pmt_151_180d
    ,t2.txn_shipout_normal_pmt_30d
    ,t2.txn_escrow_normal_pmt_30d
    ,t2.txn_shipout_normal_pmt_31_60d
    ,t2.txn_escrow_normal_pmt_31_60d
    ,t2.txn_shipout_normal_pmt_61_90d
    ,t2.txn_escrow_normal_pmt_61_90d
    ,t2.txn_shipout_normal_pmt_91_120d
    ,t2.txn_escrow_normal_pmt_91_120d
    ,t2.txn_shipout_normal_pmt_121_150d
    ,t2.txn_escrow_normal_pmt_121_150d
    ,t2.txn_shipout_normal_pmt_151_180d
    ,t2.txn_escrow_normal_pmt_151_180d
    ,t2.txn_shipout_cod_pmt_30d
    ,t2.txn_escrow_cod_pmt_30d
    ,t2.txn_shipout_cod_pmt_31_60d
    ,t2.txn_escrow_cod_pmt_31_60d
    ,t2.txn_shipout_cod_pmt_61_90d
    ,t2.txn_escrow_cod_pmt_61_90d
    ,t2.txn_shipout_cod_pmt_91_120d
    ,t2.txn_escrow_cod_pmt_91_120d
    ,t2.txn_shipout_cod_pmt_121_150d
    ,t2.txn_escrow_cod_pmt_121_150d
    ,t2.txn_shipout_cod_pmt_151_180d
    ,t2.txn_escrow_cod_pmt_151_180d
    ,t2.first_sales_date
    ,t2.is_eligible_12m
    ,t2.days_has_txn_30days
    ,t2.days_has_txn_90days
    ,t2.days_has_txn_180days
    ,t2.days_has_txn_360days
    ,t2.daily_avg_escrow
    ,t2.daily_escrow_percentile50
    ,t2.daily_escrow_percentile75
    ,t2.daily_escrow_percentile90
    ,t3.spl_max_dpd_l1m
    ,t3.spl_max_dpd_l2m
    ,t3.spl_max_dpd_l3m
    ,t3.spl_max_dpd_l6m
    ,t3.spl_max_dpd_l12m
    ,t3.sl_max_dpd_l1m
    ,t3.sl_max_dpd_l2m
    ,t3.sl_max_dpd_l3m
    ,t3.sl_max_dpd_l6m
    ,t3.sl_max_dpd_l12m
from
    (
        select
            shop_id
            ,user_id as platform_user_id
            ,1 as is_seller_active
        from mp_user.dim_shop__my_s0_live
        where
            tz_type = 'local'
            and grass_date = '${grass_date}'
            and shop_id <> 0
    ) t1
    left join (
        select
            shop_id
            ,gmv_shipout_normal_pmt_30d
            ,escrow_normal_pmt_30d
            ,gmv_shipout_normal_pmt_31_60d
            ,escrow_normal_pmt_31_60d
            ,gmv_shipout_normal_pmt_61_90d
            ,escrow_normal_pmt_61_90d
            ,gmv_shipout_normal_pmt_91_120d
            ,escrow_normal_pmt_91_120d
            ,gmv_shipout_normal_pmt_121_150d
            ,escrow_normal_pmt_121_150d
            ,gmv_shipout_normal_pmt_151_180d
            ,escrow_normal_pmt_151_180d
            ,gmv_shipout_cod_pmt_30d
            ,escrow_cod_pmt_30d
            ,gmv_shipout_cod_pmt_31_60d
            ,escrow_cod_pmt_31_60d
            ,gmv_shipout_cod_pmt_61_90d
            ,escrow_cod_pmt_61_90d
            ,gmv_shipout_cod_pmt_91_120d
            ,escrow_cod_pmt_91_120d
            ,gmv_shipout_cod_pmt_121_150d
            ,escrow_cod_pmt_121_150d
            ,gmv_shipout_cod_pmt_151_180d
            ,escrow_cod_pmt_151_180d
            ,txn_shipout_normal_pmt_30d
            ,txn_escrow_normal_pmt_30d
            ,txn_shipout_normal_pmt_31_60d
            ,txn_escrow_normal_pmt_31_60d
            ,txn_shipout_normal_pmt_61_90d
            ,txn_escrow_normal_pmt_61_90d
            ,txn_shipout_normal_pmt_91_120d
            ,txn_escrow_normal_pmt_91_120d
            ,txn_shipout_normal_pmt_121_150d
            ,txn_escrow_normal_pmt_121_150d
            ,txn_shipout_normal_pmt_151_180d
            ,txn_escrow_normal_pmt_151_180d
            ,txn_shipout_cod_pmt_30d
            ,txn_escrow_cod_pmt_30d
            ,txn_shipout_cod_pmt_31_60d
            ,txn_escrow_cod_pmt_31_60d
            ,txn_shipout_cod_pmt_61_90d
            ,txn_escrow_cod_pmt_61_90d
            ,txn_shipout_cod_pmt_91_120d
            ,txn_escrow_cod_pmt_91_120d
            ,txn_shipout_cod_pmt_121_150d
            ,txn_escrow_cod_pmt_121_150d
            ,txn_shipout_cod_pmt_151_180d
            ,txn_escrow_cod_pmt_151_180d
            ,first_sales_date
            ,is_eligible_12m
            ,days_has_txn_30days
            ,days_has_txn_90days
            ,days_has_txn_180days
            ,days_has_txn_360days
            ,daily_avg_escrow
            ,daily_escrow_percentile50
            ,daily_escrow_percentile75
            ,daily_escrow_percentile90
        from ${SCHEMA}.dws_risk_my_shop_escrow_txn_df
        where grass_date = '${grass_date}'
    ) t2 on t1.shop_id = t2.shop_id
    left join (
        select
            shop_id
            ,spl_max_dpd_l1m
            ,spl_max_dpd_l2m
            ,spl_max_dpd_l3m
            ,spl_max_dpd_l6m
            ,spl_max_dpd_l12m
            ,sl_max_dpd_l1m
            ,sl_max_dpd_l2m
            ,sl_max_dpd_l3m
            ,sl_max_dpd_l6m
            ,sl_max_dpd_l12m
        from ${SCHEMA}.dws_risk_my_user_txn_fp_repayment_df
        where grass_date = '${grass_date}'
    ) t3 on t1.shop_id = t3.shop_id
;