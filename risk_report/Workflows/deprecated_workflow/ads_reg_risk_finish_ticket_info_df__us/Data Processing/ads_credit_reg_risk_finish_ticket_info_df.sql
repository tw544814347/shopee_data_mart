create or replace view ${SCHEMA}.ads_credit_reg_risk_finish_ticket_info_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.ads_credit_br_risk_finish_ticket_info_df
union all
select
    *
    ,'MX' as grass_region
from ${SCHEMA}.ads_credit_mx_risk_finish_ticket_info_df
;