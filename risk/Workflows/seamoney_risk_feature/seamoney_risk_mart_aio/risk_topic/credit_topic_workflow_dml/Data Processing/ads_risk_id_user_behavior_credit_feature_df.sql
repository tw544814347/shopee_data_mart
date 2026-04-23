
--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-09-02
-- Theme Domain：       risk-feature
-- Description:         risk feature 贷中的所有信息
-- Data Granularity:    credit_user_id
-- 变更历史：
-- 2024-09-05 将24个贷中利用率特征合并到贷中的完整宽表, average_utilization_xxd_xxx, max_utilization_xxd_xxx
-- 2024-09-10 将12个tenure时间窗口特征合并到贷中的完整宽表，average_tenure_xxd_xxx
--********************************************************************--
drop table if exists ${SCHEMA}.ads_risk_id_user_behavior_credit_feature_df
;
create external table if not exists ${SCHEMA}.ads_risk_id_user_behavior_credit_feature_df (
    credit_user_id                      string comment 'credit user id'
    --dws_risk_id_user_repayment_df
    ,is_user_repayment_scope            int 
    ,days_to_next_spl_repay             bigint
    ,next_spl_bill_principal_os         decimal(30, 10)
    ,days_to_next_bcl_repay             bigint
    ,next_bcl_bill_principal_os         decimal(30, 10)
    ,avg_weighted_remaining_tenure      decimal(30, 10) comment '用户名下SPL,BCL,HPL所有产品未结清loan的平均remaining tenure:'
    --dws_risk_id_user_dpd_df
    ,is_user_dpd_scope                  int 
    ,ever_max_dpd_spl_core              bigint comment ''
    ,ever_max_dpd_spl_lite_core         bigint comment ''
    ,ever_max_dpd_spl_normal_core       bigint comment ''
    ,days_after_first_due_date_spl      bigint comment ''
    ,ever_max_dpd_180d_spl              bigint comment ''
    ,ever_max_dpd_360d_spl              bigint comment ''
    ,days_after_first_due_date_cashloan bigint comment ''
    ,ever_max_dpd_180d_cashloan         bigint comment ''
    ,ever_max_dpd_360d_cashloan         bigint comment ''
    ,ever_max_dpd_180d_user             bigint comment ''
    ,ever_max_dpd_360d_user             bigint comment ''
    ,ever_max_dpd_cashloan_core         bigint comment 'historical_max_dpd'
    ,last_bill_dpd_cashloan_core        bigint comment 'last_bill_dpd'
    ,ever_max_dpd_sellerloan_core       bigint comment 'historical_max_dpd'
    ,last_bill_dpd_sellerloan_core      bigint comment 'last_bill_dpd'
    ,ever_max_dpd_30d_sellerloan        bigint comment ''
    ,ever_max_dpd_90d_sellerloan        bigint comment ''
    ,ever_max_dpd_180d_sellerloan       bigint comment ''
    ,ever_max_dpd_360d_sellerloan       bigint comment ''
    ,ever_max_dpd_30d_spl               bigint comment ''
    ,ever_max_dpd_90d_spl               bigint comment ''
    ,ever_max_dpd_30d_cashloan          bigint comment ''
    ,ever_max_dpd_90d_cashloan          bigint comment ''
    ,ever_max_dpd_chp                   bigint
    ,ever_max_dpd_chp_180d              bigint
    ,ever_max_dpd_chp_360d              bigint
    --wide_bcl_id_behavior_user_df
    ,is_bcl_behavior_user_scope         int 
    ,is_today_bcl_due_user              int
    --ads_behavior_underwrting_feature_df
    ,is_underwrting_feature_scope       int 
    ,spl_user_tag                       int comment 'spl status'
    ,first_billed_from_now_spl          int comment 'spl The number of months from bill term'
    ,first_billed_from_now_bcl          int comment 'bcl The number of months from bill term'
    ,first_billed_from_now              int comment 'max(bcl/bcl The number of months from bill term)'
    ,repaid_bills_num_user              int comment 'repaid bills'
    ,credit_user_status                 int comment 'user status'
    ,is_limit_decrease_spl              int comment 'limit decrease tag in spl'
    ,is_limit_decrease_bcl              int comment 'limit decrease tag in bcl'
    ,os_spl                             int comment 'spl quota'
    ,os_bcl                             int comment 'bcl quota'
    ,eir_tenure2_bcl                    decimal comment 'User tenure2 EIR In bcl'
    ,eir_tenure3_bcl                    decimal comment 'User tenure3 EIR In bcl'
    ,eir_tenure6_bcl                    decimal comment 'User tenure6 EIR In bcl'
    ,eir_tenure12_bcl                   decimal comment 'User tenure12 EIR In bcl'
    ,eir_tenure1_spl                    decimal comment 'User tenure1 EIR In spl'
    ,eir_tenure2_spl                    decimal comment 'User tenure2 EIR In spl'
    ,eir_tenure3_spl                    decimal comment 'User tenure3 EIR In spl'
    ,eir_tenure6_spl                    decimal comment 'User tenure6 EIR In spl'
    ,eir_tenure12_spl                   decimal comment 'User tenure12 EIR In spl'
    ,eir_tenure18_spl                   decimal comment 'User tenure18 EIR In spl'
    ,eir_tenure24_spl                   decimal comment 'User tenure24 EIR In spl'
    ,repaid_bills_num_cashloan          int comment 'repaid bill num IN CL'
    ,latest_dpd_cashloan                int comment 'latest dpd IN CL'
    -- avg spl
    ,average_limit_utilization_3d_spl   decimal(30, 5) comment 'spl 3days avg limit_utilization'
    ,average_limit_utilization_7d_spl   decimal(30, 5) comment 'spl 7days avg limit_utilization'
    ,average_limit_utilization_14d_spl  decimal(30, 5) comment 'spl 14days avg limit_utilization'
    ,average_limit_utilization_30d_spl  decimal(30, 5) comment 'spl 30days avg limit_utilization'
    ,average_limit_utilization_90d_spl  decimal(30, 5) comment 'spl 90days avg limit_utilization'
    ,average_limit_utilization_180d_spl decimal(30, 5) comment 'spl 180days avg limit_utilization'
    ,average_limit_utilization_360d_spl decimal(30, 5) comment 'spl 360days avg limit_utilization'
    ,average_limit_utilization_720d_spl decimal(30, 5) comment 'spl 720days avg limit_utilization'
    -- max spl
    ,max_limit_utilization_3d_spl       decimal(30, 5) comment 'spl 3days max limit_utilization'
    ,max_limit_utilization_7d_spl       decimal(30, 5) comment 'spl 7days max limit_utilization'
    ,max_limit_utilization_14d_spl      decimal(30, 5) comment 'spl 14days avg limit_utilization'
    ,max_limit_utilization_30d_spl      decimal(30, 5) comment 'spl 30days avg limit_utilization'
    ,max_limit_utilization_90d_spl      decimal(30, 5) comment 'spl 90days max limit_utilization'
    ,max_limit_utilization_180d_spl     decimal(30, 5) comment 'spl 180days max limit_utilization'
    ,max_limit_utilization_360d_spl     decimal(30, 5) comment 'spl 360days avg limit_utilization'
    ,max_limit_utilization_720d_spl     decimal(30, 5) comment 'spl 720days avg limit_utilization'
    -- avg bcl
    ,average_limit_utilization_3d_bcl   decimal(30, 5) comment 'bcl 3days avg limit_utilization'
    ,average_limit_utilization_7d_bcl   decimal(30, 5) comment 'bcl 7days avg limit_utilization'
    ,average_limit_utilization_14d_bcl  decimal(30, 5) comment 'bcl 14days avg limit_utilization'
    ,average_limit_utilization_30d_bcl  decimal(30, 5) comment 'bcl 30days avg limit_utilization'
    ,average_limit_utilization_90d_bcl  decimal(30, 5) comment 'bcl 90days avg limit_utilization'
    ,average_limit_utilization_180d_bcl decimal(30, 5) comment 'bcl 180days avg limit_utilization'
    ,average_limit_utilization_360d_bcl decimal(30, 5) comment 'bcl 360days avg limit_utilization'
    ,average_limit_utilization_720d_bcl decimal(30, 5) comment 'bcl 720days avg limit_utilization'
    -- max bcl
    ,max_limit_utilization_3d_bcl       decimal(30, 5) comment 'bcl 3days max limit_utilization'
    ,max_limit_utilization_7d_bcl       decimal(30, 5) comment 'bcl 7days max limit_utilization'
    ,max_limit_utilization_14d_bcl      decimal(30, 5) comment 'bcl 14days avg limit_utilization'
    ,max_limit_utilization_30d_bcl      decimal(30, 5) comment 'bcl 30days avg limit_utilization'
    ,max_limit_utilization_90d_bcl      decimal(30, 5) comment 'bcl 90days max limit_utilization'
    ,max_limit_utilization_180d_bcl     decimal(30, 5) comment 'bcl 180days max limit_utilization'
    ,max_limit_utilization_360d_bcl     decimal(30, 5) comment 'bcl 360days max limit_utilization'
    ,max_limit_utilization_720d_bcl     decimal(30, 5) comment 'bcl 720days max limit_utilization'
    --dws_risk_id_user_withdraw_feature
    ,is_user_withdraw_scope             int 
    ,`postloan_reject_cnt_bcl`          bigint
    ,`postloan_reject_cnt_spl`          bigint
    ,`preloan_reject_cnt_bcl`           bigint
    ,`preloan_reject_cnt_spl`           bigint
    ,`postloan_reject_cnt_90d_bcl`      bigint
    ,`postloan_reject_cnt_90d_spl`      bigint
    ,`preloan_reject_cnt_90d_bcl`       bigint
    ,`preloan_reject_cnt_90d_spl`       bigint
    ,`postloan_reject_cnt_180d_bcl`     bigint
    ,`postloan_reject_cnt_180d_spl`     bigint
    ,`preloan_reject_cnt_180d_bcl`      bigint
    ,`preloan_reject_cnt_180d_spl`      bigint
    ,`rejected_num_90d_bcl`             bigint
    --wide_bcl_id_behavior_user_df
    ,is_spl_behavior_user_scope         int
    ,is_today_spl_due_user              int
    --average tenure
    ,average_tenure_30d_spl             decimal(30,3) comment 'average spl term in 30d'
    ,average_tenure_60d_spl             decimal(30,3) comment 'average spl term in 60d'
    ,average_tenure_90d_spl             decimal(30,3) comment 'average spl term in 90d'
    ,average_tenure_180d_spl            decimal(30,3) comment 'average spl term in 180d'
    ,average_tenure_360d_spl            decimal(30,3) comment 'average spl term in 360d'
    ,average_tenure_720d_spl            decimal(30,3) comment 'average spl term in 720d'
    ,average_tenure_30d_bcl             decimal(30,3) comment 'average bcl term in 30d'
    ,average_tenure_60d_bcl             decimal(30,3) comment 'average bcl term in 60d'
    ,average_tenure_90d_bcl             decimal(30,3) comment 'average bcl term in 90d'
    ,average_tenure_180d_bcl            decimal(30,3) comment 'average bcl term in 180d'
    ,average_tenure_360d_bcl            decimal(30,3) comment 'average bcl term in 360d'
    ,average_tenure_720d_bcl            decimal(30,3) comment 'average bcl term in 720d'
)
partitioned by (grass_date string comment 'YYYY-MM-dd') 
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/ads/ads_risk_id_user_behavior_credit_feature_df'
;

