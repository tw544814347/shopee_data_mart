------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-15
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.dws_risk_id_user_metrics_biz_manage1_df;
create table if not exists ${SCHEMA}.dws_risk_id_user_metrics_biz_manage1_df
(
    platform_user_id string comment 'platform_user_id'
    ,category        string comment 'category'
    ,scene           string comment 'scene'
    ,level           string comment 'level'
    ,source          string comment 'source'
    ,cate            string comment 'cate'
    ,limit_level     string comment 'limit_level'
    ,last_spl_increment_control_live_days_from_now bigint comment ''
    ,user_bcard_v3_score double comment 'user_level_bcard_v3_score'
    ,user_bcard_v3_user_overdue_tag bigint comment 'user_bcard_v3_user_overdue_tag'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dwd/dws_risk_user_metrics_biz_manage1_df/grass_region=ID';
--msck repair table ${SCHEMA}.dws_risk_id_user_metrics_biz_manage1_df;



insert overwrite table ${SCHEMA}.dws_risk_id_user_metrics_biz_manage1_df partition (grass_date = '${grass_date}')
select
     t1.platform_user_id
    ,t3.category       
    ,t3.scene          
    ,t3.level          
    ,t3.source         
    ,t2.cate           
    ,t2.level as limit_level
    ,t4.last_spl_increment_control_live_days_from_now
    ,t5.user_bcard_v3_score
    ,t5.user_bcard_v3_user_overdue_tag
from(
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_id_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            userid as platform_user_id
            ,cate
            , level
        from smcdrisk_antifraud.blacklist_uw_userid_unique t1 
        where grass_date = ( select max(grass_date) from smcdrisk_antifraud.blacklist_uw_userid_unique)
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,category
            ,scene
            ,level
            ,source
        from smcdrisk_antifraud.tag_uw_userid_unique_limit_increment_cashout t1 
        where grass_date = ( select max(grass_date) from smcdrisk_antifraud.tag_uw_userid_unique_limit_increment_cashout)
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            userid as platform_user_id
            ,datediff('${grass_date}', max(live_date)) as last_spl_increment_control_live_days_from_now
        from smcdrisk_policy.id_spl_limit_evaluation_history
        group by 1
        having max_by(control_test, live_date) like '%control%'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,cast(get_json_object(score, '$.score') as double) as user_bcard_v3_score
            ,cast(get_json_object(score, '$.user_overdue_tag') as bigint) as user_bcard_v3_user_overdue_tag
        from risk.dws_risk_user_score_df
        where
            grass_region = 'ID'
            and grass_date = '${grass_date}'
            and biz_type = 'user_bcard_credit_score'
            and model_type = 'label_6term_dpd30'
            and model_version = 'v3.0'
    ) t5 on t1.platform_user_id = t5.platform_user_id
;