--********************************************************************--
-- Author:              nuo.chen@shopee.com
-- Created Time:        2026-02-04
-- Theme Domain：       user biz manage table sync
-- Description:         业务侧透传表
-- Data Granularity:    
-- 文档:                 https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60224
-- 注意:                 SHCAME和SQL在一起, 新增字段记得解开drop + msck, 跑完后注释掉drop + msck (表分区多后会影响SLA)!!!              
-- 变更历史：             
-- 2026-02-04   chennuo    创建脚本
--********************************************************************--


drop table if exists ${SCHEMA}.dwd_risk_reg_user_biz_manage_spp_union_trust_entity_list_df;
create external table if not exists ${SCHEMA}.dwd_risk_reg_user_biz_manage_spp_union_trust_entity_list_df
(
    spp_uid         string
    ,szdf_list      string
    ,biz_type       string
)partitioned by(
    region          string
    ,grass_date     string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/risk_feature/dwd/dwd_risk_reg_user_biz_manage_spp_union_trust_entity_list_df'
;

msck repair table ${SCHEMA}.dwd_risk_reg_user_biz_manage_spp_union_trust_entity_list_df;
refresh table ${SCHEMA}.dwd_risk_reg_user_biz_manage_spp_union_trust_entity_list_df;


insert overwrite ${SCHEMA}.dwd_risk_reg_user_biz_manage_spp_union_trust_entity_list_df partition (region, grass_date)
select 
    spp_uid 
    ,szdf_list
    ,biz_type

    -- partition column
    ,region
    ,'${ds}' as grass_date
from (
    select *, replace('spp_kyc_device_list', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_kyc_device_list 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_kyc_device_list)
    union 
    select *, replace('spp_frequent_pay_device_list', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_frequent_pay_device_list 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_frequent_pay_device_list)
    union 
    select *, replace('spp_sub_trust_devicve_list_v1', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_sub_trust_devicve_list_v1 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_sub_trust_devicve_list_v1)
    union 
    select *, replace('spp_sub_trust_devicve_list_v2', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_sub_trust_devicve_list_v2 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_sub_trust_devicve_list_v2)
    union 
    select *, replace('spp_sub_trust_devicve_list_v3', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_sub_trust_devicve_list_v3 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_sub_trust_devicve_list_v3)
    union 
    select *, replace('spp_sub_trust_devicve_list_v4', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_sub_trust_devicve_list_v4 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_sub_trust_devicve_list_v4)
    union 
    select *, replace('spp_verified_lc_otp_device_list', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_verified_lc_otp_device_list 
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_verified_lc_otp_device_list)
    union 
    select *, replace('spp_verified_lc_device_list', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_verified_lc_device_list
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_verified_lc_device_list)
    union 
    select *, replace('spp_verified_otp_device_list', '_', '-') as biz_type
    from smcdrisk_antifraud.spp_verified_otp_device_list
    where grass_date = (select max(grass_date) from smcdrisk_antifraud.spp_verified_otp_device_list)
)


