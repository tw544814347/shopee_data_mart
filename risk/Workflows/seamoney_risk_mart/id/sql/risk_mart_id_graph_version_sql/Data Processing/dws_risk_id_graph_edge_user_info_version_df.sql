--********************************************************************--
-- Author:              zongyi.lu@shopee.com 
-- Created Time:        2024-05-16
-- Theme Domain：       risk graph
-- Description:         user graph相关的数据(边)
-- Data Granularity:    platform_user_id
-- update by zongyi.lu@shopee.com 2024-05-16 https://jira.shopee.io/browse/SPFDT-36928 1.新增dp_account_no边,ph 不需要kyc边, 2.优化-数据源改成mart表
--           credit.ods__credit_usercenter_member_${region}_db__user_contact_info_tab__sensitive -> credit_uc.dwd_uc_{region}_user_contact_info_df
--           digitalpurchase.shopee_digital_product_order_v2_${region}_db__order_tab__reg_daily_s0_live -> digitalpurchase.order_dwd_dp_trd_ord_df
-- update by zongyi.lu@shopee.com https://jira.shopee.io/browse/SPFDT-43429
--           1. 修改ID/PH/MY/SG/BR的 shopeepay_transfer边的逻辑 新增extininfo.transfer_send_datails.reveiver.user_id <> 0的过滤逻辑
--           2. 新增VN/TH的shopeepay_transfer边，逻辑参考git,https://git.garena.com/shopee-ds/shopee-kredit/ds-graph-db/-/merge_requests/2
-- update by zongyi.lu@shopee.com dwd_ofo_all_ent_df__reg_live 中的extinfo 改了结构, 多加一层 logistics_info
--********************************************************************--

