--jira: https://casement.scredit.io/project/78703/version?versionTab=task&versionId=7013&jiraKey=SPFDT-45649
--date: 2024-11-08
--editor: wei.tao

insert overwrite table ${SCHEMA}.dws_risk_${region}_store_location_df partition(grass_date)
select
    store_unique_id
    ,case when store_id_type in (1,2) then 1 when store_id_type in (3) then 2 when store_id_type = 5 then 3 when store_id_type = 6 then 4 else null end as store_id_type
    ,collect_set(cluster_id)
    ,collect_list(concat('(', lat, ', ', lng, ')')) as lat_lng_list
    ,'${grass_date}' as grass_date
from
    (   
        select 
            tmp.store_unique_id
            ,tmp.cluster_id
            ,tmp.store_id_type
            ,tmp.lat
            ,tmp.lng
            ,tmp.grass_date
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
            rescbds_credit.id_spp_merchant_location_cluster t1
            inner join (
                select
                    store_unique_id
                    ,cluster_id
                    ,max(grass_date) as grass_date
                from rescbds_credit.id_spp_merchant_location_cluster
                group by store_unique_id, cluster_id
            ) t2 on t1.store_unique_id = t2.store_unique_id
            and t1.cluster_id = t2.cluster_id
            and t1.grass_date = t2.grass_date
        --
            where t1.store_id_type not in (3,4) 
        --
        ) tmp 

        union all
--
        select
            t1.qr_acquiremerchant_id
            ,t1.cluster_id
            ,3 as store_id_type
            ,t1.lat
            ,t1.lng
            ,t1.grass_date
        from
            rescbds_credit.id_spp_merchant_location_cluster_qr_acquire t1
            inner join (
                select
                    qr_acquiremerchant_id
                    ,cluster_id
                    ,max(grass_date) as grass_date
                from rescbds_credit.id_spp_merchant_location_cluster_qr_acquire
                group by qr_acquiremerchant_id, cluster_id
            ) t2 on t1.qr_acquiremerchant_id = t2.qr_acquiremerchant_id
            and t1.cluster_id = t2.cluster_id
            and t1.grass_date = t2.grass_date
--
        union all
        select
            t1.mpan as store_unique_id
            ,t1.cluster_id
            ,6 as store_id_type
            ,t1.lat
            ,t1.lng
            ,t1.grass_date
        from
            rescbds_credit.id_spp_merchant_location_cluster_mpan t1
            inner join (
                select
                    mpan
                    ,cluster_id
                    ,max(grass_date) as grass_date
                from rescbds_credit.id_spp_merchant_location_cluster_mpan
                group by mpan, cluster_id
            ) t2 on t1.mpan = t2.mpan
            and t1.cluster_id = t2.cluster_id
            and t1.grass_date = t2.grass_date

    )
group by store_unique_id, store_id_type
;


