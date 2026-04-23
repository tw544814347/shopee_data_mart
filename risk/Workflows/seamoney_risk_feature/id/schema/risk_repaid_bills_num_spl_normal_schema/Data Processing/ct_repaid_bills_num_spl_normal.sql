drop table if exists ${SCHEMA}.repaid_bills_num_spl_normal_history;
create external table if not exists ${SCHEMA}.repaid_bills_num_spl_normal_history
(
    rowkey      string          comment         'rowkey',
    qf          string          comment         'qf',
    qf1         string          comment         'qf1'
)
partitioned by
(
    grass_date          string          comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/history/repaid_bills_num_spl_normal_history';
msck repair table ${SCHEMA}.repaid_bills_num_spl_normal_history;