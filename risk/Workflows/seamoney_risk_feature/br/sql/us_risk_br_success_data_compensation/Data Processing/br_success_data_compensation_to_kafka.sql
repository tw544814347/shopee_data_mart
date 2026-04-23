create database if not exists kafka.risk;

CREATE TABLE if not exists kafka.risk.success_join_data_detail_history (
    Req struct<
        RiskReqHeader: struct<
            Version: INT,
            AppID: STRING,
            SceneID: INT,
            FlowNo: STRING,
            ReqTime: BIGINT
        >
    >,
    ReqParams struct<
        CommonHeader: struct<
            platform_user_id: STRING,
            device_fingerprint: STRING,
            client_ip: STRING,
            extension_process_data: struct<
                tongdun_deviec_info: struct<
                    tongdun_df: STRING
                >,
                sz_dfp: struct<
                    device_id: STRING
                >
            >
        >,
        PhoneNo: STRING,
        emergencyContactInfo: struct<
            emergency_contact_phone1: STRING,
            emergency_contact_phone2: STRING
        >,
        kyc_info: struct<
            EmergencyContactInfo: array<
                struct<emergency_contact_phone: string>
            >
        >,
        is_spl_activated: BIGINT,
        is_cashloan_activated: BIGINT,
        is_sellerloan_activated: BIGINT,
        FlowNo: STRING,
        `Time`: BIGINT,
        id_card_no: STRING
    >
)
TBLPROPERTIES (
    'format'='json',
    'properties.bootstrap.servers'='di-kafka-asb01-bg1-bootstrap01-ashburn-us.data-infra.shopee.io:9093,di-kafka-asb01-bg1-bootstrap02-ashburn-us.data-infra.shopee.io:9093,di-kafka-asb01-bg1-bootstrap03-ashburn-us.data-infra.shopee.io:9093',
    'topic'='BR_live_success_data_compensation'
);

insert into table kafka.risk.success_join_data_detail_history
select 
    struct(
        struct(
            cast(get_json_object(value, '$.Req.RiskReqHeader.Version') as int) as Version
            ,get_json_object(value, '$.Req.RiskReqHeader.AppID') as AppID
            ,cast(get_json_object(value, '$.Req.RiskReqHeader.SceneID') as int) as SceneID
            ,get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as FlowNo
            ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as ReqTime
        ) as RiskReqHeader
    ) as Req
    ,struct(
        struct(
            get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id') as platform_user_id
            ,get_json_object(value, '$.ReqParams.CommonHeader.device_fingerprint') as device_fingerprint
            ,get_json_object(value, '$.ReqParams.CommonHeader.client_ip') as client_ip
            ,struct(
                struct(
                    get_json_object(value, '$.ReqParams.CommonHeader.extension_process_data.tongdun_deviec_info.tongdun_df') as tongdun_df
                ) as tongdun_deviec_info
                , struct(
                    get_json_object(value, '$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id') as device_id
                ) as sz_dfp
            ) as extension_process_data
        ) as CommonHeader
        ,get_json_object(value, '$.ReqParams.PhoneNo') as PhoneNo
        ,struct(
            get_json_object(value, '$.ReqParams.emergencyContactInfo.emergency_contact_phone1') as emergency_contact_phone1
            ,get_json_object(value, '$.ReqParams.emergencyContactInfo.emergency_contact_phone2') as emergency_contact_phone2
        ) as emergencyContactInfo
        ,struct(
            from_json(get_json_object(value, '$.ReqParams.kyc_info.EmergencyContactInfo'), 
                schema_of_json('[{"emergency_contact_phone":"081289682611"}]')) as EmergencyContactInfo
        ) as kyc_info
        ,cast(get_json_object(value, '$.ReqParams.is_spl_activated') as bigint) as is_spl_activated
        ,cast(get_json_object(value, '$.ReqParams.is_cashloan_activated') as bigint) as is_cashloan_activated
        ,cast(get_json_object(value, '$.ReqParams.is_sellerloan_activated') as bigint) as is_sellerloan_activated
        ,get_json_object(value, '$.ReqParams.FlowNo') as FlowNo
        ,cast(get_json_object(value, '$.ReqParams.Time') as bigint) as `Time`
        ,get_json_object(value, '$.ReqParams.id_card_no') as id_card_no
    ) as ReqParams
from risk.success_join_data_detail_history 
where grass_region = '${region}'
    and dt >= '${begin_3ds}'
    and abs(request_reqtime - result_reqtime) >= 7 * 86400
;
