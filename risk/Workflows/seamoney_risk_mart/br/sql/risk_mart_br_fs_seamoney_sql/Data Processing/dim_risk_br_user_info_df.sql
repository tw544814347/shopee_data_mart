--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-11
-- Theme Domain：       user_info
-- Description:         risk mp user_info, https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit#gid=617476295
-- Data Granularity:    platform_user_id
-- 变更历史：
--********************************************************************--


drop table if exists ${SCHEMA}.dim_risk_${region}_user_info_df;
create external table if not exists ${SCHEMA}.dim_risk_${region}_user_info_df (
    platform_user_id string comment 'platform_user_id'
    ,is_seller bigint comment 'is_seller'
    ,shopee_age bigint comment 'datediff(format_time(ctime,upper({region})),current_date)'
    ,is_phone_verified bigint comment 'is_phone_verified'
    ,first_credit_act_succ_lc1 string comment 'first_credit_act_succ_lc1'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_user_info_df/garss_region=${upper_region}'
;
msck repair table ${SCHEMA}.dim_risk_${region}_user_info_df;

add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

create or replace temporary view tmp_credit_act_succ_lc1 as
select
    platform_user_id
    ,activation_url1 as first_credit_act_succ_lc1
from
    (
        select
            apply_no
            ,split(face_image_urls, ',') [1] as activation_url1
            ,platform_user_id
            ,row_number() over (
                partition by platform_user_id
                order by activate_start_time asc, activate_result_time asc
            ) as rank_id
        from credit_uc.dwd_all_prod_br_uc_apply_df
        where
            grass_date = '${grass_date}'
            and apply_type = 1
            and product_id in (1, 2, 3)
    )
where rank_id = 1
;

insert overwrite table ${SCHEMA}.dim_risk_${region}_user_info_df partition(grass_date='${grass_date}')
select 
t1.userid                 as platform_user_id
,t1.is_seller             as is_seller
,datediff('${smd_grass_date}',format_time(t1.ctime,upper('${region}'))) as shopee_age
,t1.phone_verified        as is_phone_verified
,t2.first_credit_act_succ_lc1
from (
    select
        userid
        ,is_seller
        ,ctime
        ,phone_verified
    from marketplace.shopee_account_v2_db__account_tab__${region}_df
) t1
left join tmp_credit_act_succ_lc1 t2 on t1.userid = t2.platform_user_id
;