------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-09-08
-- Description:         credit score，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id+biz_type+model_type+model_version
-- PRD:                 
------------------------------------------------------------------------

create temporary function wide_table_convert_json_v2 as 'com.shopee.udf.generic.GenericUDFWideConvertJsonV2' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar'
;

insert overwrite table ${SCHEMA}.dws_risk_user_score_df partition (grass_region, grass_date)
select  userid as platform_user_id
        ,model_version
        ,model_type
        ,score
        ,biz_type
        ,source_table
        ,'MY' as grass_region
        ,'${grass_date}' as grass_date
from    (
    select  t11.userid
            ,t11.model_version
            ,t11.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t11.*), t13.schema1) as score
            ,t13.biz_type
            ,'rescbds_credit.my_scl_acard_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.my_scl_acard_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.my_scl_acard_credit_score_feature_pool
            )
    ) t11
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.my_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.my_scl_acard_credit_score_feature_pool'
        )
        group by biz_type
    ) t13
    on      1 = 1

    union all 
    select  t31.userid
            ,t31.model_version
            ,t31.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t31.*), t33.schema1) as score
            ,t33.biz_type
            ,'rescbds_credit.my_spl_acard_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.my_spl_acard_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.my_spl_acard_credit_score_feature_pool
            )
    ) t31
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.my_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.my_spl_acard_credit_score_feature_pool'
        )
        group by biz_type
    ) t33
    on      1 = 1

    union all 
    select  t41.userid
            ,t41.model_version
            ,t41.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t41.*), t43.schema1) as score
            ,t43.biz_type
            ,'rescbds_credit.my_user_bcard_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.my_user_bcard_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.my_user_bcard_credit_score_feature_pool
            )
    ) t41
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.my_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.my_user_bcard_credit_score_feature_pool'
        )
        group by biz_type
    ) t43
    on      1 = 1

    union all 
    select  t51.userid
            ,t51.model_version
            ,t51.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t51.*), t53.schema1) as score
            ,t53.biz_type
            ,'rescbds_credit.my_scl_bcard_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.my_scl_bcard_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.my_scl_bcard_credit_score_feature_pool
            )
    ) t51
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.my_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.my_scl_bcard_credit_score_feature_pool'
        )
        group by biz_type
    ) t53
    on      1 = 1

    union all 
    select  t61.userid
            ,t61.model_version
            ,t61.model_type
            ,wide_table_convert_json_v2(concat_ws('#', t61.*), t63.schema1) as score
            ,t63.biz_type
            ,'rescbds_credit.my_bcl_acard_credit_score_feature_pool' as source_table
    from    (
        select
            *
        from rescbds_credit.my_bcl_acard_credit_score_feature_pool
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.my_bcl_acard_credit_score_feature_pool
            )
    ) t61
    join    (
        select  concat_ws(',', sort_array(collect_set(struct(column_rank, schema0))).schema0) as schema1
                ,biz_type
        from    (
            select  column_rank
                    ,concat(column_name, '#', data_type) as schema0
                    ,biz_type
            from    rescbds_credit.my_dim_acard_credit_score_feature_pool
            where   output_table = 'rescbds_credit.my_bcl_acard_credit_score_feature_pool'
        )
        group by biz_type
    ) t63
    on      1 = 1

) tt1
;

