insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_info_df partition (grass_date='${ds}')
select
    ktp_request_id
    ,uuid() as credit_facility_info_id
    ,grantor_ojk_code
    ,grantor_name
    ,grantor_branch_code
    ,grantor_branch
    ,remain_balance
    ,facility_create_date
    ,facility_update_date
    ,credit_facility_month
    ,credit_facility_year
    ,facility_type_code
    ,facility_type
    ,facility_credit_type_code
    ,facility_credit_type
    ,credit_contract_agreement_code
    ,credit_contract_agreement
    ,contract_number
    ,frequency_extension
    ,contract_number_initial
    ,contract_effective_date
    ,contract_number_final
    ,contract_end_date
    ,credit_start_date
    ,start_date
    ,expire_date
    ,debtor_category_code
    ,debtor_category
    ,usage_type_code
    ,usage_type
    ,economic_sector_code
    ,economic_sector
    ,government_credit_program_code
    ,government_credit_program
    ,program_location_code
    ,program_location
    ,currency
    ,interest_rate
    ,interest_rate_type_code
    ,interest_rate_type
    ,current_status
    ,current_status_code
    ,overdue_days
    ,project_value
    ,inicial_loan_disburse
    ,loan_disburse
    ,disbursement_nominal
    ,value_original_currency
    ,loss_reason_code
    ,loss_reason
    ,loss_hapen_date
    ,overdue_principle
    ,overdue_interest
    ,overdue_frequency
    ,fine_amount
    ,restructure_frequency
    ,last_restructure_date
    ,restructure_method_code
    ,restructure_code
    ,credit_facility_condition
    ,condition_code
    ,condition_happen_date
    ,other_info
    ,last_24m_dpd
    ,last_24m_month
    ,last_24m_status
    ,last_23m_dpd
    ,last_23m_month
    ,last_23m_status
    ,last_22m_dpd
    ,last_22m_month
    ,last_22m_status
    ,last_21m_dpd
    ,last_21m_month
    ,last_21m_status
    ,last_20m_dpd
    ,last_20m_month
    ,last_20m_status
    ,last_19m_dpd
    ,last_19m_month
    ,last_19m_status
    ,last_18m_dpd
    ,last_18m_month
    ,last_18m_status
    ,last_17m_dpd
    ,last_17m_month
    ,last_17m_status
    ,last_16m_dpd
    ,last_16m_month
    ,last_16m_status
    ,last_15m_dpd
    ,last_15m_month
    ,last_15m_status
    ,last_14m_dpd
    ,last_14m_month
    ,last_14m_status
    ,last_13m_dpd
    ,last_13m_month
    ,last_13m_status
    ,last_12m_dpd
    ,last_12m_month
    ,last_12m_status
    ,last_11m_dpd
    ,last_11m_month
    ,last_11m_status
    ,last_10m_dpd
    ,last_10m_month
    ,last_10m_status
    ,last_09m_dpd
    ,last_09m_month
    ,last_09m_status
    ,last_08m_dpd
    ,last_08m_month
    ,last_08m_status
    ,last_07m_dpd
    ,last_07m_month
    ,last_07m_status
    ,last_06m_dpd
    ,last_06m_month
    ,last_06m_status
    ,last_05m_dpd
    ,last_05m_month
    ,last_05m_status
    ,last_04m_dpd
    ,last_04m_month
    ,last_04m_status
    ,last_03m_dpd
    ,last_03m_month
    ,last_03m_status
    ,last_02m_dpd
    ,last_02m_month
    ,last_02m_status
    ,last_01m_dpd
    ,last_01m_month
    ,last_01m_status
    ,agunan
    ,penjamin
