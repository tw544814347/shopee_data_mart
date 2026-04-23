--DROP TABLE IF EXISTS ${SCHEMA}.dws_id_ofo_all_ent_df_buyer_non_enabled_dropshipping_info_df_tmp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_id_ofo_all_ent_df_buyer_non_enabled_dropshipping_info_df_tmp
(
    user_id string comment 'buyer_userid'
)
comment 'Risk Graph Data - Buyers with Non-enabled Dropshipping Info'
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_ofo_all_ent_df_buyer_non_enabled_dropshipping_info_df_tmp/grass_region=${grass_region}';


insert overwrite table ${SCHEMA}.dws_id_ofo_all_ent_df_buyer_non_enabled_dropshipping_info_df_tmp
select  buyer_id as user_id
from    mp_order.dwd_ofo_all_ent_df__reg_live
where   grass_region = '${grass_region}'
group by buyer_id
having  coalesce(sum(cast(GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int)), 0) = 0;
