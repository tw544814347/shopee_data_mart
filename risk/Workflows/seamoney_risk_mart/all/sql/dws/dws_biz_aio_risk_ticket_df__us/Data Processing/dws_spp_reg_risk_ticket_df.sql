create or replace view ${SCHEMA}.dws_spp_reg_risk_ticket_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.dws_spp_br_risk_ticket_df
;