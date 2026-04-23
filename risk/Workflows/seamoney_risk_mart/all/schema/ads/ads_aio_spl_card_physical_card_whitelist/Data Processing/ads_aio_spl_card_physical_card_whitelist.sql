--ph
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_1}_spl_card_physical_card_whitelist;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_1}_spl_card_physical_card_whitelist
(
    user_id                               string comment 'user_id'
    ,status                               bigint comment 'status 1：新增; 2：删除'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist/grass_region=${upper_region_1}';
--my
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_2}_spl_card_physical_card_whitelist;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_2}_spl_card_physical_card_whitelist
(
    user_id                               string comment 'user_id'
    ,status                               bigint comment 'status 1：新增; 2：删除'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist/grass_region=${upper_region_2}';
--th
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_3}_spl_card_physical_card_whitelist;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_3}_spl_card_physical_card_whitelist
(
    user_id                               string comment 'user_id'
    ,status                               bigint comment 'status 1：新增; 2：删除'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist/grass_region=${upper_region_3}';


--ph
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_1}_spl_card_physical_card_whitelist_index;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_1}_spl_card_physical_card_whitelist_index
(
    status                               bigint comment 'status 1：新增; 2：删除'
    ,cnt                                 bigint comment 'cnt'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist_index_v2/grass_region=${upper_region_1}';
--my
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_2}_spl_card_physical_card_whitelist_index;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_2}_spl_card_physical_card_whitelist_index
(
    status                               bigint comment 'status 1：新增; 2：删除'
    ,cnt                                 bigint comment 'cnt'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist_index_v2/grass_region=${upper_region_2}';
--th
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_3}_spl_card_physical_card_whitelist_index;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_3}_spl_card_physical_card_whitelist_index
(
    status                               bigint comment 'status 1：新增; 2：删除'
    ,cnt                                 bigint comment 'cnt'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist_index_v2/grass_region=${upper_region_3}';


--ph
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_1}_spl_card_physical_card_whitelist_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_1}_spl_card_physical_card_whitelist_di
(
    user_id                               string comment 'user_id'
    ,status                               bigint comment 'status 1：新增; 2：删除'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist_di/grass_region=${upper_region_1}';
--my
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_2}_spl_card_physical_card_whitelist_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_2}_spl_card_physical_card_whitelist_di
(
    user_id                               string comment 'user_id'
    ,status                               bigint comment 'status 1：新增; 2：删除'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist_di/grass_region=${upper_region_2}';
--th
DROP TABLE IF EXISTS ${SCHEMA}.ads_${region_3}_spl_card_physical_card_whitelist_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_${region_3}_spl_card_physical_card_whitelist_di
(
    user_id                               string comment 'user_id'
    ,status                               bigint comment 'status 1：新增; 2：删除'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_aio_spl_card_physical_card_whitelist_di/grass_region=${upper_region_3}';
