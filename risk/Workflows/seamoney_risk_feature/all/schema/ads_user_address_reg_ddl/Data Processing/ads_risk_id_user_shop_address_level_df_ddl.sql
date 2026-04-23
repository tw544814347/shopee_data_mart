-- frf：https://docs.google.com/document/d/17coceaXjKzb9bB25nh0AXX2sgztsbxGGQFjgz_3tckQ/edit?tab=t.0
-- jira：https://jira.shopee.io/browse/SPFDT-57048 / https://jira.shopee.io/browse/SPFDT-58093
-- editor：wei.tao@shopee.com 
drop table if exists risk.ads_risk_id_user_shop_address_level_df;
create table if not exists risk.ads_risk_id_user_shop_address_level_df (
    user_id string
    ,address_level1_value string comment 'Province'
    ,address_level2_value string comment 'City'
    ,address_level3_value string comment 'District'
    ,shop_id              string comment 'shop owned by user'
    ,latitude             string comment 'address latitude'
    ,longitude            string comment 'address longitude'
    ,address              string comment 'address'
    ,latest_modify_time   string comment ''
    ,combine_key          string comment ''
)
partitioned by
    (grass_date string) stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_risk_id_user_shop_address_level_df';

msck repair table risk.ads_risk_id_user_shop_address_level_df;
