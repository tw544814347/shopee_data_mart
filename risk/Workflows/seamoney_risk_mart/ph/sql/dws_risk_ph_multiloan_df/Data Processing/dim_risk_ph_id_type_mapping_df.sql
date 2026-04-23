--********************************************************************--
-- Author:              nuo.chen@shopee.com
-- Created Time:        2025-12-16
-- Theme Domain：       DIM ph id_card_type 映射表
-- Description:         id_card_type映射, id_type枚举要改成与ads_2bscore_ph_user_kyc_info_df保持一致
-- Data Granularity:    platform_user_id + id_card_no + new_id_card_type + 
-- 文档:                 https://jira.shopee.io/browse/SPFDT-58591
-- 变更历史：             
--********************************************************************--


-- drop table if exists ${SCHEMA}.dim_risk_ph_id_type_mapping_df;
create table if not exists ${SCHEMA}.dim_risk_ph_id_type_mapping_df 
( 
    platform_user_id            string comment 'Shopee platform user id'
    ,id_card_no                 string comment 'Identification card number'
    ,id_type_no                 string comment 'new_id_card_type + id_card_no'
    ,new_id_card_type           bigint comment 'new ID type used in KYC'
    ,original_id_card_type      bigint comment 'original ID type used in KYC'
    ,id_card_type_name          string comment 'ID card type name'
    ,update_time                string comment 'update time'
    ,create_date                string comment 'create date'
) 
partitioned by (grass_date string comment 'YYYY-MM-dd') 
stored as orc tblproperties (
    "orc.compress" = "zstd",
    "orc.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk/dim/dim_risk_id_type_mapping_df/grass_region=PH';
-- MSCK REPAIR TABLE ${SCHEMA}.dim_risk_ph_id_type_mapping_df;

-- credit
create or replace temporary view tmp_credit_ph_concat_id_type_no as
select  concat(a.new_id_card_type_credit, '_', a.id_card_no_credit) as concat_id_type_no
        ,b.platform_user_id
        ,a.id_card_type_name_credit
        ,a.new_id_card_type_credit
        ,a.original_id_card_type_credit
        ,a.id_card_no_credit
        ,create_date_credit
        ,update_time_credit
        ,'credit' as id_source_credit
from    (
    select  credit_user_id
            ,case   when id_card_type = 4 then 'UMID'
                    when id_card_type = 3 then 'Driver License'
                    when id_card_type = 2 then 'Passport'
                    when id_card_type = 6 then 'PRC'
                    when id_card_type = 17 then 'Phil ID'
                    when id_card_type = 21 then 'e-Phil ID'
                    when id_card_type = 7 then 'Health ID'
                    when id_card_type = 8 then 'Postal ID'
                    when id_card_type = 5 then 'SSS'
                    when id_card_type = 15 then 'TIN ID'
             end as id_card_type_name_credit
            ,case   when id_card_type = 4 then 1
                    when id_card_type = 3 then 2
                    when id_card_type = 2 then 3
                    when id_card_type = 6 then 4
                    when id_card_type in (17,21) then 5
                    when id_card_type = 7 then 6
                    when id_card_type = 8 then 7
                    when id_card_type = 5 then 8
                    when id_card_type = 15 then 9
             end as new_id_card_type_credit
            ,id_card_type as original_id_card_type_credit
            ,id_card_no as id_card_no_credit
            ,date(create_time) as create_date_credit
            ,update_time as update_time_credit
    from    credit_uc.dwd_uc_ph_user_id_card_info_df
    where   grass_date = '${grass_date}'
      and   id_card_type in (4, 3, 2, 6, 17, 21, 7, 8, 5, 15)
) a
inner join (
    select  credit_user_id
            ,platform_user_id
    from    credit_uc.dws_aio_ph_uc_user_df
    where   grass_date = '${grass_date}'
    group by 1,2
) b
on      a.credit_user_id = b.credit_user_id
;

-- spp
create or replace temporary view tmp_spp_ph_concat_id_type_no as
select  concat(new_id_card_type_spp, '_', id_card_no_spp) as concat_id_type_no
        ,*
        ,'spp' as id_source_spp
from    (
    select  platform_user_id
            ,create_date as create_date_spp
            ,update_time as update_time_spp
            ,id_card_type as original_id_card_type_spp
            ,id_card_no as id_card_no_spp
            ,case   when id_card_type = 6 then 'UMID'
                    when id_card_type = 2 then 'Driver License'
                    when id_card_type = 1 then 'Passport'
                    when id_card_type = 9 then 'PRC'
                    when id_card_type = 21 then 'e-Phil ID'
                    when id_card_type = 10 or id_card_type = 22 then 'Health ID'
                    when id_card_type = 13 then 'Postal ID'
                    when id_card_type = 7 then 'SSS'
                    when id_card_type = 18 then 'TIN ID'
             end as id_card_type_name_spp
            ,case   when id_card_type = 6 then 1
                    when id_card_type = 2 then 2
                    when id_card_type = 1 then 3
                    when id_card_type = 9 then 4
                    when id_card_type = 21 then 5
                    when id_card_type = 10 or id_card_type = 22 then 6
                    when id_card_type = 13 then 7
                    when id_card_type = 7 then 8
                    when id_card_type = 18 then 9
             end as new_id_card_type_spp
    from    (
        select  shopeepay_user_id as platform_user_id
                ,id_type as id_card_type
                ,regexp_replace(replace(replace(replace(replace(id_number_decrypt, " P", ""), "CRN", ""), "Crn", ""), "PRN", ""), "[^a-zA-Z0-9]", "") as id_card_no
                ,date(from_unixtime(create_time)) as create_date
                ,from_unixtime(update_time) as update_time
        from    shopeepay.mart_dwd_us_kyc_case_record_tab_df__ph
        where   length(id_number_decrypt) > 1
          and   kyc_status = 3
          and   id_type in (6, 2, 1, 9, 21, 10, 22, 13, 7, 18)
          and   date(from_unixtime(create_time)) <= date('${grass_date}')
    )
)
where   id_card_type_name_spp is not null
;

-- 将 credit 和 spp 两个数据源合并，并对同一身份证去重，保留最早记录
create or replace temporary view tmp_2bscore_ph_concat_id_type_no as
select *
from
(
    select  concat_id_type_no as id_type_no
            ,platform_user_id
            ,id_card_no as id_card_no
            ,id_card_type_name
            ,new_id_card_type as new_id_card_type
            ,original_id_card_type as original_id_card_type
            ,update_time as update_time
            ,create_date as create_date
            ,row_number() over(partition by concat_id_type_no order by create_date) as row_num
    from
    (
        select  coalesce(t1.concat_id_type_no, t2.concat_id_type_no) as concat_id_type_no
                ,coalesce(t1.platform_user_id, t2.platform_user_id) as platform_user_id
                ,coalesce(t1.new_id_card_type_credit, t2.new_id_card_type_spp) as new_id_card_type
                ,coalesce(t1.create_date_credit, t2.create_date_spp) as create_date
                ,coalesce(t1.original_id_card_type_credit, t2.original_id_card_type_spp) as original_id_card_type
                ,coalesce(t1.id_card_type_name_credit, t2.id_card_type_name_spp) as id_card_type_name
                ,coalesce(t1.id_card_no_credit, t2.id_card_no_spp) as id_card_no
                ,coalesce(t1.id_source_credit, t2.id_source_spp) as id_source
                ,coalesce(t1.update_time_credit, t2.update_time_spp) as update_time
        from tmp_credit_ph_concat_id_type_no t1
        full outer join tmp_spp_ph_concat_id_type_no t2
        on t1.concat_id_type_no = t2.concat_id_type_no
    )
)
where row_num = 1
;

-- load data
insert overwrite  ${SCHEMA}.dim_risk_ph_id_type_mapping_df partition(grass_date='${grass_date}')
select      platform_user_id          
            ,id_card_no                   
            ,id_type_no              
            ,new_id_card_type        
            ,original_id_card_type   
            ,id_card_type_name   
            ,update_time    
            ,create_date
from tmp_2bscore_ph_concat_id_type_no
;
