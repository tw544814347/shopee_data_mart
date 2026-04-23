
------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-28
-- Description:         Risk Graph需求， kyc边，因为kyc每个地区逻辑不一致,因此单独将kyc加工之后再edge中使用模板
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-41105
-- update by zongyi.lu@shopee.com 新增kyc 逻辑 https://jira.shopee.io/browse/SPFDT-43764
------------------------------------------------------------------------

-- 好几张表没有 先刷新空表 
-- msck repair table risk.dwd_risk_br_graph_edge_user_kyc_df;
insert overwrite table risk.dwd_risk_br_graph_edge_user_kyc_df partition(grass_date)
select  
    concat('userid/', userid) as platform_user_id
    ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
    ,concat('kyc/', id_card_no) as destination_node
    ,xxhash64(concat('kyc/', id_card_no)) as hash_destination_node
    ,cast(create_date as string) as create_date
    ,cast(last_date as string) as last_date
    ,to_json(
        named_struct(
            'userid',userid
            ,'id_card_no', id_card_no
            )
        ) as extend_info
    ,'${grass_region}' as grass_region
    ,'kyc' as edge_name
    ,'${grass_date}' as grass_date
from (
    select
        userid,
        id_card_no,
        min(create_date) as create_date,
        max(create_date) as last_date
    from(
        -- to add seller side KYC in future
        -- shopeepay
        select
            shopeepay_user_id as userid -- verified shopeepay userid is same as shopee userid
            ,REGEXP_REPLACE(id_number_decrypt, '[^0-9]', '') as id_card_no -- remove non numbers from id number
            ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
        from
            shopeepay.mart_dwd_us_kyc_case_record_tab_df__br
        where
            id_type = 1
            and kyc_status = 3
            and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')

        union all

        -- credit products
        select
            userid,
            id_card_no,
            create_date
        from (
            select
                platform_user_id as userid,
                id_card_no,
                date(first_application_time) as create_date
            from credit_uc.dws_all_prod_br_uc_user_df
            where grass_date = date('${grass_date}')

            union all

            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_all_prod_br_uc_user_df
            where grass_date = date('${grass_date}')
            
        ) t1 
    )t2
    where
        id_card_no is not null and 
        length(id_card_no) = 11 -- BR region ID card length is 11
    group by userid, id_card_no
)t3

