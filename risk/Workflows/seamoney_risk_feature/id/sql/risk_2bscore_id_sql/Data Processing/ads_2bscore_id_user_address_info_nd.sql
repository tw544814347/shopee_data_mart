add JAR hdfs://R2/projects/risk/hdfs/udf/phone_normalizer_udf.jar;
;

drop temporary function if exists phone_normalizer_udf
;

create temporary function phone_normalizer_udf as 'com.shopee.udf.PhoneNormalizerUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/phone_normalizer_udf.jar'
;

insert overwrite ${SCHEMA}.ads_2bscore_id_user_address_info_nd partition (grass_date = '${ds}')
select
    t1.user_id
    ,t1.shipping_phone
    ,t1.normalized_phone
    ,t1.zipcode
    ,t1.state
    ,t1.city
    ,t1.district
    ,t1.address
    ,t1.order_cnt
    ,case
        when t2.normalized_phone is not null and t1.normalized_phone = t2.normalized_phone then 1
        else 0
    end as is_self_addr
from
    (
        select
            cast(buyer_id as bigint) as user_id
            ,GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.phone') as shipping_phone
            ,phone_normalizer_udf (
                GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.phone')
                ,'ID'
            ) as normalized_phone
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.zipcode'),'') as zipcode
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.state'),'') as state
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.city'),'') as city
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.district'),'') as district
            ,coalesce(GET_JSON_OBJECT (extinfo, '$.logistics_info.buyer_address.address'),'') as address
            ,count(1) as order_cnt
        from mp_order.dwd_ofo_all_ent_df__reg_live
        where
            tz_type = 'local'
            and grass_region = 'ID'
            and grass_date >= date('${ds}') - interval '${offset}' day
            and grass_date <= date('${ds}')
            and logistics_status_id = 5
            -- and cast (GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int) = 0 -- 无货源模式代发货，不影响buyer地址，已跟ruowen沟通去掉
        group by 1, 2, 3, 4, 5, 6, 7, 8
    ) as t1
    left join (
        select
            user_id
            ,phone_number as phone
            ,phone_normalizer_udf (phone_number, 'ID') as normalized_phone
        from mp_user.dim_user__reg_s1_live
        where
            tz_type = 'local'
            and grass_region = 'ID'
            and grass_date = '${ds}'
    ) as t2 on t1.user_id = t2.user_id