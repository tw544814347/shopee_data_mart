
------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-28
-- Description:         Risk Graph需求， kyc边，因为kyc每个地区逻辑不一致,因此单独将kyc加工之后再edge中使用模板
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-36929
--    update by zongyi.lu@shopee.com 2024-09-19 Graph数据加工 -新增边kyc_uc, kyc_spp, kyc_mp *3，以及性能优化(是kyc单独跑数据的,执行时长10min以内,暂时不优化) jira: https://jira.shopee.io/browse/SPFDT-43764
--    update by zongyi.lu@shopee.com 2024-12-03 https://jira.shopee.io/browse/SPFDT-46840 
------------------------------------------------------------------------

insert overwrite table risk.dwd_risk_id_graph_edge_user_kyc_df partition(grass_date)
select  concat('userid/', user_id) as platform_user_id
        ,xxhash64(concat('userid/', user_id)) as hash_platform_user_id
        ,concat('kyc/', id_card_no) as destination_node
        ,xxhash64(concat('kyc/', id_card_no)) as hash_destination_node
        ,cast(create_date as string) as create_date
        ,cast(last_date as string) as last_date
        ,to_json(
            named_struct(
                'userid',user_id
                ,'id_card_no', id_card_no
            )
        ) as extend_info
        ,'ID' as grass_region
        ,concat('kyc_', kyc_data_source) as edge_name
        ,'${grass_date}' as grass_date
from (
     select
        user_id,
        id_card_no,
        min(create_date) as create_date,
        max(create_date) as last_date,
        kyc_data_source
    from(
        select
            user_id,
            id_card_no,
            create_date,
            'mp' as kyc_data_source
        from(
            select
                userid as user_id,
                accountid as id_card_no,
                from_unixtime(ctime, 'yyyy-MM-dd') as create_date,
                id as target_pk
            from marketplace.shopee_user_backend_id_db__external_account_verification_tab__id_daily_s0_live
            where
                status = 3
                and verification_type != 7
                and date(from_unixtime(ctime, 'yyyy-MM-dd')) <= date('${grass_date}')
        ) a
        left anti join (
            -- remove reject cron job
            select
                distinct target_pk
            from marketplace.shopee_clearing_escrow_v1_id_archive_db__shopee_audit_log_tab__reg_continuous_s0_live
            where
                target_tab = 'external_account_verification'
                and username in ('Cron Job','CronJob')
        ) b
        on a.target_pk = b.target_pk

        union all

        select
            user_id,
            identity_number as id_card_no,
            min(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as create_date,
            'mp' as kyc_data_source
        from mp_seller.dim_seller_program_kyb_application__id_live
                where
                    grass_date = date('${grass_date}')
                    and application_status_id = 2 -- approved
                    and identity_number is not null
                    and identity_number <> ''
                group by user_id, identity_number
 
        -- from(
        --     select
        --         user_id,
        --         identity_number as id_card_no,
        --         from_unixtime(create_time, 'yyyy-MM-dd') as create_date,
        --         kyc_id
        --     from marketplace.shopee_account_kyc_id_db__kyc_tab__id_daily_s0_live
        --     where
        --         kyc_program = 3
        --         and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')
        -- ) a
        -- inner join (
        --     select
        --         kyc_id,
        --         application_id
        --     from marketplace.shopee_account_kyc_db__kyc_application_tab__id_df
        --     where application_status = 2
        -- ) b
        -- on a.kyc_id = b.kyc_id
        -- left anti join(
        --     select distinct application_id
        --     from marketplace.shopee_account_kyc_db__kyc_audit_tab__id_df
        --     where operator in ('CRON JOB')
        -- ) c
        -- on b.application_id = c.application_id

        union all

        select
            shopeepay_user_id as userid,
            id_number_decrypt as id_card_no,
            from_unixtime(create_time, 'yyyy-MM-dd') as create_date,
            'spp' as kyc_data_source
        from shopeepay.mart_dwd_us_kyc_case_record_tab_df__id
        where
            id_type = 1
            and kyc_status = 3
            and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')

        union all

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
            from credit_uc.dws_spl_id_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(first_application_time) as create_date
            from credit_uc.dws_bcl_id_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(first_application_time) as create_date
            from credit_uc.dws_scl_id_uc_user_df
            where
                grass_date = date('${grass_date}')

            union all

            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_spl_id_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_bcl_id_uc_user_df
            where
                grass_date = date('${grass_date}')
            union all
            select
                platform_user_id as userid,
                id_card_no,
                date(kyc_update_time) as create_date
            from credit_uc.dws_scl_id_uc_user_df
            where
                grass_date = date('${grass_date}')
        )
    )
    where length(id_card_no) = 16
    group by user_id, id_card_no,kyc_data_source
) a 
