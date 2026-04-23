drop table if exists ${SCHEMA}.dwd_uc_${region}_user_limit_info_df;
create external table if not exists ${SCHEMA}.dwd_uc_${region}_user_limit_info_df
(

platform_user_id              STRING       comment "platform_user_id 平台用户id"
,platform_type                INT          comment "platform_type 平台类型 1-shopee,2-airPay,3-merchant"
,sub_biz_type                 STRING       comment "sub_biz_type 子产品业务类型 partner loan中的subAppId"
,operator                     STRING       comment "operator    修改用户"
,create_time                  STRING       comment "create_time    分期信息创建时间"
,update_time                  STRING       comment "update_time    分期信息更新时间"
,activation_source            INT          comment "UNKNOWN:0; PRE_APPROVE:1; REALTIME:2; MTA:3; LITE_UPGRADE:4; LITE_UPGRADE_PRE_APPROVE:5; LITE_UPGRADE_REALTIME:6; OTA:7"
,version                      INT          comment "verstion-版本"
,currency_units               BIGINT       comment "currency_units 货币单位"
,sync_credit_status           INT          comment "sync_credit_status 同步状态" 
,event_id                     STRING       comment "event_id 上传模版" 
,event_detail                 STRING       comment "event_detail上传模版备注信息" 
,source                       STRING       comment "" 
,base_limit                   BIGINT       comment "基本额度"
,bnpl_limit                   BIGINT       comment "BNPL额度(Buy Now Pay Later)"
,installment_limit            BIGINT       comment "分期额度"
,advanced_limit               BIGINT       comment "提额额度"
,total_limit                  BIGINT       comment "基本额度"
,temporary_limit              BIGINT       comment "临时额度"
,temp_limit_start_time        STRING       comment "临时额度 开始时间"
,temp_limit_end_time          STRING       comment "临时额度 结束时间"
,ceiling_limit                BIGINT       comment "上限额度"
,customer_level_credit_limit  BIGINT       comment "term 分期期数"
)
comment 'uc_whitelist'
partitioned by
(
     app_id         int            comment         '1-spl,2-bcl,3-scl,4-fes,5-partnerLoan,6-spl_lite,7-mcl,8-cpl,9-chp'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_uc_user_limit_info_df/grass_region=${upper_region}';
msck repair table ${SCHEMA}.dwd_uc_${region}_user_limit_info_df;