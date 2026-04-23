--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-04-17
-- Theme Domain：       credit_user_id
-- Description:         统计有账单的用户,
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 1. 由于 id bcl没有账单(from 2024-04-11),不依赖bcl bill表 2.新增注释
--********************************************************************--

insert overwrite ${SCHEMA}.dwd_risk_id_bill_repayment_user_list_df PARTITION (grass_date = '${grass_date}')
select  COALESCE(t1.credit_user_id, t2.credit_user_id) as credit_user_id
from    (
    select  credit_user_id
    from    credit_mart.dws_spl_id_bill_repayment_df
    where   grass_date = '${grass_date}'
    and   total_amount_repayable - total_amount_refund - total_amount_deduct > 0
) t1
full outer join (
    select  credit_user_id
    from    credit_mart.dws_bcl_id_bill_repayment_df
    where   grass_date = '2024-04-11'
    and   total_amount_repayable - total_amount_refund - total_amount_deduct > 0
) t2
on      t1.credit_user_id = t2.credit_user_id
group by COALESCE(t1.credit_user_id, t2.credit_user_id)
;