
drop table if exists ${SCHEMA}.dwd_credit_my_risk_ticket_ops_df;
create table if not exists ${SCHEMA}.dwd_credit_my_risk_ticket_ops_df
(
    id                                  bigint
    ,ticket_id                          String
    ,flow_no                            String comment 'same as ticket_id'
    ,operator                           String
    ,content                            String
    ,version                            bigint
    ,create_time                        String comment 'local create timestamp'
    ,update_time                        String comment 'local update timestamp'
    ,notes                              String
    ,content_notes                      String
    ,operation_type                     bigint
    ,second_diff_create_update          bigint comment 'seconds between create and update'
    ,start_time                         string
    ,role                               string
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dws/dwd_credit_risk_ticket_ops_df/grass_region=MY';
msck repair table ${SCHEMA}.dwd_credit_my_risk_ticket_ops_df;
