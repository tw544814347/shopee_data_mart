insert overwrite table ${SCHEMA}.ads_risk_sync_spp_list_di partition (grass_region, grass_date, table_name)
select  data
        ,datatype
        ,'DE daily update ${ds}' as remark
        ,table_name description
        ,flag status
        ,grass_region grass_region
        ,'${ds}' grass_date
        ,table_name
from    (
    select  data
            ,dataType
            ,grass_region
            ,table_name
            ,sum(flag) flag
    from    (
        select  data
                ,dataType
                ,grass_region
                ,table_name
                ,1 flag
        from    ${SCHEMA}.ads_risk_sync_spp_list_df
        where   grass_date = '${ds}'
        group by dataType
                ,grass_region
                ,table_name
                ,data
        union all 
        select  data
                ,dataType
                ,grass_region
                ,table_name
                ,-1 flag
        from    ${SCHEMA}.ads_risk_sync_spp_list_df
        where   grass_date = date_sub('${ds}', 1)
        group by dataType
                ,grass_region
                ,table_name
                ,data
    ) t2
    group by data, dataType, grass_region, table_name
)
where   flag <> 0	--=0 all exists
;