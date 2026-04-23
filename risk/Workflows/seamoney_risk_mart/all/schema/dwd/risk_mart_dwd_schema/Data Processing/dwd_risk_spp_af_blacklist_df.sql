drop table if exists risk.dwd_risk_spp_af_blacklist_df;
create external table if not exists risk.dwd_risk_spp_af_blacklist_df
(
    list_id               bigint comment 'list_id'
    ,list_name            string comment 'list_name'
    ,list_status          string comment '1生效，0失效，-1废弃'  
    ,data                 string comment 'list data'
    ,data_type            string comment 'data_type'
    ,data_source          string comment 'listname source'
    ,action_detail        string comment 'action_detail'
    ,remark               string comment 'remark'
    ,description          string comment 'description'
    ,status               string comment 'status 1:active -1:delete 0:unactive 2:waiting'
    ,status_type          string comment 'status 1:active -1:delete 0:unactive 2:waiting'
    ,creator              string comment 'creator'
    ,create_time          string comment 'create_time'
    ,update_time          string comment 'update_time'
    ,expire_time          string comment 'expire_time'
    ,create_time_regional string comment 'sg create_time'
    ,update_time_regional string comment 'sg update_time'
    ,expire_time_regional string comment 'sg expire_time' 
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_spp_af_blacklist_df';
msck repair table ${SCHEMA}.dwd_risk_spp_af_blacklist_df;

create or replace view risk.dwd_risk_id_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'ID'
;

create or replace view risk.dwd_risk_my_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'MY'
;

create or replace view risk.dwd_risk_ph_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'PH'
;

create or replace view risk.dwd_risk_th_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'TH'
;

create or replace view risk.dwd_risk_sg_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'SG'
;

create or replace view risk.dwd_risk_vn_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'VN'
;

create or replace view risk.dwd_risk_tw_spp_af_blacklist_df as
select
    *
from risk.dwd_risk_spp_af_blacklist_df
where grass_region = 'TW'
;