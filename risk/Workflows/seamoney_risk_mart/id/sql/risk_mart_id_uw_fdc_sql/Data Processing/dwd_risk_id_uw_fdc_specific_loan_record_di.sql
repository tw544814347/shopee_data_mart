-- DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di
(   
    loan_id                    STRING
    ,trace_id                   STRING
    ,userid                     STRING  comment 'Platform user id'
    ,credit_userid              STRING
    ,ktp_inquiry_time           STRING
    ,platform_number            STRING
    ,loan_purpose               STRING
    ,borrower_name               STRING
    ,ktp_number                  STRING
    ,npwp_number                 STRING
    ,agreement_date              STRING
    ,transfer_date               STRING
    ,total_amount                DECIMAL(30,10)
    ,latest_updated_date         STRING
    ,outstanding_balance         DECIMAL(30,10)
    ,due_date                    STRING
    ,loan_quality                STRING
    ,dpd                         BIGINT
    ,dpd_max                     BIGINT
    ,loan_status                 STRING
    ,loan_purpose_description                STRING
    ,loan_quality_description    STRING
    ,loan_status_description     STRING
    ,reference                   STRING
    ,loan_id_p2p                 STRING
    ,no_hp                       STRING
    ,email                       STRING
    ,solution                    STRING
    ,is_syariah                  STRING
    ,loan_type                   STRING
    ,loan_subtype                STRING
    ,collateral                  STRING
    ,collateral_date             STRING
    ,name_guarantor              STRING
    ,collateral_number           STRING
    ,monthly_income_avg          STRING
    ,fdc_report_id               STRING
    ,flow_no                     STRING
    ,ktp_req                     STRING
    ,inquiry_date                STRING
    ,status                      STRING
)
PARTITIONED BY (
    data_source_name string comment 'data_source_name'
    ,grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_id_uw_fdc_specific_loan_record_di/grass_region=ID';
--MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di;

create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';



INSERT OVERWRITE TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di PARTITION (data_source_name,grass_date)
select
    distinct md5(concat(ktp_number,create_time,platform_number,loan_purpose,borrower_name,ktp_number,npwp_number,agreement_date,transfer_date,total_amount,latest_updated_date,outstanding_balance,due_date,loan_quality,dpd,dpd_max,loan_status,loan_purpose_description,loan_quality_description,loan_status_description)) as loan_id
    ,trace_id
    ,userid
    ,credit_userid
    ,concat(ktp_number,create_time) as ktp_inquiry_time
    ,platform_number
    ,loan_purpose
    ,borrower_name
    ,ktp_number
    ,npwp_number
    ,agreement_date
    ,transfer_date
    ,cast(total_amount as decimal(30,10)) as total_amount
    ,latest_updated_date
    ,cast(outstanding_balance as decimal(30,10)) as outstanding_balance
    ,due_date
    ,loan_quality
    ,cast(dpd as bigint) as dpd
    ,cast(dpd_max as bigint) as dpd_max
    ,loan_status
    ,loan_purpose_description
    ,loan_quality_description
    ,loan_status_description
    ,reference
    ,loan_id_p2p
    ,no_hp
    ,email
    ,solution
    ,is_syariah
    ,loan_type
    ,loan_subtype
    ,collateral
    ,collateral_date
    ,name_guarantor
    ,collateral_number
    ,monthly_income_avg
    ,fdc_report_id
    ,flow_no
    ,ktp_req
    ,inquiry_date
    ,status
    ,data_source_name
    ,grass_date
from
(
    select
        create_time
        ,json_tuple(
            pinjaman_list
            ,'id_penyelenggara'
            ,'jenis_pengguna'
            ,'nama_borrower'
            ,'no_identitas'
            ,'no_npwp'
            ,'tgl_perjanjian_borrower'
            ,'tgl_penyaluran_dana'
            ,'nilai_pendanaan'
            ,'tgl_pelaporan_data'
            ,'sisa_pinjaman_berjalan'
            ,'tgl_jatuh_tempo_pinjaman'
            ,'kualitas_pinjaman'       
            ,'dpd_terakhir'            
            ,'dpd_max'                 
            ,'status_pinjaman'         
            ,'jenis_pengguna_ket'      
            ,'kualitas_pinjaman_ket'   
            ,'status_pinjaman_ket'     
            ,'reference'               
            ,'id'                      
            ,'no_hp'                   
            ,'email'                   
            ,'penyelesaian_w_oleh'     
            ,'pendanaan_syariah'       
            ,'tipe_pinjaman'           
            ,'sub_tipe_pinjaman'       
            ,'agunan'                  
            ,'tgl_agunan'              
            ,'nama_penjamin'           
            ,'no_agunan'               
            ,'pendapatan'
        ) as
        (
            platform_number
            ,loan_purpose
            ,borrower_name
            ,ktp_number
            ,npwp_number
            ,agreement_date
            ,transfer_date
            ,total_amount
            ,latest_updated_date
            ,outstanding_balance
            ,due_date
            ,loan_quality
            ,dpd
            ,dpd_max
            ,loan_status
            ,loan_purpose_description
            ,loan_quality_description
            ,loan_status_description
            ,reference
            ,loan_id_p2p
            ,no_hp
            ,email
            ,solution
            ,is_syariah
            ,loan_type
            ,loan_subtype
            ,collateral
            ,collateral_date
            ,name_guarantor
            ,collateral_number
            ,monthly_income_avg
        )
        -- KTP 标识符兼容
        ,case   when data_source_name = 'FDCData' then concat(get_json_object(req_data,'$.IdentityNumber'), '_', unix_timestamp(create_time))
                else concat(get_json_object(req_data,'$.KTP'), '_', unix_timestamp(create_time))  end as fdc_report_id
        ,get_json_object(header_data, '$.PlatformUserId')                as userid
        ,get_json_object(header_data, '$.CreditUserId')                  as credit_userid
        ,get_json_object(header_data,'$.FlowNo')                         as flow_no
        -- KTP 标识符兼容
        ,case   when data_source_name = 'FDCData' then concat(GET_JSON_OBJECT(req_data, '$.IdentityNumber'))
                else get_json_object(req_data,'$.KTP') end as ktp_req
        ,coalesce(get_json_object(resp_raw_data,'$.inquiryDate'),get_json_object(resp_raw_data,'$.InquiryDate')) as inquiry_date
        ,coalesce(get_json_object(resp_raw_data,'$.status'),get_json_object(resp_raw_data,'$.Status')) as status
        ,trace_id
        ,data_source_name
        ,grass_date
    from
    (  select create_time,grass_date,pinjaman,header_data,req_data,resp_raw_data,data_source_name,trace_id
       from 
        (select
            format_time(create_time, 'ID') as create_time
            ,date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date 
            ,case when data_source_name = 'FDCData' then get_json_object(resp_raw_data,'$.data.pinjaman') 
                  when data_source_name = 'FDCDataV5' then get_json_object(resp_raw_data,'$.pinjaman') 
                  when data_source_name = 'FDCDataV5.2' then get_json_object(resp_raw_data, '$.pinjaman')
                  else null end  pinjaman
            ,header_data
            ,req_data
            ,resp_raw_data
            ,data_source_name
            ,trace_id
        from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
            where grass_date = '${grass_date}'
            -- and data_source_name in ('FDCData','FDCDataV5')
            and data_source_name in('FDCData','FDCDataV5','FDCDataV5.2')
            and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
            and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}' 
        ) pre_t1    
      where  pinjaman <> '[]' and pinjaman is not null
    ) t1
    lateral view explode(json_to_array(pinjaman)) tbl as pinjaman_list
) t2;
