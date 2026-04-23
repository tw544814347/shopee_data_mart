create or replace view ${SCHEMA}.ads_risk_reg_activation_apply_sla_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.ads_risk_br_activation_apply_sla_df
union all
select
    *
    ,'MX' as grass_region
from ${SCHEMA}.ads_risk_mx_activation_apply_sla_df
;