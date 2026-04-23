create or replace view ${SCHEMA}.ads_spp_reg_risk_finish_ticket_info_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.ads_spp_br_risk_finish_ticket_info_df
;