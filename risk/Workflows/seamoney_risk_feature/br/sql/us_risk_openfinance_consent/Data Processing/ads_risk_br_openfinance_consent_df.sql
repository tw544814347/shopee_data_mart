
-- drop table if exists ${SCHEMA}.ads_risk_br_openfinance_consent_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_consent_df
(    
    consent_id                      string  comment ''
    ,cpf                            string  comment ''
    ,platform_user_id               string  comment '' 
)partitioned by(
    grass_date                      string  comment ''
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/${ENV}/ads/ads_risk_openfinance_consent_df/grass_region=BR'
;

-- msck repair table ${SCHEMA}.ads_risk_br_openfinance_consent_df;
-- refresh table ${SCHEMA}.ads_risk_br_openfinance_consent_df;

insert overwrite ${SCHEMA}.ads_risk_br_openfinance_consent_df partition (grass_date = '${ds}')
select consent_id
        ,cpf
        ,platform_user_id
from (
    select  consent_id
            ,personal_tax_id as cpf
            ,platform_user_id
            ,row_number() over (partition by consent_id, platform_user_id ,personal_tax_id order by create_time desc)  as rn
    from    risk.ods__credit_risk_op_consent_br_db__consent_tab__df
    where   grass_date='${ds}'
)
where rn = 1



