
--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-28
-- Description:         Risk Graph需求， kyc边，因为kyc每个地区逻辑不一致,因此单独将kyc加工之后再edge中使用模板
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-36929
--********************************************************************--

insert overwrite table risk.dwd_risk_my_graph_edge_user_kyc_df partition(grass_date)
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
        ,'MY' as grass_region
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
        select
            userid
            ,id_card_no
            ,create_date
            ,'mp' as kyc_data_source
        from(
            select
                userid,
                accountid as id_card_no,
                from_unixtime(ctime, 'yyyy-MM-dd') as create_date,
                id as target_pk
            from marketplace.shopee_seller_backend_db__external_account_verification_tab__my_df
            where
                status = 3
                and verification_type != 7
                and coalesce(accountid, '') <> ''
                and date(from_unixtime(ctime, 'yyyy-MM-dd')) <= date('${grass_date}')
        ) a
        left anti join (
            -- remove reject cron job
            select
                distinct target_pk
            from marketplace.shopee_clearing_escrow_v1_my_archive_db__shopee_audit_log_tab__reg_continuous_s0_live
            where
                target_tab = 'external_account_verification'
                and username in ('Cron Job','CronJob')
        ) b
        on a.target_pk = b.target_pk

        union all

        select
            shopeepay_user_id as userid
            ,id_number_decrypt as id_card_no
            ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
            ,'spp' as kyc_data_source
        from shopeepay.mart_dwd_us_kyc_case_record_tab_df__my
        where
            id_type = 1
            and kyc_status = 3
            and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')

        union all

        select
            userid
            ,id_card_no
            ,create_date
            ,'uc' as kyc_data_source
        from (
            select
                platform_user_id as userid,
                id_card_no,
                date(create_time) as create_date
            from credit.decrypt__credit_usercenter_member_my_db_user_admin_map_tab__df
            where
                grass_date = date('${grass_date}')
                and date(create_time) <= date('${grass_date}')
        )
    )
    where length(id_card_no) = 12
    group by userid, id_card_no,kyc_data_source
) a 
;
