insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_user_base_info_df partition (grass_date='${ds}')
select
     ktp_request_id as qid
    ,debtor_name
    ,debtor_identity_type
    ,debtor_ktp
    ,debtor_Address
    ,debtor_gender
    ,debtor_gender_code
    ,npwp
    ,debtor_birthplace
    ,debtor_birthday
    ,grantor
    ,grantor_code
    ,debtor_info_create_date
    ,debtor_info_update_date
    ,village
    ,district
    ,city_code
    ,city
    ,postal_code
    ,country_code
    ,country
    ,occupation_code
    ,occupation
    ,working_location
    ,industry_code
    ,industry
    ,debtor_degree_code
    ,debtor_degree_status
from (
    select
        --ktp_id
        concat_ws('_', id_no, request_id) as ktp_request_id
        ,get_json_object(dataPokokDebitur, '$.namaDebitur') as debtor_name
        ,get_json_object(dataPokokDebitur, '$.identitas') as debtor_identity_type
        ,get_json_object(dataPokokDebitur, '$.noIdentitas') as debtor_ktp
        ,get_json_object(dataPokokDebitur, '$.alamat') as debtor_Address
        ,get_json_object(dataPokokDebitur, '$.jenisKelamin') as debtor_gender
        ,get_json_object(dataPokokDebitur, '$.jenisKelaminKet') as debtor_gender_code
        ,get_json_object(dataPokokDebitur, '$.npwp') as npwp
        ,get_json_object(dataPokokDebitur, '$.tempatLahir') as debtor_birthplace
        ,get_json_object(dataPokokDebitur, '$.tanggalLahir') as debtor_birthday
        ,get_json_object(dataPokokDebitur, '$.pelapor') as grantor
        ,get_json_object(dataPokokDebitur, '$.pelaporKet') as grantor_code
        ,get_json_object(dataPokokDebitur, '$.kelurahan') as village
        ,get_json_object(dataPokokDebitur, '$.kecamatan') as district
        ,get_json_object(dataPokokDebitur, '$.kabKota') as city_code
        ,get_json_object(dataPokokDebitur, '$.kabKotaKet') as city
        ,get_json_object(dataPokokDebitur, '$.kodePos') as postal_code
        ,get_json_object(dataPokokDebitur, '$.negara') as country_code
        ,get_json_object(dataPokokDebitur, '$.negaraKet') as country
        ,get_json_object(dataPokokDebitur, '$.pekerjaan') as occupation_code
        ,get_json_object(dataPokokDebitur, '$.pekerjaanKet') as occupation
        ,get_json_object(dataPokokDebitur, '$.tempatBekerja') as working_location
        ,get_json_object(dataPokokDebitur, '$.bidangUsaha') as industry_code
        ,get_json_object(dataPokokDebitur, '$.bidangUsahaKet') as industry
        ,get_json_object(dataPokokDebitur, '$.kodeGelarDebitur') as debtor_degree_code
        ,get_json_object(dataPokokDebitur, '$.statusGelarDebitur') as debtor_degree_status
        ,case 
            when coalesce(get_json_object(dataPokokDebitur, '$.tanggalDibentuk'),'') = '' then '19700101080001'
            else get_json_object(dataPokokDebitur, '$.tanggalDibentuk')
            end as debtor_info_create_date
        ,case 
            when coalesce(get_json_object(dataPokokDebitur, '$.tanggalUpdate'),'') = '' then '19700101080001'
            else get_json_object(dataPokokDebitur, '$.tanggalUpdate')
            end as debtor_info_update_date
    from (
        select 
            id_no
            ,request_id
            ,explode_table.dataPokokDebitur
        from (
            select
                --ktp_id
                get_json_object(result, '$.individual.parameterPencarian.noIdentitas') as id_no
                ,get_json_object(result, '$.header.idPermintaan') as request_id
                
                --others
                ,get_json_object(result,'$.individual.dataPokokDebitur') as dataPokokDebiturs
            from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
            where grass_date = '${ds}'
              and get_json_object(result,'$.individual.dataPokokDebitur') is not null
              and get_json_object(result,'$.individual.dataPokokDebitur') <> '[]'
        )
        lateral view explode(split(regexp_replace(regexp_extract(dataPokokDebiturs,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as dataPokokDebitur
    )
);
