create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table ${SCHEMA}.dws_risk_${region_lower}_user_bill_df partition (grass_date = '${ds}')
select  t1.credit_user_id
        ,if(t2.bill_cnt_90d = 0 or t2.bill_cnt_90d is null, 0, coalesce(t2.bill_amount_90d,0)/t2.bill_cnt_90d) as average_bill_amt_90d_bcl
        ,if(t3.bill_cnt_90d = 0 or t3.bill_cnt_90d is null, 0, coalesce(t3.bill_amount_90d,0)/t3.bill_cnt_90d) as average_bill_amt_90d_spl
        ,if(coalesce(t2.bill_cnt_90d, 0)+coalesce(t3.bill_cnt_90d, 0) = 0, 0, (coalesce(t2.bill_amount_90d, 0)+coalesce(t3.bill_amount_90d, 0))/(coalesce(t2.bill_cnt_90d, 0)+coalesce(t3.bill_cnt_90d, 0))) as average_bill_amt_90d_user--bcl+spl
        ,COALESCE(t2.latest_bill_amount,0)+COALESCE(t3.latest_bill_amount,0) as latest_bill_amt_user--bcl+spl
        ,COALESCE(t2.repaid_bills_num_user,0)+COALESCE(t3.repaid_bills_num_user,0) as repaid_bills_num_user--bcl+spl
from    (
    select  credit_user_id
    from    credit_mart.dws_spl_${region_lower}_user_df
    where   grass_date = '${ds}'
    union   
    select  credit_user_id
    from    credit_mart.dws_bcl_${bcl_region}_user_df
    where   grass_date = '${ds}'
      and   '${region_lower}' = '${bcl_region}'
    union   
    select  credit_user_id
    from    credit_mart.dws_scl_${scl_region}_user_df
    where   grass_date = '${ds}'
      and   '${region_lower}' = '${scl_region}'
) t1
left join (
    select  credit_user_id
            ,count(distinct if(month_bill_time >= date_sub('${ds}', 90), bill_id, null)) as bill_cnt_90d
            ,sum(if(month_bill_time >= date_sub('${ds}', 90), total_amount_repayable, null)) as bill_amount_90d
            ,max_by(total_amount_repayable,month_bill_time) as latest_bill_amount
            ,count(distinct if(bill_clear_status in (4,5),bill_id,null)) as repaid_bills_num_user
    from    credit_mart.dws_bcl_${bcl_region}_bill_repayment_df
    where   grass_date = '${ds}'
      and   '${region_lower}' = '${bcl_region}'
      and   total_amount_repayable > 0
    group by credit_user_id
) t2
on      t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,count(distinct if(month_bill_time >= date_sub('${ds}', 90), bill_id, null)) as bill_cnt_90d
            ,sum(if(month_bill_time >= date_sub('${ds}', 90), total_amount_repayable, null)) as bill_amount_90d
            ,max_by(total_amount_repayable,month_bill_time) as latest_bill_amount
            ,count(distinct if(bill_clear_status in (4,5),bill_id,null)) as repaid_bills_num_user
    from    credit_mart.dws_spl_${region_lower}_bill_repayment_df
    where   grass_date = '${ds}'
      and   total_amount_repayable > 0
    group by credit_user_id
) t3
on      t1.credit_user_id = t3.credit_user_id
;