msck repair table ${SCHEMA}.ads_risk_id_user_behavior_credit_feature_df
;
-- user
create or replace temporary view tmp_id_user_profile as
select  distinct credit_user_id
from    ( 
    select  credit_user_id
    from    credit_uc.dws_spl_id_uc_user_df 
    where   grass_date='${ds}' 
    and     credit_user_id is not null
    union all
    select  credit_user_id
    from    credit_uc.dws_bcl_id_uc_user_df 
    where   grass_date='${ds}'
    and     credit_user_id is not null
)
;
-- 过滤720d
-- spl
create or replace temporary view tmp_id_behavior_user_spl_window as
select  credit_user_id
        ,(
            COALESCE(common_perm_used_credit_amount, 0) +
            COALESCE(common_temp_used_credit_amount, 0) +
            COALESCE(installment_perm_used_credit_amount, 0) +
            COALESCE(lite_used_credit_amount, 0) +
            COALESCE(common_perm_frozen_credit_amount, 0) +
            COALESCE(common_temp_frozen_credit_amount, 0) +
            COALESCE(installment_perm_frozen_credit_amount, 0) +
            COALESCE(lite_frozen_credit_amount, 0)
        ) / (
            COALESCE(common_perm_credit_limit, 0) +
            COALESCE(common_temp_credit_limit, 0) +
            COALESCE(installment_perm_credit_limit, 0) +
            COALESCE(lite_credit_limit, 0)
        )
        as total_user_credit_utilisation
        ,grass_date
