create or replace view ${SCHEMA}.ads_risk_id_graph_linkage_edge_user_info_version_df_view as
select
    *
from ${SCHEMA}.dws_risk_id_graph_linkage_edge_user_info_version_df
;