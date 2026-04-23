insert overwrite ${SCHEMA}.ads_user_address_id partition(grass_date = '${grass_date}')
select
       row_key,
       latest_receiver_address,
       latitude,
       longitude,
       address_level1_value,
       address_level2_value,
       address_level3_value
from 
(
select row_number() over(partition by row_key order by modify_timestamp desc) as rk,
       row_key,
       latest_receiver_address,
       latitude,
       longitude,
       address_level1_value,
       address_level2_value,
       address_level3_value
from 
        (
                select md5(concat(address,', ',address_level2.value,', ',address_level3.value,', ',address_level1.value,', ',address_region,', ',address_zipcode)) as row_key
                        ,concat(address,', ',address_level2.value,', ',address_level3.value,', ',address_level1.value,', ',address_region,', ',address_zipcode) as latest_receiver_address
                        ,latitude
                        ,longitude
                        ,address_level1.value as address_level1_value
                        ,address_level2.value as address_level2_value
                        ,address_level3.value as address_level3_value
                        ,modify_timestamp
                from mp_user.dim_user_address__reg_s1_live
                where grass_region = 'ID' and grass_date = '${grass_date}'
        ) as tmp 
) as tmp2 
where rk = 1
;