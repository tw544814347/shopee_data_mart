-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-01-09
-- Theme Domain:        Shopeefood Dish Category
-- Data Granularity:    dish_id
-- Description:         shopeefood vn dish category dimension table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-01-09 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dwd_risk_vn_shopeefood_mart_dim_vn_dish_category_da_df;
create external table if not exists ${SCHEMA}.dwd_risk_vn_shopeefood_mart_dim_vn_dish_category_da_df
(
    dish_id bigint comment 'dish id'
    ,dish_name string comment 'dish name'
    ,cate_l1_id bigint comment 'category level 1 id'
    ,cate_l1_name string comment 'category level 1 name'
    ,cate_l2_id bigint comment 'category level 2 id'
    ,cate_l2_name string comment 'category level 2 name'
    ,cate_l3_id bigint comment 'category level 3 id'
    ,cate_l3_name string comment 'category level 3 name'
    ,foody_service_id bigint comment 'foody service id'
    ,store_id bigint comment 'store id'
)
comment 'risk shopeefood vn dish category dimension table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_vn_shopeefood_mart_dim_vn_dish_category_da_df/grass_region=VN';
--msck repair table ${SCHEMA}.dwd_risk_vn_shopeefood_mart_dim_vn_dish_category_da_df;


insert overwrite table ${SCHEMA}.dwd_risk_vn_shopeefood_mart_dim_vn_dish_category_da_df partition (grass_date)
select
    dish_id
    ,dish_name
    ,cate_l1_id
    ,cate_l1_name
    ,cate_l2_id
    ,cate_l2_name
    ,cate_l3_id
    ,cate_l3_name
    ,foody_service_id
    ,store_id
    ,'${grass_date}' as grass_date
from shopeefood.shopeefood_mart_dim_vn_dish_category_da
where dt = '${grass_date}'
;