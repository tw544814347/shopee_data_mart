--drop table if exists risk.dwd_risk_id_fdc_loan_record_parse_di;
create table if not exists risk.dwd_risk_id_fdc_loan_record_parse_di (
    fdc_report_id string,
    create_timestamp string,
    flow_no string,
    ktp_req bigint,
    userid bigint,
    credit_userid bigint,
    trace_id string,
    data_source_name string,
    inquiry_date string,
    status string,
    loan_id_p2p string,
    loan_id_raw string,
    platform_number string,
    borrower_name string,
    borrower_id_no bigint,
    no_npwp bigint,
    no_hp string,
    email string,
    agreement_date string,
    transfer_date string,
    maturity_date string,
    update_date string,
    total_principal_amount bigint,
    os_principal_amount bigint,
    current_dpd bigint,
    dpd_max bigint,
    loan_status string,
    loan_status_cat string,
    loan_quality string,
    loan_quality_cat string,
    borrower_type string,
    borrower_type_cat string,
    solution string,
    is_syariah string,
    loan_type string,
    losn_subtype string,
    reference string,
    collateral string,
    collateral_date string,
    name_guarantor string,
    collateral_number string,
    monthly_income_avg bigint
)
PARTITIONED BY (grass_date STRING COMMENT 'grass_date, partition key')
STORED AS ORC
TBLPROPERTIES ("orc.compress" = "zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd_risk_id_fdc_loan_record_parse_di/grass_region=ID';
--msck repair table risk.dwd_risk_id_fdc_loan_record_parse_di;

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE risk.dwd_risk_id_fdc_loan_record_parse_di PARTITION (grass_date)
select
    concat_ws('_', ktp_req, create_timestamp) as fdc_report_id,
    create_timestamp as create_timestamp,
    flow_no as flow_no,
    cast(ktp_req as bigint) as ktp_req,
    cast(userid as bigint) as userid,
    cast(credit_userid as bigint) as credit_userid,
    trace_id as trace_id,
    data_source_name as data_source_name,
    inquiry_date as inquiry_date,
    status as status,
    concat_ws('_', coalesce(get_json_object(pinjaman, '$.id'), get_json_object(pinjaman, '$.Id')), coalesce(get_json_object(pinjaman, '$.id_penyelenggara'), get_json_object(pinjaman, '$.idPenyelenggara'), get_json_object(pinjaman, '$.IdPenyelenggara'))) as loan_id_p2p,
    coalesce(get_json_object(pinjaman, '$.id'), get_json_object(pinjaman, '$.Id')) as loan_id_raw,
    coalesce(get_json_object(pinjaman, '$.id_penyelenggara'), get_json_object(pinjaman, '$.idPenyelenggara'), get_json_object(pinjaman, '$.IdPenyelenggara')) as platform_number,
    coalesce(get_json_object(pinjaman, '$.nama_borrower'), get_json_object(pinjaman, '$.namaBorrower'), get_json_object(pinjaman, '$.NamaBorrower')) as borrower_name,
    cast(coalesce(get_json_object(pinjaman, '$.no_identitas'), get_json_object(pinjaman, '$.noIdentitas'), get_json_object(pinjaman, '$.NoIdentitas')) as bigint) as borrower_id_no,
    cast(coalesce(get_json_object(pinjaman, '$.no_npwp'), get_json_object(pinjaman, '$.noNpwp'), get_json_object(pinjaman, '$.NoNpwp')) as bigint) as no_npwp,
    coalesce(get_json_object(pinjaman, '$.no_hp'), get_json_object(pinjaman, '$.noHp'), get_json_object(pinjaman, '$.NoHp')) as no_hp,
    coalesce(get_json_object(pinjaman, '$.email'), get_json_object(pinjaman, '$.Email')) as email,
    coalesce(get_json_object(pinjaman, '$.tgl_perjanjian_borrower'), get_json_object(pinjaman, '$.tglPerjanjianBorrower'), get_json_object(pinjaman, '$.TglPerjanjianBorrower')) as agreement_date,
    coalesce(get_json_object(pinjaman, '$.tgl_penyaluran_dana'), get_json_object(pinjaman, '$.tglPenyaluranDana'), get_json_object(pinjaman, '$.TglPenyaluranDana')) as transfer_date,
    coalesce(get_json_object(pinjaman, '$.tgl_jatuh_tempo_pinjaman'), get_json_object(pinjaman, '$.tglJatuhTempoPinjaman'), get_json_object(pinjaman, '$.TglJatuhTempoPinjaman')) as maturity_date,
    coalesce(get_json_object(pinjaman, '$.tgl_pelaporan_data'), get_json_object(pinjaman, '$.tglPelaporanData'), get_json_object(pinjaman, '$.TglPelaporanData')) as update_date,
    cast(coalesce(get_json_object(pinjaman, '$.nilai_pendanaan'), get_json_object(pinjaman, '$.nilaiPendanaan'), get_json_object(pinjaman, '$.NilaiPendanaan')) as bigint) as total_principal_amount,
    cast(coalesce(get_json_object(pinjaman, '$.sisa_pinjaman_berjalan'), get_json_object(pinjaman, '$.sisaPinjamanBerjalan'), get_json_object(pinjaman, '$.SisaPinjamanBerjalan')) as bigint) as os_principal_amount,
    cast(coalesce(get_json_object(pinjaman, '$.dpd_terakhir'), get_json_object(pinjaman, '$.dpdTerakhir'), get_json_object(pinjaman, '$.DpdTerakhir')) as bigint) as current_dpd,
    cast(coalesce(get_json_object(pinjaman, '$.dpd_max'), get_json_object(pinjaman, '$.dpdMax'), get_json_object(pinjaman, '$.DpdMax')) as bigint) as dpd_max,
    coalesce(get_json_object(pinjaman, '$.status_pinjaman'), get_json_object(pinjaman, '$.statusPinjaman'), get_json_object(pinjaman, '$.StatusPinjaman')) as loan_status,
    coalesce(get_json_object(pinjaman, '$.status_pinjaman_ket'), get_json_object(pinjaman, '$.statusPinjamanKet'), get_json_object(pinjaman, '$.StatusPinjamanKet')) as loan_status_cat,
    coalesce(get_json_object(pinjaman, '$.kualitas_pinjaman'), get_json_object(pinjaman, '$.kualitasPinjaman'), get_json_object(pinjaman, '$.KualitasPinjaman')) as loan_quality,
    coalesce(get_json_object(pinjaman, '$.kualitas_pinjaman_ket'), get_json_object(pinjaman, '$.kualitasPinjamanKet'), get_json_object(pinjaman, '$.KualitasPinjamanKet')) as loan_quality_cat,
    coalesce(get_json_object(pinjaman, '$.jenis_pengguna'), get_json_object(pinjaman, '$.jenisPengguna'), get_json_object(pinjaman, '$.JenisPengguna')) as borrower_type,
    coalesce(get_json_object(pinjaman, '$.jenis_pengguna_ket'), get_json_object(pinjaman, '$.jenisPenggunaKet'), get_json_object(pinjaman, '$.JenisPenggunaKet')) as borrower_type_cat,
    coalesce(get_json_object(pinjaman, '$.penyelesaian_w_oleh'), get_json_object(pinjaman, '$.penyelesaianWOleh'), get_json_object(pinjaman, '$.PenyelesaianWOleh')) as solution,
    coalesce(get_json_object(pinjaman, '$.pendanaan_syariah'), get_json_object(pinjaman, '$.pendanaanSyariah'), get_json_object(pinjaman, '$.PendanaanSyariah')) as is_syariah,
    coalesce(get_json_object(pinjaman, '$.tipe_pinjaman'), get_json_object(pinjaman, '$.tipePinjaman'), get_json_object(pinjaman, '$.TipePinjaman')) as loan_type,
    coalesce(get_json_object(pinjaman, '$.sub_tipe_pinjaman'), get_json_object(pinjaman, '$.subTipePinjaman'), get_json_object(pinjaman, '$.SubTipePinjaman')) as losn_subtype,
    coalesce(get_json_object(pinjaman, '$.reference'), get_json_object(pinjaman, '$.Reference')) as reference,
    coalesce(get_json_object(pinjaman, '$.agunan'), get_json_object(pinjaman, '$.Agunan')) as collateral,
    coalesce(get_json_object(pinjaman, '$.tgl_agunan'), get_json_object(pinjaman, '$.tglAgunan'), get_json_object(pinjaman, '$.TglAgunan')) as collateral_date,
    coalesce(get_json_object(pinjaman, '$.nama_penjamin'), get_json_object(pinjaman, '$.namaPenjamin'), get_json_object(pinjaman, '$.NamaPenjamin')) as name_guarantor,
    coalesce(get_json_object(pinjaman, '$.no_agunan'), get_json_object(pinjaman, '$.noAgunan'), get_json_object(pinjaman, '$.NoAgunan')) as collateral_number,
    cast(coalesce(get_json_object(pinjaman, '$.pendapatan'), get_json_object(pinjaman, '$.Pendapatan')) as bigint) as monthly_income_avg,
    grass_date
from
(
    select
        unix_timestamp(to_utc_timestamp(create_time, 'GMT+7')) as create_timestamp,
        coalesce(get_json_object(header_data, '$.flow_no'), get_json_object(header_data, '$.flowNo'), get_json_object(header_data, '$.FlowNo')) as flow_no,
        coalesce(get_json_object(req_data, '$.identity_number'), get_json_object(req_data, '$.identityNumber'), get_json_object(req_data, '$.IdentityNumber'), get_json_object(req_data, '$.ktp'), get_json_object(req_data, '$.Ktp'), get_json_object(req_data, '$.KTP')) as ktp_req,
        coalesce(get_json_object(header_data, '$.platform_user_id'), get_json_object(header_data, '$.platformUserId'), get_json_object(header_data, '$.PlatformUserId')) as userid,
        coalesce(get_json_object(header_data, '$.credit_user_id'), get_json_object(header_data, '$.creditUserId'), get_json_object(header_data, '$.CreditUserId')) as credit_userid,
        trace_id as trace_id,
        data_source_name as data_source_name,
        coalesce(get_json_object(resp_raw_data, '$.data.inquiry_date'), get_json_object(resp_raw_data, '$.data.inquiryDate'), get_json_object(resp_raw_data, '$.data.InquiryDate'), get_json_object(resp_raw_data, '$.inquiry_date'), get_json_object(resp_raw_data, '$.inquiryDate'), get_json_object(resp_raw_data, '$.InquiryDate')) as inquiry_date,
        coalesce(get_json_object(resp_raw_data, '$.data.status'), get_json_object(resp_raw_data, '$.data.Status'), get_json_object(resp_raw_data, '$.status'), get_json_object(resp_raw_data, '$.Status')) as status,
        coalesce(get_json_object(resp_raw_data, '$.pinjaman'), get_json_object(resp_raw_data, '$.data.pinjaman')) as pinjaman_list,
        date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
    from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
    where grass_date = '${grass_date}'
    and data_source_name in ('FDCData','FDCDataV5','FDCDataV5.2','FDCRealTimeDataV5.2')
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}'
) t
lateral view outer explode(json_to_array(pinjaman_list)) tbl as pinjaman;