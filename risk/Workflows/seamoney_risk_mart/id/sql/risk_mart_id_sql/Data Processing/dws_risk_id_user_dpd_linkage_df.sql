--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-04-17
-- Theme Domain：       seller_user_id
-- Description:         
-- Data Granularity:    
-- 变更历史： 2024-04-22, 取数CL max_dpd 从 bill_repayment 改为 instalment_repayment
--********************************************************************--

create or replace temporary view credit_seller_linkage as
select  seller_user_id
        ,count(distinct case when linkage_type = 'email' then buyer_user_id end) as cnt_email_linked_all_user
        ,count(distinct case when linkage_type = 'phone_mp_reg' then buyer_user_id end) as cnt_phone_mp_reg_linked_all_user
        ,count(distinct case when linkage_type = 'phone_reg_reg' then buyer_user_id end) as cnt_phone_reg_reg_linked_all_user
        ,count(distinct case when linkage_type = 'bankAccount' and product = 'SCL' then buyer_user_id end) as cnt_bank_account_linked_scl_user
        ,count(distinct case when linkage_type = 'phone_dpt_dpt' and product = 'SCL' then buyer_user_id end) as cnt_phone_dpt_dpt_linked_scl_user
        ,count(distinct case when linkage_type = 'address_phone' then buyer_user_id end) as cnt_address_phone_linked_all_user
        ,count(distinct case when linkage_type = 'phone_ec_ec' then buyer_user_id end) as cnt_phone_ec_ec_linked_all_user
        ,count(distinct case when linkage_type = 'phone_mp_ec' then buyer_user_id end) as cnt_phone_mp_ec_linked_all_user
        ,count(distinct case when linkage_type = 'phone_reg_ec' then buyer_user_id end) as cnt_phone_reg_ec_linked_all_user
        ,count(distinct case when linkage_type = 'phone_reg_mp' then buyer_user_id end) as cnt_phone_reg_mp_linked_all_user
        ,count(distinct case when linkage_type = 'SZDF_all' then buyer_user_id end) as cnt_shenzhendf_linked_all_user
from    (
    select  t2.userid as seller_user_id
            ,t2.linkage_type
            ,t2.userid2 as buyer_user_id
            ,product
    from    (
        select  credit_user_id
                ,platform_user_id
                ,'SPL' as product
                ,max(case when dpd >= 30 then 1 else 0 end) as dpd30
        from    credit_mart.dws_spl_id_bill_repayment_df
        where   grass_date >= date_sub('${grass_date}', 30)
          and   grass_date <= '${grass_date}'
        group by 1, 2
        union
        select  credit_user_id
                ,platform_user_id
                ,'BCL' as product
                ,max(case when dpd >= 30 then 1 else 0 end) as dpd30
        from    credit_mart.dws_bcl_id_instalment_repayment_df
        where   grass_date >= date_sub('${grass_date}', 30)
          and   grass_date <= '${grass_date}'
        group by 1, 2
        union
        select  credit_user_id
                ,platform_user_id
                ,'SCL' as product
                ,max(case when dpd >= 30 then 1 else 0 end) as dpd30
        from    credit_mart.dws_scl_id_instalment_repayment_df
        where   grass_date >= date_sub('${grass_date}', 30)
          and   grass_date <= '${grass_date}'
        group by 1, 2
    ) t1
    inner join (
        select  userid
                ,userid2
                ,linkage_type
        from    rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info
        where   grass_date = (select max(grass_date)
               from rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info)
          and   linkage_type not in ('tongdunDF', 'tongdunDF_90days')
        group by userid, userid2, linkage_type
    ) t2
    on      t1.platform_user_id = t2.userid2
    where   dpd30 = 1
) tt1
group by seller_user_id
;

insert overwrite table ${SCHEMA}.dws_risk_id_user_dpd_linkage_df partition (grass_date)
select
    t1.user_id as platform_user_id
    ,coalesce(t2.cnt_email_linked_all_user, 0) as cnt_email_linked_all_user
    ,coalesce(t2.cnt_phone_mp_reg_linked_all_user, 0) as cnt_phone_mp_reg_linked_all_user
    ,coalesce(t2.cnt_phone_reg_reg_linked_all_user, 0) as cnt_phone_reg_reg_linked_all_user
    ,coalesce(t2.cnt_bank_account_linked_scl_user, 0) as cnt_bank_account_linked_scl_user
    ,coalesce(t2.cnt_phone_dpt_dpt_linked_scl_user, 0) as cnt_phone_dpt_dpt_linked_scl_user
    ,coalesce(t2.cnt_address_phone_linked_all_user, 0) as cnt_address_phone_linked_all_user
    ,coalesce(t2.cnt_phone_ec_ec_linked_all_user, 0) as cnt_phone_ec_ec_linked_all_user
    ,coalesce(t2.cnt_phone_mp_ec_linked_all_user, 0) as cnt_phone_mp_ec_linked_all_user
    ,coalesce(t2.cnt_phone_reg_ec_linked_all_user, 0) as cnt_phone_reg_ec_linked_all_user
    ,coalesce(t2.cnt_phone_reg_mp_linked_all_user, 0) as cnt_phone_reg_mp_linked_all_user
    ,coalesce(t2.cnt_shenzhendf_linked_all_user, 0) as cnt_shenzhendf_linked_all_user
    ,'${grass_date}' as grass_date
from
(
    select
        user_id
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
    and grass_region = 'ID'
    and grass_date = '${grass_date}'
) t1
left join credit_seller_linkage t2
on t1.user_id = t2.seller_user_id
;

