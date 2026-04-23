--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-05-21
-- Theme Domain：        user_af_graph_linkage
-- Description:         https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit#gid=617476295
-- Data Granularity:    platform_user_id
-- 变更历史：
--********************************************************************--

--drop table if exists ${SCHEMA}.dws_risk_ph_user_graph_tag_df;
create external table if not exists ${SCHEMA}.dws_risk_ph_user_graph_tag_df (
    platform_user_id string comment 'platform_user_id'
    ,phone_ec_mp_cur_dpd15 int comment 'phone_ec_mp_cur_dpd15'
    ,phone_ec_mp_cur_dpd30 int comment 'phone_ec_mp_cur_dpd30'
    ,linked_dpd60_sellerbankaccount int comment 'linked_dpd60_sellerbankaccount'
    ,linked_sellbankaccount_user_count int comment 'linked_sellbankaccount_user_count'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_graph_tag_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.dws_risk_ph_user_graph_tag_df;

create or replace temporary view dws_risk_ph_user_graph_phone_linkage_info_df as
select
    t1.platform_user_id
    ,max(
        case
            when t1.description like '%cur_dpd15%' and t2.userid is not null then 1
        end
    ) as phone_ec_mp_cur_dpd15
    ,max(
        case
            when t1.description like '%cur_dpd30%' and t2.userid is not null then 1
        end
    ) as phone_ec_mp_cur_dpd30
from
    (
        select
            data as platform_user_id
            ,description
        from smcdrisk_antifraud.ph_blacklist_dpd_users
        where datatype = 'shopeeAccount'
    ) t1
    left join (
        select
            userid
            ,userid2
        from rescbds_credit.rescbds_credit_prod_ph__user_graph_linkage_info
        where
            linkage_type in ('phone_ec_mp')
            and grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_ph__user_graph_linkage_info)
    ) t2 on t1.platform_user_id = t2.userid2
group by t1.platform_user_id
;

create or replace temporary view dws_risk_ph_user_graph_seller_bank_account_cnt_linkage_info_df as
select
    t2.platform_user_id_1 as platform_user_id
    ,max(case when t2.linkage_type = 'sellerBankAccount' then 1 else -9999 end) as linked_dpd60_sellerbankaccount
from
    (
        select
            data as platform_user_id
        from smcdrisk_antifraud.blacklist_overdue_users_ph
        where datatype = 'shopeeAccount'
    ) t1
    inner join (
        select
            userid as platform_user_id_1
            ,userid2 as platform_user_id_2
            ,linkage_type
        from rescbds_credit.rescbds_credit_prod_ph__user_graph_linkage_info
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.rescbds_credit_prod_ph__user_graph_linkage_info
            )
    ) t2 on t1.platform_user_id = t2.platform_user_id_2
group by t2.platform_user_id_1
;

create or replace temporary view dws_risk_ph_user_graph_seller_bank_account_user_cnt_linkage_info_df as
select distinct
    userid as platform_user_id
    ,count(distinct userid2) as linked_sellbankaccount_user_count
from rescbds_credit.rescbds_credit_prod_ph__user_graph_linkage_info
where
    grass_date = (
        select
            max(grass_date)
        from rescbds_credit.rescbds_credit_prod_ph__user_graph_linkage_info
    )
    and linkage_type = 'sellerBankAccount'
group by userid
;

insert overwrite table ${SCHEMA}.dws_risk_ph_user_graph_tag_df
select
    t1.platform_user_id
    ,t11.phone_ec_mp_cur_dpd15
    ,t11.phone_ec_mp_cur_dpd30
    ,t12.linked_dpd60_sellerbankaccount
    ,t13.linked_sellbankaccount_user_count
from
    (
        select
            *
        from ${SCHEMA}.dim_risk_ph_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join dws_risk_ph_user_graph_phone_linkage_info_df t11 on t1.platform_user_id = t11.platform_user_id
    left join dws_risk_ph_user_graph_seller_bank_account_cnt_linkage_info_df t12 on t1.platform_user_id = t12.platform_user_id
    left join dws_risk_ph_user_graph_seller_bank_account_user_cnt_linkage_info_df t13 on t1.platform_user_id = t13.platform_user_id
;