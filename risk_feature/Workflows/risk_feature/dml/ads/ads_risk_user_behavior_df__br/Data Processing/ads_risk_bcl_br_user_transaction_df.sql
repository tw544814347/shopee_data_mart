-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: ads_risk_bcl_br_user_transactions_df
-- ** Create Author|创建人: jialiang.nie
-- ** Create time|创建日期: 2025-12-03
-- ** Modified log|修改日志:
-- **             修改日期: 2025-12-03  修改人:jialiang.nie  修改内容: 新增BCL表，空表，为了下游union表匹配的上
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************

-- drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_transaction_df ;
create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_transaction_df 
(
    credit_user_id                              string comment 'unique credit user id',
    biz_type                                    bigint comment 'Dimension, 1:BCL;2:SCL;3:SPL;4:FES;7:SPLX;8:CPL;11:TL;12:SVL;13:SCF',
    combine_payment_cnt_td                      bigint comment 'history combined payment order cnt',
    combine_payment_amount_td                   decimal(30,10) comment 'history combined payment total amount',
    combine_payment_spl_amount_td               decimal(30,10) comment 'history combined payment spl amount',
    combine_payment_cci_amount_td               decimal(30,10) comment 'history combined payment cci amount',
    combine_payment_pix_amount_td               decimal(30,10) comment 'history combined payment pix amount',
    combine_payment_wallet_amount_td            decimal(30,10) comment 'history combined payment wallet amount',
    combine_payment_cnt_30d                    bigint comment 'last 30d combined payment order cnt',
    combine_payment_amount_30d                 decimal(30,10) comment 'last 30dcombined payment total amount',
    combine_payment_spl_amount_30d             decimal(30,10) comment 'last 30dcombined payment spl amount',
    combine_payment_cci_amount_30d             decimal(30,10) comment 'last 30d combined payment cci amount',
    combine_payment_pix_amount_30d             decimal(30,10) comment 'last 30dcombined payment pix amount',
    combine_payment_wallet_amount_30d          decimal(30,10) comment 'last 30dcombined payment wallet amount',
    combine_payment_cnt_90d                    bigint comment 'last 90d combined payment order cnt',
    combine_payment_amount_90d                 decimal(30,10) comment 'last 90d combined payment total amount',
    combine_payment_spl_amount_90d             decimal(30,10) comment 'last 90d combined payment spl amount',
    combine_payment_cci_amount_90d             decimal(30,10) comment 'last 90d combined payment cci amount', 
    combine_payment_pix_amount_90d             decimal(30,10) comment 'last 90d combined payment pix amount',
    combine_payment_wallet_amount_90d          decimal(30,10) comment 'last 90d combined payment wallet amount',
    combine_payment_cnt_180d                   bigint comment 'last 180d combined payment order cnt',
    combine_payment_amount_180d                decimal(30,10) comment 'last 180d combined payment total amount',
    combine_payment_spl_amount_180d            decimal(30,10) comment 'last 180d combined payment spl amount',    
    combine_payment_cci_amount_180d            decimal(30,10) comment 'last 180d combined payment cci amount',    
    combine_payment_pix_amount_180d            decimal(30,10) comment 'last 180d combined payment pix amount',
    combine_payment_wallet_amount_180d         decimal(30,10) comment 'last 180d combined payment wallet amount',
    combine_payment_cnt_360d                   bigint comment 'last 360d combined payment order cnt',
    combine_payment_amount_360d                decimal(30,10) comment 'last 360d combined payment total amount',
    combine_payment_spl_amount_360d            decimal(30,10) comment 'last 360d combined payment spl amount',
    combine_payment_cci_amount_360d            decimal(30,10) comment 'last 360d combined payment cci amount',
    combine_payment_pix_amount_360d            decimal(30,10) comment 'last 360d combined payment pix amount',
    combine_payment_wallet_amount_360d         decimal(30,10) comment 'last 360d combined payment wallet amount'
)
partitioned by
(
    grass_date string comment 'Full Daily Partition'
) 
comment 'credit mart summary table'
stored as orc tblproperties ("orc.compress" = "SNAPPY", "orc.stripe.size" = "64000000") 
location '${HDFS_PATH}/ads/ads_risk_${table_product}_${table_region}_user_transaction_df/grass_region=${region}'
;
