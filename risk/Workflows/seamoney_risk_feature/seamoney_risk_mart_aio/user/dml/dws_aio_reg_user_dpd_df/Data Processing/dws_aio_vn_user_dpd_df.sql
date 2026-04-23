create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
INSERT OVERWRITE TABLE ${SCHEMA}.dws_aio_${region_lower}_user_dpd_df PARTITION (grass_date='${ds}')
select 
    t1.credit_user_id
    ,t2.latest_dpd_spl
    ,t3.latest_dpd_bcl
from 
(
    select
        credit_user_id
    from credit_mart.dws_spl_${region_lower}_user_df
    where grass_date ='${ds}'
    union
    select
        credit_user_id
    from credit_mart.dws_bcl_${bcl_region}_user_df
    where grass_date ='${ds}' and '${region_lower}'='${bcl_region}'
    union
    select
        credit_user_id
    from credit_mart.dws_scl_${scl_region}_user_df
    where grass_date ='${ds}' and '${region_lower}'='${scl_region}'
) t1
left join 
(
    select  credit_user_id
            ,dpd as latest_dpd_spl
    from    (
        select  credit_user_id
                ,dpd
                ,grass_date
                ,ROW_NUMBER() OVER (PARTITION BY credit_user_id ORDER BY rownum) AS rank
        from    (
            select  credit_user_id
                    ,bill_id
                    ,case   when grass_date < substr(month_due_time, 1, 10) and clear_time is null then -1
                            else dpd
                     end as dpd
                    ,grass_date
                    ,rownum
            from    (
                select  credit_user_id
                        ,bill_id
                        ,total_amount_os
                        ,dpd
                        ,clear_time
                        ,month_due_time
                        ,total_amount_repayable
                        ,total_amount_refund
                        ,total_amount_deduct
                        ,ROW_NUMBER() OVER (PARTITION BY credit_user_id ORDER BY month_due_time desc) AS rownum
                        ,grass_date
                from    credit_mart.dws_spl_${region_lower}_bill_repayment_df
                where   grass_date = '${ds}'
                  and   bill_status in(2, 3)
                  and   biz_type = 3
            ) t21
            where   rownum <= 4
              and   total_amount_repayable - total_amount_refund - total_amount_deduct  > 0 --账单应还大于0
        ) t22
        where   dpd >= 0
    ) t23
    where   rank = 1
) t2 on t1.credit_user_id=t2.credit_user_id
left join 
(
    select  credit_user_id
            ,dpd as latest_dpd_bcl
    from    (
        select  credit_user_id
                ,dpd
                ,grass_date
                ,ROW_NUMBER() OVER (PARTITION BY credit_user_id ORDER BY rownum) AS rank
        from    (
            select  credit_user_id
                    ,bill_id
                    ,case   when grass_date < substr(month_due_time, 1, 10) and clear_time is null then -1
                            else dpd
                     end as dpd
                    ,grass_date
                    ,rownum
            from    (
                select  credit_user_id
                        ,bill_id
                        ,total_amount_os
                        ,dpd
                        ,clear_time
                        ,month_due_time
                        ,total_amount_repayable
                        ,total_amount_refund
                        ,total_amount_deduct
                        ,ROW_NUMBER() OVER (PARTITION BY credit_user_id ORDER BY month_due_time desc) AS rownum
                        ,grass_date
                from    credit_mart.dws_bcl_${bcl_region}_bill_repayment_df
                where   grass_date = '${ds}'
                  and   bill_status in(2, 3)
                  and '${region_lower}'='${bcl_region}'
            ) t21
            where   rownum <= 4
              and   total_amount_repayable - total_amount_refund - total_amount_deduct  > 0 --账单应还大于0
        ) t22
        where   dpd >= 0
    ) t23
    where   rank = 1
) t3 on t1.credit_user_id=t3.credit_user_id;