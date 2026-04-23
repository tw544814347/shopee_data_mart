insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_lain_info_df partition (grass_date='${ds}')
select
    ktp_request_id
    ,o_month
    ,o_branch
    ,o_branch_code
    ,o_facility_type
    ,o_dpd
    ,o_information
    ,o_facility_type_code
    ,o_facility_condition
    ,o_loss_reason_code
    ,o_facility_currency
    ,o_facility_condition_code
    ,o_current_status_code
    ,o_current_status
    ,o_ljk_code
    ,o_ljk_name
    ,o_value_original_currency
    ,o_contract_number
    ,o_principle_idr
    ,o_loss_reason_des
    ,o_interest_rate
    ,o_year
    ,o_last_24m_dpd
    ,o_last_24m_month
    ,o_last_24m_status
    ,o_last_23m_dpd
    ,o_last_23m_month
    ,o_last_23m_status
    ,o_last_22m_dpd
    ,o_last_22m_month
    ,o_last_22m_status
    ,o_last_21m_dpd
    ,o_last_21m_month
    ,o_last_21m_status
    ,o_last_20m_dpd
    ,o_last_20m_month
    ,o_last_20m_status
    ,o_last_19m_dpd
    ,o_last_19m_month
    ,o_last_19m_status
    ,o_last_18m_dpd
    ,o_last_18m_month
    ,o_last_18m_status
    ,o_last_17m_dpd
    ,o_last_17m_month
    ,o_last_17m_status
    ,o_last_16m_dpd
    ,o_last_16m_month
    ,o_last_16m_status
    ,o_last_15m_dpd
    ,o_last_15m_month
    ,o_last_15m_status
    ,o_last_14m_dpd
    ,o_last_14m_month
    ,o_last_14m_status
    ,o_last_13m_dpd
    ,o_last_13m_month
    ,o_last_13m_status
    ,o_last_12m_dpd
    ,o_last_12m_month
    ,o_last_12m_status
    ,o_last_11m_dpd
    ,o_last_11m_month
    ,o_last_11m_status
    ,o_last_10m_dpd
    ,o_last_10m_month
    ,o_last_10m_status
    ,o_last_09m_dpd
    ,o_last_09m_month
    ,o_last_09m_status
    ,o_last_08m_dpd
    ,o_last_08m_month
    ,o_last_08m_status
    ,o_last_07m_dpd
    ,o_last_07m_month
    ,o_last_07m_status
    ,o_last_06m_dpd
    ,o_last_06m_month
    ,o_last_06m_status
    ,o_last_05m_dpd
    ,o_last_05m_month
    ,o_last_05m_status
    ,o_last_04m_dpd
    ,o_last_04m_month
    ,o_last_04m_status
    ,o_last_03m_dpd
    ,o_last_03m_month
    ,o_last_03m_status
    ,o_last_02m_dpd
    ,o_last_02m_month
    ,o_last_02m_status
    ,o_last_01m_dpd
    ,o_last_01m_month
    ,o_last_01m_status
    ,o_create_date
    ,o_expire_date
    ,o_condition_date
    ,o_loss_date
    ,o_start_date
    ,o_update_date
    ,o_overdue_days
