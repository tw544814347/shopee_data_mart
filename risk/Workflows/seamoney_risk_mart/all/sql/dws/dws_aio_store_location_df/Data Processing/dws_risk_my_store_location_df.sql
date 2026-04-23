insert overwrite table ${SCHEMA}.dws_risk_${region}_store_location_df partition (grass_date)
select
    store_unique_id
    ,case
        when store_id_type = 1 then 1
        when store_id_type = 2 then 4
    end as store_id_type
    ,collect_set(cluster_id)
    ,collect_list(concat('(', lat, ', ', lng, ')')) as lat_lng_list
    ,'${grass_date}' as grass_date
from
    (
        select
            t1.store_unique_id
            ,t1.cluster_id
            ,t1.store_id_type
            ,t1.lat
            ,t1.lng
            ,t1.grass_date
        from
            rescbds_credit.${region}_spp_merchant_location_cluster t1
            inner join (
                select
                    store_unique_id
                    ,cluster_id
                    ,max(grass_date) as grass_date
                from rescbds_credit.${region}_spp_merchant_location_cluster
                group by store_unique_id, cluster_id
            ) t2 on t1.store_unique_id = t2.store_unique_id
            and t1.cluster_id = t2.cluster_id
            and t1.grass_date = t2.grass_date
    )
group by store_unique_id, store_id_type
;