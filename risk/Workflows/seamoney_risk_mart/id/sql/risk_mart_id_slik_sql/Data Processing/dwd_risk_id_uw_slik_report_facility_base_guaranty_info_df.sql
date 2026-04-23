insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guaranty_info_df partition (grass_date='${ds}')
select
    credit_facility_info_id
    ,credit_collateral_address
    ,credit_collateral_issurance
    ,credit_collateral_proof_number
    ,credit_collateral_type
    ,credit_collateral_binding_type_code
    ,credit_collateral_binding_type
    ,credit_collateral_city_code
    ,credit_collateral_city
    ,credit_collateral_information
    ,credit_collateral_rating_company_code
    ,credit_collateral_rating_company
    ,credit_collateral_name
    ,credit_collateral_appraisal_agency
    ,credit_collateral_value
    ,credit_collateral_value_njop
    ,credit_collateral_number
    ,credit_collateral_rating
    ,credit_collateral_percentage
    ,credit_collateral_binding_date
    ,credit_collateral_appraisal_date
    ,credit_collateral_update_date
    ,credit_collateral_appraisal_agency_name
    ,credit_collateral_valuation_date
from (
    select
        credit_facility_info_id
        ,get_json_object(agunan, '$.jenisAgunanKet') as credit_collateral_type
        ,get_json_object(agunan, '$.nilaiAgunanMenurutLJK') as credit_collateral_value
        ,get_json_object(agunan, '$.prosentaseParipasu') as credit_collateral_percentage
        ,get_json_object(agunan, '$.nomorAgunan') as credit_collateral_number
        ,get_json_object(agunan, '$.jenisPengikatan') as credit_collateral_binding_type_code
        ,get_json_object(agunan, '$.jenisPengikatanKet') as credit_collateral_binding_type
        ,get_json_object(agunan, '$.tanggalPengikatan') as credit_collateral_binding_date
        ,get_json_object(agunan, '$.namaPemilikAgunan') as credit_collateral_name
        ,get_json_object(agunan, '$.alamatAgunan') as credit_collateral_address
        ,get_json_object(agunan, '$.kabKotaLokasiAgunan') as credit_collateral_city_code
        ,get_json_object(agunan, '$.kabKotaLokasiAgunanKet') as credit_collateral_city
        ,get_json_object(agunan, '$.tglPenilaianPelapor') as credit_collateral_valuation_date
        ,get_json_object(agunan, '$.peringkatAgunan') as credit_collateral_rating
        ,get_json_object(agunan, '$.kodeLembagaPemeringkat') as credit_collateral_rating_company_code
        ,get_json_object(agunan, '$.lembagaPemeringkat') as credit_collateral_rating_company
        ,get_json_object(agunan, '$.buktiKepemilikan') as credit_collateral_proof_number
        ,get_json_object(agunan, '$.nilaiAgunanNjop') as credit_collateral_value_njop
        ,get_json_object(agunan, '$.nilaiAgunanIndep') as credit_collateral_appraisal_agency
        ,get_json_object(agunan, '$.namaPenilaiIndep') as credit_collateral_appraisal_agency_name
        ,get_json_object(agunan, '$.asuransi') as credit_collateral_issurance
        ,get_json_object(agunan, '$.tanggalPenilaianPenilaiIndependen') as credit_collateral_appraisal_date
        ,get_json_object(agunan, '$.keterangan') as credit_collateral_information
        ,case 
            when coalesce(get_json_object(agunan, '$.tanggalUpdate'),'') = '' then '19700101080001'
            else get_json_object(agunan, '$.tanggalUpdate')
            end as credit_collateral_update_date
    from (
        select
            credit_facility_info_id
            ,agunan as agunans
        from ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_info_df
        where grass_date = date('${ds}')
          and agunan is not null
          and agunan <> '[]'
    )    
    lateral view explode(split(regexp_replace(regexp_extract(agunans,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as agunan
);