from credit_mart.dws_spl_id_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) + coalesce(installment_perm_credit_limit,0) + coalesce(lite_credit_limit,0) > 0 
        and grass_date >= date_sub('${ds}', 720)
        and biz_type = 3
;
-- bcl
create or replace temporary view tmp_id_behavior_user_bcl_window as
select  credit_user_id
        ,(
                COALESCE(common_perm_used_credit_amount, 0) +
                COALESCE(common_temp_used_credit_amount, 0) +
                COALESCE(common_perm_frozen_credit_amount, 0) +
                COALESCE(common_temp_frozen_credit_amount, 0)
        ) / (
                COALESCE(common_perm_credit_limit, 0) +
                COALESCE(common_temp_credit_limit, 0)
        )
        as total_user_credit_utilisation
        ,grass_date
from credit_mart.dws_bcl_id_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) > 0
        and grass_date >= date_sub('${ds}', 720)
        and biz_type = 1
;
-- 3d
create or replace temporary view tmp_id_behavior_user_3d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_3d_spl),0)          as average_limit_utilization_3d_spl
        ,nvl(max(max_limit_utilization_3d_spl),0)              as max_limit_utilization_3d_spl  
        ,nvl(sum(average_limit_utilization_3d_bcl),0)          as average_limit_utilization_3d_bcl
        ,nvl(max(max_limit_utilization_3d_spl),0)              as max_limit_utilization_3d_bcl
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_3d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_3d_spl
                ,0                                                                      as average_limit_utilization_3d_bcl
                ,0                                                                      as max_limit_utilization_3d_bcl
        from    tmp_id_behavior_user_spl_window
        where   grass_date >= date_sub('${ds}', 3)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_3d_spl
                ,0                                                                      as max_limit_utilization_3d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_3d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_3d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 3)
        group by credit_user_id
)
group by  credit_user_id
;
--7d
create or replace temporary view tmp_id_behavior_user_7d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_7d_spl),0)          as average_limit_utilization_7d_spl
        ,nvl(max(max_limit_utilization_7d_spl),0)              as max_limit_utilization_7d_spl  
        ,nvl(sum(average_limit_utilization_7d_bcl),0)          as average_limit_utilization_7d_bcl
        ,nvl(max(max_limit_utilization_7d_spl),0)              as max_limit_utilization_7d_bcl
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_7d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_7d_spl
                ,0                                                                      as average_limit_utilization_7d_bcl
                ,0                                                                      as max_limit_utilization_7d_bcl
        from    tmp_id_behavior_user_spl_window
        where   grass_date >= date_sub('${ds}', 7)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_7d_spl
                ,0                                                                      as max_limit_utilization_7d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_7d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_7d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 7)
        group by credit_user_id
        )
group by  credit_user_id
;
-- 14d
create or replace temporary view tmp_id_behavior_user_14d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_14d_spl),0)          as average_limit_utilization_14d_spl
        ,nvl(max(max_limit_utilization_14d_spl),0)              as max_limit_utilization_14d_spl  
        ,nvl(sum(average_limit_utilization_14d_bcl),0)          as average_limit_utilization_14d_bcl
        ,nvl(max(max_limit_utilization_14d_spl),0)              as max_limit_utilization_14d_bcl
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_14d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_14d_spl
                ,0                                                                      as average_limit_utilization_14d_bcl
                ,0                                                                      as max_limit_utilization_14d_bcl
        from    tmp_id_behavior_user_spl_window
        where   grass_date >= date_sub('${ds}', 14)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_14d_spl
                ,0                                                                      as max_limit_utilization_14d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_14d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_14d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 14)
        group by credit_user_id
        )
group by  credit_user_id
;
--30d
create or replace temporary view tmp_id_behavior_user_30d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_30d_spl),0)          as average_limit_utilization_30d_spl
        ,nvl(max(max_limit_utilization_30d_spl),0)              as max_limit_utilization_30d_spl  
        ,nvl(sum(average_limit_utilization_30d_bcl),0)          as average_limit_utilization_30d_bcl
        ,nvl(max(max_limit_utilization_30d_spl),0)              as max_limit_utilization_30d_bcl
from    (
        select  credit_user_id
                ,avg(total_user_credit_utilisation)     as average_limit_utilization_30d_spl
                ,max(total_user_credit_utilisation)     as max_limit_utilization_30d_spl
                ,0                                      as average_limit_utilization_30d_bcl
                ,0                                      as max_limit_utilization_30d_bcl
        from    tmp_id_behavior_user_spl_window
        where   grass_date >= date_sub('${ds}', 30)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_30d_spl
                ,0                                                                      as max_limit_utilization_30d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_30d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_30d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 30)
        group by credit_user_id
        )
group by  credit_user_id
;
-- 90d
create or replace temporary view tmp_id_behavior_user_90d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_90d_spl),0)          as average_limit_utilization_90d_spl
        ,nvl(max(max_limit_utilization_90d_spl),0)              as max_limit_utilization_90d_spl  
        ,nvl(sum(average_limit_utilization_90d_bcl),0)          as average_limit_utilization_90d_bcl
        ,nvl(max(max_limit_utilization_90d_spl),0)              as max_limit_utilization_90d_bcl
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_90d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_90d_spl
                ,0                                                                      as average_limit_utilization_90d_bcl
                ,0                                                                      as max_limit_utilization_90d_bcl
        from    tmp_id_behavior_user_spl_window
        where   grass_date >= date_sub('${ds}', 90)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_90d_spl
                ,0                                                                      as max_limit_utilization_90d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_90d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_90d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 90)
        group by credit_user_id
        )
