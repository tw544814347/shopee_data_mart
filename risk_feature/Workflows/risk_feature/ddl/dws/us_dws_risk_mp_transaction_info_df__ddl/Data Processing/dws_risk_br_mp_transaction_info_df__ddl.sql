drop table if exists ${SCHEMA}.dws_risk_${region}_mp_transaction_info_df; 
create external table if not exists ${SCHEMA}.dws_risk_${region}_mp_transaction_info_df (
     platform_user_id               string          comment 'shopee user id'
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
    ,cod_confirmed_order_l1d                        decimal(30, 10)       comment 'comfirmed cod order of user in last 1day'
    ,cod_confirmed_order_l30d                       decimal(30, 10)       comment 'comfirmed cod order of user in last 30day'
    ,cod_confirmed_order_l90d                       decimal(30, 10)       comment 'comfirmed cod order of user in last 90day'
    ,cod_confirmed_order_l180d                      decimal(30, 10)       comment 'comfirmed cod order of user in last 180day'
    ,cod_confirmed_order_l360d                      decimal(30, 10)       comment 'comfirmed cod order of user in last 360day'
    ,cod_confirmed_order_history                    decimal(30, 10)       comment 'comfirmed cod order of user in history'
    ,spl_confirmed_order_l1d            bigint       comment 'spl comfirmed order of user in last 1day'
    ,spl_confirmed_order_l30d           bigint       comment 'spl comfirmed order of user in last 30day'
    ,spl_confirmed_order_l90d           bigint       comment 'spl comfirmed order of user in last 90day'
    ,spl_confirmed_order_l180d          bigint       comment 'spl comfirmed order of user in last 180day'
    ,max_nmv_usd_l1d         decimal(30, 10)       comment 'Max confirmed order amount of user in last 1day'
    ,max_nmv_usd_l30d        decimal(30, 10)       comment 'Max confirmed order amount of user in last 30day'
    ,max_nmv_usd_l90d        decimal(30, 10)       comment 'Max confirmed order amount of user in last 90day'
    ,max_nmv_usd_l180d       decimal(30, 10)       comment 'Max confirmed order amount of user in last 180day'
    ,cc_nmv_usd_l1d                    decimal(30, 10)       comment 'CC Net Merchandise Value of user in last 1day'
    ,cc_nmv_usd_l30d                   decimal(30, 10)       comment 'CC Net Merchandise Value of user in last 30day'
    ,cc_nmv_usd_l90d                   decimal(30, 10)       comment 'CC Net Merchandise Value of user in last 90day'
    ,cc_nmv_usd_l180d                  decimal(30, 10)       comment 'CC Net Merchandise Value of user in last 180day'
    ,cci_nmv_usd_l1d                    decimal(30, 10)       comment 'CCI Net Merchandise Value of user in last 1day'
    ,cci_nmv_usd_l30d                   decimal(30, 10)       comment 'CCI Net Merchandise Value of user in last 30day'
    ,cci_nmv_usd_l90d                   decimal(30, 10)       comment 'CCI Net Merchandise Value of user in last 90day'
    ,cci_nmv_usd_l180d                  decimal(30, 10)       comment 'CCI Net Merchandise Value of user in last 180day'
    ,pix_nmv_usd_l1d                    decimal(30, 10)       comment 'pix Net Merchandise Value of user in last 1day'
    ,pix_nmv_usd_l30d                   decimal(30, 10)       comment 'pix Net Merchandise Value of user in last 30day'
    ,pix_nmv_usd_l90d                   decimal(30, 10)       comment 'pix Net Merchandise Value of user in last 90day'
    ,pix_nmv_usd_l180d                  decimal(30, 10)       comment 'pix Net Merchandise Value of user in last 180day'
    ,cc_max_nmv_usd_l1d         decimal(30, 10)       comment 'CC Max confirmed order amount of user in last 1day'
    ,cc_max_nmv_usd_l30d        decimal(30, 10)       comment 'CC Max confirmed order amount of user in last 30day'
    ,cc_max_nmv_usd_l90d        decimal(30, 10)       comment 'CC Max confirmed order amount of user in last 90day'
    ,cc_max_nmv_usd_l180d       decimal(30, 10)       comment 'CC Max confirmed order amount of user in last 180day'
    ,cci_max_nmv_usd_l1d         decimal(30, 10)       comment 'CCI Max confirmed order amount of user in last 1day'
    ,cci_max_nmv_usd_l30d        decimal(30, 10)       comment 'CCI Max confirmed order amount of user in last 30day'
    ,cci_max_nmv_usd_l90d        decimal(30, 10)       comment 'CCI Max confirmed order amount of user in last 90day'
    ,cci_max_nmv_usd_l180d       decimal(30, 10)       comment 'CCI Max confirmed order amount of user in last 180day'
    ,pix_max_nmv_usd_l1d         decimal(30, 10)       comment 'PIX Max confirmed order amount of user in last 1day'
    ,pix_max_nmv_usd_l30d        decimal(30, 10)       comment 'PIX Max confirmed order amount of user in last 30day'
    ,pix_max_nmv_usd_l90d        decimal(30, 10)       comment 'PIX Max confirmed order amount of user in last 90day'
    ,pix_max_nmv_usd_l180d       decimal(30, 10)       comment 'PIX Max confirmed order amount of user in last 180day'
)
partitioned by (
    grass_date string 
) 
stored as orc 
comment 'risk mp feature transction metrics pre-calculate summary table'
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)
location '${HDFS_PATH}/risk_feature/dws/dws_risk_mp_transaction_info_df/grass_region=${REGION}'
;
msck repair table ${SCHEMA}.dws_risk_${region}_mp_transaction_info_df
;