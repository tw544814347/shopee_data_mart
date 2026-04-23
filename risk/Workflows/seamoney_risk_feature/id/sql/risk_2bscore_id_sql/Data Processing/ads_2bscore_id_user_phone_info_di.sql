DROP table if exists ${SCHEMA}.ads_2bscore_id_user_phone_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_id_user_phone_info_di
(
    phone_no string
    ,platform_user_id string
    ,is_phone_matched int
    ,score int
    ,is_blacklist_hit int
    ,list_type int
    ,reason_code int
    ,address_info string
    ,score_v3 int
    ,score_v6 int
    ,predicted_label_posthoc    double
    ,predicted_label            double
    ,social_score               double        
)
PARTITIONED BY
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2bscore_user_phone_info_di/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_id_user_phone_info_di;

create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table ${SCHEMA}.ads_2bscore_id_user_phone_info_di partition (grass_date = '${ds}')
select
    t1.phone_no
    ,t1.platform_user_id
    ,t1.is_phone_matched
    ,t1.score
    ,t1.is_blacklist_hit
    ,t1.list_type
    ,t1.reason_code
    ,t1.address_info
    ,t1.score_v3
    ,t1.score_v6
    ,t1.predicted_label_posthoc
    ,t1.predicted_label
    ,t1.social_score
from
    (
        select
            *
            ,concat_ws(
                '_'
                ,phone_no
                ,platform_user_id
                ,is_phone_matched
                ,score
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,cast(sort_array(json_to_array(address_info)) as string)
                ,score_v3
                ,score_v6
                ,predicted_label_posthoc
                ,predicted_label
                ,social_score
            ) as cols
        from ${SCHEMA}.ads_2bscore_id_user_phone_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            concat_ws(
                '_'
                ,phone_no
                ,platform_user_id
                ,is_phone_matched
                ,score
                ,is_blacklist_hit
                ,list_type
                ,reason_code
                ,cast(sort_array(json_to_array(address_info)) as string)
                ,score_v3
                ,score_v6
                ,predicted_label_posthoc
                ,predicted_label
                ,social_score
            ) as cols
        from ${SCHEMA}.ads_2bscore_id_user_phone_info_df
        where grass_date = date_sub('${grass_date}', 1)
    ) t2 on t1.cols = t2.cols
where t2.cols is null
;