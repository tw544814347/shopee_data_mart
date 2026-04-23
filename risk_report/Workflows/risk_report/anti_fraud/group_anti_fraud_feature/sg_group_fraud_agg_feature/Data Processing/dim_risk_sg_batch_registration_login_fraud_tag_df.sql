--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dim 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
                -- 1、换成 af 维护的 dim 表
--********************************************************************--

drop table if exists risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df;
CREATE TABLE IF NOT EXISTS risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df(
    user_id             string,    
    create_datetime     string,    
    create_timestamp    bigint,    
    reason              string
) 
COMMENT ''
PARTITIONED BY (
    grass_date          string
)
STORED AS parquet
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/dim/dim_risk_reg_batch_registration_login_fraud_tag_df/grass_region=${grass_region}';

with shopee_fraud_tag as (
    select distinct
        cast(user_id as STRING) user_id
        ,create_datetime
        ,create_timestamp
        ,reason
    from smcdrisk_antifraud.${reg}_batch_registration_login_fraud_tag_base
    where substr(create_datetime,1,10) <= '${ds}'
    
)

insert overwrite table risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df partition (grass_date)
select  user_id
        ,create_datetime
        ,create_timestamp
        ,reason
        ,'${ds}' as grass_date
FROM shopee_fraud_tag
;

msck repair table risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df;
refresh table risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df;