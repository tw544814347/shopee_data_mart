-- prd https://confluence.shopee.io/pages/viewpage.action?pageId=1876028772
-- prd https://confluence.shopee.io/pages/viewpage.action?pageId=1903876290
-- 大规模名单业务目前是手动拆多个文件上传，存在传错的风险，希望可以走更加自动化的pipeline。
-- 1、短期需要先支持ID SPL的额度、期数费率调整等3个名单在risk系统实现
-- update by zongyi.lu@shopee.com 2024-10-14 用户删除了id_spl_holmes_temporary_limit_upload,已经建了空表因此继续同步id_spl_holmes_temporary_limit_upload的数据
-- update by chengguo.liu@shopee.com 2025-06-23 下线任务，已跟业务和DPM确认  https://confluence.shopee.io/pages/viewpage.action?pageId=1903876290


DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_holmes_user_limit_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_holmes_user_limit_list_df
(
    platform_user_id      string comment 'platform_user_id',
    platform_type         string comment '平台类型 shopee或partner app',
    extend_info           string comment '名单对应的字段信息'
)
comment 'risk sync to holmes user list'
partitioned by
(
    grass_region string comment 'region'
    ,grass_date string comment 'grass_date task_runing_date'
    ,source_table string comment 'smcdrisk_policy table'
    ,event_id string comment 'event_id,batch1表示上午批次，batch2表示下午批次，一天2个批次'
    ,event_detail string comment '事件描述, 方便业务标识批量操作的字段; '
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_holmes_user_limit_list_df';
;

insert overwrite table ${SCHEMA}.ads_risk_holmes_user_limit_list_df partition(grass_region,grass_date,source_table,event_id,event_detail)
-- 永久额度调整
select 
platform_user_id 
,platform_type 
,to_json(
        named_struct(
            'bnpl_limit',bnpl_limit
            ,'original_bnpl_limit',original_bnpl_limit
            ,'installment_limit',installment_limit
            ,'user_type',user_type
        )
    )            as extend_info
,'ID'                                      as grass_region 
,'${grass_date}'                           as grass_date
,'id_spl_holmes_permanent_limit_upload'     as source_table
,event_id                                  as event_id
,event_detail                              as event_detail
from smcdrisk_policy.id_spl_holmes_permanent_limit_upload
where event_id like '${cur_date}_batch2%'
-- 期数费率调整
union all 
select 
platform_user_id 
,platform_type 
,to_json(
        named_struct(
            'eligible_for_2m',eligible_for_2m
            ,'eligible_for_3m',eligible_for_3m
            ,'eligible_for_6m',eligible_for_6m
            ,'eligible_for_12m',eligible_for_12m
            ,'eligible_for_24m',eligible_for_24m
            ,'bnpl_interest_rate',bnpl_interest_rate
            ,'2m_interest_rate',2m_interest_rate
            ,'3m_interest_rate',3m_interest_rate
            ,'6m_interest_rate',6m_interest_rate
            ,'12m_interest_rate',12m_interest_rate
            ,'18m_interest_rate',18m_interest_rate
            ,'24m_interest_rate',24m_interest_rate
            ,'admin_fee_rate',admin_fee_rate
            ,'buyer_transaction',buyer_transaction_fee_rate
            ,'penalty_interest_rate',penalty_interest_rate
            ,'late_charge_rate',late_charge_rate
        )
    ) as extend_info
,'ID'                                      as grass_region 
,'${grass_date}'                           as grass_date
,'id_spl_holmes_tenure_and_fee_upload'     as source_table
,event_id                                  as event_id
,event_detail                              as event_detail
from smcdrisk_policy.id_spl_holmes_tenure_and_fee_upload
where event_id like '${cur_date}_batch2%'
;

msck repair table risk.ads_risk_holmes_user_limit_list_df ;
