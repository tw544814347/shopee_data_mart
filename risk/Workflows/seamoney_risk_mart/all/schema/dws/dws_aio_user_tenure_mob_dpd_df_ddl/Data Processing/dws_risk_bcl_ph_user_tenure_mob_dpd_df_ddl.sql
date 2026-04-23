drop table if exists ${SCHEMA}.dws_risk_${product}_${region}_user_tenure_mob_dpd_df;

create external table if not exists ${SCHEMA}.dws_risk_${product}_${region}_user_tenure_mob_dpd_df
(
    platform_user_id string comment ""
    ,credit_user_id string comment ""
    ,loan_tenure bigint comment "loan tenure" 
    ,dpd_bucket string comment "cassified bucket by dpd days"
    ,mob1_dpd_bucket string comment "The dpd bucket in mob1"
    ,mob2_dpd_bucket string comment "The dpd bucket in mob2"
    ,mob3_dpd_bucket string comment "The dpd bucket in mob3"
    ,mob4_dpd_bucket string comment "The dpd bucket in mob4"
    ,mob5_dpd_bucket string comment "The dpd bucket in mob5"
    ,mob6_dpd_bucket string comment "The dpd bucket in mob6"
    ,mob7_dpd_bucket string comment "The dpd bucket in mob7"
    ,mob8_dpd_bucket string comment "The dpd bucket in mob8"
    ,mob9_dpd_bucket string comment "The dpd bucket in mob9"
    ,mob10_dpd_bucket string comment "The dpd bucket in mob10"
    ,mob11_dpd_bucket string comment "The dpd bucket in mob11"
    ,mob12_dpd_bucket string comment "The dpd bucket in mob12"

    ,principal_os decimal(30,10) comment "principal outstanding"
    ,mob1_principal_os decimal(30,10) comment "principal outstanding"
    ,mob2_principal_os decimal(30,10) comment "principal outstanding"
    ,mob3_principal_os decimal(30,10) comment "principal outstanding"
    ,mob4_principal_os decimal(30,10) comment "principal outstanding"
    ,mob5_principal_os decimal(30,10) comment "principal outstanding"
    ,mob6_principal_os decimal(30,10) comment "principal outstanding"
    ,mob7_principal_os decimal(30,10) comment "principal outstanding in mob7"
    ,mob8_principal_os decimal(30,10) comment "principal outstanding in mob8"
    ,mob9_principal_os decimal(30,10) comment "principal outstanding in mob9"
    ,mob10_principal_os decimal(30,10) comment "principal outstanding in mob10"
    ,mob11_principal_os decimal(30,10) comment "principal outstanding in mob11"
    ,mob12_principal_os decimal(30,10) comment "principal outstanding in mob12"

    ,mob1_dpd decimal(30,10) comment "The principal_os in mob1"
    ,mob2_dpd decimal(30,10) comment "The principal_os in mob2"
    ,mob3_dpd decimal(30,10) comment "The principal_os in mob3"
    ,mob4_dpd decimal(30,10) comment "The principal_os in mob4"
    ,mob5_dpd decimal(30,10) comment "The principal_os in mob5"
    ,mob6_dpd decimal(30,10) comment "The principal_os in mob6"
    ,mob7_dpd decimal(30,10) comment "The principal_os in mob7"
    ,mob8_dpd decimal(30,10) comment "The principal_os in mob8"
    ,mob9_dpd decimal(30,10) comment "The principal_os in mob9"
    ,mob10_dpd decimal(30,10) comment "The principal_os in mob10"
    ,mob11_dpd decimal(30,10) comment "The principal_os in mob11"
    ,mob12_dpd decimal(30,10) comment "The principal_os in mob12"

    ,interest_repayable         decimal(30,10) comment "The interest_repayable"
    ,mob1_interest_repayable    decimal(30,10) comment "The interest_repayable in mob1"
    ,mob2_interest_repayable    decimal(30,10) comment "The interest_repayable in mob2"
    ,mob3_interest_repayable    decimal(30,10) comment "The interest_repayable in mob3"
    ,mob4_interest_repayable    decimal(30,10) comment "The interest_repayable in mob4"
    ,mob5_interest_repayable    decimal(30,10) comment "The interest_repayable in mob5"
    ,mob6_interest_repayable    decimal(30,10) comment "The interest_repayable in mob6"
    ,mob7_interest_repayable    decimal(30,10) comment "The interest_repayable in mob7"
    ,mob8_interest_repayable    decimal(30,10) comment "The interest_repayable in mob8"
    ,mob9_interest_repayable    decimal(30,10) comment "The interest_repayable in mob9"
    ,mob10_interest_repayable   decimal(30,10) comment "The interest_repayable in mob10"
    ,mob11_interest_repayable   decimal(30,10) comment "The interest_repayable in mob11"
    ,mob12_interest_repayable   decimal(30,10) comment "The interest_repayable in mob12"

    ,interest_repaid         decimal(30,10) comment "The interest_repaid"
    ,mob1_interest_repaid    decimal(30,10) comment "The interest_repaid in mob1"
    ,mob2_interest_repaid    decimal(30,10) comment "The interest_repaid in mob2"
    ,mob3_interest_repaid    decimal(30,10) comment "The interest_repaid in mob3"
    ,mob4_interest_repaid    decimal(30,10) comment "The interest_repaid in mob4"
    ,mob5_interest_repaid    decimal(30,10) comment "The interest_repaid in mob5"
    ,mob6_interest_repaid    decimal(30,10) comment "The interest_repaid in mob6"
    ,mob7_interest_repaid    decimal(30,10) comment "The interest_repaid in mob7"
    ,mob8_interest_repaid    decimal(30,10) comment "The interest_repaid in mob8"
    ,mob9_interest_repaid    decimal(30,10) comment "The interest_repaid in mob9"
    ,mob10_interest_repaid   decimal(30,10) comment "The interest_repaid in mob10"
    ,mob11_interest_repaid   decimal(30,10) comment "The interest_repaid in mob11"
    ,mob12_interest_repaid   decimal(30,10) comment "The interest_repaid in mob12"
    ,mob_on_date string comment ""
) 
partitioned by(grass_date string)
comment 'Tag:risk summary table'
stored as orc
tblproperties("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_user_tenure_mob_dpd_df/grass_region=${upper_region}/product_id=${product_id}'
;

msck repair table ${SCHEMA}.dws_risk_${product}_${region}_user_tenure_mob_dpd_df;
