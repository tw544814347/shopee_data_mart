-- =============================================================================
--  Version History:
--  2025-11-20 - chengguo.liu - 确认下游没有使用，下线清理
-- =============================================================================

set spark.sql.session.timeZone=GMT+7;

INSERT OVERWRITE TABLE ${SCHEMA}.dwd_th_af_activation_aripay_info_df PARTITION (grass_date = '${bizdate}')
select flow_no
      ,app_id
      ,scene_id
      ,platform_user_id
      ,create_time
      ,get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_liveness_check_picture_url1')            as airpay_liveness_check_picture_url1
      ,get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_liveness_check_picture_url2')            as airpay_liveness_check_picture_url2
      ,cast(get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_liveness_check_result') as int)     as airpay_liveness_check_result
      ,cast(get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_liveness_check_time') as bigint)    as airpay_liveness_check_time
      ,cast(get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_anti_spoofing_result') as int)      as airpay_anti_spoofing_result
      ,cast(get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_anti_spoofing_time') as bigint)     as airpay_anti_spoofing_time
      ,get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_anti_spoofing_score')                    as airpay_anti_spoofing_score
      ,cast(get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_facial_matching_result') as int)    as airpay_facial_matching_result
      ,cast(get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_facial_matching_time') as bigint)   as airpay_facial_matching_time
      ,get_json_object(cast(unbase64(get_json_object(input, '$.Params')) as string), '$.airpay_facial_macthing_score')                  as airpay_facial_macthing_score
from risk.ods__credit_risk_control_th_db__workflow_tab__df
where grass_date = '${bizdate}'
  and ((app_id = 'kredit' and scene_id = 10011) or (app_id in ('spj', 'spjup') and scene_id = 10001))
;

msck repair table risk.dwd_th_af_activation_aripay_info_df;