--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_info_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_info_version_df
(
    platform_user_id      string comment 'source vertex',
    hash_platform_user_id string comment 'hash source vertex',
    destination_node      string comment 'destination_vertex',
    hash_destination_node string comment 'hash_destination_vertex',
    create_date      string comment 'create_date',
    last_date       string comment 'last_date',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    version_name string comment 'version_name',
    edge_name string comment 'edge name, login/register_mail etc.',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_info_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_edge_user_info_version_df;

create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';


insert overwrite table ${SCHEMA}.dws_risk_id_graph_edge_user_info_version_df partition(version_name,edge_name,grass_date)
select 
    t2.platform_user_id,
    t1.hash_platform_user_id,
    t2.destination_node,
    t2.hash_destination_node,
    t2.create_date,
    t2.last_date,
    t2.extend_info,
    'v2' as version_name,
    t2.edge_name,
    t2.grass_date
from
(
    select  xxhash64(concat('userid/', user_id)) as hash_platform_user_id
    from    mp_user.dim_user__reg_s0_live
    where   tz_type = 'local'
      and   grass_region = '${grass_region}'
      and   grass_date = '${grass_date}'
) t1
inner join
(
    -- bank_account
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('bank_account/', full_account) as destination_node
            ,xxhash64(concat('bank_account/', full_account)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'full_account',full_account
                    ,'account_number',account_number
                    ,'account_name',account_name
                    ,'bank_name_id',bank_name_id
                    ,'bank_name',bank_name
                    ,'status',status
                    ,'is_seller_withdrawal_account',is_seller_withdrawal_account
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'bank_account' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,full_account
                ,account_number
                ,account_name
                ,bank_name
                ,is_seller_withdrawal_account
                ,bank_name_id
                ,status
                ,create_date
                ,last_date
        from(
            select  userid
                    ,full_account
                    ,account_number
                    ,account_name
                    ,bank_name
                    ,coalesce(is_seller_withdrawal_account, 0) as is_seller_withdrawal_account
                    ,bank_name_id
                    ,status
                    ,min(create_date) over (partition by userid, full_account) as create_date
                    ,max(create_date) over (partition by userid, full_account) as last_date
                    ,row_number() over (
                        partition by userid, full_account 
                        order by create_date desc
                    ) as rnk
            from    (
                select  shopee_user_id as userid
                        ,concat_ws(',',
                            payout_bank_account_number_sensitive_data_hash,
                            payout_bank_name
                         ) as full_account
                        ,payout_bank_account_number_sensitive_data_hash as account_number
                        ,lower(trim(payout_bank_account_name)) as account_name
                        ,payout_bank_name_id as bank_name_id
                        ,payout_bank_name as bank_name
                        ,payout_bank_account_status as status
                        ,spm_payout_bank_account_id as id
                        ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
                from    shopeepay.mart_dim_spm_payout_bank_account_df__${region}
                where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
                  and   coalesce(trim(payout_bank_account_number_sensitive_data_hash), '') <> ''
                  and   payout_bank_name_id <> 0
                  and   lower(payout_bank_account_name) not like '%shopee%'
                  and   create_time <> 0
            ) a
            left join (
                select  bank_account_id
                        ,1 as is_seller_withdrawal_account
                from    mp_order.dwd_seller_wallet_withdrawal_all_ent_df__reg_live
                where   grass_region = '${grass_region}'
                  and   grass_date <= '${grass_date}'
                  and   bank_account_id <> 0
                  and   withdrawal_status_id = 4
                group by bank_account_id
            ) b
            on a.id = b.bank_account_id
        )
        where rnk = 1
    )

    -- credit_card
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('credit_card/', credit_card) as destination_node
            ,xxhash64(concat('credit_card/', credit_card)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'credit_card',credit_card
                    ,'card_number',card_number
                    ,'expiry_date',expiry_date
                    ,'status',status
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'credit_card' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,credit_card
                ,card_number
                ,expiry_date
                ,status
                ,create_date
                ,last_date
        from(
            select  userid
                    ,credit_card
                    ,card_number
                    ,expiry_date
                    ,status
                    ,min(grass_date) over (partition by userid, credit_card) as create_date
                    ,max(grass_date) over (partition by userid, credit_card) as last_date
                    ,row_number() over (partition by userid, credit_card order by grass_date desc) as rnk
            from    (
                select  shopee_user_id as userid
                        ,case
                            when '${grass_region}' IN ('ID')
                                then concat_ws(
                                    ',',
                                    card_number,
                                    expiry_date
                                )
                            when '${grass_region}' IN ('PH','MY','SG','TH','VN','BR')  then fingerprint
                        end as credit_card
                        ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
                        ,card_number
                        ,expiry_date
                        ,linkage_status as status
                from    shopeepay.mart_dim_payment_channel_item_df__${region}
                where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
                  and  case
                          when '${grass_region}' IN ('ID')  then coalesce(card_number, '') <> '' and coalesce(expiry_date, '') <> ''
                          when '${grass_region}' IN ('PH','MY','SG','TH','VN','BR') then coalesce(fingerprint, '') <> ''
                        end = true
                    and shopee_user_id != 0
            )
            where   credit_card not in ('BIN_NOT_FOUND_IN_APCC','CARD_EXPIRED','test','EEEE','0')
        )
        where rnk = 1
    )

    -- shopeepay_transfer
    union all
    select  concat('userid/', sender_userid) as platform_user_id
            ,xxhash64(concat('userid/', sender_userid)) as hash_platform_user_id
            ,concat('userid/', receiver_userid) as destination_node
            ,xxhash64(concat('userid/', receiver_userid)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'sender_userid',sender_userid
                    ,'receiver_userid',receiver_userid
                    ,'event_count',event_count
                    ,'event_amount',event_amount
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'shopeepay_transfer' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  sender_userid
                ,receiver_userid
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,sum(amount) as event_amount
        from    (
            select  user_id as sender_userid
                    ,extinfo.transfer_send_details.receiver.user_id as receiver_userid
                    ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
                    ,cast(amount/100000 as integer) as amount
            from    shopeepay.dwd_wallet_${person_table_region}_transaction_tab_df
            where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
              and   transaction_type = 10
              and   user_id <> 0
              and   extinfo.transfer_send_details.receiver.user_id <> 0
              -- 因为TH/VN没有 dwd_wallet_region_transaction_tab_df表,因此这部分先就不统计
              and   '${person_table_region}' = '${region}'
              -- TH/VN 用这个逻辑
              union all 
              select 
                shopee_user_id as sender_userid, 
                transfer_receive_user_id as receiver_userid,
                create_date as grass_date,
                cast(actual_amount as int) as amount
            from shopeepay.mart_dwd_wide_user_order_wallet_all_ent_df__${region}
            where to_date(format_time(create_time,upper('${region}'))) <= '${grass_date}'
            and to_date(format_time(create_time,upper('${region}'))) >= date_sub('${grass_date}',730)
            and order_type_name = 'Transfer Send' 
            and transfer_receive_user_id is not null
            and '${region}' in('vn','th')
        )
        group by sender_userid, receiver_userid
    )

    -- shopee_transfer
    union all
    select  concat('userid/', buyer_userid) as platform_user_id
            ,xxhash64(concat('userid/', buyer_userid)) as hash_platform_user_id
            ,concat('userid/', seller_userid) as destination_node
            ,xxhash64(concat('userid/', seller_userid)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'buyer_userid',buyer_userid
                    ,'seller_userid',seller_userid
                    ,'event_count',event_count
                    ,'event_item_count',event_item_count
                    ,'event_amount',event_amount
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'shopee_transfer' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  buyer_userid
                ,seller_userid
                ,create_date
                ,last_date
                ,event_count
                ,event_item_count
                ,event_amount
        from (
            select  buyer_id as buyer_userid
                    ,seller_id as seller_userid
                    ,min(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as create_date
                    ,max(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as last_date
                    ,count(distinct order_id) as event_count
                    ,sum(item_amount) as event_item_count
                    ,sum(gmv_usd) as event_amount
            from    mp_order.dwd_order_item_all_ent_df__reg_s0_live
            where   grass_region = '${grass_region}'
              and   from_unixtime(create_timestamp, 'yyyy-MM-dd') <= '${grass_date}'
              and   seller_id is not null
            group by buyer_id, seller_id
        ) a
        inner join (
            select user_id from ${SCHEMA}.tmp_zero_enabled_dropshipping_info
        ) b
        on a.buyer_userid = b.user_id
    )
    -- dp_account_no
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('account_no/', account_no) as destination_node
            ,xxhash64(concat('account_no/', account_no)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'category_id', category_id
                    ,'account_no',account_no
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'dp_account_no' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,account_no
                ,category_id
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from    (
            select
                user_id as userid
                ,concat(category_id,'/', customer_id) as account_no
                ,category_id
                ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
            from digitalpurchase.order_dwd_dp_trd_ord_df
            where from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
                and grass_region = '${grass_region}'
                and category_id in (20102,20103,20125,20127)
                and coalesce(customer_id,'') <> ''
                and payment_status = 'P2'
                and order_status = 'OR6'
                and   grass_region ='${grass_region}'
                and   grass_date = '${grass_date}'
        )
        group by userid, account_no, category_id
    )

    -- id kyc 
    union all 
    select  
        platform_user_id       as platform_user_id
        ,hash_platform_user_id as hash_platform_user_id
        ,destination_node      as destination_node
        ,hash_destination_node as hash_destination_node
        ,create_date           as create_date
        ,last_date             as last_date
        ,extend_info           as extend_info
        ,'${grass_region}'     as grass_region
        ,edge_name             as edge_name
        ,grass_date            as grass_date
    from risk.dws_risk_${region}_graph_edge_user_kyc_version_df
    where version_name = 'v2'
    and grass_date='${grass_date}'

    --login
    union all 
    select  
        platform_user_id       as platform_user_id
        ,hash_platform_user_id as hash_platform_user_id
        ,destination_node      as destination_node
        ,hash_destination_node as hash_destination_node
        ,create_date           as create_date
        ,last_date             as last_date
        ,extend_info           as extend_info
        ,'${grass_region}'     as grass_region
        ,edge_name             as edge_name
        ,grass_date            as grass_date
    from risk.dws_risk_${region}_graph_edge_user_login_version_df
    where version_name = 'v2'
    and grass_date='${grass_date}'

    --phone
    union all 
    select  
        platform_user_id       as platform_user_id
        ,hash_platform_user_id as hash_platform_user_id
        ,destination_node      as destination_node
        ,hash_destination_node as hash_destination_node
        ,create_date           as create_date
        ,last_date             as last_date
        ,extend_info           as extend_info
        ,'${grass_region}'     as grass_region
        ,edge_name             as edge_name
        ,grass_date            as grass_date
    from risk.dws_risk_${region}_graph_edge_user_phone_version_df
    where version_name = 'v2'
    and grass_date='${grass_date}'

    --register_mail
    union all 
    select  
        platform_user_id       as platform_user_id
        ,hash_platform_user_id as hash_platform_user_id
        ,destination_node      as destination_node
        ,hash_destination_node as hash_destination_node
        ,create_date           as create_date
        ,last_date             as last_date
        ,extend_info           as extend_info
        ,'${grass_region}'     as grass_region
        ,edge_name             as edge_name
        ,grass_date            as grass_date
    from risk.dws_risk_${region}_graph_edge_user_register_mail_version_df
    where version_name = 'v2'
    and grass_date='${grass_date}'

    --shipping_address
    union all 
    select  
        platform_user_id       as platform_user_id
        ,hash_platform_user_id as hash_platform_user_id
        ,destination_node      as destination_node
        ,hash_destination_node as hash_destination_node
        ,create_date           as create_date
        ,last_date             as last_date
        ,extend_info           as extend_info
        ,'${grass_region}'     as grass_region
        ,edge_name             as edge_name
        ,grass_date            as grass_date
    from risk.dws_risk_${region}_graph_edge_user_shipping_address_version_df
    where version_name = 'v2'
    and grass_date='${grass_date}'
) t2
on t1.hash_platform_user_id = t2.hash_platform_user_id
;