use ${SCHEMA};
-- drop table if exists ${SCHEMA}.ads_risk_br_credit_user_cpf_df;
create external table if not exists ${SCHEMA}.ads_risk_br_credit_user_cpf_df
(
    credit_user_id                  string 
    ,qf                             string 
    ,user_name                      string 
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_credit_user_cpf_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_credit_user_cpf_df;
refresh table ${SCHEMA}.ads_risk_br_credit_user_cpf_df;


insert overwrite ${SCHEMA}.ads_risk_br_credit_user_cpf_df partition (grass_date = '${ds}')
select distinct credit_user_id, id_card_no, replace(user_name, ' ', '|') as user_name
from credit_uc.dws_aio_br_uc_user_df
where grass_date = '${ds}' 
and product_id in (1, 2, 3)
and length(id_card_no) = 11
and credit_user_id <> '1790074964049714225'
union  
select distinct credit_user_id, '09293513714' as id_card_no, 'JULIANA|DA|SILVA|COSTA' as user_name
from credit_uc.dws_aio_br_uc_user_df
where grass_date = '${ds}' 
and product_id in (1, 2, 3)
and length(id_card_no) = 11
and credit_user_id = '1790074964049714225'
;
