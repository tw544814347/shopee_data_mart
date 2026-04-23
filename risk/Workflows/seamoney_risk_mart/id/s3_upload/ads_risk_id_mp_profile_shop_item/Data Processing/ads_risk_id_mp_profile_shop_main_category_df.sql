--********************************************************************--
-- Author:              nuo.chen@shopee.com
-- Created Time:        2026-02-25
-- Theme Domain：       
-- Description:         新增profile计算店铺主要类别
-- Data Granularity:    shop_id
-- 文档:                 https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60500
-- 注意:                 SHCAME和SQL在一起, 新增字段记得解开drop + msck, 跑完后注释掉drop + msck (表分区多后会影响SLA)!!!              
-- 变更历史：             
-- 2026-02-25   chennuo    创建脚本
--********************************************************************--

-- drop table if exists ${SCHEMA}.ads_risk_id_mp_profile_shop_main_category_df;
create external table if not exists ${SCHEMA}.ads_risk_id_mp_profile_shop_main_category_df
(
    shop_id                 string
    ,shop_main_category     string
    ,region                 string
)partitioned by(
    grass_date              string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_mp_profile_shop_main_category_df'
;

-- msck repair table ${SCHEMA}.ads_risk_id_mp_profile_shop_main_category_df;
-- refresh table ${SCHEMA}.ads_risk_id_mp_profile_shop_main_category_df;


insert overwrite ${SCHEMA}.ads_risk_id_mp_profile_shop_main_category_df partition (grass_date)
select 
    shop_id
    ,max_by(level1_global_be_category, nmv) as shop_main_category
    ,'ID' as region 
    ,'${ds}' as grass_date
from(
    select 
        shop_id
        ,level1_global_be_category
        ,sum(nmv) as nmv
    from mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where grass_region = 'ID'
        and order_be_status_id in (2,4,11,12,13,14,15)
        and from_unixtime(create_timestamp) >= add_months(date('${ds}'), -1) 
        and from_unixtime(create_timestamp) < date('${ds}')
        and grass_date >= add_months(date('${ds}'), -1)  
        and grass_date < date('${ds}')
        and nmv > 0
        and tz_type = 'local'
    group by 1,2
        )
group by 1