drop table if exists ${SCHEMA}.last_login_sus_device_from_now_dimension;
create table if not exists ${SCHEMA}.last_login_sus_device_from_now_dimension
(
    szdf           string          comment         'szdf'
)
partitioned by
(
    region         string          comment         'partition key'
    ,dt            string          comment         'partition key, yyyy-MM-dd'
)
stored as parquet
;

drop table if exists ${SCHEMA}.last_login_sus_device_from_now_dimension_status;
create table if not exists ${SCHEMA}.last_login_sus_device_from_now_dimension_status
(
    szdf           string          comment         'szdf'
    ,status        string          comment         '1: normal, -1: abnormal'
)
partitioned by
(
    region         string          comment         'partition key'
    ,dt            string          comment         'partition key, yyyy-MM-dd'
)
stored as parquet
;

drop table if exists ${SCHEMA}.last_login_sus_device_from_now_history;
create table if not exists ${SCHEMA}.last_login_sus_device_from_now_history (
    rowkey         string,
    login_time     string,
    szdf           string
) 
partitioned by
(
    region         string          comment         'partition key'
    ,dt            string          comment         'partition key, yyyy-MM-dd'
)
stored as parquet;