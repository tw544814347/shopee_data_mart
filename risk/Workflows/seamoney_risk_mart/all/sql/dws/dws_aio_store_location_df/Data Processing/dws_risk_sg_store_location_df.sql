--jira: https://jira.shopee.io/browse/SPFDT-52888
--editor: wei.tao

insert overwrite table ${SCHEMA}.dws_risk_${region}_store_location_df partition (grass_date)
select
    store_unique_id
    ,case when merchant_scope_name like '%On_us Merchant%' then 1
          when merchant_scope_name like '%Off_us Merchant%' then 7
          else null
          end
        as store_id_type
    ,collect_set(cluster_id)
    ,collect_list(concat('(', lat, ', ', lng, ')')) as lat_lng_list
    ,'${grass_date}' as grass_date
from
    (
        select
            t1.unique_store_key as store_unique_id
            ,t1.cluster_id 
            ,t1.merchant_scope_name
            --,t1.store_id_type
            ,t1.lat
            ,t1.lng
            ,t1.grass_date
        from
            rescbds_credit.${region}_spp_merchant_location_cluster_unique_store_key as t1
            inner join (
                select
                    unique_store_key as store_unique_id
                    ,cluster_id
                    ,max(grass_date) as grass_date
                from rescbds_credit.${region}_spp_merchant_location_cluster_unique_store_key
                group by store_unique_id, cluster_id
            ) t2 on t1.unique_store_key = t2.store_unique_id
            and t1.cluster_id = t2.cluster_id
            and t1.grass_date = t2.grass_date
    )
group by store_unique_id, store_id_type
;