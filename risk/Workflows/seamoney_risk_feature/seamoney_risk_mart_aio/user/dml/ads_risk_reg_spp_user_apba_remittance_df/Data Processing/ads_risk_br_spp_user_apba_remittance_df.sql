create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table ${SCHEMA}.ads_risk_${region_lower}_spp_user_apba_remittance_df partition (grass_date = '${ds}')
select  pair as key
        ,count(distinct order_id) as alltime_order
        ,count(distinct if(order_status = 7, order_id, null)) as alltime_success_order
        ,count(distinct if(order_status!=7, order_id, null)) as alltime_notsuccess_order
        ,count(distinct if(order_status = 7 and txn_date >= current_date - interval '30' day, order_id, null)) as alltime_success_order_1m
        ,count(distinct if(order_status!=7 and txn_date >= current_date - interval '30' day, order_id, null)) as alltime_notsuccess_order_1m
        ,count(distinct if(order_status = 7 and txn_date >= current_date - interval '90' day, order_id, null)) as alltime_success_order_3m
        ,count(distinct if(order_status!=7 and txn_date >= current_date - interval '90' day, order_id, null)) as alltime_notsuccess_order_3m
from    (
    select  concat(user_id, bank_name, account_number) as pair
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
            select  GET_JSON_OBJECT(extinfo_json, '$.remittance_extinfo.account_id') as account_id
                    ,cast(user_id as string) as user_id
                    ,order_id
                    ,amount /100000. as amount	--IDR									
                    ,format_time(create_time,'${region_upper}') as txn_time
                    ,date(format_time(create_time,'${region_upper}')) as txn_date
                    ,order_status
            from    shopeepay.ods__shopeepay_uws_order_${region_lower}_db__order_tab__df
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
group by pair

