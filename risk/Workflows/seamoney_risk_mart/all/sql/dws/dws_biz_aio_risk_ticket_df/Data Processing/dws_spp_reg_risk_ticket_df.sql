create or replace view ${SCHEMA}.dws_spp_reg_risk_ticket_df as
select
    *
    ,'ID' as grass_region
from ${SCHEMA}.dws_spp_id_risk_ticket_df
union all
select
    *
    ,'MY' as grass_region
from ${SCHEMA}.dws_spp_my_risk_ticket_df
union all
select
    *
    ,'PH' as grass_region
from ${SCHEMA}.dws_spp_ph_risk_ticket_df
union all
select
    *
    ,'TH' as grass_region
from ${SCHEMA}.dws_spp_th_risk_ticket_df
union all
select
    *
    ,'SG' as grass_region
from ${SCHEMA}.dws_spp_sg_risk_ticket_df
union all
select
    *
    ,'VN' as grass_region
from ${SCHEMA}.dws_spp_vn_risk_ticket_df
;