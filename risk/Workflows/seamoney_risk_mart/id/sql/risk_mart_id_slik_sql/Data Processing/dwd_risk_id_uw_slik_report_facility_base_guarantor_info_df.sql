insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guarantor_info_df partition (grass_date='${ds}')
select
    credit_facility_info_id
    ,guarantor_address
    ,guarantor_information
    ,guarantor_type
    ,guarantor_code
    ,guarantor_name
    ,guarantor_id
    ,guarantor_create_date
    ,guarantor_update_date
from (
    select
        credit_facility_info_id
        ,get_json_object(penjamin, '$.alamatPenjamin') as guarantor_address
        ,get_json_object(penjamin, '$.keterangan') as guarantor_information
        ,get_json_object(penjamin, '$.keteranganJenisPenjamin') as guarantor_type
        ,get_json_object(penjamin, '$.kodeJenisPenjamin') as guarantor_code
        ,get_json_object(penjamin, '$.namaPenjamin') as guarantor_name
        ,get_json_object(penjamin, '$.nomorIdentitas') as guarantor_id
        ,case 
            when coalesce(get_json_object(penjamin, '$.tanggalBuat'),'') = '' then '19700101080001'
            else get_json_object(penjamin, '$.tanggalBuat')
            end as guarantor_create_date
        ,case 
            when coalesce(get_json_object(penjamin, '$.tanggalUpdate'),'') = '' then '19700101080001'
            else get_json_object(penjamin, '$.tanggalUpdate')
            end as guarantor_update_date
    from (
        select
            credit_facility_info_id
            ,penjamin as penjamins
        from ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_info_df
        where grass_date = date('${ds}')
          and penjamin is not null
          and penjamin <> '[]'
    )
    lateral view explode(split(regexp_replace(regexp_extract(penjamins,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as penjamin
);
