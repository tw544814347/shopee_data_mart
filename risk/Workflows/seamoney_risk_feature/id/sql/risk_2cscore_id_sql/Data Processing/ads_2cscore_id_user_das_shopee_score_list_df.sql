create or replace view   ${SCHEMA}.view_ads_2cscore_id_user_score_list_max_ds
as
select  max(grass_date) max_grass_date
from    rescbds_credit.rescbds_credit_prod_id__das_shopee_score_to_c
;


insert overwrite table ${SCHEMA}.ads_2cscore_id_user_das_shopee_score_list_df partition(grass_date = '${ds}')
    select  t1.user_id as shopee_userid
            ,concat_ws('|', sort_array(collect_set(t1.score))) score_list
    from    (
        select  userid as user_id 
                ,cast(round(score) as bigint) score
        from    rescbds_credit.rescbds_credit_prod_id__das_shopee_score_to_c a
        join    ${SCHEMA}.view_ads_2cscore_id_user_score_list_max_ds b
        on      a.grass_date = b.max_grass_date
        where   a.score is not null
          and   a.score > 0
    ) t1
    group by t1.user_id
