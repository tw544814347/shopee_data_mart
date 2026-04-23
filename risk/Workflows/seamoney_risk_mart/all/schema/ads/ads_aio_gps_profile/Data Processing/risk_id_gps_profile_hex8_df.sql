drop table if exists ${SCHEMA}.risk_id_gps_profile_hex8_df;
create external table if not exists ${SCHEMA}.risk_id_gps_profile_hex8_df
(
    gps_hex_8 string
    , hex_tag_final string
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/risk_id_gps_profile_hex8_df';

msck repair table ${SCHEMA}.risk_id_gps_profile_hex8_df;

INSERT OVERWRITE TABLE risk_id_gps_profile_hex8_df
PARTITION (grass_date='${ds}')
-- insert into table risk_id_gps_profile_hex8_df

select gps_hex_8
        -- , concat(gps_hex_8, '_', 'gpshex8') as inkey
        , hex_tag_final
        -- , grass_date
from smcdrisk_antifraud.gps_profile_hex8
where grass_date = (select max(grass_date) from smcdrisk_antifraud.gps_profile_hex8)
;