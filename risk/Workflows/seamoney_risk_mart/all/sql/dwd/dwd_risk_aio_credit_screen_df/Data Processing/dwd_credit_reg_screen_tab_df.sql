create or replace view ${SCHEMA}.dwd_credit_reg_screen_tab_df as
select
    *
    ,'ID' as grass_region
from ${SCHEMA}.dwd_credit_id_screen_tab_df
union all
select
    *
    ,'PH' as grass_region
from ${SCHEMA}.dwd_credit_ph_screen_tab_df
;