drop table if exists ${SCHEMA}.dwd_risk_${region}_ticket_ops_df;

create table if not exists ${SCHEMA}.dwd_risk_${region}_ticket_ops_df
(
 id                                                                                                   bigint               comment ''
,ticket_id                                                                                            string               comment ''
,operator                                                                                             string               comment ''
,content                                                                                              string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          string               comment 'create_time local'
,update_time                                                                                          string               comment 'update time local'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as parquet
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_ticket_ops_df/grass_region=${grass_region}';

msck repair table ${SCHEMA}.dwd_risk_${region}_ticket_ops_df;

