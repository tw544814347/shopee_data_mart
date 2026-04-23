-- SLIK数据源
WITH individual_credit AS (
    SELECT 
    ktp as ktp_no,
    user_reference_code as report_no,
    file_exist as status,
    substr(create_time,1,10) as create_time,
    CONCAT(
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 1, 4), '-',     -- 年
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 5, 2), '-',     -- 月
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 7, 2), ' ',
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 9, 2), ':',
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 11, 2), ':',
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 13, 2)
    ) as report_update_time,
    explode(
        from_json(
            get_json_object(result, '$.individual.fasilitas.kreditPembiayan'),
            'array<string>'
        )
    ) as loan
    FROM risk.ods__credit_datafetch_slik_id_db__slik_report_history_tab__df
    WHERE grass_date = '${ds}' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
),
final_tab as (
SELECT 
    null as trace_id,
    null as credit_user_id,
    null as platform_user_id,
    null as flow_no,
    ktp_no,
    report_no,
    status,
    null as is_error,
    create_time,
    report_update_time,
    get_json_object(loan, '$.noAkadAwal') as initial_contract_no,
    get_json_object(agunan, '$.alamatAgunan') as collateral_address,
    get_json_object(agunan, '$.nomorAgunan') as register_code,
    get_json_object(agunan, '$.jenisAgunanKet') as collateral_type,
    get_json_object(agunan, '$.peringkatAgunan') as collateral_rating,
    get_json_object(agunan, '$.kodeLembagaPemeringkat') as rating_agency_code,
    get_json_object(agunan, '$.lembagaPemeringkat') as rating_agency,
    get_json_object(agunan, '$.jenisPengikatan') as binding_type_code,
    get_json_object(agunan, '$.jenisPengikatanKet') as binding_type,
    get_json_object(agunan, '$.tanggalPengikatan') as binding_date,
    get_json_object(agunan, '$.namaPemilikAgunan') as name_of_the_collateral_owner,
    get_json_object(agunan, '$.buktiKepemilikan') as proof_of_owner_ship,
    get_json_object(agunan, '$.kabKotaLokasiAgunan') as district_city_code,
    get_json_object(agunan, '$.kabKotaLokasiAgunanKet') as district_city,
    get_json_object(agunan, '$.nilaiAgunanNjop') as collateral_value_NJOP,
    get_json_object(agunan, '$.tglPenilaianPelapor') as reporting_evaluation_date,
    get_json_object(agunan, '$.nilaiAgunanIndep') as collateral_value_by_independent_appraiser,
    get_json_object(agunan, '$.nilaiAgunanMenurutLJK') as collateral_value_by_LJK,
    get_json_object(agunan, '$.namaPenilaiIndep') as name_of_independent_appraiser,
    get_json_object(agunan, '$.tanggalPenilaianPenilaiIndependen') as date_of_independent_appraisal_assessment,
    get_json_object(agunan, '$.prosentaseParipasu') as percentage_of_paripasu,
    get_json_object(agunan, '$.asuransi') as insured,
    get_json_object(agunan, '$.keterangan') as description,
    get_json_object(agunan, '$.tanggalUpdate') as update_timestamp,
    get_json_object(agunan, '$.tglPenilaianPelapor') as reporter_rating_date
FROM individual_credit
LATERAL VIEW explode(
        from_json(
            get_json_object(loan, '$.agunan'),
            'array<string>'
        )
    ) t AS agunan
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_collateral_info_di
PARTITION (data_source='SLIK', grass_date)

SELECT
  trace_id,  -- STRING类型保持原样
  CAST(credit_user_id AS BIGINT) AS credit_user_id,
  CAST(platform_user_id AS BIGINT) AS platform_user_id,
  flow_no,  -- STRING
  CAST(ktp_no AS BIGINT) AS ktp_no,
  report_no,  -- STRING
  status,  -- STRING
  is_error,  -- STRING
  create_time,  -- STRING
  report_update_time,  -- STRING
  initial_contract_no,  -- STRING
  collateral_address,  -- STRING
  register_code,  -- STRING
  collateral_type,  -- STRING
  collateral_rating,  -- STRING
  rating_agency_code,  -- STRING
  rating_agency,  -- STRING
  CAST(binding_type_code AS STRING) AS binding_type_code,
  binding_type,  -- STRING
  binding_date,  -- STRING
  name_of_the_collateral_owner,  -- STRING
  proof_of_owner_ship,  -- STRING
  CAST(district_city_code AS STRING) AS district_city_code,
  district_city,  -- STRING
  CAST(collateral_value_NJOP AS DECIMAL(20,10)) AS collateral_value_NJOP,
  reporting_evaluation_date,  -- STRING
  CAST(collateral_value_by_independent_appraiser AS DECIMAL(20,10)) AS collateral_value_by_independent_appraiser,
  CAST(collateral_value_by_LJK AS DECIMAL(20,10)) AS collateral_value_by_LJK,
  name_of_independent_appraiser,  -- STRING
  date_of_independent_appraisal_assessment,  -- STRING
  CAST(percentage_of_paripasu AS DECIMAL(20,10)) AS percentage_of_paripasu,
  insured,  -- STRING
  description,  -- STRING
  update_timestamp,  -- STRING
  reporter_rating_date,  -- STRING
  create_time as grass_date 
FROM final_tab
;