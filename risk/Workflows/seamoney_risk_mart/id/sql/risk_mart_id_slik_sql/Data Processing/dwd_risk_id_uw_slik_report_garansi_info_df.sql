insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_garansi_info_df partition (grass_date='${ds}')
select
    ktp_request_id
    ,g_month
    ,g_branch
    ,g_branch_code
    ,g_type_code
    ,g_type_des
    ,g_information
    ,g_condition_code
    ,g_destination_code
    ,g_currency_code
    ,g_condition_des
    ,g_current_status_code
    ,g_current_status
    ,g_ljk_code
    ,g_ljk_name
    ,g_bank_guarantee
    ,g_final_contract_number
    ,g_acct_number
    ,g_initial_contract_number
    ,g_nominal
    ,g_disburse_amount
    ,g_nominal_value
    ,g_year
    ,g_last_24m_dpd
    ,g_last_24m_month
    ,g_last_24m_status
    ,g_last_23m_dpd
    ,g_last_23m_month
    ,g_last_23m_status
    ,g_last_22m_dpd
    ,g_last_22m_month
    ,g_last_22m_status
    ,g_last_21m_dpd
    ,g_last_21m_month
    ,g_last_21m_status
    ,g_last_20m_dpd
    ,g_last_20m_month
    ,g_last_20m_status
    ,g_last_19m_dpd
    ,g_last_19m_month
    ,g_last_19m_status
    ,g_last_18m_dpd
    ,g_last_18m_month
    ,g_last_18m_status
    ,g_last_17m_dpd
    ,g_last_17m_month
    ,g_last_17m_status
    ,g_last_16m_dpd
    ,g_last_16m_month
    ,g_last_16m_status
    ,g_last_15m_dpd
    ,g_last_15m_month
    ,g_last_15m_status
    ,g_last_14m_dpd
    ,g_last_14m_month
    ,g_last_14m_status
    ,g_last_13m_dpd
    ,g_last_13m_month
    ,g_last_13m_status
    ,g_last_12m_dpd
    ,g_last_12m_month
    ,g_last_12m_status
    ,g_last_11m_dpd
    ,g_last_11m_month
    ,g_last_11m_status
    ,g_last_10m_dpd
    ,g_last_10m_month
    ,g_last_10m_status
    ,g_last_09m_dpd
    ,g_last_09m_month
    ,g_last_09m_status
    ,g_last_08m_dpd
    ,g_last_08m_month
    ,g_last_08m_status
    ,g_last_07m_dpd
    ,g_last_07m_month
    ,g_last_07m_status
    ,g_last_06m_dpd
    ,g_last_06m_month
    ,g_last_06m_status
    ,g_last_05m_dpd
    ,g_last_05m_month
    ,g_last_05m_status
    ,g_last_04m_dpd
    ,g_last_04m_month
    ,g_last_04m_status
    ,g_last_03m_dpd
    ,g_last_03m_month
    ,g_last_03m_status
    ,g_last_02m_dpd
    ,g_last_02m_month
    ,g_last_02m_status
    ,g_last_01m_dpd
    ,g_last_01m_month
    ,g_last_01m_status
    ,g_contract_end_date
    ,g_contract_effective_date
    ,g_contract_create_date
    ,g_contract_issued_date
    ,g_due_date
    ,g_condition_date
    ,g_update_date
    ,g_default_date
    ,g_loan_destination
