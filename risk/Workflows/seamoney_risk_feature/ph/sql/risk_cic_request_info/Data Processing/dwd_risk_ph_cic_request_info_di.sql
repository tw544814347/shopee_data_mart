insert overwrite ${SCHEMA}.dwd_risk_ph_cic_request_info_di partition (grass_date)
select
get_json_object(value,'$.ReqParams.CommonHeader.platform_user_id')  as platform_user_id
,'PHP' as application_currency
, '${ds}' as application_contractrequestdate
, 'RQ' as application_contractphase
, '70' as application_contracttype
, '' as application_noninstallment_creditlimit
, if(scene_id='10011',get_json_object(value,'$.ReqParams.kyc_info.current_addr'),get_json_object(value,'$.ReqParams.address')) as miaddress
, if(scene_id='10011',get_json_object(value,'$.ReqParams.kyc_info.current_addr'),get_json_object(value,'$.ReqParams.address')) as aiaddress
, 'B' as link_role
, uuid() as applicationcodes_providerapplicationno
, '' as applicationcodes_providercontractno
, '' as applicationcodes_cbcontractcode
, '' as link_companyrole
,if(scene_id='10011',get_json_object(value,'$.ReqParams.kyc_info.birthday'),get_json_object(value,'$.ReqParams.date_of_birth')) as subject_individual_birthdata_date
,'3' as subject_individual_contact_type
,get_json_object(value,'$.ReqParams.PhoneNo') as subject_individual_contact_value
,get_json_object(value,'$.ReqParams.gender_by_user') as subject_individual_generaldataindividual_gender
,if(scene_id='10011',get_json_object(value,'$.ReqParams.kyc_info.birthday'),get_json_object(value,'$.ReqParams.date_of_birth')) as subject_individual_id_number
,if(scene_id='10011',get_json_object(value,'$.ReqParams.kyc_info.id_type'),get_json_object(value,'$.ReqParams.id_type')) as subject_individual_id_type
,get_json_object(value,'$.ReqParams.id_card_no') as subject_individual_identificationcode_number
,if(scene_id='10011',get_json_object(value,'$.ReqParams.kyc_info.id_type'),get_json_object(value,'$.ReqParams.id_type')) as subject_individual_identificationcode_type
,split(get_json_object(value,'$.ReqParams.user_name'),'\\|')[0] as subject_individual_individualname_firstname
,split(get_json_object(value,'$.ReqParams.user_name'),'\\|')[2] as subject_individual_individualname_lastname
,scene_id
,tn
,grass_date
from    risk.ods_risk_live_kafka_gateway_req_rsp_di
where   grass_region = 'PH'
  and   scene_id in ('10011', '10001')
  and   tn in ('ph_live_credit_risk_gateway_req_rsp_kredit', 'ph_live_credit_risk_gateway_req_rsp_spj')
  and   grass_date='${ds}'
