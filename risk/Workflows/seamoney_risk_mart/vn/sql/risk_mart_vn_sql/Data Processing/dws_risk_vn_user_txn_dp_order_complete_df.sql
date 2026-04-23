add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_dp_order_complete_df PARTITION (grass_date)
select
    t1.platform_user_id as platform_user_id,
    coalesce(t2.completed_order_30d,0) as completed_order_30d,
    coalesce(t2.completed_order_60d ,0) as completed_order_60d,
    coalesce(t2.completed_order_90d,0) as completed_order_90d,
    coalesce(t2.completed_order_120d,0) as completed_order_120d,
    coalesce(t2.completed_order_180d,0) as completed_order_180d,
    coalesce(t2.completed_order_360d,0) as completed_order_360d,
    '${ds}' as grass_date 
from (
     select distinct platform_user_id 
     from risk.dim_risk_${grass_region_lower}_user_info_df 
     where grass_date='${ds}'
) t1 
left join (
    select user_id,sum(if(complete_date between 0 and 30,1,0)) as completed_order_30d,
          sum(if(complete_date between 0 and 60,1,0)) as completed_order_60d,
          sum(if(complete_date between 0 and 90,1,0)) as completed_order_90d,
          sum(if(complete_date between 0 and 120,1,0)) as completed_order_120d,
          sum(if(complete_date between 0 and 180,1,0)) as completed_order_180d,
          sum(if(complete_date between 0 and 360,1,0)) as completed_order_360d
    from (
    select  user_id,DATEDIFF('${smd_grass_date}',date(format_time(complete_time,'${grass_region}'))) as complete_date 
    from   digitalpurchase.order_dwd_dp_trd_ord_df
    where   grass_date = '${ds}' and grass_region = '${grass_region}' and order_status = 'OR6'
  )tt 
    group by 1
) t2 on t1.platform_user_id=t2.user_id

;