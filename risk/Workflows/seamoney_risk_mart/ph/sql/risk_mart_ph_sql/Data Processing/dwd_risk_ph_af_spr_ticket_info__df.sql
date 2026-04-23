insert overwrite table risk.dwd_risk_ph_af_spr_ticket_info__df partition(grass_date)
select
    ticket_id,
    platform_user_id,
    result,
    create_time,
    update_time,
    reject_platform_user_id,
    reject_user_name,
    reject_gender,
    reject_birthday,
    cast(get_json_object(json_string,'$.MatchedType') as string) as ticket_matched_type,
    cast(get_json_object(json_string,'$.PlatformUserId') as string) as ticket_platform_user_id,
    cast(get_json_object(json_string,'$.CreditUserId') as string) as ticket_credit_user_id,
    cast(get_json_object(json_string,'$.FaceMatchingScore') as bigint) as ticket_face_matching_score,
    cast(get_json_object(json_string,'$.UserName') as string) as ticket_user_name,
    cast(get_json_object(json_string,'$.Gender') as bigint) as ticket_gender,
    cast(get_json_object(json_string,'$.Birthday') as string) as ticket_birthday,
    grass_date
from(
    select
        ticket_id,
        platform_user_id,
        result,
        create_time,
        update_time,
        reject_platform_user_id,
        reject_user_name,
        reject_gender,
        reject_birthday,
        split(regexp_replace(regexp_extract(temp_string_array,'^\\[(.+)\\]$',1),'\\}\\,\\{','\\}\\|\\|\\{'),'\\|\\|') as temp_json_list,
        grass_date
    from(
        select
            ticket_id,
            platform_user_id,
            af_screen_result as result,
            UNIX_TIMESTAMP(af_screen_start_time) as  create_time,
            UNIX_TIMESTAMP(af_screen_update_time) as update_time,
            cast(get_json_object(reject_reason,'$.PlatformUserId') as string) as reject_platform_user_id,
            cast(get_json_object(reject_reason,'$.UserName') as string) as reject_user_name,
            cast(get_json_object(reject_reason,'$.Gender')  as bigint) as reject_gender,
            cast(get_json_object(reject_reason,'$.Birthday')  as string) as reject_birthday,
            get_json_object(ticket_info,'$.TicketDuplicateInfoForOneToN')  as temp_string_array,
            grass_date
        from risk.dwd_credit_ph_risk_ticket_df
        where grass_date='${grass_date}'
        and app_id = 'spr'
        and scene_id = 10001
        and ticket_category = 7
        and ticket_subtype  = 1
        and status = 2
        and to_date(af_screen_start_time) >= '2021-12-17'
    )a
)b lateral view explode(temp_json_list) as json_string
;

msck repair table risk.dwd_risk_ph_af_spr_ticket_info__df ;