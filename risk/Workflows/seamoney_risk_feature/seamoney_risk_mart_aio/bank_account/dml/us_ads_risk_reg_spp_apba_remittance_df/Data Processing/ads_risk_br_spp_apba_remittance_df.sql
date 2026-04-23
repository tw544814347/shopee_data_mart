create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table ${SCHEMA}.ads_risk_${region_lower}_spp_apba_remittance_df partition (grass_date = '${ds}')
select 
    bname_ba as key ,
    count(distinct order_id) as alltime_order_cnt,
    count(distinct user_id) as alltime_user_cnt,								
    count(distinct if(order_status=7,order_id,null)) as alltime_success_order_cnt,
    count(distinct if(order_status=7,user_id,null)) as alltime_success_user_cnt,								
    count(distinct if(order_status!=7,order_id,null)) as alltime_notsuccess_order_cnt,
    count(distinct if(order_status!=7,user_id,null)) as alltime_notsuccess_user_cnt,								
    count(distinct if(txn_date>= current_date - interval '30' day,order_id,null)) as alltime_order_cnt_1m,								
    count(distinct if(txn_date>= current_date - interval '30' day,user_id,null)) as alltime_user_cnt_1m,								
    count(distinct if(order_status=7 and txn_date>= current_date - interval '30' day,order_id,null)) as alltime_success_order_cnt_1m,								
    count(distinct if(order_status=7 and txn_date>= current_date - interval '30' day,user_id,null)) as alltime_success_user_cnt_1m,								
    count(distinct if(order_status!=7 and txn_date>= current_date - interval '30' day,order_id,null)) as alltime_notsuccess_order_cnt_1m,								
    count(distinct if(order_status!=7 and txn_date>= current_date - interval '30' day,user_id,null)) as alltime_notsuccess_user_cnt_1m,								
    count(distinct if(txn_date>= current_date - interval '90' day,order_id,null)) as alltime_order_cnt_3m,								
    count(distinct if(txn_date>= current_date - interval '90' day,user_id,null)) as alltime_user_cnt_3m,								
    count(distinct if(order_status=7 and txn_date>= current_date - interval '90' day,order_id,null)) as alltime_success_order_cnt_3m,								
    count(distinct if(order_status=7 and txn_date>= current_date - interval '90' day,user_id,null)) as alltime_success_user_cnt_3m,								
    count(distinct if(order_status!=7 and txn_date>= current_date - interval '90' day,order_id,null)) as alltime_notsuccess_order_cnt_3m,								
    count(distinct if(order_status!=7 and txn_date>= current_date - interval '90' day,user_id,null)) as alltime_notsuccess_user_cnt_3mfrom    
from
(
    select  concat(bank_name,account_number) as bname_ba
            ,user_id
            ,order_id
            ,txn_date
            ,order_status
    from    (
        select  t1.user_id
                ,t1.order_id
                ,t1.txn_date
                ,t1.order_status
                ,t2.account_number
                ,t2.bank_name
        from    (
            select  get_json_object(uws_extinfo, '$.remittance_extinfo.account_id') as account_id
                    ,shopeepay_user_id as user_id
                    ,uws_order_id as order_id
                    ,amount /100000. as amount	--IDR									
                    ,format_time(create_time,'${region_upper}') as txn_time
                    ,date(format_time(create_time,'${region_upper}')) as txn_date
                    ,order_status
            from    shopeepay.mart_dwd_wide_user_order_wallet_all_ent_df__br
            where   order_type = 5
        ) t1
        join    (
            select 
                    payout_bank_account_number as account_number
                    ,apm_payout_bank_account_id  as apba_account_id
                    ,payout_bank_name as bank_name
            from    shopeepay.mart_dim_apm_payout_bank_account_df__${region_lower} 
        ) t2
        on      cast(t1.account_id as string) = cast(t2.apba_account_id as string)
        group by t1.user_id, t1.order_id, t1.txn_date, t1.order_status, t2.account_number, t2.bank_name
    )
) tmp
group by bname_ba

