-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-20
-- Theme Domain:        User Info Limit Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df
(
    credit_user_id                                      string         comment 'shopee user id'
    ,average_limit_utilization_in_30d_spl               decimal(30,10) comment 'SPL average limit utilization in 30d'
    ,average_limit_utilization_in_90d_spl               decimal(30,10) comment 'SPL average limit utilization in 90d'
    ,average_limit_utilization_in_180d_spl              decimal(30,10) comment 'SPL average limit utilization in 180d'
    ,max_limit_utilization_in_30d_spl                   decimal(30,10) comment 'SPL max limit utilization in 30d'
    ,max_limit_utilization_in_90d_spl                   decimal(30,10) comment 'SPL max limit utilization in 90d'
    ,max_limit_utilization_in_180d_spl                  decimal(30,10) comment 'SPL max limit utilization in 180d'
    ,average_limit_utilization_in_30d_bcl               decimal(30,10) comment 'BCL max limit utilization in 30d'
    ,average_limit_utilization_in_90d_bcl               decimal(30,10) comment 'BCL average limit utilization in 90d'
    ,average_limit_utilization_in_180d_bcl              decimal(30,10) comment 'BCL average limit utilization in 180d'
    ,max_limit_utilization_in_30d_bcl                   decimal(30,10) comment 'BCL max limit utilization in 30d'
    ,max_limit_utilization_in_90d_bcl                   decimal(30,10) comment 'BCL max limit utilization in 90d'
    ,max_limit_utilization_in_180d_bcl                  decimal(30,10) comment 'BCL max limit utilization in 180d'
    ,average_limit_utilization_in_30d_chp               decimal(30,10) comment 'SPL-X/CHP average limit utilization in 30d'
    ,average_limit_utilization_in_90d_chp               decimal(30,10) comment 'SPL-X/CHP average limit utilization in 90d'
    ,average_limit_utilization_in_180d_chp              decimal(30,10) comment 'SPL-X/CHP average limit utilization in 180d'
    ,max_limit_utilization_in_30d_chp                   decimal(30,10) comment 'SPL-X/CHP max limit utilization in 30d'
    ,max_limit_utilization_in_90d_chp                   decimal(30,10) comment 'SPL-X/CHP max limit utilization in 90d'
    ,max_limit_utilization_in_180d_chp                  decimal(30,10) comment 'SPL-X/CHP max limit utilization in 180d'
    ,average_limit_utilization_in_30d_tl                decimal(30,10) comment 'TL average limit utilization in 30d'
    ,average_limit_utilization_in_90d_tl                decimal(30,10) comment 'TL average limit utilization in 90d'
    ,average_limit_utilization_in_180d_tl               decimal(30,10) comment 'TL average limit utilization in 180d'
    ,average_limit_utilization_in_360d_tl               decimal(30,10) comment 'TL average limit utilization in 360d'
    ,max_limit_utilization_in_30d_tl                    decimal(30,10) comment 'TL max limit utilization in 30d'
    ,max_limit_utilization_in_90d_tl                    decimal(30,10) comment 'TL max limit utilization in 90d'
    ,max_limit_utilization_in_180d_tl                   decimal(30,10) comment 'TL max limit utilization in 180d'
    ,max_limit_utilization_in_360d_tl                   decimal(30,10) comment 'TL max limit utilization in 360d'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_limit_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df;


create or replace temporary view tmp_user_txn_limit_spl as
select
    credit_user_id
    ,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_spl else 0 end)      as total_limit_utilization_30d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)      as total_limit_utilization_90d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)     as total_limit_utilization_180d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_spl
    ,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_spl else 0 end)      as max_spl_limit_utilization_in_30d_th  
    ,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)      as max_spl_limit_utilization_in_90d_th  
    ,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)     as max_spl_limit_utilization_in_180d_th 
from (
select 
    credit_user_id                     as credit_user_id
    ,--total_user_credit_utilisation      
        (
            COALESCE(common_perm_used_credit_amount, 0) +
            COALESCE(common_temp_used_credit_amount, 0) +
            COALESCE(installment_perm_used_credit_amount, 0) +
            --COALESCE(lite_used_credit_amount, 0) +
            COALESCE(common_perm_frozen_credit_amount, 0) +
            COALESCE(common_temp_frozen_credit_amount, 0) +
            COALESCE(installment_perm_frozen_credit_amount, 0) 
            --COALESCE(lite_frozen_credit_amount, 0)
        ) / (
            COALESCE(common_perm_credit_limit, 0) +
            COALESCE(common_temp_credit_limit, 0) +
            COALESCE(installment_perm_credit_limit, 0) 
            --COALESCE(lite_credit_limit, 0)
        )
    as total_limit_util_spl
    ,grass_date                         as grass_date
from credit_mart.dws_spl_th_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) + coalesce(installment_perm_credit_limit,0) --+ coalesce(lite_credit_limit,0) 
    > 0
    and biz_type = 3
    and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

