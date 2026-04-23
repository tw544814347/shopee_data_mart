DROP TABLE IF EXISTS risk.ads_risk_ph_aml_payer_account_list;
CREATE TABLE IF NOT EXISTS risk.ads_risk_ph_aml_payer_account_list
(
    payer_account string,
    related_user_count_1d bigint,
    related_user_count_3d bigint,
    related_user_count_7d bigint,
    related_user_count_14d bigint,
    related_user_list_1d string,
    related_user_list_3d string,
    related_user_list_7d string,
    related_user_list_14d string
)
stored as parquet tblproperties (
                                    "parquet.compress" = "SNAPPY",
                                    "parquet.stripe.size" = "2147483648"
                                )
;



DROP TABLE IF EXISTS risk.ads_risk_ph_aml_judge_result_by_userid;
CREATE TABLE IF NOT EXISTS risk.ads_risk_ph_aml_judge_result_by_userid
(
    rowkey  string,
    judge_result_7d bigint,
    judge_result_14d bigint
)
stored as parquet tblproperties (
                                    "parquet.compress" = "SNAPPY",
                                    "parquet.stripe.size" = "2147483648"
                                )
;
