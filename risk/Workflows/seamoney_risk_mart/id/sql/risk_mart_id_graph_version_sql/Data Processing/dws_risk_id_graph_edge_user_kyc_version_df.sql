--drop table if exists ${SCHEMA}.dws_risk_${region}_graph_edge_user_kyc_version_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_graph_edge_user_kyc_version_df
(
    platform_user_id                string comment 'platform_user_id'
    ,hash_platform_user_id          string comment 'hash_platform_user_id'
    ,destination_node               string comment 'destination_node'
    ,hash_destination_node          string comment 'hash_destination_node'
    ,create_date                    string comment 'create_date'
    ,last_date                      string comment 'last_date'
    ,extend_info                    string comment 'extend_info'
    ,edge_name                      string comment 'edge_name'
)
partitioned by
(   
    version_name string comment 'version_name'
    ,grass_date string comment 'grass_date'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_kyc_version_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_graph_edge_user_kyc_version_df;

create or replace temporary view v_risk_graph_edge_user_kyc_mp_data_source_df as
select
    m.user_id as userid
    ,t.state
    ,first(get_json_object(data, '$.ic_number')) as id_card_no
    ,min(from_unixtime(ctime, 'yyyy-MM-dd')) as create_date
from
    marketplace.shopee_shop_kyb_record_db__kyb_record_tab__${region}_df t
    left join (
        select
            user_id
            ,shop_id
        from mp_user.dim_shop__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = '${grass_region}'
            and grass_date = '${grass_date}'
    ) m on t.shop_id = m.shop_id
where
    date(from_unixtime(ctime, 'yyyy-MM-dd')) <= date('${grass_date}')
    and get_json_object(data, '$.ic_number') is not null
    and get_json_object(data, '$.ic_number') <> ''
    and state in (1, 2, 3, 4, 5) ---- pending submission, submitted, under review, rejected, approved
    and m.user_id is not null
group by m.user_id, t.state
;

insert overwrite table risk.dws_risk_${region}_graph_edge_user_kyc_version_df partition(version_name,grass_date)
select
    concat('userid/', userid) as platform_user_id
    ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
    ,concat('kyc/', id_card_no) as destination_node
    ,xxhash64(concat('kyc/', id_card_no)) as hash_destination_node
    ,cast(create_date as string) as create_date
    ,cast(last_date as string) as last_date
    ,to_json(named_struct('userid', userid, 'id_card_no', id_card_no)) as extend_info
    ,concat('kyc_', kyc_data_source) as edge_name
    ,'v2' as version_name
    ,'${grass_date}' as grass_date
from
    (
        select
            userid
            ,id_card_no
            ,min(create_date) as create_date
            ,max(create_date) as last_date
            ,kyc_data_source
        from
            (
                select
                    user_id as userid
                    ,id_card_no
                    ,create_date
                    ,'mp' as kyc_data_source
                from
                    (
                        select
                            userid as user_id
                            ,accountid as id_card_no
                            ,from_unixtime(ctime, 'yyyy-MM-dd') as create_date
                            ,id as target_pk
                        from
                            marketplace.shopee_user_backend_${region}_db__external_account_verification_tab__${region}_daily_s0_live
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
                    ) b on a.target_pk = b.target_pk

                union all
                select
                    user_id
                    ,identity_number as id_card_no
                    ,min(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as create_date
                    ,'mp' as kyc_data_source
                from mp_seller.dim_seller_program_kyb_application__id_live
                where
                    grass_date = date('${grass_date}')
                    and application_status_id = 2 -- approved
                    and identity_number is not null
                    and identity_number <> ''
                group by user_id, identity_number

                union all
                select
                    userid
                    ,first(id_card_no) as id_card_no
                    ,min(create_date) as create_date
                    ,'mp' as kyc_data_source
                from v_risk_graph_edge_user_kyc_mp_data_source_df
                where state = 5
                group by userid

                union all

                -- marketplace (all status)
                select
                    user_id as userid
                    ,id_card_no
                    ,create_date
                    ,'mp_all' as kyc_data_source
                from
                    (
                        select
                            userid as user_id
                            ,upper(accountid) as id_card_no
                            ,from_unixtime(ctime, 'yyyy-MM-dd') as create_date
                            ,id as target_pk
                        from
                            marketplace.shopee_user_backend_${region}_db__external_account_verification_tab__${region}_daily_s0_live
                        where
                            status is not null
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
                    ) b on a.target_pk = b.target_pk

                union all

                select
                    user_id
                    ,upper(identity_number) as id_card_no
                    ,min(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as create_date
                    ,'mp_all' as kyc_data_source
                from mp_seller.dim_seller_program_kyb_application__id_live
                where
                    grass_date = date('${grass_date}')
                    and application_status_id is not null
                    and identity_number is not null
                    and identity_number <> ''
                group by user_id, identity_number
                
                union all
                select
                    userid
                    ,first(id_card_no) as id_card_no
                    ,min(create_date) as create_date
                    ,'mp_all' as kyc_data_source
                from v_risk_graph_edge_user_kyc_mp_data_source_df
                group by userid

                union all
                -- shopeepay
                select
                    shopeepay_user_id as userid -- verified that shopeepay uid is same as shopee uid for ID region
                    ,id_number_decrypt as id_card_no
                    ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
                    ,'spp' as kyc_data_source
                from shopeepay.mart_dwd_us_kyc_case_record_tab_df__${region}
                where
                    id_type = 1
                    and kyc_status = 3
                    and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')

                union all

                select
                    shopeepay_user_id as userid -- verified that shopeepay uid is same as shopee uid for SG region
                    ,id_number_decrypt as id_card_no
                    ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
                    ,'spp_all' as kyc_data_source
                from shopeepay.mart_dwd_us_kyc_case_record_tab_df__${region}
                where
                    id_type = 1
                    and kyc_status in (2,3,4)
                    and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')
                    and id_number_decrypt is not null and id_number_decrypt <> '' 
                    
                union all

                -- credit uc - application for credit products
                select
                    userid
                    ,id_card_no
                    ,create_date
                    ,'uc' as kyc_data_source
                from
                    (
                        select
                            platform_user_id as userid
                            ,id_card_no
                            ,date(first_application_time) as create_date
                        from credit_uc.dws_spl_${region}_uc_user_df
                        where grass_date <= date('${grass_date}')
                        union all
                        select
                            platform_user_id as userid
                            ,id_card_no
                            ,date(first_application_time) as create_date
                        from credit_uc.dws_bcl_${region}_uc_user_df
                        where grass_date <= date('${grass_date}')
                        union all
                        select
                            platform_user_id as userid
                            ,id_card_no
                            ,date(first_application_time) as create_date
                        from credit_uc.dws_scl_${region}_uc_user_df
                        where grass_date <= date('${grass_date}')
                        union all
                        select
                            platform_user_id as userid
                            ,id_card_no
                            ,date(kyc_update_time) as create_date
                        from credit_uc.dws_spl_${region}_uc_user_df
                        where grass_date <= date('${grass_date}')
                        union all
                        select
                            platform_user_id as userid
                            ,id_card_no
                            ,date(kyc_update_time) as create_date
                        from credit_uc.dws_bcl_${region}_uc_user_df
                        where grass_date <= date('${grass_date}')
                        union all
                        select
                            platform_user_id as userid
                            ,id_card_no
                            ,date(kyc_update_time) as create_date
                        from credit_uc.dws_scl_${region}_uc_user_df
                        where grass_date <= date('${grass_date}')
                    )
                    where id_card_no is not null and id_card_no != ''

                union all

                select
                    platform_user_id as userid
                    ,id_card_no_by_ocr as id_card_no
                    ,grass_date as create_date
                    ,'uc_all' as kyc_data_source
                from credit_uc.dwd_uc_${region}_apply_ocr_check_df
                where grass_date <= date('${grass_date}') 
                    and id_card_no_by_ocr is not null and id_card_no_by_ocr != ''
            )
        where length(id_card_no) = 16
        group by userid, id_card_no, kyc_data_source
    )
