alter table ${SCHEMA}.ads_risk_id_profile_all add if not exists partition(grass_date='${ds}',bz_type='profile_user')
location 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/ads_risk_profile_user_df/tz_type=local/grass_region=ID/grass_date=${ds}';

alter table ${SCHEMA}.ads_risk_id_profile_all add if not exists partition(grass_date='${ds}',bz_type='profile_device')
location 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/ads_risk_profile_device_df/tz_type=local/grass_region=ID/grass_date=${ds}';

alter table ${SCHEMA}.ads_risk_id_profile_all add if not exists partition(grass_date='${ds}',bz_type='profile_tongdun_device')
location 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/ads_risk_profile_tongdun_device_df/tz_type=local/grass_region=ID/grass_date=${ds}';

msck repair table ${SCHEMA}.ads_risk_id_profile_all;