insert overwrite table ${SCHEMA}.ads_2cscore_id_user_score_list_df partition (grass_date = '${ds}')
select  tt1.platform_user_id shopee_userid
        ,tt1.id_card_no id_card_number
        ,concat_ws('|', sort_array(collect_set(tt2.score))) score_list
from    (
    select
        platform_user_id
        ,id_card_no
    from
        (
            select
                t1.platform_user_id
                ,t2.id_card_no
                ,row_number() over (partition by t2.id_card_no order by t2.create_time desc) as row_num
            from
                (
                    select
                        platform_user_id
                        ,credit_user_id
                    from credit_uc.dwd_aio_id_uc_account_df
                    where grass_date = '${ds}'
                ) t1
                left join (
                    select
                        id_card_no
                        ,create_time
                        ,user_id as credit_user_id
                    from credit_uc.dwd_credit_id_uc_id_card_info_tab_df
                    where grass_date = '${ds}'
                ) t2 on t1.credit_user_id = t2.credit_user_id
        )
    where
        row_num = 1
        and coalesce(trim(id_card_no), '') <> ''
) tt1
join    (
        select  userid
                ,cast(round(score) as bigint) score
        from    rescbds_credit.rescbds_credit_prod_id__das_shopee_score_to_c
        where   grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_id__das_shopee_score_to_c where grass_date <= '${ds}')
          and   score is not null
          and   score > 0
) tt2
on      tt1.platform_user_id = tt2.userid
group by 1,2
;

