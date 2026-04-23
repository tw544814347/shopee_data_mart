create or replace view ${SCHEMA}.ads_risk_reg_activation_apply_sla_df as
select
    *
    ,'ID' as grass_region
from ${SCHEMA}.ads_risk_id_activation_apply_sla_df
union all
select
    *
    ,'MY' as grass_region
from ${SCHEMA}.ads_risk_my_activation_apply_sla_df
union all
select
    *
    ,'PH' as grass_region
from ${SCHEMA}.ads_risk_ph_activation_apply_sla_df
union all
select
    *
    ,'TH' as grass_region
from ${SCHEMA}.ads_risk_th_activation_apply_sla_df
union all
select
    *
    ,'SG' as grass_region
from ${SCHEMA}.ads_risk_sg_activation_apply_sla_df
union all
select
    *
    ,'VN' as grass_region
from ${SCHEMA}.ads_risk_vn_activation_apply_sla_df
union all
select
    *
    ,'TW' as grass_region
from ${SCHEMA}.ads_risk_tw_activation_apply_sla_df
;