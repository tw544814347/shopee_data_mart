insert overwrite table risk.dwd_risk_ph_uw_bureau_main_id_history_address_df partition(grass_date)
select
    platform_user_id
    ,flow_no
    ,request_time
    ,cast(get_json_object(json_string,'$.FlagCurrent') as string) as flag_current
    ,cast(get_json_object(json_string,'$.LastUpdateDate') as string) as last_update_date
    ,cast(get_json_object(json_string,'$.Address.FullAddress') as string) as full_address
    ,cast(get_json_object(json_string,'$.Address.OccupiedSince') as string) as occupied_since
    ,cast(get_json_object(json_string,'$.Address.Type') as string) as type
    ,cast(get_json_object(json_string,'$.Address.Barangay') as string) as barangay
    ,cast(get_json_object(json_string,'$.Address.City') as string) as city
    ,cast(get_json_object(json_string,'$.Address.PostalCode') as string) as postal_code
    ,cast(get_json_object(json_string,'$.Address.Province') as string) as province
    ,cast(get_json_object(json_string,'$.Address.StreetNo') as string) as street_no
    ,cast(get_json_object(json_string,'$.Address.Subdivision') as string) as subdivision
    ,cast(get_json_object(json_string,'$.AddressDesc.HouseOwnerLesseeDesc') as string) as house_owner_lessee_desc
    ,cast(get_json_object(json_string,'$.AddressDesc.TypeDesc') as string) as type_desc
    ,cast(get_json_object(json_string,'$.AddressDesc.CountryDesc') as string) as country_desc
    ,grass_date
from(
    select
        platform_user_id
        ,flow_no
        ,request_time
        ,split(regexp_replace(regexp_extract(temp_string_array,'^\\[(.+)\\]$',1),'\\}\\,\\{','\\}\\|\\|\\{'),'\\|\\|') as temp_json_list
        ,grass_date
    from(
        select
            cast(get_json_object(header_data,'$.PlatformUserId') as string )  as platform_user_id
            ,cast(get_json_object(header_data,'$.FlowNo') as string )         as flow_no
            ,create_time                                                      as request_time
            ,get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.MatchedSubject.Individual.AddressHistory')  as temp_string_array
            ,grass_date
        from risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
        where grass_date = '${grass_date}'
        and data_source_name = 'CrifData'
        and data_source_code = 2
    )a
)b lateral view explode(temp_json_list) as json_string;