group by  credit_user_id
;
--180d
create or replace temporary view tmp_id_behavior_user_180d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_180d_spl),0)          as average_limit_utilization_180d_spl
        ,nvl(max(max_limit_utilization_180d_spl),0)              as max_limit_utilization_180d_spl  
        ,nvl(sum(average_limit_utilization_180d_bcl),0)          as average_limit_utilization_180d_bcl
        ,nvl(max(max_limit_utilization_180d_spl),0)              as max_limit_utilization_180d_bcl
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_180d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_180d_spl
                ,0                                                                      as average_limit_utilization_180d_bcl
                ,0                                                                      as max_limit_utilization_180d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 180)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_180d_spl
                ,0                                                                      as max_limit_utilization_180d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_180d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_180d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 180)
        group by credit_user_id

        )
group by  credit_user_id
;
--360d
create or replace temporary view tmp_id_behavior_user_360d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_360d_spl),0)          as average_limit_utilization_360d_spl
        ,nvl(max(max_limit_utilization_360d_spl),0)              as max_limit_utilization_360d_spl   
        ,nvl(sum(average_limit_utilization_360d_bcl),0)          as average_limit_utilization_360d_bcl
        ,nvl(max(max_limit_utilization_360d_spl),0)              as max_limit_utilization_360d_bcl 
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_360d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_360d_spl
                ,0                                                                      as average_limit_utilization_360d_bcl
                ,0                                                                      as max_limit_utilization_360d_bcl
        from    tmp_id_behavior_user_spl_window
        where   grass_date >= date_sub('${ds}', 360)
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_360d_spl
                ,0                                                                      as max_limit_utilization_360d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_360d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_360d_bcl
        from    tmp_id_behavior_user_bcl_window
        where   grass_date >= date_sub('${ds}', 360)
        group by credit_user_id
        )
group by  credit_user_id
;
--720d
create or replace temporary view tmp_id_behavior_user_720d as
select  credit_user_id
        ,nvl(sum(average_limit_utilization_720d_spl),0)          as average_limit_utilization_720d_spl
        ,nvl(max(max_limit_utilization_720d_spl),0)              as max_limit_utilization_720d_spl   
        ,nvl(sum(average_limit_utilization_720d_bcl),0)          as average_limit_utilization_720d_bcl
        ,nvl(max(max_limit_utilization_720d_spl),0)              as max_limit_utilization_720d_bcl 
from    (
        select  credit_user_id
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_720d_spl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_720d_spl
                ,0                                                                      as average_limit_utilization_720d_bcl
                ,0                                                                      as max_limit_utilization_720d_bcl
        from    tmp_id_behavior_user_spl_window
        group by credit_user_id
        union all
        select  credit_user_id
                ,0                                                                      as average_limit_utilization_720d_spl
                ,0                                                                      as max_limit_utilization_720d_spl
                ,sum(total_user_credit_utilisation) / count(distinct grass_date)        as average_limit_utilization_720d_bcl
                ,max(total_user_credit_utilisation)                                     as max_limit_utilization_720d_bcl
        from    tmp_id_behavior_user_bcl_window
        group by credit_user_id
        )
group by  credit_user_id
;

create or replace temporary view tmp_id_user_utilization_limit as
select
    a.credit_user_id
    -- avg spl utilization
    ,t1.average_limit_utilization_3d_spl    as average_limit_utilization_3d_spl
    ,t2.average_limit_utilization_7d_spl    as average_limit_utilization_7d_spl
    ,t3.average_limit_utilization_14d_spl   as average_limit_utilization_14d_spl
    ,t4.average_limit_utilization_30d_spl   as average_limit_utilization_30d_spl
    ,t5.average_limit_utilization_90d_spl   as average_limit_utilization_90d_spl
    ,t6.average_limit_utilization_180d_spl  as average_limit_utilization_180d_spl
    ,t7.average_limit_utilization_360d_spl  as average_limit_utilization_360d_spl
    ,t8.average_limit_utilization_720d_spl  as average_limit_utilization_720d_spl
    -- max spl utilization
    ,t1.max_limit_utilization_3d_spl        as max_limit_utilization_3d_spl
    ,t2.max_limit_utilization_7d_spl        as max_limit_utilization_7d_spl
    ,t3.max_limit_utilization_14d_spl       as max_limit_utilization_14d_spl
    ,t4.max_limit_utilization_30d_spl       as max_limit_utilization_30d_spl
    ,t5.max_limit_utilization_90d_spl       as max_limit_utilization_90d_spl
    ,t6.max_limit_utilization_180d_spl      as max_limit_utilization_180d_spl
    ,t7.max_limit_utilization_360d_spl      as max_limit_utilization_360d_spl
    ,t8.max_limit_utilization_720d_spl      as max_limit_utilization_720d_spl
    -- avg bcl utilization
    ,t1.average_limit_utilization_3d_bcl    as average_limit_utilization_3d_bcl                               
    ,t2.average_limit_utilization_7d_bcl    as average_limit_utilization_7d_bcl
    ,t3.average_limit_utilization_14d_bcl   as average_limit_utilization_14d_bcl
    ,t4.average_limit_utilization_30d_bcl   as average_limit_utilization_30d_bcl
    ,t5.average_limit_utilization_90d_bcl   as average_limit_utilization_90d_bcl
    ,t6.average_limit_utilization_180d_bcl  as average_limit_utilization_180d_bcl
    ,t7.average_limit_utilization_360d_bcl  as average_limit_utilization_360d_bcl
    ,t8.average_limit_utilization_720d_bcl  as average_limit_utilization_720d_bcl
    -- max bcl utilization
    ,t1.max_limit_utilization_3d_bcl        as max_limit_utilization_3d_bcl
    ,t2.max_limit_utilization_7d_bcl        as max_limit_utilization_7d_bcl
    ,t3.max_limit_utilization_14d_bcl       as max_limit_utilization_14d_bcl
    ,t4.max_limit_utilization_30d_bcl       as max_limit_utilization_30d_bcl
    ,t5.max_limit_utilization_90d_bcl       as max_limit_utilization_90d_bcl
    ,t6.max_limit_utilization_180d_bcl      as max_limit_utilization_180d_bcl
    ,t7.max_limit_utilization_360d_bcl      as max_limit_utilization_360d_bcl
    ,t8.max_limit_utilization_720d_bcl      as max_limit_utilization_720d_bcl
