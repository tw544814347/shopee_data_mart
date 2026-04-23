-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-24
-- Theme Domain:        
-- Data Granularity:    
-- Description:         dwd screen_tab
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-24 - chengguo.liu - 初始化, BR screen_tab暂未上线
-- =============================================================================

--drop table if exists ${SCHEMA}.dwd_credit_${region}_risk_screen_df;
create external table if not exists ${SCHEMA}.dwd_credit_${region}_risk_screen_df (
    id                                  string comment '申请单ID'
    ,apply_no                           string comment '申请单编号'
    ,platform_type                      bigint comment '平台类型ID：0-none;1-shopee;2-airpay;3-merchat'
    ,platform_type_name                 string comment '平台类型名'
    ,platform_user_id                   string comment '平台id'
    ,credit_user_id                     string comment '用户id'
    ,apply_type                         bigint comment '申请业务类型: 0-NONE; 1-ACTIVATION(激活); 2-INCREASE_LIMIT(提额); 3-UPDATE_KYC_INFO(更新kyc资料)'
    ,apply_type_name                    string comment '申请业务类型: 0-NONE; 1-ACTIVATION(激活); 2-INCREASE_LIMIT(提额); 3-UPDATE_KYC_INFO(更新kyc资料)'
    ,apply_status                       bigint comment '申请单状态，4=通过，5=拒绝，apply_activation_order_tab也能取到'
    ,is_apply_type_activation           bigint comment '申请类型是否是激活：1:yes,0:no'
    ,post_update_info                   string comment '更新信息'
    ,operator                           string comment 'ops操作者邮箱'
    ,create_time                        string comment '创建时间'
    ,update_time                        string comment '更新时间'
    ,audit_not_mother_name              string comment 'additionalInfo.notMotherName'
    ,audit_not_occupation               string comment 'additionalInfo.notOccupation'
    ,audit_not_company_name             string comment 'additionalInfo.notCompanyName'
    ,audit_not_risk_level               string comment 'additionalInfo.notRiskLevel'
    ,audit_not_real_human_photo         string comment 'additionalInfo.notRealHumanPhoto'
    ,audit_not_face_match               string comment 'additionalInfo.notFaceMatch'
    ,operator_start_time                string comment '派单审核开始时间'
    ,operator_end_time                  string comment '派单审核提交时间'
    ,audit_extra_info                   string comment 'BRScreenRejectType'
    ,maker_operator                     string comment 'maker审核人'
    ,maker_extra_info                   string comment 'maker审核扩展信息'
    ,maker_update_info                  string comment 'maker更新时间'
    ,maker_submit_time                  string comment 'maker审核提交时间'
    ,audit_other                        string comment '审核输出other内容'
    ,maker_audit_other                  string comment 'maker审核输出other内容'
    ,context                            string comment '工单拒绝原因'
    ,reject_code                        string comment '工单拒绝码'
    ,screen_platform                    bigint comment '0=UC 1=Risk'
    ,submission_time                    string comment 'submission_time'
    ,screen_completed_time              string comment '审核完成时间'
    ,audit_not_ektp_number_not_clear    string comment 'additionalInfo.notEktpOrNumberNotClear'
    ,audit_ic_screenshot_or_copy       string comment 'additionalInfo.icScreenshotOrCopy'
    ,audit_not_main_information         string comment 'additionalInfo.notMainInformation'
    ,kyc_freeze_reasons                 string comment '冻结原因-kyc'
    ,fraud_freeze_reasons               string comment '冻结原因-欺诈'
    ,is_skip_idwall                     bigint comment '是否跳过idwall'
    ,operator_map_no                    string comment '审核人map_no'
    ,broken_ektp_name                   bigint comment '审核输出'
    ,audit_not_allow_age                string comment 'additionalInfo.notAllowAge'
    ,not_nik_clear                      string comment 'additionalInfo.notIdCardNoClear'
    ,not_ektp                           string comment 'additionalInfo.notEktp'
    ,broken_ektp_nik                    string comment 'additionalInfo.notEktp=false&&additionalInfo.brokenNik=true'
    ,broken_ektp_photo                  string comment 'additionalInfo.notEktp=false&&additionalInfo.brokenPhoto=true'
    ,user_label                         string comment ''
    ,screen_type                        string comment 'screen_type'
) partitioned by (
    product_id  bigint
    ,grass_date string comment 'YYYY-MM-dd'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dwd/dwd_credit_reg_risk_screen_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dwd_credit_${region}_risk_screen_df;
