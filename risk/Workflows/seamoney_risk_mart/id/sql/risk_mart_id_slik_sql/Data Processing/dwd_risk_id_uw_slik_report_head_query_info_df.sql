insert overwrite table ${SCHEMA}.dwd_risk_id_uw_slik_report_head_query_info_df partition (grass_date='${ds}')
select
    concat_ws('_', a1.id_no, a1.request_id) as id
    ,a2.shopee_id
    ,a2.credit_user_id
    ,a1.request_reference_code
    ,a1.report_search_date
    ,a1.request_id
    ,a1.requester_userid
    ,a1.requester_username
    ,a1.requester_ljk_code
    ,a1.requester_branch_code
    ,a1.requester_code
    ,a1.report_request_date
    ,a1.total_section
    ,a1.report_section
    ,a1.report_id
    ,a1.latest_update_date
    ,a1.request_date
    ,a1.name
    ,a1.gender
    ,a1.gender_code
    ,a1.id_no
    ,a1.npwp
    ,a1.birthplace
    ,a1.birthday
from (
    select
        -- header
        get_json_object(header, '$.idPermintaan') as request_id
        ,get_json_object(header, '$.kodeReferensiPengguna') as request_reference_code
        ,case 
            when coalesce(get_json_object(header, '$.tanggalHasil'),'') = '' then '19700101080001'
            else get_json_object(header, '$.tanggalHasil')
            end as report_search_date
        ,get_json_object(header, '$.idPenggunaPermintaan') as requester_userid
        ,get_json_object(header, '$.dibuatOleh') as requester_username
        ,get_json_object(header, '$.kodeLJKPermintaan') as requester_ljk_code
        ,get_json_object(header, '$.kodeCabangPermintaan') as requester_branch_code
        ,get_json_object(header, '$.kodeTujuanPermintaan') as requester_code
        ,case 
            when coalesce(get_json_object(header, '$.tanggalPermintaan'),'') = '' then '19700101080001'
            else get_json_object(header, '$.tanggalPermintaan')
            end as report_request_date
        ,get_json_object(header, '$.totalBagian') as total_section
        ,get_json_object(header, '$.nomorBagian') as report_section
        
        -- individual
        ,get_json_object(individual, '$.nomorLaporan') as report_id
        ,get_json_object(individual, '$.posisiDataTerakhir') as latest_update_date
        ,case 
            when coalesce(get_json_object(individual, '$.tanggalPermintaan'),'') = '' then '19700101080001'
            else get_json_object(individual, '$.tanggalPermintaan')
            end as request_date
        
        --parameterPencarian
        ,get_json_object(parameterPencarian, '$.namaDebitur') as name
        ,get_json_object(parameterPencarian, '$.jenisKelamin') as gender
        ,get_json_object(parameterPencarian, '$.jenisKelaminKet') as gender_code
        ,get_json_object(parameterPencarian, '$.npwp') as npwp
        ,get_json_object(parameterPencarian, '$.tempatLahir') as birthplace
        ,get_json_object(parameterPencarian, '$.tanggalLahir') as birthday
        ,get_json_object(parameterPencarian, '$.noIdentitas') as id_no
    from (
        select
            get_json_object(result, '$.header') as header
            ,get_json_object(result, '$.individual') as individual
            ,get_json_object(result, '$.individual.parameterPencarian') as parameterPencarian
        from ${SCHEMA}.dwd_risk_id_uw_slik_report_df
        where grass_date = '${ds}'
          and get_json_object(result, '$.individual.parameterPencarian') is not null
          and get_json_object(result, '$.individual.parameterPencarian') <> ''
    )
) a1
left outer join (
    select
        *
    from (
        select 
            ktp,
            shopee_id,
            credit_user_id,
            row_number() over(partition by ktp order by apply_id asc) as rn
        from risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab__df
        where
        grass_date = '${ds}'
        and coalesce(shopee_id, 0) <> 0 and coalesce(credit_user_id, 0) <> 0
    )
    where rn = 1
) a2
on a1.id_no = a2.ktp;