-- black list full table
create table if not exists ${SCHEMA}.dimension_blacklist_tag_history_full (
    rowkey string,
    status int,
    data_sources string
) partitioned by (
    grass_region string,
    grass_date string
) stored as parquet;

-- black list increase table
create table if not exists ${SCHEMA}.dimension_blacklist_tag_history_incr (
    `data` string,
    datat_ype string,
    data_source string,
    status int,
    change_type int -- add: 1; delete: 0, -1: change
) partitioned by (
    grass_region string,
    grass_date string
) stored as parquet;

-- id mapping full table
create table if not exists ${SCHEMA}.dimension_shop_id_mapping_platform_uid_history_full (
    shop_id string,
    platform_userid string
) partitioned by (
    grass_region string,
    grass_date string
) stored as parquet;

-- id mapping increase table
create table if not exists ${SCHEMA}.dimension_shop_id_mapping_platform_uid_history_incr (
    shop_id string,
    platform_userid string,
    change_type int -- add: 1; delete: 0
) partitioned by (
    grass_region string,
    grass_date string
) stored as parquet;

-- login history table
create table if not exists ${SCHEMA}.f_get_shop_black_list_tag_history_login (
    rowkey string,
    is_black string,
    szdf string
) partitioned by (
    grass_region string,
    grass_date string
) stored as parquet;

-- modify phone history table
create table if not exists ${SCHEMA}.f_get_shop_black_list_tag_history_modify_phone (
    rowkey string,
    is_black string,
    phone string
) partitioned by (
    grass_region string,
    grass_date string
) stored as parquet;