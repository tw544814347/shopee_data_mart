create or replace view ${SCHEMA}.ads_spp_reg_risk_finish_ticket_info_df as
select
    *
    ,'ID' as grass_region
from ${SCHEMA}.ads_spp_id_risk_finish_ticket_info_df
union all
select
    *
    ,'MY' as grass_region
from ${SCHEMA}.ads_spp_my_risk_finish_ticket_info_df
union all
select
    *
    ,'PH' as grass_region
from ${SCHEMA}.ads_spp_ph_risk_finish_ticket_info_df
union all
select
    *
    ,'TH' as grass_region
from ${SCHEMA}.ads_spp_th_risk_finish_ticket_info_df
union all
select
    *
    ,'VN' as grass_region
from ${SCHEMA}.ads_spp_vn_risk_finish_ticket_info_df
;