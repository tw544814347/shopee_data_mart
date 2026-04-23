create or replace view ${SCHEMA}.dws_risk_reg_uw_pending_summary_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.dws_risk_br_uw_pending_summary_df
union all
select
    *
    ,'MX' as grass_region
from ${SCHEMA}.dws_risk_mx_uw_pending_summary_df
;