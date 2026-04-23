-- drop table if exists risk.ads_risk_id_user_address_level_df;

create table if not exists risk.ads_risk_id_user_address_level_df (
    user_id string
    ,address_level1_value string comment 'Province'
    ,address_level2_value string comment 'City'
    ,address_level3_value string comment 'District'
    ,shop_id              string comment 'shop owned by user'
    ,latitude             string comment 'address latitude'
    ,longitude            string comment 'address longitude'
    ,address              string comment 'address'
    ,latest_modify_time   string comment ''
)
partitioned by
    (grass_date string) stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_risk_id_user_address_level_df';

msck repair table risk.ads_risk_id_user_address_level_df;

insert overwrite ${SCHEMA}.ads_risk_id_user_address_level_df partition(grass_date = '${grass_date}')

select
       user_id,
       address_level1_value,
       address_level2_value,
       address_level3_value,
       shop_id,        -- 2025-11-11 by huangyue 
       latitude,       
       longitude,
       address,
       from_unixtime(modify_timestamp-3600) as latest_modify_time
from 
(
select row_number() over(partition by user_id order by modify_timestamp desc) as rk,
       user_id,
       address_level1_value,
       address_level2_value,
       address_level3_value,
       shop_id,        -- 2025-11-11 by huangyue 
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
                        ,cast(shop_id as string)   as shop_id     -- 2025-11-11 by huangyue 
                        ,cast(latitude as string)  as latitude        
                        ,cast(longitude as string) as longitude
                        ,cast(address as string)   as address
                        ,modify_timestamp
                from mp_user.dim_user_address__reg_s1_live
                where grass_region = 'ID' and grass_date = date('${grass_date}')
        ) as tmp 
) as tmp2 
where rk = 1
;