from (
    select
        --ktp_id
        concat_ws('_', id_no, request_id) as ktp_request_id
        ,get_json_object(fasilitasLain, '$.bulan') as o_month
        ,get_json_object(fasilitasLain, '$.cabang') as o_branch
        ,get_json_object(fasilitasLain, '$.cabangKet') as o_branch_code
        ,get_json_object(fasilitasLain, '$.jenisFasilitasKet') as o_facility_type
        ,get_json_object(fasilitasLain, '$.jumlahHariTunggakan') as o_dpd
        ,get_json_object(fasilitasLain, '$.keterangan') as o_information
        ,get_json_object(fasilitasLain, '$.kodeJenisFasilitas') as o_facility_type_code
        ,get_json_object(fasilitasLain, '$.kodeKondisi') as o_facility_condition
        ,get_json_object(fasilitasLain, '$.kodeSebabMacet') as o_loss_reason_code
        ,get_json_object(fasilitasLain, '$.kodeValuta') as o_facility_currency
        ,get_json_object(fasilitasLain, '$.kondisiKet') as o_facility_condition_code
        ,get_json_object(fasilitasLain, '$.kualitas') as o_current_status_code
        ,get_json_object(fasilitasLain, '$.kualitasKet') as o_current_status
        ,get_json_object(fasilitasLain, '$.ljk') as o_ljk_code
        ,get_json_object(fasilitasLain, '$.ljkKet') as o_ljk_name
        ,get_json_object(fasilitasLain, '$.nilaiDalamMataUangAsal') as o_value_original_currency
        ,get_json_object(fasilitasLain, '$.noRekening') as o_contract_number
        ,get_json_object(fasilitasLain, '$.nominalJumlahKwajibanIDR') as o_principle_idr
        ,get_json_object(fasilitasLain, '$.sebabMacetDesc') as o_loss_reason_des
        ,get_json_object(fasilitasLain, '$.sukuBungaImbalan') as o_interest_rate
        ,get_json_object(fasilitasLain, '$.tahun') as o_year
        ,get_json_object(fasilitasLain, '$.tahunBulan01') as o_last_24m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan01Ht') as o_last_24m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan01Kol') as o_last_24m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan02') as o_last_23m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan02Ht') as o_last_23m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan02Kol') as o_last_23m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan03') as o_last_22m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan03Ht') as o_last_22m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan03Kol') as o_last_22m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan04') as o_last_21m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan04Ht') as o_last_21m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan04Kol') as o_last_21m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan05') as o_last_20m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan05Ht') as o_last_20m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan05Kol') as o_last_20m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan06') as o_last_19m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan06Ht') as o_last_19m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan06Kol') as o_last_19m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan07') as o_last_18m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan07Ht') as o_last_18m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan07Kol') as o_last_18m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan08') as o_last_17m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan08Ht') as o_last_17m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan08Kol') as o_last_17m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan09') as o_last_16m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan09Ht') as o_last_16m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan09Kol') as o_last_16m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan10') as o_last_15m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan10Ht') as o_last_15m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan10Kol') as o_last_15m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan11') as o_last_14m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan11Ht') as o_last_14m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan11Kol') as o_last_14m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan12') as o_last_13m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan12Ht') as o_last_13m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan12Kol') as o_last_13m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan13') as o_last_12m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan13Ht') as o_last_12m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan13Kol') as o_last_12m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan14') as o_last_11m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan14Ht') as o_last_11m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan14Kol') as o_last_11m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan15') as o_last_10m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan15Ht') as o_last_10m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan15Kol') as o_last_10m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan16') as o_last_09m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan16Ht') as o_last_09m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan16Kol') as o_last_09m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan17') as o_last_08m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan17Ht') as o_last_08m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan17Kol') as o_last_08m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan18') as o_last_07m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan18Ht') as o_last_07m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan18Kol') as o_last_07m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan19') as o_last_06m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan19Ht') as o_last_06m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan19Kol') as o_last_06m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan20') as o_last_05m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan20Ht') as o_last_05m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan20Kol') as o_last_05m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan21') as o_last_04m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan21Ht') as o_last_04m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan21Kol') as o_last_04m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan22') as o_last_03m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan22Ht') as o_last_03m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan22Kol') as o_last_03m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan23') as o_last_02m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan23Ht') as o_last_02m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan23Kol') as o_last_02m_status
        ,get_json_object(fasilitasLain, '$.tahunBulan24') as o_last_01m_month
        ,get_json_object(fasilitasLain, '$.tahunBulan24Ht') as o_last_01m_dpd
        ,get_json_object(fasilitasLain, '$.tahunBulan24Kol') as o_last_01m_status
        ,get_json_object(fasilitasLain, '$.tanggalJatuhTempo') as o_expire_date
        ,get_json_object(fasilitasLain, '$.tanggalKondisi') as o_condition_date
        ,get_json_object(fasilitasLain, '$.tanggalMacet') as o_loss_date
        ,get_json_object(fasilitasLain, '$.tanggalMulai') as o_start_date
        ,get_json_object(fasilitasLain, '$.tunggakan') as o_overdue_days
        ,case 
            when coalesce(get_json_object(fasilitasLain, '$.tanggalDibentuk'),'') = '' then '19700101080001'
            else get_json_object(fasilitasLain, '$.tanggalDibentuk')
            end as o_create_date
        ,case 
            when coalesce(get_json_object(fasilitasLain, '$.tanggalUpdate'),'') = '' then '19700101080001'
            else get_json_object(fasilitasLain, '$.tanggalUpdate')
            end as o_update_date
    from (
        select 
            id_no
            ,request_id
            ,explode_table.fasilitasLain
        from (
            select
                --ktp_id
                get_json_object(result, '$.individual.parameterPencarian.noIdentitas') as id_no
                ,get_json_object(result, '$.header.idPermintaan') as request_id
                
                --others
                ,get_json_object(result,'$.individual.fasilitas.fasilitasLain') as fasilitasLains
            from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
            where grass_date = '${ds}'
              and get_json_object(result,'$.individual.fasilitas.fasilitasLain') is not null
              and get_json_object(result,'$.individual.fasilitas.fasilitasLain') <> '[]'
        )
        lateral view explode(split(regexp_replace(regexp_extract(fasilitasLains,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as fasilitasLain
    )
);