from    tmp_id_user_profile as a
left join tmp_id_behavior_user_3d t1    on a.credit_user_id = t1.credit_user_id
left join tmp_id_behavior_user_7d t2    on a.credit_user_id = t2.credit_user_id
left join tmp_id_behavior_user_14d t3   on a.credit_user_id = t3.credit_user_id
left join tmp_id_behavior_user_30d t4   on a.credit_user_id = t4.credit_user_id
left join tmp_id_behavior_user_90d  t5  on a.credit_user_id = t5.credit_user_id
left join tmp_id_behavior_user_180d t6  on a.credit_user_id = t6.credit_user_id
left join tmp_id_behavior_user_360d t7  on a.credit_user_id = t7.credit_user_id
left join tmp_id_behavior_user_720d t8  on a.credit_user_id = t8.credit_user_id
;
-- t10
create or replace temporary view tmp_id_loan_repayment as
select  credit_user_id
        ,nvl(sum(average_tenure_30d_spl),0)     as average_tenure_30d_spl
        ,nvl(sum(average_tenure_60d_spl),0)     as average_tenure_60d_spl
        ,nvl(sum(average_tenure_90d_spl),0)     as average_tenure_90d_spl
        ,nvl(sum(average_tenure_180d_spl),0)    as average_tenure_180d_spl
        ,nvl(sum(average_tenure_360d_spl),0)    as average_tenure_360d_spl
        ,nvl(sum(average_tenure_720d_spl),0)    as average_tenure_720d_spl
        ,nvl(sum(average_tenure_30d_bcl),0)     as average_tenure_30d_bcl
        ,nvl(sum(average_tenure_60d_bcl),0)     as average_tenure_60d_bcl
        ,nvl(sum(average_tenure_90d_bcl),0)     as average_tenure_90d_bcl
        ,nvl(sum(average_tenure_180d_bcl),0)     as average_tenure_180d_bcl
        ,nvl(sum(average_tenure_360d_bcl),0)     as average_tenure_360d_bcl
        ,nvl(sum(average_tenure_720d_bcl),0)     as average_tenure_720d_bcl
from    (
        select  credit_user_id
                ,avg(case when disburse_time >= date_sub('${ds}', 30) then loan_tenure end)     as average_tenure_30d_spl
                ,avg(case when disburse_time >= date_sub('${ds}', 60) then loan_tenure end)     as average_tenure_60d_spl
                ,avg(case when disburse_time >= date_sub('${ds}', 90) then loan_tenure end)     as average_tenure_90d_spl
                ,avg(case when disburse_time >= date_sub('${ds}', 180) then loan_tenure end)    as average_tenure_180d_spl
                ,avg(case when disburse_time >= date_sub('${ds}', 360) then loan_tenure end)    as average_tenure_360d_spl
                ,avg(case when disburse_time >= date_sub('${ds}', 720) then loan_tenure end)    as average_tenure_720d_spl
                ,0                                                                              as average_tenure_30d_bcl
                ,0                                                                              as average_tenure_60d_bcl
                ,0                                                                              as average_tenure_90d_bcl   
                ,0                                                                              as average_tenure_180d_bcl
                ,0                                                                              as average_tenure_360d_bcl
                ,0                                                                              as average_tenure_720d_bcl 
        from    credit_mart.dws_spl_id_loan_repayment_df
        where   grass_date = '${ds}'
        and     principal_repayable > 0  
        group by credit_user_id       
        union all          
        select  credit_user_id
                ,0                                                                              as average_tenure_30d_spl
                ,0                                                                              as average_tenure_60d_spl
                ,0                                                                              as average_tenure_90d_spl   
                ,0                                                                              as average_tenure_180d_spl
                ,0                                                                              as average_tenure_360d_spl
                ,0                                                                              as average_tenure_720d_spl 
                ,avg(case when disburse_time >= date_sub('${ds}', 30) then loan_tenure end)     as average_tenure_30d_bcl
                ,avg(case when disburse_time >= date_sub('${ds}', 60) then loan_tenure end)     as average_tenure_60d_bcl
                ,avg(case when disburse_time >= date_sub('${ds}', 90) then loan_tenure end)     as average_tenure_90d_bcl
                ,avg(case when disburse_time >= date_sub('${ds}', 180) then loan_tenure end)    as average_tenure_180d_bcl
                ,avg(case when disburse_time >= date_sub('${ds}', 360) then loan_tenure end)    as average_tenure_360d_bcl
                ,avg(case when disburse_time >= date_sub('${ds}', 720) then loan_tenure end)    as average_tenure_720d_bcl
        from    credit_mart.dws_bcl_id_loan_repayment_df
        where   grass_date = '${ds}'
        and     principal_repayable > 0  
        group by credit_user_id          
) a
group by credit_user_id
;





