
------------------------------------------------------------------------
-- Author:              wei.tao
-- Created Time:        2025-03-05
-- Description:         Risk Graph需求， kyc边，因为kyc每个地区逻辑不一致,因此单独将kyc加工之后再edge中使用模板
-- Data Granularity:    
-- PRD:                 https://jira.shopee.io/browse/SPFDT-49676
------------------------------------------------------------------------
-- MX kyc edge
insert overwrite table risk.dwd_risk_mx_graph_edge_user_kyc_df partition(grass_date)
select  concat('userid/', userid) as platform_user_id
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
        ,concat('kyc_', kyc_data_source) as edge_name
        ,'${grass_date}' as grass_date
from (
    select
        userid,
        id_card_no,
        min(create_date) as create_date,
        max(create_date) as last_date,
        kyc_data_source
    from(
        
        
        -- credit products
        select
            userid,
            id_card_no,
            create_date,
            'uc' as kyc_data_source
        from (
            select
                platform_user_id as userid,
                id_card_no,
                date(first_application_time) as create_date
            from credit_uc.dws_spl_${region}_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(first_application_time) as create_date
            from credit_uc.dws_bcl_${region}_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(first_application_time) as create_date
            from credit_uc.dws_scl_${region}_uc_user_df
            where
                grass_date = date('${grass_date}')

            union all

            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_spl_${region}_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_bcl_${region}_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_scl_${region}_uc_user_df
            where
                grass_date = date('${grass_date}')
        )
    )
    where
        id_card_no is not null and 
        length(id_card_no) = 18 -- MX region ID card length is 18
    group by userid, id_card_no, kyc_data_source
)
