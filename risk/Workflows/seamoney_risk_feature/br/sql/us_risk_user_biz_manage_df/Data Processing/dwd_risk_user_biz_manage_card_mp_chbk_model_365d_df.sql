-- =============================================================================
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain:        Anti-Fraud
-- Data Granularity:    
-- Description:         业务侧透传表，落切片+DQC，落明细数据
-- Documents:           
-- =============================================================================

drop table if exists ${SCHEMA}.dwd_risk_user_biz_manage_card_mp_chbk_model_365d_df;
create external table if not exists ${SCHEMA}.dwd_risk_user_biz_manage_card_mp_chbk_model_365d_df (
    payment_channel_item_id BIGINT,
    max_cb_score_1day DOUBLE,
    max_cb_score_3day DOUBLE,
    max_cb_score_7day DOUBLE,
    max_cb_score_14day DOUBLE,
    max_cb_score_30day DOUBLE,
    max_cb_score_60day DOUBLE,
    max_cb_score_90day DOUBLE,
    max_cb_score_180day DOUBLE,
    max_cb_score_365day DOUBLE,
    cnt_1day BIGINT,
    cnt_3day BIGINT,
    cnt_7day BIGINT,
    cnt_14day BIGINT,
    cnt_30day BIGINT,
    cnt_60day BIGINT,
    cnt_90day BIGINT,
    cnt_180day BIGINT,
    cnt_365day BIGINT
)
partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk/BR/dwd/dwd_risk_user_biz_manage_card_mp_chbk_model_365d_df'
;
msck repair table ${SCHEMA}.dwd_risk_user_biz_manage_card_mp_chbk_model_365d_df;

insert overwrite table ${SCHEMA}.dwd_risk_user_biz_manage_card_mp_chbk_model_365d_df partition(grass_date = '${grass_date}')
select
*
from smcdrisk_antifraud.card_mp_chbk_model_365d
;