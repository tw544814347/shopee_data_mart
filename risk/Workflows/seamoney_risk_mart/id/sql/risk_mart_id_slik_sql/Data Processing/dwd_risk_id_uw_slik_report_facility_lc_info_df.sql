insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_lc_info_df partition (grass_date='${ds}')
select
    ktp_request_id
    ,lc_json
from (
    select
        --ktp_id
        concat_ws('_', id_no, request_id) as ktp_request_id
        ,lc as lc_json
    from (
        select 
            id_no
            ,request_id
            ,explode_table.lc
        from (
            select
                --ktp_id
                get_json_object(result, '$.individual.parameterPencarian.noIdentitas') as id_no
                ,get_json_object(result, '$.header.idPermintaan') as request_id
                
                --others
                ,get_json_object(result,'$.individual.fasilitas.lc') as lcs
            from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
            where grass_date = '${ds}'
              and get_json_object(result,'$.individual.fasilitas.lc') is not null
              and get_json_object(result,'$.individual.fasilitas.lc') <> '[]'
        )
        lateral view explode(split(regexp_replace(regexp_extract(lcs,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as lc
    )
);
