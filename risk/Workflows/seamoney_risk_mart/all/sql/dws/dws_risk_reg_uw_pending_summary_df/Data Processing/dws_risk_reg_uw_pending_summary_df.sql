create or replace view ${SCHEMA}.dws_risk_reg_uw_pending_summary_df as
select
    *
    ,'ID' as grass_region
from ${SCHEMA}.dws_risk_id_uw_pending_summary_df
union all
select
    *
    ,'MY' as grass_region
from ${SCHEMA}.dws_risk_my_uw_pending_summary_df
union all
select
    *
    ,'PH' as grass_region
from ${SCHEMA}.dws_risk_ph_uw_pending_summary_df
union all
select
    *
    ,'TH' as grass_region
from ${SCHEMA}.dws_risk_th_uw_pending_summary_df
union all
select
    *
    ,'SG' as grass_region
from ${SCHEMA}.dws_risk_sg_uw_pending_summary_df
union all
select
    *
    ,'VN' as grass_region
from ${SCHEMA}.dws_risk_vn_uw_pending_summary_df
;