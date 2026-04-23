create or replace view ${SCHEMA}.dwd_credit_reg_risk_ticket_df as
select
    *
    ,'BR' as grass_region
from ${SCHEMA}.dwd_credit_br_risk_ticket_df
union all
select
    *
    ,'MX' as grass_region
from ${SCHEMA}.dwd_credit_mx_risk_ticket_df
;