from (
    select
        --ktp_id
        concat_ws('_', id_no, request_id) as ktp_request_id
        ,get_json_object(garansiYgDiberikan, '$.bulan') as g_month
        ,get_json_object(garansiYgDiberikan, '$.cabang') as g_branch
        ,get_json_object(garansiYgDiberikan, '$.cabangKet') as g_branch_code
        ,get_json_object(garansiYgDiberikan, '$.jenisGaransi') as g_type_code
        ,get_json_object(garansiYgDiberikan, '$.jenisGaransiKet') as g_type_des
        ,get_json_object(garansiYgDiberikan, '$.kodeKondisi') as g_condition_code
        ,get_json_object(garansiYgDiberikan, '$.kodeTujuanGaransi') as g_destination_code
        ,get_json_object(garansiYgDiberikan, '$.kodeValuta') as g_currency_code
        ,get_json_object(garansiYgDiberikan, '$.kondisiKet') as g_condition_des
        ,get_json_object(garansiYgDiberikan, '$.kualitas') as g_current_status_code
        ,get_json_object(garansiYgDiberikan, '$.kualitasKet') as g_current_status
        ,get_json_object(garansiYgDiberikan, '$.ljk') as g_ljk_code
        ,get_json_object(garansiYgDiberikan, '$.ljkKet') as g_ljk_name
        ,get_json_object(garansiYgDiberikan, '$.namaYangDijamin') as g_bank_guarantee
        ,get_json_object(garansiYgDiberikan, '$.noAkadAkhir') as g_final_contract_number
        ,get_json_object(garansiYgDiberikan, '$.noRekening') as g_acct_number
        ,get_json_object(garansiYgDiberikan, '$.nominalBg') as g_nominal
        ,get_json_object(garansiYgDiberikan, '$.plafon') as g_disburse_amount
        ,get_json_object(garansiYgDiberikan, '$.setoranJaminan') as g_nominal_value
        ,get_json_object(garansiYgDiberikan, '$.tahun') as g_year
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan01') as g_last_24m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan01Ht') as g_last_24m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan01Kol') as g_last_24m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan02') as g_last_23m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan02Ht') as g_last_23m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan02Kol') as g_last_23m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan03') as g_last_22m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan03Ht') as g_last_22m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan03Kol') as g_last_22m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan04') as g_last_21m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan04Ht') as g_last_21m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan04Kol') as g_last_21m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan05') as g_last_20m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan05Ht') as g_last_20m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan05Kol') as g_last_20m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan06') as g_last_19m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan06Ht') as g_last_19m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan06Kol') as g_last_19m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan07') as g_last_18m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan07Ht') as g_last_18m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan07Kol') as g_last_18m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan08') as g_last_17m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan08Ht') as g_last_17m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan08Kol') as g_last_17m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan09') as g_last_16m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan09Ht') as g_last_16m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan09Kol') as g_last_16m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan10') as g_last_15m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan10Ht') as g_last_15m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan10Kol') as g_last_15m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan11') as g_last_14m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan11Ht') as g_last_14m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan11Kol') as g_last_14m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan12') as g_last_13m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan12Ht') as g_last_13m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan12Kol') as g_last_13m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan13') as g_last_12m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan13Ht') as g_last_12m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan13Kol') as g_last_12m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan14') as g_last_11m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan14Ht') as g_last_11m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan14Kol') as g_last_11m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan15') as g_last_10m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan15Ht') as g_last_10m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan15Kol') as g_last_10m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan16') as g_last_09m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan16Ht') as g_last_09m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan16Kol') as g_last_09m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan17') as g_last_08m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan17Ht') as g_last_08m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan17Kol') as g_last_08m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan18') as g_last_07m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan18Ht') as g_last_07m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan18Kol') as g_last_07m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan19') as g_last_06m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan19Ht') as g_last_06m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan19Kol') as g_last_06m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan20') as g_last_05m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan20Ht') as g_last_05m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan20Kol') as g_last_05m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan21') as g_last_04m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan21Ht') as g_last_04m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan21Kol') as g_last_04m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan22') as g_last_03m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan22Ht') as g_last_03m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan22Kol') as g_last_03m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan23') as g_last_02m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan23Ht') as g_last_02m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan23Kol') as g_last_02m_status
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan24') as g_last_01m_month
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan24Ht') as g_last_01m_dpd
        ,get_json_object(garansiYgDiberikan, '$.tahunBulan24Kol') as g_last_01m_status
        ,get_json_object(garansiYgDiberikan, '$.tanggalAkadAkhir') as g_contract_end_date
        ,get_json_object(garansiYgDiberikan, '$.tanggalAkadAwal') as g_contract_effective_date
        ,get_json_object(garansiYgDiberikan, '$.tanggalDiterbitkan') as g_contract_issued_date
        ,get_json_object(garansiYgDiberikan, '$.tanggalJatuhTempo') as g_due_date
        ,get_json_object(garansiYgDiberikan, '$.tanggalKondisi') as g_condition_date
        ,get_json_object(garansiYgDiberikan, '$.tanggalWanPrestasi') as g_default_date
        ,get_json_object(garansiYgDiberikan, '$.tujuanGaransiKet') as g_loan_destination   
             
        ,trim(get_json_object(garansiYgDiberikan, '$.keterangan')) as g_information
        ,trim(get_json_object(garansiYgDiberikan, '$.noAkadAwal')) as g_initial_contract_number
        
        ,case 
            when coalesce(get_json_object(garansiYgDiberikan, '$.tanggalDibentuk'),'') = '' then '19700101080001'
            else get_json_object(garansiYgDiberikan, '$.tanggalDibentuk')
            end as g_contract_create_date
        ,case 
            when coalesce(get_json_object(garansiYgDiberikan, '$.tanggalUpdate'),'') = '' then '19700101080001'
            else get_json_object(garansiYgDiberikan, '$.tanggalUpdate')
            end as g_update_date
    from (
        select 
            id_no
            ,request_id
            ,explode_table.garansiYgDiberikan
        from (
            select
                --ktp_id
                get_json_object(result, '$.individual.parameterPencarian.noIdentitas') as id_no
                ,get_json_object(result, '$.header.idPermintaan') as request_id
                
                --others
                ,get_json_object(result,'$.individual.fasilitas.garansiYgDiberikan') as garansiYgDiberikans
            from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
            where grass_date = '${ds}'
              and get_json_object(result,'$.individual.fasilitas.garansiYgDiberikan') is not null
              and get_json_object(result,'$.individual.fasilitas.garansiYgDiberikan') <> '[]'
        )
        lateral view explode(split(regexp_replace(regexp_extract(garansiYgDiberikans,'\\[(.*)\\]',1), '\\},','\\}\\^,'),'\\^,')) explode_table as garansiYgDiberikan
    )
);
