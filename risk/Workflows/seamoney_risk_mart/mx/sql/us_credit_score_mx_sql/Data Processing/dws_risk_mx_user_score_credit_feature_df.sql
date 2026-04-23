-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-09
-- Theme Domain:        User Score Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-09 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_mx_user_score_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_mx_user_score_credit_feature_df
(
    credit_user_id string
    ,model_version string
    ,model_type string
    ,score string
    ,biz_type string
    ,source_table string
)
partitioned by
(
    grass_date string
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_score_credit_feature_df/grass_region=MX'
;
--msck repair table ${SCHEMA}.dws_risk_mx_user_score_credit_feature_df;


create TEMPORARY function wide_table_convert_json_v2 as 'com.shopee.udf.generic.GenericUDFWideConvertJsonV2' using jar 'hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

insert overwrite table ${SCHEMA}.dws_risk_mx_user_score_credit_feature_df partition (grass_date)
select  credit_user_id
        ,model_version
        ,model_type
        ,score
        ,biz_type
        ,source_table
        ,'${grass_date}' as grass_date
from    (
    select  t11.credit_user_id
            ,t11.model_version
            ,t11.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t11.*), t13.schema1) as score
            ,t13.biz_type
            ,'rescbds_credit.mx_user_bcard_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.mx_user_bcard_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.mx_user_bcard_credit_score_feature_pool
            )
    ) t11
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.mx_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.mx_user_bcard_credit_score_feature_pool'
        )
        group by biz_type
    ) t13
    on      1 = 1
)
;

