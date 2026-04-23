create or replace view ${SCHEMA}.dwd_spp_reg_risk_ticket_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.dwd_spp_br_risk_ticket_df
;