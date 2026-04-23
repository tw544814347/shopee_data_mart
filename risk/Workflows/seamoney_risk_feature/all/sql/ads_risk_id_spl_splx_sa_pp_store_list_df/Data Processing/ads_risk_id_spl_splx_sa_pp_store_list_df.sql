-- drop table if exists risk.ads_risk_id_spl_splx_sa_pp_store_list_df;

-- create table risk.ads_risk_id_spl_splx_sa_pp_store_list_df (
--     sa_qr_link string
--     ,original_sa_qr_link string
--     ,sa_name string 
--     ,status bigint  
--     ,sid bigint

--     ,gps_latitude decimal(20,10)
--     ,gps_longitude decimal(20,10)
-- )
-- partitioned by
--     (grass_date string) stored as orc 
-- tblproperties ("orc.compress" = "zstd") 
-- location '${HDFS_PATH}/risk_feature/ads/ads_risk_id_spl_splx_sa_pp_store_list_df';

with tmp as (
SELECT 
  REGEXP_EXTRACT(sa_qr_link, 'from=([^()]*)', 1) AS sa_qr_link
  ,sa_qr_link as original_sa_qr_link
  ,sa_name
  ,cast(status as bigint) as status
  ,cast(sid as bigint) as sid
FROM smcdrisk_policy.splx_offline_sa_pp_store_list
WHERE sa_qr_link IS NOT NULL 
),

tmp2 as (
select
  sa_qr_link
  ,original_sa_qr_link
  ,sa_name
  ,row_number() over(partition by sa_qr_link order by status desc) as rk
  ,status
  ,sid
from tmp 
)

INSERT OVERWRITE TABLE risk.ads_risk_id_spl_splx_sa_pp_store_list_df PARTITION (grass_date = '${ds}')

select 
  tmp2.sa_qr_link
  ,tmp2.original_sa_qr_link
  ,tmp2.sa_name
  ,tmp2.status
  ,tmp2.sid
  
  ,t1.gps_latitude
  ,t1.gps_longitude
from tmp2
left join smcdrisk_antifraud.f_id_cicilan_store_whitelist_detail t1
  on tmp2.sid=t1.store_id
where tmp2.rk = 1