drop table if exists ${SCHEMA}.dws_risk_${region}_mp_feature_mid_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_mp_feature_mid_df (
     platform_user_id               string          comment 'shopee user id'
    ,shopee_age                     int          comment 'User registration days'
    ,is_phone_verified              int          comment 'Whether phone number is verified'
    ,is_a30                         int          comment 'Whether user has logged in Shopee APP in the last 30days'
    ,is_a90                         int          comment 'Whether user has logged in Shopee APP in the last 90days'
    ,is_a180                        int          comment 'Whether user has logged in Shopee APP in the last 180days'
    ,is_a360                        int          comment 'Whether user has logged in Shopee APP in the last 360days'
    ,shopee_user_status             string          comment 'shopee account status name'
    ,confirmed_order_l1d            bigint       comment 'comfirmed order of user in last 1day'
    ,confirmed_order_l30d           bigint       comment 'comfirmed order of user in last 30days'
    ,confirmed_order_l90d           bigint       comment 'comfirmed order of user in last 90days'
    ,confirmed_order_l180d          bigint       comment 'comfirmed order of user in last 180days'
    ,confirmed_order_l360d          bigint       comment 'comfirmed order of user in last 360days'
    ,confirmed_order_history        bigint       comment 'comfirmed order of user in history'
    ,nmv_usd_l1d                    decimal(30, 10)       comment 'Net Merchandise Value of user in last 1day'
    ,nmv_usd_l30d                   decimal(30, 10)       comment 'Net Merchandise Value of user in last 30day'
    ,nmv_usd_l90d                   decimal(30, 10)       comment 'Net Merchandise Value of user in last 90day'
    ,nmv_usd_l180d                  decimal(30, 10)       comment 'Net Merchandise Value of user in last 180day'
    ,nmv_usd_l360d                  decimal(30, 10)       comment 'Net Merchandise Value of user in last 360day'
    ,nmv_usd_history                decimal(30, 10)       comment 'Net Merchandise Value of user in history'
    ,spl_nmv_usd_l1d                    decimal(30, 10)       comment 'SPL Net Merchandise Value of user in last 1day'
    ,spl_nmv_usd_l30d                   decimal(30, 10)       comment 'SPL Net Merchandise Value of user in last 30day'
    ,spl_nmv_usd_l90d                   decimal(30, 10)       comment 'SPL Net Merchandise Value of user in last 90day'
    ,spl_nmv_usd_l180d                  decimal(30, 10)       comment 'SPL Net Merchandise Value of user in last 180day'
    ,spl_nmv_usd_l360d                  decimal(30, 10)       comment 'SPL Net Merchandise Value of user in last 360day'
    ,spl_nmv_usd_history                decimal(30, 10)       comment 'SPL Net Merchandise Value of user in history'
    ,abs_usd_l1d                        decimal(30, 10)       comment 'abs_usd_l1d'
    ,abs_usd_l30d                       decimal(30, 10)       comment 'abs_usd_l30d'
    ,abs_usd_l90d                       decimal(30, 10)       comment 'abs_usd_l90d'
    ,abs_usd_l180d                      decimal(30, 10)       comment 'abs_usd_l180d'
    ,abs_usd_l360d                      decimal(30, 10)       comment 'abs_usd_l360d'
    ,abs_usd_history                    decimal(30, 10)       comment 'abs_usd_history'
    ,pct_cod_l1d                        decimal(30, 10)       comment 'Percent of COD orders in last 1day'
    ,pct_cod_l30d                       decimal(30, 10)       comment 'Percent of COD orders in last 30days'
    ,pct_cod_l90d                       decimal(30, 10)       comment 'Percent of COD orders in last 90days'
    ,pct_cod_l180d                      decimal(30, 10)       comment 'Percent of COD orders in last 180days'
    ,pct_cod_l360d                      decimal(30, 10)       comment 'Percent of COD orders in last 360days'
    ,pct_cod_history                    decimal(30, 10)       comment 'Percent of COD orders in history'
)
partitioned by (
    grass_date string 
) 
stored as orc 
comment 'risk mp feature summary table'
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)
location '${HDFS_PATH}/risk_feature/dws/dws_risk_mp_feature_mid_df/grass_region=${REGION}'
;
msck repair table ${SCHEMA}.dws_risk_${region}_mp_feature_mid_df
;