create or replace temporary view tmp_user_txn_limit_bcl as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_bcl else 0 end)      as total_limit_utilization_30d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_bcl else 0 end)      as total_limit_utilization_90d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_bcl else 0 end)     as total_limit_utilization_180d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_bcl
,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_bcl else 0 end)      as max_bcl_limit_utilization_in_30d_th 
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_bcl else 0 end)      as max_bcl_limit_utilization_in_90d_th 
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_bcl else 0 end)     as max_bcl_limit_utilization_in_180d_th
from (
select 
    credit_user_id                     as credit_user_id
    ,--total_user_credit_utilisation      
        (
                COALESCE(common_perm_used_credit_amount, 0) +
                COALESCE(common_temp_used_credit_amount, 0) +
                COALESCE(common_perm_frozen_credit_amount, 0) +
                COALESCE(common_temp_frozen_credit_amount, 0)
        ) / (
                COALESCE(common_perm_credit_limit, 0) +
                COALESCE(common_temp_credit_limit, 0)
        )
    as total_limit_util_bcl
    ,grass_date                         as grass_date
from credit_mart.dws_bcl_th_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) > 0
    and biz_type = 1    
    and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

create or replace temporary view tmp_user_txn_limit_chp as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_chp else 0 end)      as total_limit_utilization_30d_chp
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_chp else 0 end)      as total_limit_utilization_90d_chp
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_chp else 0 end)     as total_limit_utilization_180d_chp
,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_chp
,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_chp
,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_chp
,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_chp else 0 end)      as max_limit_utilization_30d_chp
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_chp else 0 end)      as max_limit_utilization_90d_chp
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_chp else 0 end)     as max_limit_utilization_180d_chp
from (
select
    credit_user_id                     as credit_user_id
    ,(one_time_used_credit_amount+one_time_frozen_credit_amount)/one_time_credit_limit as total_limit_util_chp
    ,grass_date                         as grass_date
from credit_mart.dws_spl_th_account_df
where one_time_credit_limit > 0
    and grass_date >=date_sub('${grass_date}',180) and biz_type = 7
) a 
group by credit_user_id
;

--tl只有一次性额度
create or replace temporary view tmp_user_txn_limit_tl as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_tl else 0 end)      as total_limit_utilization_30d_tl
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_tl else 0 end)      as total_limit_utilization_90d_tl
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_tl else 0 end)     as total_limit_utilization_180d_tl
,sum(case when grass_date>=date_sub('${grass_date}',360) then total_limit_util_tl else 0 end)     as total_limit_utilization_360d_tl
,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_tl
,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_tl
,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_tl
,count(distinct case when grass_date>=date_sub('${grass_date}',360) then grass_date else null end) as grass_date_cnt_360d_tl
,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_tl else 0 end)      as max_limit_utilization_in_30d_tl
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_tl else 0 end)      as max_limit_utilization_in_90d_tl 
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_tl else 0 end)     as max_limit_utilization_in_180d_tl
,max(case when grass_date>=date_sub('${grass_date}',360) then total_limit_util_tl else 0 end)     as max_limit_utilization_in_360d_tl
from (
select 
    credit_user_id                     as credit_user_id
    ,   (
                COALESCE(one_time_used_credit_amount, 0) +
                COALESCE(one_time_frozen_credit_amount, 0)
        ) / (
                COALESCE(one_time_credit_limit, 0)
        )
    as total_limit_util_tl
    ,grass_date                         as grass_date
from credit_mart.dws_tl_th_account_df
where coalesce(one_time_credit_limit,0) > 0
    and biz_type = 11
    and grass_date >=date_sub('${grass_date}',360)
) a 
group by credit_user_id
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.average_limit_utilization_in_30d_spl
    ,t2.average_limit_utilization_in_90d_spl
    ,t2.average_limit_utilization_in_180d_spl
    ,t2.max_limit_utilization_in_30d_spl
    ,t2.max_limit_utilization_in_90d_spl
    ,t2.max_limit_utilization_in_180d_spl
    ,t3.average_limit_utilization_in_30d_bcl
    ,t3.average_limit_utilization_in_90d_bcl
    ,t3.average_limit_utilization_in_180d_bcl
    ,t3.max_limit_utilization_in_30d_bcl
    ,t3.max_limit_utilization_in_90d_bcl
    ,t3.max_limit_utilization_in_180d_bcl
    ,t4.average_limit_utilization_in_30d_chp
    ,t4.average_limit_utilization_in_90d_chp
    ,t4.average_limit_utilization_in_180d_chp
    ,t4.max_limit_utilization_in_30d_chp
    ,t4.max_limit_utilization_in_90d_chp
    ,t4.max_limit_utilization_in_180d_chp
    ,t5.average_limit_utilization_in_30d_tl
    ,t5.average_limit_utilization_in_90d_tl
    ,t5.average_limit_utilization_in_180d_tl
    ,t5.average_limit_utilization_in_360d_tl
    ,t5.max_limit_utilization_in_30d_tl
    ,t5.max_limit_utilization_in_90d_tl
    ,t5.max_limit_utilization_in_180d_tl
    ,t5.max_limit_utilization_in_360d_tl
