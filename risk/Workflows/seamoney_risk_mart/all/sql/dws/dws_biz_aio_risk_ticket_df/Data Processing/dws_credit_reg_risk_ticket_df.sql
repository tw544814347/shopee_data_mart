create or replace view ${SCHEMA}.dws_credit_reg_risk_ticket_df as
select
    *
    ,'ID' as grass_region
from ${SCHEMA}.dws_credit_id_risk_ticket_df
union all
select
    *
    ,'MY' as grass_region
from ${SCHEMA}.dws_credit_my_risk_ticket_df
union all
select
    *
    ,'PH' as grass_region
from ${SCHEMA}.dws_credit_ph_risk_ticket_df
union all
select
    *
    ,'TH' as grass_region
from ${SCHEMA}.dws_credit_th_risk_ticket_df
union all
select
    *
    ,'VN' as grass_region
from ${SCHEMA}.dws_credit_vn_risk_ticket_df
;