-- success join关联结果表，先用于BR（kredit 10011/spj 10001）
drop table if exists ${SCHEMA}.success_join_data_detail_history;
create table if not exists ${SCHEMA}.success_join_data_detail_history
(
    request_flowno           string          comment         'source data => Req.RiskReqHeader.FlowNo'
    ,request_reqtime         bigint          comment         'source data => Req.RiskReqHeader.ReqTime'
    ,result_flowno           string          comment         'result data => Req.RiskReqHeader.FlowNo'
    ,result_reqtime          bigint          comment         'result data => Req.RiskReqHeader.ReqTime'
    ,join_field              string          comment         'join field'
    ,value                   string          comment         'detail info'
)
partitioned by
(
    grass_region         string          comment         'region'
    ,scene_id            string          comment         'app_id || "_" || scene_id'
    ,dt                  string          comment         'kafka ingest date(yyyy-MM-dd)'
)
stored as parquet;
-- location '${HDFS_PATH}/risk_mart/dwd/success_join_data_detail_history';
msck repair table ${SCHEMA}.success_join_data_detail_history;