from 
(
    select
        credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${grass_date}'
        and credit_user_id <> ''
        and credit_user_id <> '0'
        and credit_user_id is not null
    group by credit_user_id
) t1
left join (
    select
    credit_user_id
    ,total_limit_utilization_30d_spl/grass_date_cnt_30d_spl   as average_limit_utilization_in_30d_spl
    ,total_limit_utilization_90d_spl/grass_date_cnt_90d_spl   as average_limit_utilization_in_90d_spl
    ,total_limit_utilization_180d_spl/grass_date_cnt_180d_spl as average_limit_utilization_in_180d_spl
    ,max_spl_limit_utilization_in_30d_th                      as max_limit_utilization_in_30d_spl
    ,max_spl_limit_utilization_in_90d_th                      as max_limit_utilization_in_90d_spl
    ,max_spl_limit_utilization_in_180d_th                     as max_limit_utilization_in_180d_spl
    from tmp_user_txn_limit_spl
) t2 on t1.credit_user_id = t2.credit_user_id 
left join (
    select
    credit_user_id
    ,total_limit_utilization_30d_bcl/grass_date_cnt_30d_bcl   as average_limit_utilization_in_30d_bcl
    ,total_limit_utilization_90d_bcl/grass_date_cnt_90d_bcl   as average_limit_utilization_in_90d_bcl
    ,total_limit_utilization_180d_bcl/grass_date_cnt_180d_bcl as average_limit_utilization_in_180d_bcl
    ,max_bcl_limit_utilization_in_30d_th                      as max_limit_utilization_in_30d_bcl
    ,max_bcl_limit_utilization_in_90d_th                      as max_limit_utilization_in_90d_bcl
    ,max_bcl_limit_utilization_in_180d_th                     as max_limit_utilization_in_180d_bcl
    from tmp_user_txn_limit_bcl
) t3 on t1.credit_user_id = t3.credit_user_id
left join (
    select
    credit_user_id
    ,total_limit_utilization_30d_chp/grass_date_cnt_30d_chp   as average_limit_utilization_in_30d_chp
    ,total_limit_utilization_90d_chp/grass_date_cnt_90d_chp   as average_limit_utilization_in_90d_chp
    ,total_limit_utilization_180d_chp/grass_date_cnt_180d_chp as average_limit_utilization_in_180d_chp
    ,max_limit_utilization_30d_chp                            as max_limit_utilization_in_30d_chp
    ,max_limit_utilization_90d_chp                            as max_limit_utilization_in_90d_chp
    ,max_limit_utilization_180d_chp                           as max_limit_utilization_in_180d_chp
    from tmp_user_txn_limit_chp
) t4 on t1.credit_user_id = t4.credit_user_id
left join (
    select
    credit_user_id
    ,total_limit_utilization_30d_tl/grass_date_cnt_30d_tl   as average_limit_utilization_in_30d_tl
    ,total_limit_utilization_90d_tl/grass_date_cnt_90d_tl   as average_limit_utilization_in_90d_tl
    ,total_limit_utilization_180d_tl/grass_date_cnt_180d_tl as average_limit_utilization_in_180d_tl
    ,total_limit_utilization_360d_tl/grass_date_cnt_360d_tl as average_limit_utilization_in_360d_tl
    ,max_limit_utilization_in_30d_tl
    ,max_limit_utilization_in_90d_tl
    ,max_limit_utilization_in_180d_tl
    ,max_limit_utilization_in_360d_tl
    from tmp_user_txn_limit_tl
) t5 on t1.credit_user_id = t5.credit_user_id
;