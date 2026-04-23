-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-06
-- Theme Domain:        User Base Info SPP Feature
-- Data Granularity:    shopeepay_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-19 - chenyingying - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_spp_basic_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_spp_basic_info_df
(
    shopeepay_user_id   string comment 'shopeepay user id'
    ,cpf                string comment 'cpf'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_spp_basic_info_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_info_spp_basic_info_df;


create or replace temporary view user_base as
select  spp_user_id
        ,credit_user_id
from credit_uc.dws_spl_br_uc_user_df
where grass_date = '${ds}'
and has_ever_valid_apply = 1 
;


-------- platform_user_id with their CPF, coz some quod query dont have pid 
create or replace temporary view pid_cpf_11 as
    select 
        credit_user_id
        ,id_card_no
        ,create_time
        ,update_time
        ,grass_date
    from 
    (select 
        credit_user_id
        ,id_card_no
        ,create_time
        ,update_time
        ,grass_date
        ,row_number() over (partition by credit_user_id order by create_time desc, update_time desc,grass_date desc) rk
    from
    (
        select 
        credit_user_id
        ,id_card_no
        ,create_time
        ,update_time
        ,grass_date
        ,row_number() over (partition by id_card_no order by create_time desc, update_time desc,grass_date desc) rank_id
        from credit_uc.dwd_aio_br_uc_user_df
        where length(id_card_no) = 11
    )
    where rank_id = 1
    )
    where rk = 1
;


-------- platform_user_id with their CPF, coz some quod query dont have pid  length(id_card_no) != 11
create or replace temporary view pid_cpf_no11 as 
   SELECT 
       a.credit_user_id
       ,a.id_card_no
       ,a.create_time
       ,a.update_time
       ,a.grass_date
    FROM
    (
    SELECT 
        credit_user_id
        , id_card_no
        , create_time
        ,update_time
        ,grass_date
        ,row_number() over (partition by id_card_no order by create_time desc,update_time desc,grass_date desc) rank_id
    from credit_uc.dwd_aio_br_uc_user_df
    where length(id_card_no) != 11
    ) a left join pid_cpf_11 b on a.credit_user_id = b.credit_user_id 
    WHERE a.rank_id = 1
    and b.credit_user_id is null 
;

insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_spp_basic_info_df partition (grass_date = '${ds}')
select t1.shopeepay_user_id
        ,t2.cpf
from   (
    select  shopeepay_user_id
    from    shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where   grass_date = '${ds}'
) t1
left join (
    select a.spp_user_id as shopeepay_user_id
            ,b.id_card_no as cpf
    from user_base a 
    left join ( 
        select credit_user_id
                ,id_card_no
        from pid_cpf_11
        union all 
        select  credit_user_id
                ,id_card_no
        from pid_cpf_no11
    ) b
    on a.credit_user_id = b.credit_user_id
) t2
on t1.shopeepay_user_id = t2.shopeepay_user_id
;