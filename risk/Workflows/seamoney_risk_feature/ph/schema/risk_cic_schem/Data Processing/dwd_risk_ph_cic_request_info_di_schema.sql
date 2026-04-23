DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_ph_cic_request_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_ph_cic_request_info_di
(
  platform_user_id     string comment'shop id',
  application_currency STRING,
  application_contractrequeststring string,
  application_contractphase STRING,
  application_contracttype STRING,
  application_noninstallment_creditlimit string,
  miaddress STRING,
  aiaddress STRING,
  link_role STRING,
  applicationcodes_providerapplicationno STRING,
  applicationcodes_providercontractno STRING,
  applicationcodes_cbcontractcode STRING,
  link_companyrole STRING,
  subject_individual_birthdata_string string,
  subject_individual_contact_type STRING,
  subject_individual_contact_value STRING,
  subject_individual_generaldataindividual_gender STRING,
  subject_individual_id_number STRING,
  subject_individual_id_type STRING,
  subject_individual_identificationcode_number STRING,
  subject_individual_identificationcode_type STRING,
  subject_individual_individualname_firstname STRING,
  subject_individual_individualname_lastname STRING,
  scene_id string ,
  tn string
)
PARTITIONED BY
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_feature/dwd/dwd_risk_ph_cic_request_info_di/grass_region=PH';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_cic_request_info_di;
