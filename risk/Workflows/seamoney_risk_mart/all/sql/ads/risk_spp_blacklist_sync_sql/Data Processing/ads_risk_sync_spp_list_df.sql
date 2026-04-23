insert overwrite table ${SCHEMA}.ads_risk_sync_spp_list_df partition (grass_region, grass_date, table_name)
select  data
        ,datatype
        ,'ID' grass_region
        ,'${ds}' grass_date
        ,'opv_blacklist_userid_holmes_fraudtag_id_df' as table_name
from    smcdrisk_antifraud.opv_blacklist_userid_holmes_fraudtag_id_df
group by data
        ,datatype
;