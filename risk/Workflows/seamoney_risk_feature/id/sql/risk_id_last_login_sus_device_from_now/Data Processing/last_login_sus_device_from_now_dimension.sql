alter table ${SCHEMA}.last_login_sus_device_from_now_dimension drop if exists partition(dt <= '${delete_limit_date}');

insert overwrite ${SCHEMA}.last_login_sus_device_from_now_dimension partition (region = '${region_lower}', dt = '${bizdate}')
select 
    distinct(t.sz_dfp_device_id) as szdf
from (
    select 
        sz_dfp_device_id
    from Smcdrisk_antifraud.f_id_szdf_ato_risk_level_df
    -- date_format(grass_date, 'yyyy-MM-dd') = '${bizdate}'
    where grass_date in (select max(grass_date) from Smcdrisk_antifraud.f_id_szdf_ato_risk_level_df)
        and flag_risk_level = 'severe'
        and char_length(trim(sz_dfp_device_id)) > 0
    union all 
    select 
        sz_dfp_device_id
    from Smcdrisk_antifraud.f_id_szdf_risk_level_di
    -- date_format(grass_date, 'yyyy-MM-dd') = '${bizdate}'
    where grass_date in (select max(grass_date) from Smcdrisk_antifraud.f_id_szdf_risk_level_di)
        and flag_device_risk_level = 'severe'
        and char_length(trim(sz_dfp_device_id)) > 0
) t
;
