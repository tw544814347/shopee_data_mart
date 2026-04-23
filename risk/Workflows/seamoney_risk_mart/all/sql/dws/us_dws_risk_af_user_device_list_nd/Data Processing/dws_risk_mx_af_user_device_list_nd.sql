create or replace view ${SCHEMA}.dws_risk_${region}_af_user_device_list_nd as
select
    *
from ${SCHEMA}.dws_risk_af_user_device_list_nd
where
    grass_region = upper('${region}')
    and grass_date = '${grass_date}'
;