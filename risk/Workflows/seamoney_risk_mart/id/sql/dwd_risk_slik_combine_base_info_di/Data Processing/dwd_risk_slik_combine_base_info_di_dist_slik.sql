-- 获取原始数据
WITH base_info AS (
  SELECT 
    ktp as ktp_no,
    user_reference_code as report_no,
    file_exist as status, 
    CONCAT( 
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 1, 4), '-',     -- 年
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 5, 2), '-',     -- 月
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 7, 2), ' ',
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 9, 2), ':',
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 11, 2), ':',
    SUBSTRING(get_json_object(result, '$.header.tanggalHasil'), 13, 2)
    ) as report_update_time,
    substr(create_time,1,10) as create_time,
    explode(
      from_json(
          get_json_object(result, '$.individual.dataPokokDebitur'),
        'array<string>'
      )
    ) as info_record,
    get_json_object(result, '$.individual.ringkasanFasilitas') as summary_info
  FROM risk.ods__credit_datafetch_slik_id_db__slik_report_history_tab__df
  WHERE grass_date = '${ds}' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
),
final_tab as (
SELECT 
    NULL AS trace_id,
    NULL AS credit_user_id,
    NULL AS platform_user_id,
    NULL AS flow_no,
    ktp_no,
    report_no,
    status,
    NULL AS is_error,
    report_update_time,
    create_time,

    -- 基本信息 (3个)
    get_json_object(info_record, '$.namaDebitur') AS name,
    get_json_object(info_record, '$.tanggalLahir') AS birth_date,
    get_json_object(info_record, '$.tempatLahir') AS birth_place,

    -- 身份信息 (3个)
    get_json_object(info_record, '$.identitas') AS identity_id,
    get_json_object(info_record, '$.noIdentitas') AS identity_number,
    get_json_object(info_record, '$.npwp') AS npwp,

    -- 性别信息 (2个)
    get_json_object(info_record, '$.jenisKelamin') AS gender_id,
    get_json_object(info_record, '$.jenisKelaminKet') AS gender,

    -- 教育信息 (2个)
    get_json_object(info_record, '$.kodeGelarDebitur') AS degree_id,
    get_json_object(info_record, '$.statusGelarDebitur') AS degree,

    -- 工作信息 (5个)
    get_json_object(info_record, '$.pekerjaan') AS job_id,
    get_json_object(info_record, '$.pekerjaanKet') AS job,
    get_json_object(info_record, '$.tempatBekerja') AS work_place,
    get_json_object(info_record, '$.bidangUsaha') AS business_field_id,
    get_json_object(info_record, '$.bidangUsahaKet') AS business_field,

    -- 地址信息 (8个)
    get_json_object(info_record, '$.alamat') AS address,
    get_json_object(info_record, '$.negara') AS country_id,
    get_json_object(info_record, '$.negaraKet') AS country,
    get_json_object(info_record, '$.kabKota') AS city_id,
    get_json_object(info_record, '$.kabKotaKet') AS city,
    get_json_object(info_record, '$.kecamatan') AS district,
    get_json_object(info_record, '$.kelurahan') AS village,
    get_json_object(info_record, '$.kodePos') AS zipcode,

    -- 报告相关信息 (4个)
    get_json_object(info_record, '$.tanggalUpdate') AS report_update_date,
    get_json_object(info_record, '$.pelapor') AS reporter_ljk_id,
    get_json_object(info_record, '$.pelaporKet') AS reporter,
    get_json_object(info_record, '$.tanggalDibentuk') AS report_create_date,

    -- 财务指标 (18个)
    get_json_object(summary_info, '$.kualitasTerburuk') AS worst_quality,
    get_json_object(summary_info, '$.kualitasBulanDataTerburuk') AS worst_quality_date,
    get_json_object(summary_info, '$.krediturBankUmum') AS bank_reporter_cnt,
    get_json_object(summary_info, '$.krediturBPR/S') AS bpr_reporter_cnt,
    get_json_object(summary_info, '$.krediturLp') AS financial_reporter_cnt,
    get_json_object(summary_info, '$.krediturLainnya') AS other_reporter_cnt,
    get_json_object(summary_info, '$.bakiDebetGyd') AS guarantee_os_amt,
    get_json_object(summary_info, '$.bakiDebetKreditPembiayaan') AS credit_os_amt,
    get_json_object(summary_info, '$.bakiDebetLain') AS other_os_amt,
    get_json_object(summary_info, '$.bakiDebetLc') AS lc_os_amt,
    get_json_object(summary_info, '$.bakiDebetSec') AS securities_os_amt,
    get_json_object(summary_info, '$.plafonEfektifGyd') AS guarantee_amt,
    get_json_object(summary_info, '$.plafonEfektifKreditPembiayaan') AS credit_amt,
    get_json_object(summary_info, '$.plafonEfektifLain') AS other_amt,
    get_json_object(summary_info, '$.plafonEfektifLc') AS lc_amt,
    get_json_object(summary_info, '$.plafonEfektifSec') AS securities_amt,
    get_json_object(summary_info, '$.plafonEfektifTotal') AS total_amt,
    get_json_object(summary_info, '$.bakiDebetTotal') AS total_os_amt
FROM base_info
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_base_info_di
PARTITION (data_source='SLIK',grass_date)

SELECT
  trace_id,
  CAST(credit_user_id AS BIGINT) AS credit_user_id,
  CAST(platform_user_id AS BIGINT) AS platform_user_id,
  flow_no,
  CAST(ktp_no AS BIGINT) AS ktp_no,
  report_no,
  status,
  is_error,
  report_update_time,
  create_time,
  name,
  CAST(birth_date AS STRING) AS birth_date,
  birth_place,
  CAST(identity_id AS BIGINT) AS identity_id,
  CAST(identity_number AS BIGINT) AS identity_number,
  CAST(npwp AS BIGINT) AS npwp,
  gender_id,
  gender,
  CAST(degree_id AS STRING) AS degree_id,
  degree,
  CAST(job_id AS STRING) AS job_id,
  job,
  work_place,
  business_field_id,
  business_field,
  address,
  country_id,
  country,
  CAST(city_id AS BIGINT) AS city_id,
  city,
  district,
  village,
  CAST(zipcode AS STRING) AS zipcode,
  report_update_date,
  CAST(reporter_ljk_id AS STRING) AS reporter_ljk_id,
  reporter,
  report_create_date,
  worst_quality,
  worst_quality_date,
  CAST(bank_reporter_cnt AS BIGINT) AS bank_reporter_cnt,
  CAST(bpr_reporter_cnt AS BIGINT) AS bpr_reporter_cnt,
  CAST(financial_reporter_cnt AS BIGINT) AS financial_reporter_cnt,
  CAST(other_reporter_cnt AS BIGINT) AS other_reporter_cnt,
  CAST(guarantee_os_amt AS DECIMAL(20,10)) AS guarantee_os_amt,
  CAST(credit_os_amt AS DECIMAL(20,10)) AS credit_os_amt,
  CAST(other_os_amt AS DECIMAL(20,10)) AS other_os_amt,
  CAST(lc_os_amt AS DECIMAL(20,10)) AS lc_os_amt,
  CAST(securities_os_amt AS DECIMAL(20,10)) AS securities_os_amt,
  CAST(guarantee_amt AS DECIMAL(20,10)) AS guarantee_amt,
  CAST(credit_amt AS DECIMAL(20,10)) AS credit_amt,
  CAST(other_amt AS DECIMAL(20,10)) AS other_amt,
  CAST(lc_amt AS DECIMAL(20,10)) AS lc_amt,
  CAST(securities_amt AS DECIMAL(20,10)) AS securities_amt,
  CAST(total_amt AS DECIMAL(20,10)) AS total_amt,
  CAST(total_os_amt AS DECIMAL(20,10)) AS total_os_amt,
  create_time as grass_date
FROM final_tab;