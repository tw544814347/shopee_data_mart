create TEMPORARY function wide_table_convert_json_v2 as 'com.shopee.udf.generic.GenericUDFWideConvertJsonV2' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

insert overwrite table ${SCHEMA}.dws_risk_phone_score_df partition (grass_region, grass_date)
select  phone_number
        ,model_version
        ,model_type
        ,score
        ,biz_type
        ,source_table
        ,'SG' as grass_region
        ,'${grass_date}' as grass_date
from    (
    select  t11.phone_number
            ,t11.model_version
            ,t11.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t11.*), t13.schema1) as score
            ,t13.biz_type
            ,'rescbds_credit.sg_rst_phone_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.sg_rst_phone_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.sg_rst_phone_credit_score_feature_pool
            )
    ) t11
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.sg_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.sg_rst_phone_credit_score_feature_pool'
        )
        group by biz_type
    ) t13
    on      1 = 1

) tt1
;