from (
    select
        --ktp_id
        concat_ws('_', id_no, request_id) as ktp_request_id
        ,get_json_object(kreditPembiayan, '$.bulan') as o_month
        ,get_json_object(kreditPembiayan, '$.ljk') as grantor_ojk_code
        ,get_json_object(kreditPembiayan, '$.ljkKet') as grantor_name
        ,get_json_object(kreditPembiayan, '$.cabang') as grantor_branch_code
        ,get_json_object(kreditPembiayan, '$.cabangKet') as grantor_branch
        ,get_json_object(kreditPembiayan, '$.bakiDebet') as remain_balance
        ,get_json_object(kreditPembiayan, '$.bulan') as credit_facility_month
        ,get_json_object(kreditPembiayan, '$.tahun') as credit_facility_year
        ,get_json_object(kreditPembiayan, '$.sifatKreditPembiayaan') as facility_type_code
        ,get_json_object(kreditPembiayan, '$.sifatKreditPembiayaanKet') as facility_type
        ,get_json_object(kreditPembiayan, '$.jenisKreditPembiayaan') as facility_credit_type_code
        ,get_json_object(kreditPembiayan, '$.jenisKreditPembiayaanKet') as facility_credit_type
        ,get_json_object(kreditPembiayan, '$.akadKreditPembiayaan') as credit_contract_agreement_code
        ,get_json_object(kreditPembiayan, '$.akadKreditPembiayaanKet') as credit_contract_agreement
        ,get_json_object(kreditPembiayan, '$.noRekening') as contract_number
        ,get_json_object(kreditPembiayan, '$.frekPerpjganKreditPembiayaan') as frequency_extension
        ,get_json_object(kreditPembiayan, '$.noAkadAwal') as contract_number_initial
        ,get_json_object(kreditPembiayan, '$.tanggalAkadAwal') as contract_effective_date
        ,get_json_object(kreditPembiayan, '$.noAkadAkhir') as contract_number_final
        ,get_json_object(kreditPembiayan, '$.tanggalAkadAkhir') as contract_end_date
        ,get_json_object(kreditPembiayan, '$.tanggalAwalKredit') as credit_start_date
        ,get_json_object(kreditPembiayan, '$.tanggalMulai') as start_date
        ,get_json_object(kreditPembiayan, '$.tanggalJatuhTempo') as expire_date
        ,get_json_object(kreditPembiayan, '$.kategoriDebiturKode') as debtor_category_code
        ,get_json_object(kreditPembiayan, '$.kategoriDebiturKet') as debtor_category
        ,get_json_object(kreditPembiayan, '$.jenisPenggunaan') as usage_type_code
        ,get_json_object(kreditPembiayan, '$.jenisPenggunaanKet') as usage_type
        ,get_json_object(kreditPembiayan, '$.sektorEkonomi') as economic_sector_code
        ,get_json_object(kreditPembiayan, '$.sektorEkonomiKet') as economic_sector
        ,get_json_object(kreditPembiayan, '$.kreditProgramPemerintah') as government_credit_program_code
        ,get_json_object(kreditPembiayan, '$.kreditProgramPemerintahKet') as government_credit_program
        ,get_json_object(kreditPembiayan, '$.lokasiProyek') as program_location_code
        ,get_json_object(kreditPembiayan, '$.lokasiProyekKet') as program_location
        ,get_json_object(kreditPembiayan, '$.valutaKode') as currency
        ,get_json_object(kreditPembiayan, '$.sukuBungaImbalan') as interest_rate
        ,get_json_object(kreditPembiayan, '$.jenisSukuBungaImbalan') as interest_rate_type_code
        ,get_json_object(kreditPembiayan, '$.jenisSukuBungaImbalanKet') as interest_rate_type
        ,get_json_object(kreditPembiayan, '$.kualitas') as current_status
        ,get_json_object(kreditPembiayan, '$.kualitasKet') as current_status_code
        ,get_json_object(kreditPembiayan, '$.jumlahHariTunggakan') as overdue_days
        ,get_json_object(kreditPembiayan, '$.nilaiProyek') as project_value
        ,get_json_object(kreditPembiayan, '$.plafonAwal') as inicial_loan_disburse
        ,get_json_object(kreditPembiayan, '$.plafon') as loan_disburse
        ,get_json_object(kreditPembiayan, '$.realisasiBulanBerjalan') as disbursement_nominal
        ,get_json_object(kreditPembiayan, '$.nilaiDalamMataUangAsal') as value_original_currency
        ,get_json_object(kreditPembiayan, '$.kodeSebabMacet') as loss_reason_code
        ,get_json_object(kreditPembiayan, '$.sebabMacetKet') as loss_reason
        ,get_json_object(kreditPembiayan, '$.tanggalMacet') as loss_hapen_date
        ,get_json_object(kreditPembiayan, '$.tunggakanPokok') as overdue_principle
        ,get_json_object(kreditPembiayan, '$.tunggakanBunga') as overdue_interest
        ,get_json_object(kreditPembiayan, '$.frekuensiTunggakan') as overdue_frequency
        ,get_json_object(kreditPembiayan, '$.denda') as fine_amount
        ,get_json_object(kreditPembiayan, '$.frekuensiRestrukturisasi') as restructure_frequency
        ,get_json_object(kreditPembiayan, '$.tanggalRestrukturisasiAkhir') as last_restructure_date
        ,get_json_object(kreditPembiayan, '$.kodeCaraRestrukturisasi') as restructure_method_code
        ,get_json_object(kreditPembiayan, '$.restrukturisasiKet') as restructure_code
        ,get_json_object(kreditPembiayan, '$.kondisi') as credit_facility_condition
        ,get_json_object(kreditPembiayan, '$.kondisiKet') as condition_code
        ,get_json_object(kreditPembiayan, '$.tanggalKondisi') as condition_happen_date
        ,get_json_object(kreditPembiayan, '$.keterangan') as other_info
        ,get_json_object(kreditPembiayan, '$.tahunBulan01Ht') as last_24m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan01') as last_24m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan01Kol') as last_24m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan02Ht') as last_23m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan02') as last_23m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan02Kol') as last_23m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan03Ht') as last_22m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan03') as last_22m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan03Kol') as last_22m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan04Ht') as last_21m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan04') as last_21m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan04Kol') as last_21m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan05Ht') as last_20m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan05') as last_20m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan05Kol') as last_20m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan06Ht') as last_19m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan06') as last_19m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan06Kol') as last_19m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan07Ht') as last_18m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan07') as last_18m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan07Kol') as last_18m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan08Ht') as last_17m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan08') as last_17m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan08Kol') as last_17m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan09Ht') as last_16m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan09') as last_16m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan09Kol') as last_16m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan10Ht') as last_15m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan10') as last_15m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan10Kol') as last_15m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan11Ht') as last_14m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan11') as last_14m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan11Kol') as last_14m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan12Ht') as last_13m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan12') as last_13m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan12Kol') as last_13m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan13Ht') as last_12m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan13') as last_12m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan13Kol') as last_12m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan14Ht') as last_11m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan14') as last_11m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan14Kol') as last_11m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan15Ht') as last_10m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan15') as last_10m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan15Kol') as last_10m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan16Ht') as last_09m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan16') as last_09m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan16Kol') as last_09m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan17Ht') as last_08m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan17') as last_08m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan17Kol') as last_08m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan18Ht') as last_07m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan18') as last_07m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan18Kol') as last_07m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan19Ht') as last_06m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan19') as last_06m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan19Kol') as last_06m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan20Ht') as last_05m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan20') as last_05m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan20Kol') as last_05m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan21Ht') as last_04m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan21') as last_04m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan21Kol') as last_04m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan22Ht') as last_03m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan22') as last_03m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan22Kol') as last_03m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan23Ht') as last_02m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan23') as last_02m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan23Kol') as last_02m_status
        ,get_json_object(kreditPembiayan, '$.tahunBulan24Ht') as last_01m_dpd
        ,get_json_object(kreditPembiayan, '$.tahunBulan24') as last_01m_month
        ,get_json_object(kreditPembiayan, '$.tahunBulan24Kol') as last_01m_status        
        ,get_json_object(kreditPembiayan, '$.agunan') as agunan
        ,get_json_object(kreditPembiayan, '$.penjamin') as penjamin
        ,case 
            when coalesce(get_json_object(kreditPembiayan, '$.tanggalDibentuk'),'') = '' then '19700101080001'
            else get_json_object(kreditPembiayan, '$.tanggalDibentuk')
            end as facility_create_date
        ,case 
            when coalesce(get_json_object(kreditPembiayan, '$.tanggalUpdate'),'') = '' then '19700101080001'
            else get_json_object(kreditPembiayan, '$.tanggalUpdate')
            end as facility_update_date
    from (
        select 
            id_no
            ,request_id
            ,explode_table.kreditPembiayan
        from (
            select
                --ktp_id
                get_json_object(result, '$.individual.parameterPencarian.noIdentitas') as id_no
                ,get_json_object(result, '$.header.idPermintaan') as request_id
                
                --others
                ,get_json_object(result,'$.individual.fasilitas.kreditPembiayan') as kreditPembiayans
            from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
            where grass_date = '${ds}'
              and get_json_object(result,'$.individual.fasilitas.kreditPembiayan') is not null
              and get_json_object(result,'$.individual.fasilitas.kreditPembiayan') <> '[]'
        )
        lateral view explode(split(regexp_replace(regexp_extract(kreditPembiayans,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as kreditPembiayan
    )
);