
create table if not exists ${SCHEMA}.ads_risk_id_profile_shop_non_partitions
(
    shop_id BIGINT
    ,shopee_registration_timestamp BIGINT
) stored as parquet;
;

insert overwrite table ${SCHEMA}.ads_risk_id_profile_shop_non_partitions
select  shop_id
        ,shopee_registration_timestamp
from    ${SCHEMA}.ads_risk_profile_user_df
where   tz_type = 'local'
  and   grass_region = 'ID'
  and   grass_date = '${ds}'
;

