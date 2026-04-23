--********************************************************************--
-- Author:              nuo.chen@shopee.com
-- Created Time:        2026-02-25
-- Theme Domain：       
-- Description:         新增profile计算平均渗透率
-- Data Granularity:    shop_id + item_id
-- 文档:                 https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60500
-- 注意:                 SHCAME和SQL在一起, 新增字段记得解开drop + msck, 跑完后注释掉drop + msck (表分区多后会影响SLA)!!!              
-- 变更历史：             
-- 2026-02-25   chennuo    创建脚本
--********************************************************************--

-- drop table if exists ${SCHEMA}.ads_risk_id_mp_profile_spl_pene_df;
create external table if not exists ${SCHEMA}.ads_risk_id_mp_profile_spl_pene_df
(
    shop_id             string
    ,item_id            string
    ,spl_pene           decimal(25,10)
    ,region             string
)partitioned by(
    grass_date          string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_mp_profile_spl_pene_df'
;

-- msck repair table ${SCHEMA}.ads_risk_id_mp_profile_spl_pene_df;
-- refresh table ${SCHEMA}.ads_risk_id_mp_profile_spl_pene_df;


insert overwrite ${SCHEMA}.ads_risk_id_mp_profile_spl_pene_df partition (grass_date)
select 
    shop_id
    ,item_id
    ,sum(case when payment_method_id = 24 then nmv else null end)/ sum(nmv) as spl_pene
    ,'ID'       as region
    ,'${ds}'    as grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where grass_region = 'ID'
    and order_be_status_id in (2,4,11,12,13,14,15)
    and from_unixtime(create_timestamp) >= add_months(date('${ds}'), -2) 
    and from_unixtime(create_timestamp) < date('${ds}')
    and nmv > 0
    and tz_type = 'local'
group by 1,2

