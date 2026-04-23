-- -- add jar hdfs://D2/projects/credit/hdfs/udf/hive-udf.jar; 
-- -- drop temporary function if exists format_time; 
-- -- create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- SET spark.sql.session.timeZone = America/Sao_Paulo;

-- -- drop table if exists ${SCHEMA}.ads_risk_br_openfinance_data_sharing_contract_df;
-- create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_data_sharing_contract_df
-- (    
--     credit_user_id                  string 
--     ,cpf                            string 
--     ,user_name                      string 
--     ,loan_id                        string 
--     ,contract_id                    string
--     ,product_type                   string
--     -- API 
--     ,find                           string 
--     ,scheduled_instalments          string 
--     ,payments                       string
-- )partitioned by(
--     grass_date                      string
-- )
-- stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
-- LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_data_sharing_contract_df/grass_region=BR'
-- ;

-- msck repair table ${SCHEMA}.ads_risk_br_openfinance_data_sharing_contract_df;
-- refresh table ${SCHEMA}.ads_risk_br_openfinance_data_sharing_contract_df;


-- insert overwrite ${SCHEMA}.ads_risk_br_openfinance_data_sharing_contract_df partition (grass_date = '${ds}')
-- select  credit_user_id
--         ,cpf
--         ,user_name 
--         ,loan_id
--         ,contract_id
--         ,product_type
--         ,find                          
--         ,scheduled_instalments         
--         ,payments                      
-- from ${SCHEMA}.ads_risk_br_openfinance_data_sharing_df
-- where grass_date = '${ds}'
-- ;

