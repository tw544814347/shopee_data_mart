drop table if exists ${SCHEMA}.ads_risk_id_gps_profile_hexn_df;
create external table if not exists ${SCHEMA}.ads_risk_id_gps_profile_hexn_df
(
    gps_hexn string
    , inkey string
    , hex_tag_final string
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_gps_profile_hexn_df';

msck repair table ${SCHEMA}.ads_risk_id_gps_profile_hexn_df;

INSERT OVERWRITE TABLE ads_risk_id_gps_profile_hexn_df
PARTITION (grass_date='${ds}')
-- insert into table ads_risk_id_gps_profile_hexn_df

select gps_hex_10
        , concat(gps_hex_10, '_', 'gpshex10') as inkey
        , hex_tag_final
        -- , grass_date
from risk.risk_id_gps_profile_hex10_df
where grass_date = '${ds}'

UNION ALL 

select gps_hex_8
        , concat(gps_hex_8, '_', 'gpshex8') as inkey
        , hex_tag_final
        -- , grass_date
from risk.risk_id_gps_profile_hex8_df
where grass_date = '${ds}'
;