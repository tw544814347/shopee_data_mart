-- insert overwrite table ${SCHEMA}.ads_risk_ph_aml_payer_account_list
-- select  payer_account
--         ,related_user_count_1d
--         ,related_user_count_3d
--         ,related_user_count_7d
--         ,related_user_count_14d
-- from    (
--     select  get_json_object(extra_data, '$.payer_account') as payer_account
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 1) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_count_1d
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 3) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_count_3d
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 7) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_count_7d
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 14) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_count_14d
--              ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 1) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then concat_ws(',',distinct get_json_object(extra_data, '$.user_id')) 
--                     else null
--              end as related_user_list_1d
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 3) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_list_3d
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 7) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_list_7d
--             ,case   when from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') > date_sub('${ds}', 14) and from_unixtime(floor(ctime/86400)*86400, 'yyyy-MM-dd') <= '${ds}' and count(distinct get_json_object(extra_data, '$.user_id')) > 5 then count(distinct get_json_object(extra_data, '$.user_id'))
--                     else null
--              end as related_user_list_14d
--     from    shopeepay.ods__shopeepay_apm_payment_ph_db__payment_tab__df__sensitive
--     where   channel_id = 4011600
--       and   char_length(get_json_object(extra_data, '$.payer_account')) > 0
--     group by get_json_object(extra_data, '$.payer_account')
-- )
-- where   related_user_count_1d is not null
--   and   related_user_count_3d is not null
--   and   related_user_count_7d is not null
--   and   related_user_count_14d is not null
-- ;


insert overwrite table ${SCHEMA}.ads_risk_ph_aml_judge_result_by_userid
select  concat(substr(md5(cast(get_json_object(t2.extra_data, '$.user_id') as string)), 0, 2), '_', get_json_object(t2.extra_data, '$.user_id')) as rowkey
        ,max(case   when t1.related_user_count_7d > 5 then 1
                else 0
         end) as judge_result_7d
        ,max(case   when t1.related_user_count_14d > 5 then 1
                else 0
         end) as judge_result_14d
from    (
    select  get_json_object(extra_data, '$.payer_account') as payer_account
            ,count(distinct case
                                   when from_unixtime(floor(create_time / 86400) * 86400, 'yyyy-MM-dd') > date_sub('${ds}', 7) and
                                        from_unixtime(floor(create_time / 86400) * 86400, 'yyyy-MM-dd') <= '${ds}' then
                                       get_json_object(extra_data, '$.user_id')
                                   else null end) as related_user_count_7d
            ,count(distinct case
                                   when from_unixtime(floor(create_time / 86400) * 86400, 'yyyy-MM-dd') > date_sub('${ds}', 14) and
                                        from_unixtime(floor(create_time / 86400) * 86400, 'yyyy-MM-dd') <= '${ds}' then
                                       get_json_object(extra_data, '$.user_id')
                                   else null end) as related_user_count_14d
    from    shopeepay.mart_dwd_pps_inbound_payment_tab_df__ph
    where   pps_payment_channel_id = 4011600
      and   char_length(get_json_object(extra_data, '$.payer_account')) > 0
    group by get_json_object(extra_data, '$.payer_account')
) t1
inner join shopeepay.mart_dwd_pps_inbound_payment_tab_df__ph t2
on      t1.payer_account = get_json_object(t2.extra_data, '$.payer_account')
where   t2.pps_payment_channel_id = 4011600
  and   t1.related_user_count_7d is not null
  and   t1.related_user_count_14d is not null
  and   get_json_object(t2.extra_data, '$.user_id') > 0
group by concat(substr(md5(cast(get_json_object(t2.extra_data, '$.user_id') as string)), 0, 2), '_', get_json_object(t2.extra_data, '$.user_id'))
;

