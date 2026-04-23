DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_br_user_cpf_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_br_user_cpf_df
(
    platform_user_id      string comment 'platform_user_id',
    credit_user_id        string comment 'credit_user_id',
    cpf                   string comment 'id_card_no'
)
comment 'Tag:risk summary table  risk user id card'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="snappy")
location '${HDFS_PATH}/risk_feature/ads/ads_risk_user_cpf_df/grass_region=BR';


-- create or replace temporary view first_bill as
-- select 
--     credit_user_id               as credit_user_id
--     ,platform_user_id            as  platform_user_id
--     ,min(bill_term)              as first_bill_term
--     ,max(month_due_time)         as latest_due_date
-- from credit_mart.dws_spl_br_bill_repayment_df
-- where grass_date = '${grass_date}'
-- and total_amount_repayable - total_amount_refund - total_amount_deduct > 0 
-- and bill_status in (1,2,3) --3: overdue 
-- group by credit_user_id, platform_user_id
-- ;

-- user base: ever applied users
create or replace temporary view user_base as
select 
 credit_user_id
 ,platform_user_id
from credit_uc.dws_spl_br_uc_user_df
where grass_date = '${grass_date}'
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
insert overwrite table risk.ads_risk_br_user_cpf_df partition(grass_date)
select
    a.platform_user_id  as platform_user_id 
    ,b.credit_user_id      as credit_user_id
    ,b.id_card_no         as cpf 
    ,'${grass_date}'      as grass_date 
from user_base a 
left join ( 
    select 
    credit_user_id
    ,id_card_no
    from pid_cpf_11
    union all 
    select 
    credit_user_id
    ,id_card_no
    from pid_cpf_no11
) b on a.credit_user_id = b.credit_user_id 
where b.credit_user_id is not null 
;