insert overwrite ${SCHEMA}.ads_risk_id_user_behavior_credit_feature_df partition (grass_date = '${ds}')
select  credit_user_id
        --dws_risk_id_user_repayment_df
        ,nvl(max(is_user_repayment_scope),null)
        ,nvl(max(days_to_next_spl_repay),null)
        ,nvl(max(next_spl_bill_principal_os),null)
        ,nvl(max(days_to_next_bcl_repay),null)
        ,nvl(max(next_bcl_bill_principal_os),null)
        ,nvl(max(avg_weighted_remaining_tenure),null)
        --dws_risk_id_user_dpd_df
        ,nvl(max(is_user_dpd_scope),null) 
        ,nvl(max(ever_max_dpd_spl_core),null)
        ,nvl(max(ever_max_dpd_spl_lite_core),null)
        ,nvl(max(ever_max_dpd_spl_normal_core),null)
        ,nvl(max(days_after_first_due_date_spl),null)
        ,nvl(max(ever_max_dpd_180d_spl),null)
        ,nvl(max(ever_max_dpd_360d_spl),null)
        ,nvl(max(days_after_first_due_date_cashloan),null)
        ,nvl(max(ever_max_dpd_180d_cashloan),null)
        ,nvl(max(ever_max_dpd_360d_cashloan),null)
        ,nvl(max(ever_max_dpd_180d_user),null)
        ,nvl(max(ever_max_dpd_360d_user),null)
        ,nvl(max(ever_max_dpd_cashloan_core),null)
        ,nvl(max(last_bill_dpd_cashloan_core),null)
        ,nvl(max(ever_max_dpd_sellerloan_core),null)
        ,nvl(max(last_bill_dpd_sellerloan_core),null)
        ,nvl(max(ever_max_dpd_30d_sellerloan),null)
        ,nvl(max(ever_max_dpd_90d_sellerloan),null)
        ,nvl(max(ever_max_dpd_180d_sellerloan),null)
        ,nvl(max(ever_max_dpd_360d_sellerloan),null)
        ,nvl(max(ever_max_dpd_30d_spl),null)
        ,nvl(max(ever_max_dpd_90d_spl),null)
        ,nvl(max(ever_max_dpd_30d_cashloan),null)
        ,nvl(max(ever_max_dpd_90d_cashloan),null)
        ,nvl(max(ever_max_dpd_chp),null)
        ,nvl(max(ever_max_dpd_chp_180d),null)
        ,nvl(max(ever_max_dpd_chp_360d),null)
        --wide_bcl_id_behavior_user_df
        ,nvl(max(is_bcl_behavior_user_scope),null)
        ,nvl(max(is_today_bcl_due_user),null)
        --ads_behavior_underwrting_feature_df
        ,nvl(max(is_underwrting_feature_scope),null)
        ,nvl(max(spl_user_tag),null)
        ,nvl(max(first_billed_from_now_spl),null)
        ,nvl(max(first_billed_from_now_bcl),null)
        ,nvl(max(first_billed_from_now),null)
        ,nvl(max(repaid_bills_num_user),null)
        ,nvl(max(credit_user_status),null)
        ,nvl(max(is_limit_decrease_spl),null)
        ,nvl(max(is_limit_decrease_bcl),null)
        ,nvl(max(os_spl),null)
        ,nvl(max(os_bcl),null)
        ,nvl(max(eir_tenure2_bcl),null)
        ,nvl(max(eir_tenure3_bcl),null)
        ,nvl(max(eir_tenure6_bcl),null)
        ,nvl(max(eir_tenure12_bcl),null)
        ,nvl(max(eir_tenure1_spl),null)
        ,nvl(max(eir_tenure2_spl),null)
        ,nvl(max(eir_tenure3_spl),null)
        ,nvl(max(eir_tenure6_spl),null)
        ,nvl(max(eir_tenure12_spl),null)
        ,nvl(max(eir_tenure18_spl),null)
        ,nvl(max(eir_tenure24_spl),null)
        ,nvl(max(repaid_bills_num_cashloan),null)
        ,nvl(max(latest_dpd_cashloan),null)
        --tmp_id_user_utilization_limit
        ,nvl(max(average_limit_utilization_3d_spl),null)
        ,nvl(max(average_limit_utilization_7d_spl),null)
        ,nvl(max(average_limit_utilization_14d_spl),null)
        ,nvl(max(average_limit_utilization_30d_spl),null)
        ,nvl(max(average_limit_utilization_90d_spl),null)
        ,nvl(max(average_limit_utilization_180d_spl),null)
        ,nvl(max(average_limit_utilization_360d_spl),null)
        ,nvl(max(average_limit_utilization_720d_spl),null)
        -- max spl utilization
        ,nvl(max(max_limit_utilization_3d_spl),null)
        ,nvl(max(max_limit_utilization_7d_spl),null)
        ,nvl(max(max_limit_utilization_14d_spl),null)
        ,nvl(max(max_limit_utilization_30d_spl),null)
        ,nvl(max(max_limit_utilization_90d_spl),null)
        ,nvl(max(max_limit_utilization_180d_spl),null)
        ,nvl(max(max_limit_utilization_360d_spl),null)
        ,nvl(max(max_limit_utilization_720d_spl),null)
        -- bcl
        ,nvl(max(average_limit_utilization_3d_bcl),null)
        ,nvl(max(average_limit_utilization_7d_bcl),null)
        ,nvl(max(average_limit_utilization_14d_bcl),null)
        ,nvl(max(average_limit_utilization_30d_bcl),null)
        ,nvl(max(average_limit_utilization_90d_bcl),null)
        ,nvl(max(average_limit_utilization_180d_bcl),null)
        ,nvl(max(average_limit_utilization_360d_bcl),null)
        ,nvl(max(average_limit_utilization_720d_bcl),null)
        -- max bcl utilization
        ,nvl(max(max_limit_utilization_3d_bcl),null)
        ,nvl(max(max_limit_utilization_7d_bcl),null)
        ,nvl(max(max_limit_utilization_14d_bcl),null)
        ,nvl(max(max_limit_utilization_30d_bcl),null)
        ,nvl(max(max_limit_utilization_90d_bcl),null)
        ,nvl(max(max_limit_utilization_180d_bcl),null)
        ,nvl(max(max_limit_utilization_360d_bcl),null)
        ,nvl(max(max_limit_utilization_720d_bcl),null)
        --dws_risk_id_user_withdraw_info_df
        ,nvl(max(is_user_withdraw_scope),null)
        ,nvl(max(postloan_reject_cnt_bcl),null)
        ,nvl(max(postloan_reject_cnt_spl),null)
        ,nvl(max(preloan_reject_cnt_bcl),null)
        ,nvl(max(preloan_reject_cnt_spl),null)
        ,nvl(max(postloan_reject_cnt_90d_bcl),null)
        ,nvl(max(postloan_reject_cnt_90d_spl),null)
        ,nvl(max(preloan_reject_cnt_90d_bcl),null)
        ,nvl(max(preloan_reject_cnt_90d_spl),null)
        ,nvl(max(postloan_reject_cnt_180d_bcl),null)
        ,nvl(max(postloan_reject_cnt_180d_spl),null)
        ,nvl(max(preloan_reject_cnt_180d_bcl),null)
        ,nvl(max(preloan_reject_cnt_180d_spl),null)
        ,nvl(max(rejected_num_90d_bcl),null)
        --wide_bcl_id_behavior_user_df
        ,nvl(max(is_spl_behavior_user_scope),null)
        ,nvl(max(is_today_spl_due_user),null)
        --tmp_id_loan_repayment
        ,nvl(max(average_tenure_30d_spl),null)
        ,nvl(max(average_tenure_60d_spl),null)
        ,nvl(max(average_tenure_90d_spl),null)
        ,nvl(max(average_tenure_180d_spl),null)
        ,nvl(max(average_tenure_360d_spl),null)
        ,nvl(max(average_tenure_720d_spl),null)
        ,nvl(max(average_tenure_30d_bcl),null)
        ,nvl(max(average_tenure_60d_bcl),null)
        ,nvl(max(average_tenure_90d_bcl),null)
        ,nvl(max(average_tenure_180d_bcl),null)
        ,nvl(max(average_tenure_360d_bcl),null)
        ,nvl(max(average_tenure_720d_bcl),null)
