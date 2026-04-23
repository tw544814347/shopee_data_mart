--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-19
-- Theme Domain：       seller
-- Description:         需要用在fes放款中，而fes每天是固定批次(e.g. 18点)放款，在放款前fes订单的状态会变化，需要包含当天的订单数据
-- Data Granularity:    seller_id
-- 变更历史：          
-- 2024-03-19 zongyi.lu 1.https://jira.shopee.io/browse/SPFDT-34365 ;fast_escrow_order_tab&fast_escrow_eligible_order_tab 改成view
--                      2. (ID/MY/TH/PH) - SGT 5pm
--********************************************************************--

create or replace temporary view fes_estimated_escrow_order_detail as
select  t2.seller_user_id
        ,t2.buyer_user_id
        ,t2.order_sn
        ,t2.estimated_escrow_amount
from    (
    select  entity_sn
            ,shopee_user_id as seller_id
--     from    credit.ods__credit_fast_escrow_transaction_id_db__fast_escrow_order_tab__df
--     where   grass_date = '${ds}'
    from credit.view__credit_fast_escrow_transaction_id_db__fast_escrow_order_tab__spark
    where fast_escrow_status in (4, 19, 20, 21)
) t1
inner join (
    select  order_sn
            ,seller_user_id
            ,buyer_user_id
            ,estimated_escrow_amount
--     from    credit.ods__credit_fast_escrow_gateway_id_db__fast_escrow_eligible_order_tab__df
--     where   grass_date = '${ds}'
     from credit.view__credit_fast_escrow_gateway_id_db__fast_escrow_eligible_order_tab__spark
) t2
on      t1.entity_sn = t2.order_sn
;

create or replace temporary view  fes_estimated_escrow_order_total as
select  seller_user_id
        ,count(distinct order_sn) as estimated_escrow_order_cnt_total
        ,sum(estimated_escrow_amount) estimated_escrow_amount_total
from    fes_estimated_escrow_order_detail
group by seller_user_id
;

create or replace temporary view fes_estimated_escrow_order_seller_buyer_linkage_metrics as
select  t1.seller_user_id
        ,t1.buyer_user_id
        ,t2.linkage_type
        ,count(distinct t1.order_sn) as estimated_escrow_order_cnt
        ,sum(t1.estimated_escrow_amount) estimated_escrow_amount
from    fes_estimated_escrow_order_detail t1
inner join (
    select  userid
            ,userid2
            ,linkage_type
    from    rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info
    where   grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info)
    group by userid, userid2, linkage_type
) t2
on      t1.seller_user_id = t2.userid
  and   t1.buyer_user_id = t2.userid2
group by t1.seller_user_id, t1.buyer_user_id, t2.linkage_type
;


insert overwrite table ${SCHEMA}.dws_risk_id_fes_seller_linkage_txn_df partition (grass_date)
select  t2.seller_user_id
        ,t2.linkage_type
        ,t2.estimated_escrow_order_cnt
        ,t2.estimated_escrow_amount
        ,case when t1.estimated_escrow_order_cnt_total>0 then round(t2.estimated_escrow_order_cnt/t1.estimated_escrow_order_cnt_total, 2) else -9998 end as estimated_escrow_order_cnt_ratio
        ,case when t1.estimated_escrow_amount_total>0 then round(t2.estimated_escrow_amount/t1.estimated_escrow_amount_total, 2) else -9998 end as estimated_escrow_amount_ratio
        ,'${ds}' as grass_date
from    fes_estimated_escrow_order_total t1
left join fes_estimated_escrow_order_seller_buyer_linkage_metrics t2
on      t1.seller_user_id = t2.seller_user_id
;


