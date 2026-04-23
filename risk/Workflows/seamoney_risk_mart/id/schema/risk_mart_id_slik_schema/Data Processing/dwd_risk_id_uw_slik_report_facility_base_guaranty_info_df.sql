DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guaranty_info_df_temp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guaranty_info_df_temp
(
    credit_facility_info_id string,
    credit_collateral_address string,
    credit_collateral_issurance string,
    credit_collateral_proof_number string,
    credit_collateral_type string,
    credit_collateral_binding_type_code string,
    credit_collateral_binding_type string,
    credit_collateral_city_code string,
    credit_collateral_city string,
    credit_collateral_information string,
    credit_collateral_rating_company_code string,
    credit_collateral_rating_company string,
    credit_collateral_name string,
    credit_collateral_appraisal_agency string,
    credit_collateral_value string,
    credit_collateral_value_njop string,
    credit_collateral_number string,
    credit_collateral_rating string,
    credit_collateral_percentage string,
    credit_collateral_binding_date string,
    credit_collateral_appraisal_date string,
    credit_collateral_update_date string,
    credit_collateral_appraisal_agency_name string,
    credit_collateral_valuation_date string
)
comment 'ID SLIK report guaranty info snapshot table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_uw_slik_report_facility_base_guaranty_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guaranty_info_df_temp;