from    (
        select  t1.credit_user_id
        --dws_risk_id_user_repayment_df
        ,if(t2.credit_user_id is not null,1,0) is_user_repayment_scope
        ,days_to_next_spl_repay
        ,next_spl_bill_principal_os
        ,days_to_next_bcl_repay
        ,next_bcl_bill_principal_os
        ,avg_weighted_remaining_tenure
        --dws_risk_id_user_dpd_df
        ,if(t3.user_id is not null,1,0) is_user_dpd_scope
        ,ever_max_dpd_spl_core
        ,ever_max_dpd_spl_lite_core
        ,ever_max_dpd_spl_normal_core
        ,days_after_first_due_date_spl
        ,ever_max_dpd_180d_spl
        ,ever_max_dpd_360d_spl
        ,days_after_first_due_date_cashloan
        ,ever_max_dpd_180d_cashloan
        ,ever_max_dpd_360d_cashloan
        ,ever_max_dpd_180d_user
        ,ever_max_dpd_360d_user
        ,ever_max_dpd_cashloan_core
        ,last_bill_dpd_cashloan_core
        ,ever_max_dpd_sellerloan_core
        ,last_bill_dpd_sellerloan_core
        ,ever_max_dpd_30d_sellerloan
        ,ever_max_dpd_90d_sellerloan
        ,ever_max_dpd_180d_sellerloan
        ,ever_max_dpd_360d_sellerloan
        ,ever_max_dpd_30d_spl
        ,ever_max_dpd_90d_spl
        ,ever_max_dpd_30d_cashloan
        ,ever_max_dpd_90d_cashloan
        ,ever_max_dpd_chp
        ,ever_max_dpd_chp_180d
        ,ever_max_dpd_chp_360d
        --wide_bcl_id_behavior_user_df
        ,if(t4.credit_user_id is not null,1,0) is_bcl_behavior_user_scope
        ,is_today_bcl_due_user
        --ads_behavior_underwrting_feature_df
        ,if(t6.credit_user_id is not null,1,0) is_underwrting_feature_scope
        ,spl_user_tag
        ,first_billed_from_now_spl
        ,first_billed_from_now_bcl
        ,first_billed_from_now
        ,repaid_bills_num_user
        ,credit_user_status
        ,is_limit_decrease_spl
        ,is_limit_decrease_bcl
        ,os_spl
        ,os_bcl
        ,eir_tenure2_bcl
        ,eir_tenure3_bcl
        ,eir_tenure6_bcl
        ,eir_tenure12_bcl
        ,eir_tenure1_spl
        ,eir_tenure2_spl
        ,eir_tenure3_spl
        ,eir_tenure6_spl
        ,eir_tenure12_spl
        ,eir_tenure18_spl
        ,eir_tenure24_spl
        ,repaid_bills_num_cashloan
        ,latest_dpd_cashloan
        --tmp_id_user_utilization_limit
        ,average_limit_utilization_3d_spl
        ,average_limit_utilization_7d_spl
        ,average_limit_utilization_14d_spl
        ,average_limit_utilization_30d_spl
        ,average_limit_utilization_90d_spl
        ,average_limit_utilization_180d_spl
        ,average_limit_utilization_360d_spl
        ,average_limit_utilization_720d_spl
        -- max spl utilization
        ,max_limit_utilization_3d_spl
        ,max_limit_utilization_7d_spl
        ,max_limit_utilization_14d_spl
        ,max_limit_utilization_30d_spl
        ,max_limit_utilization_90d_spl
        ,max_limit_utilization_180d_spl
        ,max_limit_utilization_360d_spl
        ,max_limit_utilization_720d_spl
        -- bcl
        ,average_limit_utilization_3d_bcl
        ,average_limit_utilization_7d_bcl
        ,average_limit_utilization_14d_bcl
        ,average_limit_utilization_30d_bcl
        ,average_limit_utilization_90d_bcl
        ,average_limit_utilization_180d_bcl
        ,average_limit_utilization_360d_bcl
        ,average_limit_utilization_720d_bcl
        -- max bcl utilization
        ,max_limit_utilization_3d_bcl
        ,max_limit_utilization_7d_bcl
        ,max_limit_utilization_14d_bcl
        ,max_limit_utilization_30d_bcl
        ,max_limit_utilization_90d_bcl
        ,max_limit_utilization_180d_bcl
        ,max_limit_utilization_360d_bcl
        ,max_limit_utilization_720d_bcl
        --dws_risk_id_user_withdraw_info_df
        ,if(t7.credit_user_id is not null,1,0) is_user_withdraw_scope
        ,postloan_reject_cnt_bcl
        ,postloan_reject_cnt_spl
        ,preloan_reject_cnt_bcl
        ,preloan_reject_cnt_spl
        ,postloan_reject_cnt_90d_bcl
        ,postloan_reject_cnt_90d_spl
        ,preloan_reject_cnt_90d_bcl
        ,preloan_reject_cnt_90d_spl
        ,postloan_reject_cnt_180d_bcl
        ,postloan_reject_cnt_180d_spl
        ,preloan_reject_cnt_180d_bcl
        ,preloan_reject_cnt_180d_spl
        ,rejected_num_90d_bcl
        --wide_bcl_id_behavior_user_df
        ,if(t8.credit_user_id is not null,1,0) is_spl_behavior_user_scope
        ,is_today_spl_due_user
        --tmp_id_loan_repayment
        ,average_tenure_30d_spl
        ,average_tenure_60d_spl
        ,average_tenure_90d_spl
        ,average_tenure_180d_spl
        ,average_tenure_360d_spl
        ,average_tenure_720d_spl
        ,average_tenure_30d_bcl
        ,average_tenure_60d_bcl
        ,average_tenure_90d_bcl
        ,average_tenure_180d_bcl
        ,average_tenure_360d_bcl
        ,average_tenure_720d_bcl
from    tmp_id_user_profile t1
left join   (
    select  credit_user_id
            ,days_to_next_spl_repay
            ,next_spl_bill_principal_os
            ,days_to_next_bcl_repay
            ,next_bcl_bill_principal_os
            ,avg_weighted_remaining_tenure
            ,grass_date
    from    risk.dws_risk_id_user_repayment_df
    where   grass_date = '${ds}'
) t2 
on  t1.credit_user_id = t2.credit_user_id
left join (
    select  user_id
            ,ever_max_dpd_spl_core
            ,ever_max_dpd_spl_lite_core
            ,ever_max_dpd_spl_normal_core
            ,days_after_first_due_date_spl
            ,ever_max_dpd_180d_spl
            ,ever_max_dpd_360d_spl
            ,days_after_first_due_date_cashloan
            ,ever_max_dpd_180d_cashloan
            ,ever_max_dpd_360d_cashloan
            ,ever_max_dpd_180d_user
            ,ever_max_dpd_360d_user
            ,ever_max_dpd_cashloan_core
            ,last_bill_dpd_cashloan_core
            ,ever_max_dpd_sellerloan_core
            ,last_bill_dpd_sellerloan_core
            ,ever_max_dpd_30d_sellerloan
            ,ever_max_dpd_90d_sellerloan
            ,ever_max_dpd_180d_sellerloan
            ,ever_max_dpd_360d_sellerloan
            ,ever_max_dpd_30d_spl
            ,ever_max_dpd_90d_spl
            ,ever_max_dpd_30d_cashloan
            ,ever_max_dpd_90d_cashloan
            ,ever_max_dpd_chp
            ,ever_max_dpd_chp_180d
            ,ever_max_dpd_chp_360d
            ,grass_date
    from    risk.dws_risk_id_user_dpd_df
    where   grass_date = '${ds}'
) t3 
on  t1.credit_user_id = t3.user_id
left join (
    select  credit_user_id
            ,1 as is_today_bcl_due_user
    from    credit_mart.wide_bcl_id_behavior_user_df
    where   grass_date = '${ds}'
            and bill_due_day = day(date('${ds}'))
) t4 
on  t1.credit_user_id = t4.credit_user_id
left join (
    select  credit_user_id
            ,spl_user_tag
            ,first_billed_from_now_spl
            ,first_billed_from_now_bcl
            ,first_billed_from_now
            ,repaid_bills_num_user
            ,credit_user_status
            ,is_limit_decrease_spl
            ,is_limit_decrease_bcl
            ,os_spl
            ,os_bcl
            ,eir_tenure2_bcl
            ,eir_tenure3_bcl
            ,eir_tenure6_bcl
            ,eir_tenure12_bcl
            ,eir_tenure1_spl
            ,eir_tenure2_spl
            ,eir_tenure3_spl
            ,eir_tenure6_spl
            ,eir_tenure12_spl
            ,eir_tenure18_spl
            ,eir_tenure24_spl
            ,repaid_bills_num_cashloan
            ,latest_dpd_cashloan
            ,grass_region
            ,grass_date
    from    risk.ads_behavior_underwrting_feature_df
    where   grass_region = 'ID'
    and     grass_date = '${ds}'
) t6 
on  t1.credit_user_id = t6.credit_user_id
left join (
    select  credit_user_id
            ,average_limit_utilization_3d_spl
            ,average_limit_utilization_7d_spl
            ,average_limit_utilization_14d_spl
            ,average_limit_utilization_30d_spl
            ,average_limit_utilization_90d_spl
            ,average_limit_utilization_180d_spl
            ,average_limit_utilization_360d_spl
            ,average_limit_utilization_720d_spl
            -- max spl utilization
            ,max_limit_utilization_3d_spl
            ,max_limit_utilization_7d_spl
            ,max_limit_utilization_14d_spl
            ,max_limit_utilization_30d_spl
            ,max_limit_utilization_90d_spl
            ,max_limit_utilization_180d_spl
            ,max_limit_utilization_360d_spl
            ,max_limit_utilization_720d_spl
            -- bcl
            ,average_limit_utilization_3d_bcl
            ,average_limit_utilization_7d_bcl
            ,average_limit_utilization_14d_bcl
            ,average_limit_utilization_30d_bcl
            ,average_limit_utilization_90d_bcl
            ,average_limit_utilization_180d_bcl
            ,average_limit_utilization_360d_bcl
            ,average_limit_utilization_720d_bcl
            -- max bcl utilization
            ,max_limit_utilization_3d_bcl
            ,max_limit_utilization_7d_bcl
            ,max_limit_utilization_14d_bcl
            ,max_limit_utilization_30d_bcl
            ,max_limit_utilization_90d_bcl
            ,max_limit_utilization_180d_bcl
            ,max_limit_utilization_360d_bcl
            ,max_limit_utilization_720d_bcl
    from tmp_id_user_utilization_limit
)   t9
on  t1.credit_user_id = t9.credit_user_id
left join (
    select  row_key
            ,credit_user_id
            ,postloan_reject_cnt_bcl
            ,postloan_reject_cnt_spl
            ,preloan_reject_cnt_bcl
            ,preloan_reject_cnt_spl
            ,postloan_reject_cnt_90d_bcl
            ,postloan_reject_cnt_90d_spl
            ,preloan_reject_cnt_90d_bcl
            ,preloan_reject_cnt_90d_spl
            ,postloan_reject_cnt_180d_bcl
            ,postloan_reject_cnt_180d_spl
            ,preloan_reject_cnt_180d_bcl
            ,preloan_reject_cnt_180d_spl
            ,rejected_num_90d_bcl
            ,grass_date
    from risk.dws_risk_id_user_withdraw_info_df
    where grass_date = '${ds}'
)   t7 
on  t1.credit_user_id = t7.credit_user_id
left join (
        select  credit_user_id
                ,1 as is_today_spl_due_user
        from    credit_mart.wide_spl_id_behavior_user_df
        where   grass_date = '${ds}'
        and     bill_due_day = day(date('${ds}'))
) t8 
on  t1.credit_user_id = t8.credit_user_id
left join (
        select  credit_user_id
                ,average_tenure_30d_spl
                ,average_tenure_60d_spl
                ,average_tenure_90d_spl
                ,average_tenure_180d_spl
                ,average_tenure_360d_spl
                ,average_tenure_720d_spl
                ,average_tenure_30d_bcl
                ,average_tenure_60d_bcl
                ,average_tenure_90d_bcl
                ,average_tenure_180d_bcl
                ,average_tenure_360d_bcl
                ,average_tenure_720d_bcl
        from    tmp_id_loan_repayment
) t10
on  t1.credit_user_id = t10.credit_user_id
)
group by credit_user_id
;