--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-12-25
-- Theme Domain：       risk-feature
-- Description:        
-- Data Granularity:    credit_user_id
-- 变更历史：
--  v1 by wei.tao@shopee.com，jira:https://jira.shopee.io/browse/SPFDT-58774
--********************************************************************--

-- DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_sg_user_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_sg_user_dpd_df(
  user_id                            STRING comment 'credit_user_id',
  ever_max_dpd_spl_core              BIGINT comment '',
  ever_max_dpd_spl_lite_core         BIGINT comment '',
  ever_max_dpd_spl_normal_core       BIGINT comment '',
  ever_max_dpd_180d_spl              BIGINT comment ''
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=SG';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_sg_user_dpd_df;


INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_sg_user_dpd_df PARTITION (grass_date)
select 
    t1.user_id
     ,coalesce(t2.historical_max_dpd_eod,-9999)                 as ever_max_dpd_spl_core
     ,coalesce(t2.historical_max_dpd_lite,-9999)                as ever_max_dpd_spl_lite_core
     ,coalesce(t2.historical_max_dpd_normal,-9999)              as ever_max_dpd_spl_normal_core
     ,coalesce(t3.ever_max_dpd_180d, -9999)                     as ever_max_dpd_180d_spl
     ,t1.grass_date                                             as grass_date
from 
    (
        select
            credit_user_id as user_id
            ,grass_date
        from credit_uc.dws_aio_sg_uc_user_df
        where grass_date = '${ds}'
        and credit_user_id is not null
        group by credit_user_id, grass_date
    )t1
left join
    (
        select
            credit_user_id as user_id
                ,max(historical_max_dpd_eod) as historical_max_dpd_eod
                ,max(historical_max_dpd_eod_lite) as historical_max_dpd_lite
                ,max(historical_max_dpd_eod_normal) as historical_max_dpd_normal
                ,grass_date
        from
            credit_mart.tdm_sg_user_dpd_df
        where
            grass_date = '${ds}'
        group by credit_user_id, grass_date
    )t2
    on  t1.user_id = t2.user_id
left join 
    (
        select
            credit_user_id as user_id
             ,max(ever_max_dpd_180d) as ever_max_dpd_180d
             ,grass_date
        from credit_mart.dws_spl_sg_user_df
        where grass_date = '${ds}'
        group by credit_user_id, grass_date
    )t3 on t1.user_id=t3.user_id