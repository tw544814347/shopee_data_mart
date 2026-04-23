insert overwrite table ${SCHEMA}.ads_risk_id_seller_data_df partition(grass_date = '${grass_date}')
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'seller_type') as rowkey
       ,cast(seller_type as string) as qf
       
from (
  select user_id,shop_id,seller_type
        ,row_number() over(partition by user_id, shop_id order by grass_date desc) asc_rn 
  from idecbi_eng.ec_shopee_bd_bsm_seller_dim__seller_segmenting
  where user_id > 0
  and shop_id > 0
  and char_length(seller_type) > 0
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1

union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'shop_id') as rowkey
       ,cast(shop_id as string) as qf
       
from (
  select user_id,shop_id,seller_type
        ,row_number() over(partition by user_id, shop_id order by grass_date desc) asc_rn 
  from idecbi_eng.ec_shopee_bd_bsm_seller_dim__seller_segmenting
  where user_id > 0
  and shop_id > 0
  and char_length(seller_type) > 0
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1

union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'shop_id') as rowkey
       ,cast(shop_id as string) as qf
       
from (
  select user_id,shop_id
        ,row_number() over(partition by user_id, shop_id,grass_region  order by grass_date desc) asc_rn 
  from mp_user.dim_shop__id_s0_live
where user_id > 0
  and shop_id > 0
  and grass_region = 'ID'
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1

union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'is_preferred_plus_shop') as rowkey
       ,cast(is_preferred_plus_shop as string) as qf
       
from (
  select user_id,shop_id,is_preferred_plus_shop
        ,row_number() over(partition by user_id, shop_id,grass_region  order by grass_date desc) asc_rn 
  from mp_user.dim_shop__id_s0_live
where user_id > 0
  and shop_id > 0
  and char_length(cast(is_preferred_plus_shop as string)) > 0
  and grass_region = 'ID'
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1

union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'is_preferred_shop') as rowkey
       ,cast(is_preferred_shop as string) as qf
       
from (
  select user_id,shop_id,is_preferred_shop
        ,row_number() over(partition by user_id, shop_id,grass_region  order by grass_date desc) asc_rn 
  from mp_user.dim_shop__id_s0_live
where user_id > 0
  and shop_id > 0
  and char_length(cast(is_preferred_shop as string)) > 0
  and grass_region = 'ID'
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1


union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'is_official_shop') as rowkey
       ,cast(is_official_shop as string) as qf
       
from (
  select user_id,shop_id,is_official_shop
        ,row_number() over(partition by user_id, shop_id,grass_region  order by grass_date desc) asc_rn 
  from mp_user.dim_shop__id_s0_live
where user_id > 0
  and shop_id > 0
  and char_length(cast(is_official_shop as string)) > 0
  and grass_region = 'ID'
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1

union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'shop_id') as rowkey
       ,cast(shop_id as string) as qf
       
from (
  select user_id,shop_id
        ,row_number() over(partition by user_id, shop_id,grass_region  order by grass_date desc) asc_rn 
  from mp_user.dim_user__id_s0_live
where user_id > 0
  and shop_id > 0
  and grass_region = 'ID'
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1

union all 
select concat_ws('_', substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), 'is_seller') as rowkey
       ,cast(is_seller as string) as qf
       
from (
  select user_id,shop_id,is_seller
        ,row_number() over(partition by user_id, shop_id,grass_region  order by grass_date desc) asc_rn 
  from mp_user.dim_user__id_s0_live
where user_id > 0
  and shop_id > 0
  and char_length(cast(is_seller as string)) > 0
  and grass_region = 'ID'
  and grass_date >= date_sub('${grass_date}', 30)
)
where asc_rn = 1
;





