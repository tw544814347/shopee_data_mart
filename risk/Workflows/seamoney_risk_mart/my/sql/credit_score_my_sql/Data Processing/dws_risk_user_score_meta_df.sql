insert overwrite table ${SCHEMA}.dws_risk_user_score_meta_df partition (grass_region, grass_date)
select  t1.biz_type
        ,coalesce(t2.model_version,t4.model_version,t5.model_version,t6.model_version,t7.model_version,t8.model_version,t9.model_version) as model_version
        ,t1.column_name
        ,t1.data_type
        ,'MY' as grass_region
        ,'${ds}' as grass_date
from    (
    select  biz_type
            ,column_name
            ,data_type
    from    rescbds_credit.my_dim_acard_credit_score_feature_pool
    group by biz_type, column_name, data_type
) t1
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.my_scl_acard_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.my_scl_acard_credit_score_feature_pool)
    group by biz_type, model_version
) t2
on t1.biz_type = t2.biz_type
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.my_spl_acard_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.my_spl_acard_credit_score_feature_pool)
    group by biz_type, model_version
) t4
on t1.biz_type = t4.biz_type
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.my_rst_phone_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.my_rst_phone_credit_score_feature_pool)
    group by biz_type, model_version
) t5
on t1.biz_type = t5.biz_type
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.my_user_bcard_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.my_user_bcard_credit_score_feature_pool)
    group by biz_type, model_version
) t6
on t1.biz_type = t6.biz_type
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.my_scl_bcard_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.my_scl_bcard_credit_score_feature_pool)
    group by biz_type, model_version
) t7
on t1.biz_type = t7.biz_type
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.my_bcl_acard_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.my_bcl_acard_credit_score_feature_pool)
    group by biz_type, model_version
) t8
on t1.biz_type = t8.biz_type
left join (
    select  biz_type
            ,model_version
    from    rescbds_credit.id_user_acard_credit_score_feature_pool
    where   grass_date = (select max(grass_date) from rescbds_credit.id_user_acard_credit_score_feature_pool)
    group by biz_type, model_version
) t9
on t1.biz_type = t9.biz_type
;

