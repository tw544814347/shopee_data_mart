-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-28
-- Theme Domain:        User Behavior ID 2bscore
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-28 - chengguo.liu - 初始化
-- =============================================================================

--DROP TABLE IF EXISTS ${SCHEMA}.ads_2bscore_id_user_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_id_user_info_df
(
    shopee_user_id string
    ,platform_user_id string
    ,score int
    ,is_blacklist_hit int
    ,list_type int
    ,reason_code int
    ,address_info string
    ,score_v3 int
    ,predicted_label_posthoc double
    ,predicted_label double
    ,score_v6 int
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_feature/ads/ads_2bscore_reg_user_info_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_id_user_info_df;


insert overwrite table ${SCHEMA}.ads_2bscore_id_user_info_df partition (grass_date = '${ds}')
select  tt1.platform_user_id as shopee_user_id
        ,tt1.platform_user_id
        ,tt2.score
        ,coalesce(tt3.is_blacklist_hit, 0)
        ,tt3.list_type
        ,cast(tt3.reason_code as int)
        ,case when tt4.address_info is null then '' else tt4.address_info end as address_info
        ,tt5.score_v3
        ,tt6.predicted_label_posthoc as predicted_label_posthoc
        ,tt6.predicted_label as predicted_label
        ,tt7.score_v6
from    (
    select
        user_id as platform_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) tt1
left join (
    select  a.userid
            ,round(a.score) score
    from    rescbds_credit.rescbds_credit_prod_id__das_shopee_score_to_b a
    where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_id__das_shopee_score_to_b where grass_date <= '${ds}')
) tt2
on      tt1.platform_user_id = tt2.userid
left join (
    select  a.userid
            ,a.ifmatched as is_blacklist_hit
            ,a.list_type
            ,a.reason_code
    from    rescbds_credit.rescbds_credit_prod_id__das_user_blacklist a
    where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_id__das_user_blacklist where grass_date <= '${ds}')
) tt3
on      tt1.platform_user_id = tt3.userid
left join (
    select user_id
           ,to_json(collect_list(map(
                                'address', case when lat_long = 'NA' or lat_long = 'ERROR' then ''
                                           else lat_long
                                           end,
                                'confidence_level', case when is_self_addr = 1 and order_cnt >= 10 then 'High'
                                                         when is_self_addr = 1 and order_cnt < 10 then 'Medium'
                                                         when is_self_addr = 0 and order_cnt >= 10 then 'Medium'
                                                         when is_self_addr = 0 and order_cnt < 10 then 'Low'
                                                    else ''
                                                    end 
           ))) AS address_info
    from (
        select t1.user_id
           ,t1.shipping_phone
           ,t1.normalized_phone
           ,t1.zipcode
           ,t1.state
           ,t1.city
           ,t1.district
           ,t1.address
           ,t1.is_self_addr
           ,t1.order_cnt
           ,t2.lat_long
        from risk.ads_2bscore_id_user_address_info_nd t1
        left join risk.dim_2bscore_id_user_address_lat_long t2
        on  t1.zipcode = t2.zipcode
        and t1.state = t2.state
        and t1.city = t2.city
        and t1.district = t2.district
        and t1.address = t2.address
        and t2.grass_date = '${ds_t_2}'
        where t1.grass_date = '${ds}'
          and t2.lat_long <> 'ERROR' and t2.lat_long <> 'NA' and t2.lat_long is not null --tob dev暂时无法处理，先过滤掉 2023.06.14
        group by t1.user_id, t1.shipping_phone, t1.normalized_phone, t1.zipcode, t1.state, t1.city, t1.district, t1.address, t1.is_self_addr, t1.order_cnt, t2.lat_long
    )
    group by user_id
) tt4 
on      tt1.platform_user_id = tt4.user_id
left join (
    select  userid
            ,round(score) as score_v3
    from    rescbds_credit.id_tob_credit_score
    where grass_date = (select max(grass_date) from rescbds_credit.id_tob_credit_score where model_version = 'v3.0' and grass_date <= '${grass_date}')
    and   model_version = 'v3.0'
) tt5
on      tt1.platform_user_id = tt5.userid
left join (
    select userid, predicted_label_posthoc, predicted_label
    from rescbds_credit.id_income_range_tob_prediction
    where grass_date = (select max(grass_date) from rescbds_credit.id_income_range_tob_prediction where grass_date <= date('${grass_date}'))
) tt6
on      tt1.platform_user_id = tt6.userid
left join (
    select  userid
            ,round(score) as score_v6
    from    rescbds_credit.id_user_acard_credit_score
    where grass_date = (select max(grass_date) from rescbds_credit.id_user_acard_credit_score where grass_date <= '${grass_date}')
) tt7
on      tt1.platform_user_id = tt7.userid
;

refresh table ${SCHEMA}.ads_2bscore_id_user_info_df
;

