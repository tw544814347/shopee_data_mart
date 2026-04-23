--********************************************************************--
-- Author:              xiukai.yu@seamoney.com
-- Created Time:        2024-11-20
-- Description:         https://docs.google.com/spreadsheets/d/1Q0kBoljyNJ_bep2f0rZ8ZIRs1JdiErZ8Z2b0zTjK53M/edit?pli=1&gid=1148389135#gid=1148389135
--********************************************************************--

--drop table if exists ${SCHEMA}.dws_risk_my_user_af_graph_dpd_df;
create table if not exists ${SCHEMA}.dws_risk_my_user_af_graph_dpd_df
(
    platform_user_id                                string
    ,cnt_phone_mp_dpt_linked_user_dpd1              bigint
    ,cnt_phone_ec_ec_linked_user_dpd1               bigint
    ,cnt_shopeedf_90days_linked_user_dpd1           bigint
    ,cnt_phone_mp_mp_linked_user_dpd1               bigint
    ,cnt_phone_mp_ec_linked_user_dpd1               bigint
    ,cnt_phone_ec_mp_linked_user_dpd1               bigint
    ,cnt_phone_reg_ec_linked_user_dpd1              bigint
    ,cnt_phone_dpt_mp_linked_user_dpd1              bigint
    ,cnt_phone_reg_mp_linked_user_dpd1              bigint
    ,cnt_phone_reg_reg_linked_user_dpd1             bigint
    ,cnt_phone_dpt_reg_linked_user_dpd1             bigint
    ,cnt_tongdundf_linked_user_dpd1                 bigint
    ,cnt_phone_dpt_ec_linked_user_dpd1              bigint
    ,cnt_tongdundf_90days_linked_user_dpd1          bigint
    ,cnt_shopeedf_linked_user_dpd1                  bigint
    ,cnt_phone_reg_dpt_linked_user_dpd1             bigint
    ,cnt_facebook_linked_user_dpd1                  bigint
    ,cnt_phone_ec_dpt_linked_user_dpd1              bigint
    ,cnt_phone_dpt_dpt_linked_user_dpd1             bigint
    ,cnt_phone_ec_reg_linked_user_dpd1              bigint
    ,cnt_bankaccount_linked_user_dpd1               bigint
    ,cnt_creditcard_linked_user_dpd1                bigint
    ,cnt_phone_mp_reg_linked_user_dpd1              bigint
    ,cnt_email_linked_user_dpd1                     bigint
    ,cnt_bankaccountsuccess_linked_user_dpd1        bigint
    ,cnt_address_linked_user_dpd1                   bigint
    ,cnt_creditcardmask_linked_user_dpd1            bigint
    ,cnt_address_phone_linked_user_dpd1             bigint
    ,cnt_phone_mp_dpt_linked_user_dpd15             bigint
    ,cnt_phone_ec_ec_linked_user_dpd15              bigint
    ,cnt_shopeedf_90days_linked_user_dpd15          bigint
    ,cnt_phone_mp_mp_linked_user_dpd15              bigint
    ,cnt_phone_mp_ec_linked_user_dpd15              bigint
    ,cnt_phone_ec_mp_linked_user_dpd15              bigint
    ,cnt_phone_reg_ec_linked_user_dpd15             bigint
    ,cnt_phone_dpt_mp_linked_user_dpd15             bigint
    ,cnt_phone_reg_mp_linked_user_dpd15             bigint
    ,cnt_phone_reg_reg_linked_user_dpd15            bigint
    ,cnt_phone_dpt_reg_linked_user_dpd15            bigint
    ,cnt_tongdundf_linked_user_dpd15                bigint
    ,cnt_phone_dpt_ec_linked_user_dpd15             bigint
    ,cnt_tongdundf_90days_linked_user_dpd15         bigint
    ,cnt_shopeedf_linked_user_dpd15                 bigint
    ,cnt_phone_reg_dpt_linked_user_dpd15            bigint
    ,cnt_facebook_linked_user_dpd15                 bigint
    ,cnt_phone_ec_dpt_linked_user_dpd15             bigint
    ,cnt_phone_dpt_dpt_linked_user_dpd15            bigint
    ,cnt_phone_ec_reg_linked_user_dpd15             bigint
    ,cnt_bankaccount_linked_user_dpd15              bigint
    ,cnt_creditcard_linked_user_dpd15               bigint
    ,cnt_phone_mp_reg_linked_user_dpd15             bigint
    ,cnt_email_linked_user_dpd15                    bigint
    ,cnt_bankaccountsuccess_linked_user_dpd15       bigint
    ,cnt_address_linked_user_dpd15                  bigint
    ,cnt_creditcardmask_linked_user_dpd15           bigint
    ,cnt_address_phone_linked_user_dpd15            bigint
    ,cnt_phone_mp_dpt_linked_user_dpd30             bigint
    ,cnt_phone_ec_ec_linked_user_dpd30              bigint
    ,cnt_shopeedf_90days_linked_user_dpd30          bigint
    ,cnt_phone_mp_mp_linked_user_dpd30              bigint
    ,cnt_phone_mp_ec_linked_user_dpd30              bigint
    ,cnt_phone_ec_mp_linked_user_dpd30              bigint
    ,cnt_phone_reg_ec_linked_user_dpd30             bigint
    ,cnt_phone_dpt_mp_linked_user_dpd30             bigint
    ,cnt_phone_reg_mp_linked_user_dpd30             bigint
    ,cnt_phone_reg_reg_linked_user_dpd30            bigint
    ,cnt_phone_dpt_reg_linked_user_dpd30            bigint
    ,cnt_tongdundf_linked_user_dpd30                bigint
    ,cnt_phone_dpt_ec_linked_user_dpd30             bigint
    ,cnt_tongdundf_90days_linked_user_dpd30         bigint
    ,cnt_shopeedf_linked_user_dpd30                 bigint
    ,cnt_phone_reg_dpt_linked_user_dpd30            bigint
    ,cnt_facebook_linked_user_dpd30                 bigint
    ,cnt_phone_ec_dpt_linked_user_dpd30             bigint
    ,cnt_phone_dpt_dpt_linked_user_dpd30            bigint
    ,cnt_phone_ec_reg_linked_user_dpd30             bigint
    ,cnt_bankaccount_linked_user_dpd30              bigint
    ,cnt_creditcard_linked_user_dpd30               bigint
    ,cnt_phone_mp_reg_linked_user_dpd30             bigint
    ,cnt_email_linked_user_dpd30                    bigint
    ,cnt_bankaccountsuccess_linked_user_dpd30       bigint
    ,cnt_address_linked_user_dpd30                  bigint
    ,cnt_creditcardmask_linked_user_dpd30           bigint
    ,cnt_address_phone_linked_user_dpd30            bigint
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_my_user_af_graph_dpd_df/grass_region=MY';
--msck repair table ${SCHEMA}.dws_risk_my_user_af_graph_dpd_df;

create or replace temporary view dpd as
select
    credit_user_id
    ,platform_user_id
    ,grass_date
    ,max(case when max_dpd> 0 then 1 else 0 end) as dpd1
    ,max(case when max_dpd> 15 then 1 else 0 end) as dpd15
    ,max(case when max_dpd> 30 then 1 else 0 end) as dpd30
    -- 换成新的表 旧表：credit.dwd_spl_my_bill_repayment_df
from credit_mart.dws_spl_my_bill_repayment_df
    where grass_date = '${grass_date}'
    and principal_repayable > 0
    and bill_status = 2
    group by credit_user_id, platform_user_id, grass_date
;

-- 使用新的用户表
create or replace temporary view user_full_view as
select 
    distinct platform_user_id as user_id
from risk.dim_risk_my_user_info_df
where grass_date = '${grass_date}'
;


insert overwrite ${SCHEMA}.dws_risk_my_user_af_graph_dpd_df partition (grass_date = '${grass_date}')
select 
    t.platform_user_id
    ,count(distinct (case when linkage_type='phone_mp_dpt' and dpd1 = 1 then user_linked else null end)) as cnt_phone_mp_dpt_linked_user_dpd1
    ,count(distinct (case when linkage_type='phone_ec_ec' and dpd1 = 1 then user_linked else null end)) as cnt_phone_ec_ec_linked_user_dpd1
    ,count(distinct(case when linkage_type='shopeeDF_90days' and dpd1 = 1 then user_linked else null end)) as cnt_shopeedf_90days_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_mp_mp' and dpd1 = 1 then user_linked else null end)) as cnt_phone_mp_mp_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_mp_ec' and dpd1 = 1 then user_linked else null end)) as cnt_phone_mp_ec_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_ec_mp' and dpd1 = 1 then user_linked else null end)) as cnt_phone_ec_mp_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_reg_ec' and dpd1 = 1 then user_linked else null end)) as cnt_phone_reg_ec_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_dpt_mp' and dpd1 = 1 then user_linked else null end)) as cnt_phone_dpt_mp_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_reg_mp' and dpd1 = 1 then user_linked else null end)) as cnt_phone_reg_mp_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_reg_reg' and dpd1 = 1 then user_linked else null end)) as cnt_phone_reg_reg_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_dpt_reg' and dpd1 = 1 then user_linked else null end)) as cnt_phone_dpt_reg_linked_user_dpd1
    ,count(distinct(case when linkage_type='tongdunDF' and dpd1 = 1 then user_linked else null end)) as cnt_tongdundf_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_dpt_ec' and dpd1 = 1 then user_linked else null end)) as cnt_phone_dpt_ec_linked_user_dpd1
    ,count(distinct(case when linkage_type='tongdunDF_90days' and dpd1 = 1 then user_linked else null end)) as cnt_tongdundf_90days_linked_user_dpd1
    ,count(distinct(case when linkage_type='shopeeDF' and dpd1 = 1 then user_linked else null end)) as cnt_shopeedf_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_reg_dpt' and dpd1 = 1 then user_linked else null end)) as cnt_phone_reg_dpt_linked_user_dpd1
    ,count(distinct(case when linkage_type='facebook' and dpd1 = 1 then user_linked else null end)) as cnt_facebook_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_ec_dpt' and dpd1 = 1 then user_linked else null end)) as cnt_phone_ec_dpt_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_dpt_dpt' and dpd1 = 1 then user_linked else null end)) as cnt_phone_dpt_dpt_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_ec_reg' and dpd1 = 1 then user_linked else null end)) as cnt_phone_ec_reg_linked_user_dpd1
    ,count(distinct(case when linkage_type='bankAccount' and dpd1 = 1 then user_linked else null end)) as cnt_bankaccount_linked_user_dpd1
    ,count(distinct(case when linkage_type='creditCard' and dpd1 = 1 then user_linked else null end)) as cnt_creditcard_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_mp_reg' and dpd1 = 1 then user_linked else null end)) as cnt_phone_mp_reg_linked_user_dpd1
    ,count(distinct(case when linkage_type='email' and dpd1 = 1 then user_linked else null end)) as cnt_email_linked_user_dpd1
    ,count(distinct(case when linkage_type='bankAccountSuccess' and dpd1 = 1 then user_linked else null end)) as cnt_bankaccountsuccess_linked_user_dpd1
    ,count(distinct(case when linkage_type='address' and dpd1 = 1 then user_linked else null end)) as cnt_address_linked_user_dpd1
    ,count(distinct(case when linkage_type='creditCardMask' and dpd1 = 1 then user_linked else null end)) as cnt_creditcardmask_linked_user_dpd1
    ,count(distinct(case when linkage_type='address_phone' and dpd1 = 1 then user_linked else null end)) as cnt_address_phone_linked_user_dpd1
    ,count(distinct(case when linkage_type='phone_mp_dpt' and dpd15 = 1 then user_linked else null end)) as cnt_phone_mp_dpt_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_ec_ec' and dpd15 = 1 then user_linked else null end)) as cnt_phone_ec_ec_linked_user_dpd15
    ,count(distinct(case when linkage_type='shopeeDF_90days' and dpd15 = 1 then user_linked else null end)) as cnt_shopeedf_90days_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_mp_mp' and dpd15 = 1 then user_linked else null end)) as cnt_phone_mp_mp_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_mp_ec' and dpd15 = 1 then user_linked else null end)) as cnt_phone_mp_ec_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_ec_mp' and dpd15 = 1 then user_linked else null end)) as cnt_phone_ec_mp_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_reg_ec' and dpd15 = 1 then user_linked else null end)) as cnt_phone_reg_ec_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_dpt_mp' and dpd15 = 1 then user_linked else null end)) as cnt_phone_dpt_mp_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_reg_mp' and dpd15 = 1 then user_linked else null end)) as cnt_phone_reg_mp_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_reg_reg' and dpd15 = 1 then user_linked else null end)) as cnt_phone_reg_reg_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_dpt_reg' and dpd15 = 1 then user_linked else null end)) as cnt_phone_dpt_reg_linked_user_dpd15
    ,count(distinct(case when linkage_type='tongdunDF' and dpd15 = 1 then user_linked else null end)) as cnt_tongdundf_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_dpt_ec' and dpd15 = 1 then user_linked else null end)) as cnt_phone_dpt_ec_linked_user_dpd15
    ,count(distinct(case when linkage_type='tongdunDF_90days' and dpd15 = 1 then user_linked else null end)) as cnt_tongdundf_90days_linked_user_dpd15
    ,count(distinct(case when linkage_type='shopeeDF' and dpd15 = 1 then user_linked else null end)) as cnt_shopeedf_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_reg_dpt' and dpd15 = 1 then user_linked else null end)) as cnt_phone_reg_dpt_linked_user_dpd15
    ,count(distinct(case when linkage_type='facebook' and dpd15 = 1 then user_linked else null end)) as cnt_facebook_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_ec_dpt' and dpd15 = 1 then user_linked else null end)) as cnt_phone_ec_dpt_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_dpt_dpt' and dpd15 = 1 then user_linked else null end)) as cnt_phone_dpt_dpt_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_ec_reg' and dpd15 = 1 then user_linked else null end)) as cnt_phone_ec_reg_linked_user_dpd15
    ,count(distinct(case when linkage_type='bankAccount' and dpd15 = 1 then user_linked else null end)) as cnt_bankaccount_linked_user_dpd15
    ,count(distinct(case when linkage_type='creditCard' and dpd15 = 1 then user_linked else null end)) as cnt_creditcard_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_mp_reg' and dpd15 = 1 then user_linked else null end)) as cnt_phone_mp_reg_linked_user_dpd15
    ,count(distinct(case when linkage_type='email' and dpd15 = 1 then user_linked else null end)) as cnt_email_linked_user_dpd15
    ,count(distinct(case when linkage_type='bankAccountSuccess' and dpd15 = 1 then user_linked else null end)) as cnt_bankaccountsuccess_linked_user_dpd15
    ,count(distinct(case when linkage_type='address' and dpd15 = 1 then user_linked else null end)) as cnt_address_linked_user_dpd15
    ,count(distinct(case when linkage_type='creditCardMask' and dpd15 = 1 then user_linked else null end)) as cnt_creditcardmask_linked_user_dpd15
    ,count(distinct(case when linkage_type='address_phone' and dpd15 = 1 then user_linked else null end)) as cnt_address_phone_linked_user_dpd15
    ,count(distinct(case when linkage_type='phone_mp_dpt' and dpd30 = 1 then user_linked else null end)) as cnt_phone_mp_dpt_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_ec_ec' and dpd30 = 1 then user_linked else null end)) as cnt_phone_ec_ec_linked_user_dpd30
    ,count(distinct(case when linkage_type='shopeeDF_90days' and dpd30 = 1 then user_linked else null end)) as cnt_shopeedf_90days_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_mp_mp' and dpd30 = 1 then user_linked else null end)) as cnt_phone_mp_mp_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_mp_ec' and dpd30 = 1 then user_linked else null end)) as cnt_phone_mp_ec_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_ec_mp' and dpd30 = 1 then user_linked else null end)) as cnt_phone_ec_mp_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_reg_ec' and dpd30 = 1 then user_linked else null end)) as cnt_phone_reg_ec_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_dpt_mp' and dpd30 = 1 then user_linked else null end)) as cnt_phone_dpt_mp_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_reg_mp' and dpd30 = 1 then user_linked else null end)) as cnt_phone_reg_mp_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_reg_reg' and dpd30 = 1 then user_linked else null end)) as cnt_phone_reg_reg_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_dpt_reg' and dpd30 = 1 then user_linked else null end)) as cnt_phone_dpt_reg_linked_user_dpd30
    ,count(distinct(case when linkage_type='tongdunDF' and dpd30 = 1 then user_linked else null end)) as cnt_tongdundf_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_dpt_ec' and dpd30 = 1 then user_linked else null end)) as cnt_phone_dpt_ec_linked_user_dpd30
    ,count(distinct(case when linkage_type='tongdunDF_90days' and dpd30 = 1 then user_linked else null end)) as cnt_tongdundf_90days_linked_user_dpd30
    ,count(distinct(case when linkage_type='shopeeDF' and dpd30 = 1 then user_linked else null end)) as cnt_shopeedf_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_reg_dpt' and dpd30 = 1 then user_linked else null end)) as cnt_phone_reg_dpt_linked_user_dpd30
    ,count(distinct(case when linkage_type='facebook' and dpd30 = 1 then user_linked else null end)) as cnt_facebook_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_ec_dpt' and dpd30 = 1 then user_linked else null end)) as cnt_phone_ec_dpt_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_dpt_dpt' and dpd30 = 1 then user_linked else null end)) as cnt_phone_dpt_dpt_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_ec_reg' and dpd30 = 1 then user_linked else null end)) as cnt_phone_ec_reg_linked_user_dpd30
    ,count(distinct(case when linkage_type='bankAccount' and dpd30 = 1 then user_linked else null end)) as cnt_bankaccount_linked_user_dpd30
    ,count(distinct(case when linkage_type='creditCard' and dpd30 = 1 then user_linked else null end)) as cnt_creditcard_linked_user_dpd30
    ,count(distinct(case when linkage_type='phone_mp_reg' and dpd30 = 1 then user_linked else null end)) as cnt_phone_mp_reg_linked_user_dpd30
    ,count(distinct(case when linkage_type='email' and dpd30 = 1 then user_linked else null end)) as cnt_email_linked_user_dpd30
    ,count(distinct(case when linkage_type='bankAccountSuccess' and dpd30 = 1 then user_linked else null end)) as cnt_bankaccountsuccess_linked_user_dpd30
    ,count(distinct(case when linkage_type='address' and dpd30 = 1 then user_linked else null end)) as cnt_address_linked_user_dpd30
    ,count(distinct(case when linkage_type='creditCardMask' and dpd30 = 1 then user_linked else null end)) as cnt_creditcardmask_linked_user_dpd30
    ,count(distinct(case when linkage_type='address_phone' and dpd30 = 1 then user_linked else null end)) as cnt_address_phone_linked_user_dpd30
from 
    (
        select 
            platform_user_id
        from risk.dim_risk_my_user_info_df
        where grass_date = '${grass_date}'
    ) as t
    left join  
    (
        select
            a.userid
            ,a.linkage_type
            ,a.userid2 as user_linked
            ,dpd1
            ,dpd15
            ,dpd30
        from rescbds_credit.rescbds_credit_prod_my__user_graph_linkage_info a
        inner join dpd b
            on cast(a.userid2 as string) = b.platform_user_id
        where dpd1 = 1
            and a.grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_my__user_graph_linkage_info)
        group by a.userid, a.linkage_type, a.userid2, b.dpd1, b.dpd15, b.dpd30
    ) c
    on t.platform_user_id = c.userid
    group by t.platform_user_id








