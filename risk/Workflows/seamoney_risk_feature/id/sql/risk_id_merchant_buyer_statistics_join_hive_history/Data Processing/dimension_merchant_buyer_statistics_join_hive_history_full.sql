alter table ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_full drop if exists partition(grass_region = '${region_upper}', grass_date < '${delete_limit_date}');

-- High risk Hex8、High risk Hex10、MP address different cit
create or replace temporary view filter_latest_view as 
select 
    'hex8' as flag,
    gps_hex_8 as flag_key,
    '1' as flag_object,
    date_format(grass_date, 'yyyy-MM-dd') as latest_grass_date
from Smcdrisk_antifraud.gps_profile_hex8
where hex_tag_final = '01.good'
    and char_length(trim(gps_hex_8)) > 0
    and grass_date in (select max(grass_date) from Smcdrisk_antifraud.gps_profile_hex8)
union all 
select 
    'hex10' as flag,
    gps_hex_10 as flag_key,
    '1' as flag_object,
    date_format(grass_date, 'yyyy-MM-dd') as latest_grass_date
from Smcdrisk_antifraud.gps_profile_hex10
where hex_tag_final = '01.good'
    and char_length(trim(gps_hex_10)) > 0
    and grass_date in (select max(grass_date) from Smcdrisk_antifraud.gps_profile_hex10)
union all 
select 
    'address' as flag,
    cast(user_id as string) as flag_key,
    base64(trim(config_addr_list_td)) as flag_object,
    '${bizdate}' as latest_grass_date
from risk.ads_risk_profile_user_df
where grass_region = '${region_upper}'
    and grass_date in (
            select max(grass_date) from risk.ads_risk_profile_user_df 
            where grass_region = '${region_upper}'
                and grass_date >= '${grass_limit_date}'
        )
    and char_length(cast(user_id as string)) > 0
    and char_length(trim(config_addr_list_td)) > 0
;

insert overwrite ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_full partition(grass_region = '${region_upper}', grass_date = '${bizdate}')
select 
    flag,
    flag_key,
    flag_object,
    latest_grass_date
from filter_latest_view
;