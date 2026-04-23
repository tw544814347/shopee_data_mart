insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_user_debt_summary_info_df partition (grass_date='${ds}')
select
    ktp_request_id as id
    ,total_os
    ,lc_limit
    ,gyd_limit
    ,securities_limit
    ,other_limit
    ,total_distursed_amt
    ,credit_facility_balance
    ,lc_balance
    ,gyd_balance
    ,securities_balance
    ,other_balance
    ,total_balance
    ,no_of_bank_fi
    ,number_of_BRP
    ,no_of_nonbank_fi
    ,no_of_other_fi
    ,historical_worst_status
    ,worst_status_record_date
from (
    select
        --ktp_id
        concat_ws('_', id_no, request_id) as ktp_request_id
        ,get_json_object(ringkasanFasilitas, '$.plafonEfektifLc') as lc_limit
        ,get_json_object(ringkasanFasilitas, '$.plafonEfektifGyd') as gyd_limit
        ,get_json_object(ringkasanFasilitas, '$.plafonEfektifSec') as securities_limit
        ,get_json_object(ringkasanFasilitas, '$.plafonEfektifLain') as other_limit
        ,get_json_object(ringkasanFasilitas, '$.bakiDebetKreditPembiayaan') as credit_facility_balance
        ,get_json_object(ringkasanFasilitas, '$.bakiDebetLc') as lc_balance
        ,get_json_object(ringkasanFasilitas, '$.bakiDebetGyd') as gyd_balance
        ,get_json_object(ringkasanFasilitas, '$.bakiDebetSec') as securities_balance
        ,get_json_object(ringkasanFasilitas, '$.bakiDebetLain') as other_balance
        ,get_json_object(ringkasanFasilitas, '$.bakiDebetTotal') as total_balance
        ,get_json_object(ringkasanFasilitas, '$.krediturBPR/S') as number_of_BRP
        ,get_json_object(ringkasanFasilitas, '$.krediturLainnya') as no_of_other_fi
        
        ,case 
            when coalesce(get_json_object(ringkasanFasilitas, '$.plafonEfektifKreditPembiayaan'),'') = '' then '-99999'
            else get_json_object(ringkasanFasilitas, '$.plafonEfektifKreditPembiayaan')
            end as total_os        
        ,case 
            when coalesce(get_json_object(ringkasanFasilitas, '$.plafonEfektifTotal'),'') = '' then '-99999'
            else get_json_object(ringkasanFasilitas, '$.plafonEfektifTotal')
            end as total_distursed_amt       
        ,case 
            when coalesce(get_json_object(ringkasanFasilitas, '$.krediturBankUmum'),'') = '' then '-99999'
            else get_json_object(ringkasanFasilitas, '$.krediturBankUmum')
            end as no_of_bank_fi        
        ,case 
            when coalesce(get_json_object(ringkasanFasilitas, '$.krediturLp'),'') = '' then '-99999'
            else get_json_object(ringkasanFasilitas, '$.krediturLp')
            end as no_of_nonbank_fi        
        ,case 
            when coalesce(get_json_object(ringkasanFasilitas, '$.kualitasTerburuk'),'') = '' then '-99999'
            else get_json_object(ringkasanFasilitas, '$.kualitasTerburuk')
            end as historical_worst_status
        ,case 
            when coalesce(get_json_object(ringkasanFasilitas, '$.kualitasBulanDataTerburuk'),'') = '' then '19700101080001'
            else get_json_object(ringkasanFasilitas, '$.kualitasBulanDataTerburuk')
            end as worst_status_record_date
    from (
        select
            --ktp_id
            get_json_object(result, '$.individual.parameterPencarian.noIdentitas') as id_no
            ,get_json_object(result, '$.header.idPermintaan') as request_id
            --others
            ,get_json_object(result, '$.individual.ringkasanFasilitas') as ringkasanFasilitas
        from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
        where grass_date = '${ds}'
            and get_json_object(result, '$.individual.ringkasanFasilitas') is not null
            and get_json_object(result, '$.individual.ringkasanFasilitas') <> ''
    )
);
