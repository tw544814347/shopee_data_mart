create or replace view ${SCHEMA}.dim_risk_item_df
(
    item_id comment 'item id '
    ,level1_global_be_category_id comment 'item  level 1 category id '
    ,level1_global_be_category comment 'item level 1 category name '
    ,is_physical_product comment 'is the physical product defined by the level1_global_be_category name. Y : physical product, N : non-physical product '
    ,tz_type comment 'partition '
    ,grass_region comment 'partition : ID / VN / TH / SG / TW / MY / PH / BR '
    ,grass_date comment 'partition : format: yyyy-MM-dd'
)
comment 'The item table used to risk mart'
as
select
    item_id
    ,level1_global_be_category_id
    ,level1_global_be_category
    -- ,case
    --     when grass_region = 'ID' and level1_global_be_category in ('Vouchers', 'Paid Ads') then 'N'
    --     when grass_region = 'PH' and level1_global_be_category_id in (cast(15580 as bigint)) then 'N'
    --     when grass_region = 'TH' and level1_global_be_category_id in (cast(15580 as bigint)) then 'N'
    --     when grass_region = 'PW' and level1_global_be_category_id in (cast(15580 as bigint)) then 'N'
    --     when grass_region = 'TW' and level1_global_be_category_id in (cast(74 as bigint), cast(10202 as bigint)) then 'N'
    --     else 'Y'
    --     end as is_physical_product
    ,case
        when level1_global_be_category_id in (100642) then 'N'
        else 'Y' end as is_physical_product
    ,'local' as tz_type
    ,grass_region
    ,grass_date
from mp_item.dim_item__reg_s0_live;