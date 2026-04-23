-- frf：https://docs.google.com/document/d/17coceaXjKzb9bB25nh0AXX2sgztsbxGGQFjgz_3tckQ/edit?tab=t.0
-- jira：https://jira.shopee.io/browse/SPFDT-57048 / https://jira.shopee.io/browse/SPFDT-58093
-- editor：wei.tao@shopee.com 

insert overwrite ${SCHEMA}.ads_risk_id_user_shop_address_level_df partition(grass_date = '${grass_date}')

select
       user_id,
       address_level1_value,
       address_level2_value,
       address_level3_value,
       shop_id,        
       latitude,       
       longitude,
       address,
       from_unixtime(modify_timestamp-3600) as latest_modify_time,
       concat(shop_id,'_',md5(address)) as combine_key
from 
(
select 
       user_id,
       address_level1_value,
       address_level2_value,
       address_level3_value,
       shop_id,        
       latitude,       
       longitude,
       address,
       modify_timestamp
from 
        (
            select  user_id as user_id
                    ,address_level1.value as address_level1_value
                    ,address_level2.value as address_level2_value
                    ,address_level3.value as address_level3_value
                    ,cast(shop_id as string)   as shop_id     
                    ,cast(latitude as string)  as latitude        
                    ,cast(longitude as string) as longitude
                    ,cast(address as string)   as address
                    ,modify_timestamp
            from mp_user.dim_user_address__reg_s1_live
            where grass_region = 'ID' and grass_date = date('${grass_date}') and is_pick_up_address = 1 and tz_type = 'local'
        ) as tmp 
) as tmp2 
;